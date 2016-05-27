//
//  ADJPackageHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJRequestHandler.h"
#import "ADJActivityPackage.h"
#import "ADJLogger.h"
#import "ADJUtil.h"
#import "ADJAdjustFactory.h"
#import "ADJBackoffStrategy.h"
#import "ADJPackageBuilder.h"

static NSString   * const kPackageQueueFilename = @"AdjustIoPackageQueue";
static const char * const kInternalQueueName    = "io.adjust.PackageQueue";


#pragma mark - private
@interface ADJPackageHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic) dispatch_semaphore_t sendingSemaphore;
@property (nonatomic, assign) id<ADJActivityHandler> activityHandler;
@property (nonatomic, retain) id<ADJRequestHandler> requestHandler;
@property (nonatomic, retain) id<ADJLogger> logger;
@property (nonatomic, retain) NSMutableArray *packageQueue;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, retain) ADJBackoffStrategy * backoffStrategy;

@end

#pragma mark -
@implementation ADJPackageHandler

+ (id<ADJPackageHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                      startsSending:(BOOL)startsSending
{
    return [[ADJPackageHandler alloc] initWithActivityHandler:activityHandler startsSending:startsSending];
}

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.backoffStrategy = [ADJAdjustFactory packageHandlerBackoffStrategy];

    dispatch_async(self.internalQueue, ^{
        [self initInternal:activityHandler startsSending:startsSending];
    });

    return self;
}

- (void)addPackage:(ADJActivityPackage *)package {
    dispatch_async(self.internalQueue, ^{
        [self addInternal:package];
    });
}

- (void)sendFirstPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendFirstInternal];
    });
}

- (void)sendNextPackage:(ADJResponseData *)responseData{
    dispatch_async(self.internalQueue, ^{
        [self sendNextInternal];
    });

    [self.activityHandler finishedTracking:responseData];
}

- (void)closeFirstPackage:(ADJResponseData *)responseData
          activityPackage:(ADJActivityPackage *)activityPackage
{
    responseData.willRetry = YES;
    [self.activityHandler finishedTracking:responseData];

    dispatch_block_t work = ^{
        [self.logger verbose:@"Package handler can send"];
        dispatch_semaphore_signal(self.sendingSemaphore);

        [self sendFirstPackage];
    };

    if (activityPackage == nil) {
        work();
        return;
    }

    NSInteger retries = [activityPackage increaseRetries];
    NSTimeInterval waitTime = [ADJUtil waitingTime:retries backoffStrategy:self.backoffStrategy];
    NSString * waitTimeFormatted = [ADJUtil secondsNumberFormat:waitTime];

    [self.logger verbose:@"Waiting for %@ seconds before retrying the %d time", waitTimeFormatted, retries];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, work);
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

- (void)updatePackages:(NSDictionary *)sessionCallbackParameters
sessionPartnerParameters:(NSDictionary *)sessionPartnerParameters
{
    dispatch_async(self.internalQueue, ^{
        [self updatePackagesInternal:sessionCallbackParameters
            sessionPartnerParameters:sessionPartnerParameters];
    });
}

#pragma mark - internal
- (void)initInternal:(id<ADJActivityHandler>)activityHandler
        startsSending:(BOOL)startsSending
{
    self.activityHandler = activityHandler;
    self.paused = !startsSending;
    self.requestHandler = [ADJAdjustFactory requestHandlerForPackageHandler:self];
    self.logger = ADJAdjustFactory.logger;
    self.sendingSemaphore = dispatch_semaphore_create(1);
    [self readPackageQueue];
}

- (void)addInternal:(ADJActivityPackage *)newPackage {
    [self.packageQueue addObject:newPackage];
    [self.logger debug:@"Added package %d (%@)", self.packageQueue.count, newPackage];
    [self.logger verbose:@"%@", newPackage.extendedString];

    [self writePackageQueue];
}

- (void)sendFirstInternal {
    NSUInteger queueSize = self.packageQueue.count;
    if (queueSize == 0) return;

    if (self.paused) {
        [self.logger debug:@"Package handler is paused"];
        return;
    }

    if (dispatch_semaphore_wait(self.sendingSemaphore, DISPATCH_TIME_NOW) != 0) {
        [self.logger verbose:@"Package handler is already sending"];
        return;
    }

    ADJActivityPackage *activityPackage = [self.packageQueue objectAtIndex:0];
    if (![activityPackage isKindOfClass:[ADJActivityPackage class]]) {
        [self.logger error:@"Failed to read activity package"];
        [self sendNextInternal];
        return;
    }

    [self.requestHandler sendPackage:activityPackage
                           queueSize:queueSize - 1];
}

- (void)sendNextInternal {
    [self.packageQueue removeObjectAtIndex:0];
    [self writePackageQueue];
    dispatch_semaphore_signal(self.sendingSemaphore);
    [self sendFirstInternal];
}

- (void)updatePackagesInternal:(NSDictionary *)sessionCallbackParameters
      sessionPartnerParameters:(NSDictionary *)sessionPartnerParameters
{
    [self.logger debug:@"Updating package handler queue"];
    [self.logger verbose:@"Session callback parameters %@", sessionCallbackParameters];
    [self.logger verbose:@"Session partner parameters %@", sessionPartnerParameters];

    // if callback parameters is null
    if (sessionCallbackParameters == nil && sessionPartnerParameters == nil) {
        return;
    }

    for (ADJActivityPackage * activityPackage in self.packageQueue) {
        [self updateCallbackParameters:activityPackage
             sessionCallbackParameters:sessionCallbackParameters];

        [self updatePartnerParameters:activityPackage
             sessionPartnerParameters:sessionCallbackParameters];
    }
}

- (void)updateCallbackParameters:(ADJActivityPackage *)activityPackage
                 sessionCallbackParameters:(NSDictionary *)sessionCallbackParameters
{
    NSDictionary * mergedParameters = nil;

    if (sessionCallbackParameters == nil) {
        mergedParameters = activityPackage.callbackParameters;
    }

    if (activityPackage.callbackParameters == nil) {
        mergedParameters = sessionCallbackParameters;
    }

    if (activityPackage.callbackParameters != nil && sessionCallbackParameters != nil) {
        mergedParameters = [ADJUtil mergeParameters:sessionCallbackParameters
                                             source:activityPackage.callbackParameters
                                      parameterName:@"Callback"];
    }

    if (mergedParameters == nil) {
        return;
    }
    // get activity package parameters to save
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:activityPackage.parameters];
    // save the merged parameters
    [ADJPackageBuilder parameters:parameters
                    setDictionary:mergedParameters
                           forKey:@"callback_params"];
    activityPackage.parameters = parameters;
}

- (void)updatePartnerParameters:(ADJActivityPackage *)activityPackage
       sessionPartnerParameters:(NSDictionary *)sessionPartnerParameters
{
    NSDictionary * mergedParameters = nil;

    if (sessionPartnerParameters == nil) {
        mergedParameters = activityPackage.partnerParameters;
    }

    if (activityPackage.partnerParameters == nil) {
        mergedParameters = sessionPartnerParameters;
    }

    if (activityPackage.partnerParameters != nil && sessionPartnerParameters != nil) {
        mergedParameters = [ADJUtil mergeParameters:sessionPartnerParameters
                                             source:activityPackage.partnerParameters
                                      parameterName:@"Partner"];
    }

    if (mergedParameters == nil) {
        return;
    }
    // get activity package parameters to save
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithDictionary:activityPackage.parameters];
    // save the merged parameters
    [ADJPackageBuilder parameters:parameters
                    setDictionary:mergedParameters
                           forKey:@"partner_params"];
    activityPackage.parameters = parameters;
}


#pragma mark - private
- (void)readPackageQueue {
    @try {
        [NSKeyedUnarchiver setClass:[ADJActivityPackage class] forClassName:@"AIActivityPackage"];
        NSString *filename = self.packageQueueFilename;
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if ([object isKindOfClass:[NSArray class]]) {
            self.packageQueue = object;
            [self.logger debug:@"Package handler read %d packages", self.packageQueue.count];
            return;
        } else if (object == nil) {
            [self.logger verbose:@"Package queue file not found"];
        } else {
            [self.logger error:@"Failed to read package queue"];
        }
    } @catch (NSException *exception) {
        [self.logger error:@"Failed to read package queue (%@)", exception];
    }

    // start with a fresh package queue in case of any exception
    self.packageQueue = [NSMutableArray array];
}

- (void)writePackageQueue {
    NSString *filename = self.packageQueueFilename;
    BOOL result = [NSKeyedArchiver archiveRootObject:self.packageQueue toFile:filename];
    if (result == YES) {
        [ADJUtil excludeFromBackup:filename];
        [self.logger debug:@"Package handler wrote %d packages", self.packageQueue.count];
    } else {
        [self.logger error:@"Failed to write package queue"];
    }
}

- (NSString *)packageQueueFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:kPackageQueueFilename];
    return filename;
}

-(void)dealloc {
    //cleanup code
    if (self.sendingSemaphore != nil) {
        dispatch_semaphore_signal(self.sendingSemaphore);
    }
}

@end

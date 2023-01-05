//
//  ADJPackageHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJPackageHandler.h"
#import "ADJActivityPackage.h"
#import "ADJLogger.h"
#import "ADJUtil.h"
#import "ADJAdjustFactory.h"
#import "ADJBackoffStrategy.h"
#import "ADJPackageBuilder.h"
#import "ADJUserDefaults.h"

static NSString   * const kPackageQueueFilename = @"AdjustIoPackageQueue";
static const char * const kInternalQueueName    = "io.adjust.PackageQueue";


#pragma mark - private
@interface ADJPackageHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) dispatch_semaphore_t sendingSemaphore;
@property (nonatomic, strong) ADJRequestHandler *requestHandler;
@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) ADJBackoffStrategy *backoffStrategy;
@property (nonatomic, strong) ADJBackoffStrategy *backoffStrategyForInstallSession;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, weak) id<ADJActivityHandler> activityHandler;
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, assign) NSInteger lastPackageRetriesCount;

@end

#pragma mark -
@implementation ADJPackageHandler

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.backoffStrategy = [ADJAdjustFactory packageHandlerBackoffStrategy];
    self.backoffStrategyForInstallSession = [ADJAdjustFactory installSessionBackoffStrategy];
    self.lastPackageRetriesCount = 0;

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler * selfI) {
                         [selfI initI:selfI
                     activityHandler:activityHandler
                       startsSending:startsSending
                          userAgent:userAgent
                          urlStrategy:urlStrategy];
                     }];

    return self;
}

- (void)addPackage:(ADJActivityPackage *)package {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
                         [selfI addI:selfI package:package];
                     }];
}

- (void)sendFirstPackage {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
                         [selfI sendFirstI:selfI];
                     }];
}

- (void)responseCallback:(ADJResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:@"Got JSON response with message: %@", responseData.message];
    } else {
        [self.logger error:@"Could not get JSON response with message: %@", responseData.message];
    }
    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADJTrackingStateOptedOut) {
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }
    if (responseData.jsonResponse == nil) {
        [self closeFirstPackage:responseData];
    } else {
        [self sendNextPackage:responseData];
    }
}

- (void)sendNextPackage:(ADJResponseData *)responseData {
    self.lastPackageRetriesCount = 0;

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
                         [selfI sendNextI:selfI];
                     }];

    [self.activityHandler finishedTracking:responseData];
}

- (void)closeFirstPackage:(ADJResponseData *)responseData
{
    responseData.willRetry = YES;
    [self.activityHandler finishedTracking:responseData];

    self.lastPackageRetriesCount++;

    NSTimeInterval waitTime;
    if (responseData.activityKind == ADJActivityKindSession && [ADJUserDefaults getInstallTracked] == NO) {
        waitTime = [ADJUtil waitingTime:self.lastPackageRetriesCount backoffStrategy:self.backoffStrategyForInstallSession];
    } else {
        waitTime = [ADJUtil waitingTime:self.lastPackageRetriesCount backoffStrategy:self.backoffStrategy];
    }
    NSString *waitTimeFormatted = [ADJUtil secondsNumberFormat:waitTime];

    [self.logger verbose:@"Waiting for %@ seconds before retrying the %d time", waitTimeFormatted, self.lastPackageRetriesCount];
    dispatch_after
        (dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)),
         self.internalQueue,
         ^{
            [self.logger verbose:@"Package handler finished waiting"];

            dispatch_semaphore_signal(self.sendingSemaphore);

            [self sendFirstPackage];
        });
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

- (void)updatePackages:(ADJSessionParameters *)sessionParameters
{
    // make copy to prevent possible Activity Handler changes of it
    ADJSessionParameters * sessionParametersCopy = [sessionParameters copy];

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
                         [selfI updatePackagesI:selfI sessionParameters:sessionParametersCopy];
                     }];
}

- (void)flush {
    [ADJUtil launchInQueue:self.internalQueue selfInject:self block:^(ADJPackageHandler *selfI) {
        [selfI flushI:selfI];
    }];
}

- (void)teardown {
    [ADJAdjustFactory.logger verbose:@"ADJPackageHandler teardown"];
    if (self.sendingSemaphore != nil) {
        dispatch_semaphore_signal(self.sendingSemaphore);
    }
    [self teardownPackageQueueS];
    self.internalQueue = nil;
    self.sendingSemaphore = nil;
    self.requestHandler = nil;
    self.backoffStrategy = nil;
    self.activityHandler = nil;
    self.logger = nil;
}

+ (void)deleteState {
    [ADJPackageHandler deletePackageQueue];
}

+ (void)deletePackageQueue {
    [ADJUtil deleteFileWithName:kPackageQueueFilename];
}

#pragma mark - internal
- (void)
    initI:(ADJPackageHandler *)selfI
        activityHandler:(id<ADJActivityHandler>)activityHandler
        startsSending:(BOOL)startsSending
        userAgent:(NSString *)userAgent
        urlStrategy:(ADJUrlStrategy *)urlStrategy
{
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.requestHandler = [[ADJRequestHandler alloc]
                                initWithResponseCallback:self
                                urlStrategy:urlStrategy
                                userAgent:userAgent
                                requestTimeout:[ADJAdjustFactory requestTimeout]];
    selfI.logger = ADJAdjustFactory.logger;
    selfI.sendingSemaphore = dispatch_semaphore_create(1);
    [selfI readPackageQueueI:selfI];
}

- (void)addI:(ADJPackageHandler *)selfI
     package:(ADJActivityPackage *)newPackage
{
    [selfI.packageQueue addObject:newPackage];

    [selfI.logger debug:@"Added package %d (%@)", selfI.packageQueue.count, newPackage];
    [selfI.logger verbose:@"%@", newPackage.extendedString];

    [selfI writePackageQueueS:selfI];
}

- (void)sendFirstI:(ADJPackageHandler *)selfI
{
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) return;

    if (selfI.paused) {
        [selfI.logger debug:@"Package handler is paused"];
        return;
    }

    if (dispatch_semaphore_wait(selfI.sendingSemaphore, DISPATCH_TIME_NOW) != 0) {
        [selfI.logger verbose:@"Package handler is already sending"];
        return;
    }

    ADJActivityPackage *activityPackage = [selfI.packageQueue objectAtIndex:0];
    if (![activityPackage isKindOfClass:[ADJActivityPackage class]]) {
        [selfI.logger error:@"Failed to read activity package"];
        [selfI sendNextI:selfI];
        return;
    }

    NSMutableDictionary *sendingParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (queueSize - 1 > 0) {
        [ADJPackageBuilder parameters:sendingParameters
                               setInt:(int)queueSize - 1
                               forKey:@"queue_size"];
    }
    [ADJPackageBuilder parameters:sendingParameters
                        setString:[ADJUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]]
                           forKey:@"sent_at"];

    [selfI.requestHandler sendPackageByPOST:activityPackage
                          sendingParameters:[sendingParameters copy]];
}

- (void)sendNextI:(ADJPackageHandler *)selfI {
    if ([selfI.packageQueue count] > 0) {
        [selfI.packageQueue removeObjectAtIndex:0];
        [selfI writePackageQueueS:selfI];
    }

    dispatch_semaphore_signal(selfI.sendingSemaphore);
    [selfI sendFirstI:selfI];
}

- (void)updatePackagesI:(ADJPackageHandler *)selfI
      sessionParameters:(ADJSessionParameters *)sessionParameters {
    [selfI.logger debug:@"Updating package handler queue"];
    [selfI.logger verbose:@"Session callback parameters: %@", sessionParameters.callbackParameters];
    [selfI.logger verbose:@"Session partner parameters: %@", sessionParameters.partnerParameters];

    // create package queue copy for new state of array
    NSMutableArray *packageQueueCopy = [NSMutableArray array];

    for (ADJActivityPackage *activityPackage in selfI.packageQueue) {
        // callback parameters
        NSDictionary *mergedCallbackParameters = [ADJUtil mergeParameters:sessionParameters.callbackParameters
                                                                   source:activityPackage.callbackParameters
                                                            parameterName:@"Callback"];
        [ADJPackageBuilder parameters:activityPackage.parameters
                        setDictionary:mergedCallbackParameters
                               forKey:@"callback_params"];

        // partner parameters
        NSDictionary *mergedPartnerParameters = [ADJUtil mergeParameters:sessionParameters.partnerParameters
                                                                  source:activityPackage.partnerParameters
                                                           parameterName:@"Partner"];
        [ADJPackageBuilder parameters:activityPackage.parameters
                        setDictionary:mergedPartnerParameters
                               forKey:@"partner_params"];
        // add to copy queue
        [packageQueueCopy addObject:activityPackage];
    }

    // write package queue copy
    selfI.packageQueue = packageQueueCopy;
    [selfI writePackageQueueS:selfI];
}

- (void)flushI:(ADJPackageHandler *)selfI {
    [selfI.packageQueue removeAllObjects];
    [selfI writePackageQueueS:selfI];
}

#pragma mark - private
- (void)readPackageQueueI:(ADJPackageHandler *)selfI {
    [NSKeyedUnarchiver setClass:[ADJActivityPackage class] forClassName:@"AIActivityPackage"];
    
    id object = [ADJUtil readObject:kPackageQueueFilename
                         objectName:@"Package queue"
                              class:[NSArray class]
                         syncObject:[ADJPackageHandler class]];
    
    if (object != nil) {
        selfI.packageQueue = object;
    } else {
        selfI.packageQueue = [NSMutableArray array];
    }

}

- (void)writePackageQueueS:(ADJPackageHandler *)selfS {
    if (selfS.packageQueue == nil) {
        return;
    }
    
    [ADJUtil writeObject:selfS.packageQueue
                fileName:kPackageQueueFilename
              objectName:@"Package queue"
              syncObject:[ADJPackageHandler class]];
}

- (void)teardownPackageQueueS {
    @synchronized ([ADJPackageHandler class]) {
        if (self.packageQueue == nil) {
            return;
        }
        
        [self.packageQueue removeAllObjects];
        self.packageQueue = nil;
    }
}

- (void)dealloc {
    // Cleanup code
    if (self.sendingSemaphore != nil) {
        dispatch_semaphore_signal(self.sendingSemaphore);
    }
}

@end

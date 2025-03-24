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
@property (nonatomic, assign) BOOL isRetrying;
@property (nonatomic, assign) NSTimeInterval retryStartedAt;
@property (nonatomic, assign) double totalWaitTime;

@end

#pragma mark -
@implementation ADJPackageHandler

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                  urlStrategy:(ADJUrlStrategy *)urlStrategy
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.backoffStrategy = [ADJAdjustFactory packageHandlerBackoffStrategy];
    self.backoffStrategyForInstallSession = [ADJAdjustFactory installSessionBackoffStrategy];
    self.lastPackageRetriesCount = 0;
    self.isRetrying = NO;
    self.totalWaitTime = 0.0;

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler * selfI) {
        [selfI initI:selfI
     activityHandler:activityHandler
       startsSending:startsSending
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
    if (responseData.jsonResponse == nil || responseData.retryInMilli != nil) {
        [self closeFirstPackage:responseData];
    } else {
        [self sendNextPackage:responseData];
    }
}

- (void)sendNextPackage:(ADJResponseData *)responseData {
    self.lastPackageRetriesCount = 0;
    self.isRetrying = NO;
    self.retryStartedAt = 0.0;

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
        [selfI sendNextI:selfI previousResponseContinueIn:responseData.continueInMilli];
    }];

    [self.activityHandler finishedTracking:responseData];
}

- (void)closeFirstPackage:(ADJResponseData *)responseData {
    responseData.willRetry = YES;

    [self.activityHandler finishedTracking:responseData];

    self.lastPackageRetriesCount++;

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
                         [selfI writePackageQueueS:selfI];
                     }];

    NSTimeInterval waitTime;
    if (responseData.retryInMilli != nil) {
        waitTime = [responseData.retryInMilli intValue] / 1000.0;

        [self.logger verbose:@"Waiting for %@ seconds before retrying with retry_in",
         [ADJUtil secondsNumberFormat:waitTime]];
    } else {
        waitTime = [self retryPackageUsingBackoffWithResponse:responseData];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)),
                   self.internalQueue, ^{
        [self.logger verbose:@"Package handler finished waiting to retry"];
        if (self.sendingSemaphore == nil) {
            [self.logger error:@"Sending semaphore is nil"];
            return;
        }
        dispatch_semaphore_signal(self.sendingSemaphore);
        responseData.sdkPackage.waitBeforeSend += waitTime;
        [self sendFirstPackage];
    });
}

- (NSTimeInterval)retryPackageUsingBackoffWithResponse:(ADJResponseData *)responseData {
    self.lastPackageRetriesCount++;

    NSTimeInterval waitTime;
    if (responseData.activityKind == ADJActivityKindSession
        && [ADJUserDefaults getInstallTracked] == NO)
    {
        waitTime = [ADJUtil waitingTime:self.lastPackageRetriesCount
                        backoffStrategy:self.backoffStrategyForInstallSession];
    } else {
        waitTime = [ADJUtil waitingTime:self.lastPackageRetriesCount
                        backoffStrategy:self.backoffStrategy];
    }

    [self.logger verbose:@"Waiting for %@ seconds before retrying the %d time",
     [ADJUtil secondsNumberFormat:waitTime], self.lastPackageRetriesCount];

    return waitTime;
}

- (void)pauseSending {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
        selfI.paused = YES;
    }];
}

- (void)resumeSending {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
        selfI.paused = NO;
    }];
}

- (void)updatePackagesWithAttStatus:(int)attStatus {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPackageHandler* selfI) {
        [selfI updatePackagesTrackingI:selfI
                             attStatus:attStatus];
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
- (void)initI:(ADJPackageHandler *)selfI
activityHandler:(id<ADJActivityHandler>)activityHandler
startsSending:(BOOL)startsSending
  urlStrategy:(ADJUrlStrategy *)urlStrategy {

    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.requestHandler = [[ADJRequestHandler alloc]
                            initWithResponseCallback:self
                            urlStrategy:urlStrategy
                            requestTimeout:[ADJAdjustFactory requestTimeout]
                            adjustConfiguration:activityHandler.adjustConfig];
    selfI.logger = ADJAdjustFactory.logger;
    selfI.sendingSemaphore = dispatch_semaphore_create(1);
    [selfI readPackageQueueI:selfI];
}

- (void)addI:(ADJPackageHandler *)selfI
     package:(ADJActivityPackage *)newPackage
{
    if (self.isRetrying == YES) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        newPackage.waitBeforeSend = self.totalWaitTime - (now - self.retryStartedAt);
    }
    [ADJPackageBuilder parameters:newPackage.parameters
                           setInt:(int)selfI.packageQueue.count
                           forKey:@"enqueue_size"];
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
        [selfI sendNextI:selfI previousResponseContinueIn:nil];
        return;
    }

    NSMutableDictionary *sendingParameters = [NSMutableDictionary dictionaryWithCapacity:2];
    if (queueSize - 1 > 0) {
        [ADJPackageBuilder parameters:sendingParameters
                               setInt:(int)queueSize - 1
                               forKey:@"queue_size"];
    }

    [ADJPackageBuilder parameters:sendingParameters
                           setInt:(int)activityPackage.errorCount
                           forKey:@"retry_count"];
    [ADJPackageBuilder parameters:sendingParameters
         setNumberWithoutRounding:activityPackage.firstErrorCode
                           forKey:@"first_error"];
    [ADJPackageBuilder parameters:sendingParameters
         setNumberWithoutRounding:activityPackage.lastErrorCode
                           forKey:@"last_error"];
    [ADJPackageBuilder parameters:sendingParameters
                        setDouble:self.totalWaitTime
                           forKey:@"wait_total"];
    [ADJPackageBuilder parameters:sendingParameters
                        setDouble:activityPackage.waitBeforeSend
                           forKey:@"wait_time"];

    [selfI.requestHandler sendPackageByPOST:activityPackage
                          sendingParameters:[sendingParameters copy]];
}

- (void)sendNextI:(ADJPackageHandler *)selfI
    previousResponseContinueIn:(NSNumber *)previousResponseContinueIn
{
    if ([selfI.packageQueue count] > 0) {
        [selfI.packageQueue removeObjectAtIndex:0];
        [selfI writePackageQueueS:selfI];
    } else {
        // at this point, the queue has been emptied
        // reset total_wait in this moment to allow all requests to populate total_wait
        selfI.totalWaitTime = 0.0;
    }

    // if previous response contained continue_in
    // delay for that time
    if (previousResponseContinueIn != nil) {
        NSTimeInterval waitTime = [previousResponseContinueIn intValue] / 1000.0;

        [self.logger verbose:
         @"Waiting for %@ seconds before continuing for next package in continue_in",
         [ADJUtil secondsNumberFormat:waitTime]];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)),
                       self.internalQueue, ^{
            [self.logger verbose:@"Package handler finished waiting to continue"];
            if (selfI.sendingSemaphore == nil) {
                [self.logger error:@"Sending semaphore is nil"];
                return;
            }
            dispatch_semaphore_signal(selfI.sendingSemaphore);
            [self sendFirstPackage];
        });
    } else {
        // otherwise just signal and send next
        if (selfI.sendingSemaphore == nil) {
            [self.logger error:@"Sending semaphore is nil"];
            return;
        }
        dispatch_semaphore_signal(selfI.sendingSemaphore);
        [selfI sendFirstI:selfI];
    }
}

- (void)updatePackagesTrackingI:(ADJPackageHandler *)selfI
                      attStatus:(int)attStatus {
    [selfI.logger debug:@"Updating package queue with idfa and att_status: %d", (long)attStatus];
    // create package queue copy for new state of array
    NSMutableArray *packageQueueCopy = [NSMutableArray array];

    for (ADJActivityPackage *activityPackage in selfI.packageQueue) {
        [ADJPackageBuilder parameters:activityPackage.parameters setInt:attStatus forKey:@"att_status"];
        [ADJPackageBuilder addConsentDataToParameters:activityPackage.parameters
                                      forActivityKind:activityPackage.activityKind
                                        withAttStatus:attStatus
                                        configuration:selfI.activityHandler.adjustConfig
                                        packageParams:selfI.activityHandler.packageParams
                                        activityState:selfI.activityHandler.activityState];
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
    NSSet<Class> *allowedClasses = [NSSet setWithObjects:[NSArray class], [ADJActivityPackage class], nil];
    id object = [ADJUtil readObject:kPackageQueueFilename
                         objectName:@"Package queue"
                            classes:allowedClasses
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

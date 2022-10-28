//
//  ADJTelemetryHandler.m
//  Adjust SDK
//
//  Created by Ugljesa Erceg (@uerceg) on 28th October 2022.
//  Copyright © 2022-Present Adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJAdjustFactory.h"
#import "ADJTelemetryHandler.h"
#import "ADJBackoffStrategy.h"
#import "ADJUserDefaults.h"
#import "ADJPackageBuilder.h"

static const char * const kInternalQueueName = "com.adjust.TelemetryQueue";

@interface ADJTelemetryHandler()

@property (nonatomic, strong) NSMutableArray *packageQueue;

@property (nonatomic, strong) dispatch_queue_t internalQueue;

@property (nonatomic, strong) ADJRequestHandler *requestHandler;

@property (nonatomic, assign) BOOL paused;

@property (nonatomic, strong) ADJBackoffStrategy *backoffStrategy;

@property (nonatomic, weak) id<ADJLogger> logger;

@property (nonatomic, weak) id<ADJActivityHandler> activityHandler;

@property (nonatomic, assign) NSInteger lastPackageRetriesCount;

@end

@implementation ADJTelemetryHandler

#pragma mark - Public instance methods

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy
{
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.logger = ADJAdjustFactory.logger;
    self.lastPackageRetriesCount = 0;

    self.requestHandler = [[ADJRequestHandler alloc] initWithResponseCallback:self
                                                                  urlStrategy:urlStrategy
                                                                    userAgent:userAgent
                                                               requestTimeout:[ADJAdjustFactory requestTimeout]];

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJTelemetryHandler *selfI) {
                         [selfI initI:selfI activityHandler:activityHandler startsSending:startsSending];
                     }];
    return self;
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
    [self sendNextTelemetryPackage];
}

- (void)sendTelemetryPackage:(ADJActivityPackage *)telemetryPackage {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJTelemetryHandler *selfI) {
                         [selfI sendTelemetryPackageI:selfI telemetryPackage:telemetryPackage];
                     }];
}

- (void)sendNextTelemetryPackage {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJTelemetryHandler *selfI) {
                         [selfI sendNextTelemetryPackageI:selfI];
                     }];
}

- (void)teardown {
    [ADJAdjustFactory.logger verbose:@"ADJTelemetryHandler teardown"];

    if (self.packageQueue != nil) {
        [self.packageQueue removeAllObjects];
    }

    self.internalQueue = nil;
    self.logger = nil;
    self.backoffStrategy = nil;
    self.packageQueue = nil;
    self.activityHandler = nil;
}

#pragma mark - Private & helper methods

-   (void)initI:(ADJTelemetryHandler *)selfI
activityHandler:(id<ADJActivityHandler>)activityHandler
  startsSending:(BOOL)startsSending {
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.backoffStrategy = [ADJAdjustFactory sdkClickHandlerBackoffStrategy];
    selfI.packageQueue = [NSMutableArray array];
}

- (void)sendTelemetryPackageI:(ADJTelemetryHandler *)selfI
             telemetryPackage:(ADJActivityPackage *)telemetryPackage {
    [selfI.packageQueue addObject:telemetryPackage];
    [selfI.logger debug:@"Added telemetry package %d", selfI.packageQueue.count];
    [selfI.logger verbose:@"%@", telemetryPackage.extendedString];
    [selfI sendNextTelemetryPackage];
}

- (void)sendNextTelemetryPackageI:(ADJTelemetryHandler *)selfI {
    if (selfI.paused) {
        return;
    }
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) {
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"Telemetry request won't be fired for GDPR forgotten user"];
        return;
    }

    ADJActivityPackage *telemetryPackage = [self.packageQueue objectAtIndex:0];
    [self.packageQueue removeObjectAtIndex:0];

    if (![telemetryPackage isKindOfClass:[ADJActivityPackage class]]) {
        [selfI.logger error:@"Failed to read telemetry package"];
        [selfI sendNextTelemetryPackage];
        return;
    }

    dispatch_block_t work = ^{
        NSDictionary *sendingParameters = @{
            @"sent_at": [ADJUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]]
        };
        [selfI.requestHandler sendPackageByPOST:telemetryPackage
                              sendingParameters:sendingParameters];
        [selfI sendNextTelemetryPackage];
    };

    if (selfI.lastPackageRetriesCount <= 0) {
        work();
        return;
    }

    NSTimeInterval waitTime = [ADJUtil waitingTime:selfI.lastPackageRetriesCount backoffStrategy:self.backoffStrategy];
    NSString *waitTimeFormatted = [ADJUtil secondsNumberFormat:waitTime];

    [self.logger verbose:@"Waiting for %@ seconds before retrying telemetry package for the %d time", waitTimeFormatted, selfI.lastPackageRetriesCount];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, work);
}

- (void)responseCallback:(ADJResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:
            @"Got telemetry JSON response with message: %@", responseData.message];
    } else {
        [self.logger error:
            @"Could not get telemetry JSON response with message: %@", responseData.message];
    }
    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADJTrackingStateOptedOut) {
        self.lastPackageRetriesCount = 0;
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }
    if (responseData.jsonResponse == nil) {
        self.lastPackageRetriesCount++;
        [self.logger error:@"Retrying telemetry package for the %d time", self.lastPackageRetriesCount];
        [self sendTelemetryPackage:responseData.telemetryPackage];
        return;
    }
    self.lastPackageRetriesCount = 0;
    [self.activityHandler finishedTracking:responseData];
}

@end

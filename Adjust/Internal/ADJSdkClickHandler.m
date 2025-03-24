//
//  ADJSdkClickHandler.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 21st April 2016.
//  Copyright © 2016 Adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJAdjustFactory.h"
#import "ADJSdkClickHandler.h"
#import "ADJBackoffStrategy.h"
#import "ADJUserDefaults.h"
#import "ADJPackageBuilder.h"

static const char * const kInternalQueueName = "com.adjust.SdkClickQueue";

@interface ADJSdkClickHandler()

@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADJRequestHandler *requestHandler;

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) ADJBackoffStrategy *backoffStrategy;

@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, weak) id<ADJActivityHandler> activityHandler;

@property (nonatomic, assign) NSInteger lastPackageRetriesCount;
@property (nonatomic, strong) NSNumber *lastPackageRetryInMilli;

@end

@implementation ADJSdkClickHandler

#pragma mark - Public instance methods

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                  urlStrategy:(ADJUrlStrategy *)urlStrategy
{
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.logger = ADJAdjustFactory.logger;
    self.lastPackageRetriesCount = 0;

    self.requestHandler = [[ADJRequestHandler alloc]
                           initWithResponseCallback:self
                           urlStrategy:urlStrategy
                           requestTimeout:[ADJAdjustFactory requestTimeout]
                           adjustConfiguration:activityHandler.adjustConfig];

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJSdkClickHandler *selfI) {
                         [selfI initI:selfI
                      activityHandler:activityHandler
                        startsSending:startsSending];
                     }];
    return self;
}

- (void)pauseSending {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJSdkClickHandler *selfI) {
        selfI.paused = YES;
    }];
}

- (void)resumeSending {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJSdkClickHandler *selfI) {
        selfI.paused = NO;
        [selfI sendNextSdkClick];
    }];
}

- (void)sendSdkClick:(ADJActivityPackage *)sdkClickPackage {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJSdkClickHandler *selfI) {
                         [selfI sendSdkClickI:selfI sdkClickPackage:sdkClickPackage];
                     }];
}

- (void)sendNextSdkClick {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJSdkClickHandler *selfI) {
                         [selfI sendNextSdkClickI:selfI];
                     }];
}

- (void)updatePackagesWithAttStatus:(int)attStatus {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJSdkClickHandler *selfI) {
        [selfI updatePackagesTrackingI:selfI
                             attStatus:attStatus];
    }];
}

- (void)teardown {
    [ADJAdjustFactory.logger verbose:@"ADJSdkClickHandler teardown"];

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

-   (void)initI:(ADJSdkClickHandler *)selfI
activityHandler:(id<ADJActivityHandler>)activityHandler
  startsSending:(BOOL)startsSending {
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.backoffStrategy = [ADJAdjustFactory sdkClickHandlerBackoffStrategy];
    selfI.packageQueue = [NSMutableArray array];
}

- (void)sendSdkClickI:(ADJSdkClickHandler *)selfI
      sdkClickPackage:(ADJActivityPackage *)sdkClickPackage {
    [selfI.packageQueue addObject:sdkClickPackage];
    [selfI.logger debug:@"Added sdk_click %d", selfI.packageQueue.count];
    [selfI.logger verbose:@"%@", sdkClickPackage.extendedString];
    [selfI sendNextSdkClick];
}

- (void)sendNextSdkClickI:(ADJSdkClickHandler *)selfI {
    if (selfI.paused) {
        [selfI.logger debug:@"Click handler is paused"];
        return;
    }
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) {
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"sdk_click request won't be fired for forgotten user"];
        return;
    }

    ADJActivityPackage *sdkClickPackage = [self.packageQueue objectAtIndex:0];
    [self.packageQueue removeObjectAtIndex:0];

    if (![sdkClickPackage isKindOfClass:[ADJActivityPackage class]]) {
        [selfI.logger error:@"Failed to read sdk_click package"];
        [selfI sendNextSdkClick];
        return;
    }
    
    if ([ADJPackageBuilder isAdServicesPackage:sdkClickPackage]) {
        // refresh token
        NSString *token = [ADJUtil fetchAdServicesAttribution:nil];
        
        if (token != nil && ![sdkClickPackage.parameters[ADJAttributionTokenParameter] isEqualToString:token]) {
            // update token
            [ADJPackageBuilder parameters:sdkClickPackage.parameters
                                setString:token
                                   forKey:ADJAttributionTokenParameter];
            
            // update created_at
            [ADJPackageBuilder parameters:sdkClickPackage.parameters
                              setDate1970:[NSDate.date timeIntervalSince1970]
                                   forKey:@"created_at"];
        }
    }

    dispatch_block_t work = ^{
        [selfI.requestHandler sendPackageByPOST:sdkClickPackage
                              sendingParameters:nil];
        [selfI sendNextSdkClick];
    };

    NSNumber *waitTimeSecondsDouble = [selfI waitTimeTimeInterval];

    if (waitTimeSecondsDouble != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                     (int64_t)(waitTimeSecondsDouble.doubleValue * NSEC_PER_SEC)),
                       self.internalQueue, work);
    } else {
        work();
    }
}

- (NSNumber *)waitTimeTimeInterval {
    if (self.lastPackageRetriesCount > 0) {
        NSTimeInterval waitTime = [ADJUtil waitingTime:self.lastPackageRetriesCount
                                       backoffStrategy:self.backoffStrategy];

        [self.logger verbose:@"Waiting for %@ seconds before retrying sdk_click for the %d time",
         [ADJUtil secondsNumberFormat:waitTime], self.lastPackageRetriesCount];

        return @(waitTime);
    }

    if (self.lastPackageRetryInMilli != nil) {
        NSTimeInterval waitTime = [self.lastPackageRetryInMilli intValue] / 1000.0;

        [self.logger verbose:@"Waiting for %@ seconds before retrying sdk_click with retry_in",
         [ADJUtil secondsNumberFormat:waitTime]];

        return @(waitTime);
    }

    return nil;
}

- (void)updatePackagesTrackingI:(ADJSdkClickHandler *)selfI
                      attStatus:(int)attStatus {
    [selfI.logger debug:@"Updating sdk_click queue with idfa and att_status: %d", attStatus];
    for (ADJActivityPackage *activityPackage in selfI.packageQueue) {
        [ADJPackageBuilder parameters:activityPackage.parameters
                               setInt:attStatus
                               forKey:@"att_status"];

        [ADJPackageBuilder addConsentDataToParameters:activityPackage.parameters
                                      forActivityKind:activityPackage.activityKind
                                        withAttStatus:attStatus
                                        configuration:selfI.activityHandler.adjustConfig
                                        packageParams:selfI.activityHandler.packageParams
                                        activityState:selfI.activityHandler.activityState];
    }
}

- (void)responseCallback:(ADJResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:
            @"Got click JSON response with message: %@", responseData.message];
    } else {
        [self.logger error:
            @"Could not get click JSON response with message: %@", responseData.message];
    }
    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADJTrackingStateOptedOut) {
        self.lastPackageRetriesCount = 0;
        self.lastPackageRetryInMilli = nil;
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }

    if ([self retryPackageWithResponse:responseData]) {
        [self sendSdkClick:responseData.sdkClickPackage];
        return;
    }

    self.lastPackageRetriesCount = 0;
    self.lastPackageRetryInMilli = nil;

    if ([ADJPackageBuilder isAdServicesPackage:responseData.sdkClickPackage]) {
        // set as tracked
        [ADJUserDefaults setAdServicesTracked];
        [self.logger info:@"Received Apple Ads click response"];
    }

    // in case there's resolved_click_url in the response
    ((ADJSdkClickResponseData *)responseData).resolvedDeeplink = [responseData.jsonResponse objectForKey:@"resolved_click_url"];

    [self.activityHandler finishedTracking:responseData];
}

- (BOOL)retryPackageWithResponse:(ADJResponseData *)responseData {
    if (responseData.jsonResponse == nil) {
        self.lastPackageRetriesCount++;
        [self.logger error:@"Retrying sdk_click package for the %d time",
         self.lastPackageRetriesCount];
        return YES;
    }

    if (responseData.retryInMilli != nil) {
        self.lastPackageRetryInMilli = responseData.retryInMilli;
        [self.logger error:@"Retrying sdk_click package with retry in %d ms",
         [responseData.retryInMilli intValue]];
        return YES;
    }

    return NO;
}

@end

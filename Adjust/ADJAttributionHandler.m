//
//  ADJAttributionHandler.m
//  adjust
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJAttributionHandler.h"
#import "ADJAdjustFactory.h"
#import "ADJUtil.h"
#import "ADJActivityHandler.h"
#import "NSString+ADJAdditions.h"
#import "ADJTimerOnce.h"
#import "ADJPackageBuilder.h"
#import "ADJUtil.h"

static const char * const kInternalQueueName     = "com.adjust.AttributionQueue";
static NSString   * const kAttributionTimerName   = @"Attribution timer";

@interface ADJAttributionHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADJRequestHandler *requestHandler;
@property (nonatomic, weak) id<ADJActivityHandler> activityHandler;
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) ADJTimerOnce *attributionTimer;
@property (atomic, assign) BOOL paused;
@property (nonatomic, copy) NSString *lastInitiatedBy;

@end

@implementation ADJAttributionHandler
- (id)initWithActivityHandler:(id<ADJActivityHandler>) activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.requestHandler = [[ADJRequestHandler alloc]
                                initWithResponseCallback:self
                                urlStrategy:urlStrategy
                                userAgent:userAgent
                                requestTimeout:[ADJAdjustFactory requestTimeout]];
    self.activityHandler = activityHandler;
    self.logger = ADJAdjustFactory.logger;
    self.paused = !startsSending;
    __weak __typeof__(self) weakSelf = self;
    self.attributionTimer = [ADJTimerOnce timerWithBlock:^{
        __typeof__(self) strongSelf = weakSelf;
        if (strongSelf == nil) return;

        [strongSelf requestAttributionI:strongSelf];
    }
                                                   queue:self.internalQueue
                                                    name:kAttributionTimerName];

    return self;
}

- (void)checkSessionResponse:(ADJSessionResponseData *)sessionResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJAttributionHandler* selfI) {
                         [selfI checkSessionResponseI:selfI
                                  sessionResponseData:sessionResponseData];
                     }];
}

- (void)checkSdkClickResponse:(ADJSdkClickResponseData *)sdkClickResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJAttributionHandler* selfI) {
                         [selfI checkSdkClickResponseI:selfI
                                  sdkClickResponseData:sdkClickResponseData];
                     }];
}

- (void)checkAttributionResponse:(ADJAttributionResponseData *)attributionResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJAttributionHandler* selfI) {
                         [selfI checkAttributionResponseI:selfI
                                  attributionResponseData:attributionResponseData];

                     }];
}

- (void)getAttribution {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJAttributionHandler* selfI) {
                         selfI.lastInitiatedBy = @"sdk";
                         [selfI waitRequestAttributionWithDelayI:selfI
                                               milliSecondsDelay:0];

                     }];
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

#pragma mark - internal
- (void)checkSessionResponseI:(ADJAttributionHandler*)selfI
          sessionResponseData:(ADJSessionResponseData *)sessionResponseData {
    [selfI checkAttributionI:selfI responseData:sessionResponseData];
    
    [selfI.activityHandler launchSessionResponseTasks:sessionResponseData];
}

- (void)checkSdkClickResponseI:(ADJAttributionHandler*)selfI
          sdkClickResponseData:(ADJSdkClickResponseData *)sdkClickResponseData {
    [selfI checkAttributionI:selfI responseData:sdkClickResponseData];
    
    [selfI.activityHandler launchSdkClickResponseTasks:sdkClickResponseData];
}

- (void)checkAttributionResponseI:(ADJAttributionHandler*)selfI
                  attributionResponseData:(ADJAttributionResponseData *)attributionResponseData {
    [selfI checkAttributionI:selfI responseData:attributionResponseData];

    [selfI checkDeeplinkI:selfI attributionResponseData:attributionResponseData];
    
    [selfI.activityHandler launchAttributionResponseTasks:attributionResponseData];
}

- (void)checkAttributionI:(ADJAttributionHandler*)selfI
             responseData:(ADJResponseData *)responseData {
    if (responseData.jsonResponse == nil) {
        return;
    }

    NSNumber *timerMilliseconds = [responseData.jsonResponse objectForKey:@"ask_in"];

    if (timerMilliseconds != nil) {
        [selfI.activityHandler setAskingAttribution:YES];

        selfI.lastInitiatedBy = @"backend";
        [selfI waitRequestAttributionWithDelayI:selfI
                              milliSecondsDelay:[timerMilliseconds intValue]];

        return;
    }

    [selfI.activityHandler setAskingAttribution:NO];

    NSDictionary * jsonAttribution = [responseData.jsonResponse objectForKey:@"attribution"];
    responseData.attribution = [ADJAttribution dataWithJsonDict:jsonAttribution adid:responseData.adid];
}

- (void)checkDeeplinkI:(ADJAttributionHandler*)selfI
attributionResponseData:(ADJAttributionResponseData *)attributionResponseData {
    if (attributionResponseData.jsonResponse == nil) {
        return;
    }

    NSDictionary * jsonAttribution = [attributionResponseData.jsonResponse objectForKey:@"attribution"];
    if (jsonAttribution == nil) {
        return;
    }

    NSString *deepLink = [jsonAttribution objectForKey:@"deeplink"];
    if (deepLink == nil) {
        return;
    }

    attributionResponseData.deeplink = [NSURL URLWithString:deepLink];
}

- (void)requestAttributionI:(ADJAttributionHandler*)selfI {
    if (selfI.paused) {
        [selfI.logger debug:@"Attribution handler is paused"];
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"Attribution request won't be fired for forgotten user"];
        return;
    }

    ADJActivityPackage* attributionPackage = [selfI buildAndGetAttributionPackageI:selfI];

    [selfI.logger verbose:@"%@", attributionPackage.extendedString];

    NSDictionary *sendingParameters = @{
        @"sent_at": [ADJUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]]
    };

    [selfI.requestHandler sendPackageByGET:attributionPackage
                        sendingParameters:sendingParameters];
}

- (void)responseCallback:(ADJResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:
            @"Got attribution JSON response with message: %@", responseData.message];
    } else {
        [self.logger error:
            @"Could not get attribution JSON response with message: %@", responseData.message];
    }

    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADJTrackingStateOptedOut) {
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }

    if ([responseData isKindOfClass:[ADJAttributionResponseData class]]) {
        [self checkAttributionResponse:(ADJAttributionResponseData*)responseData];
    }
}

- (void)waitRequestAttributionWithDelayI:(ADJAttributionHandler*)selfI
                       milliSecondsDelay:(int)milliSecondsDelay {
    NSTimeInterval secondsDelay = milliSecondsDelay / 1000;
    NSTimeInterval nextAskIn = [selfI.attributionTimer fireIn];
    if (nextAskIn > secondsDelay) {
        return;
    }

    if (milliSecondsDelay > 0) {
        [selfI.logger debug:@"Waiting to query attribution in %d milliseconds", milliSecondsDelay];
    }

    // set the new time the timer will fire in
    [selfI.attributionTimer startIn:secondsDelay];
}

- (ADJActivityPackage *)buildAndGetAttributionPackageI:(ADJAttributionHandler*)selfI
{
    double now = [NSDate.date timeIntervalSince1970];

    ADJPackageBuilder *attributionBuilder = [[ADJPackageBuilder alloc]
                                             initWithPackageParams:selfI.activityHandler.packageParams
                                             activityState:selfI.activityHandler.activityState
                                             config:selfI.activityHandler.adjustConfig
                                             sessionParameters:selfI.activityHandler.sessionParameters
                                             trackingStatusManager:selfI.activityHandler.trackingStatusManager
                                             createdAt:now];
    ADJActivityPackage *attributionPackage = [attributionBuilder buildAttributionPackage:selfI.lastInitiatedBy];

    selfI.lastInitiatedBy = nil;

    return attributionPackage;
}

#pragma mark - private

- (void)teardown {
    [ADJAdjustFactory.logger verbose:@"ADJAttributionHandler teardown"];

    if (self.attributionTimer != nil) {
        [self.attributionTimer cancel];
    }
    self.internalQueue = nil;
    self.activityHandler = nil;
    self.logger = nil;
    self.attributionTimer = nil;
    self.requestHandler = nil;
}

@end

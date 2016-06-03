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

static const char * const kInternalQueueName     = "com.adjust.AttributionQueue";
static NSString   * const kAttributionTimerName   = @"Attribution timer";

@interface ADJAttributionHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, weak) id<ADJActivityHandler> activityHandler;
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) ADJTimerOnce *attributionTimer;
@property (nonatomic, strong) ADJActivityPackage * attributionPackage;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL hasNeedsResponseDelegate;

@end

static const double kRequestTimeout = 60; // 60 seconds

@implementation ADJAttributionHandler

+ (id<ADJAttributionHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                 withAttributionPackage:(ADJActivityPackage *) attributionPackage
                                          startsSending:(BOOL)startsSending
                          hasAttributionChangedDelegate:(BOOL)hasAttributionChangedDelegate;
{
    return [[ADJAttributionHandler alloc] initWithActivityHandler:activityHandler
                                           withAttributionPackage:attributionPackage
                                                    startsSending:startsSending
                                    hasAttributionChangedDelegate:hasAttributionChangedDelegate];
}

- (id)initWithActivityHandler:(id<ADJActivityHandler>) activityHandler
       withAttributionPackage:(ADJActivityPackage *) attributionPackage
                startsSending:(BOOL)startsSending
hasAttributionChangedDelegate:(BOOL)hasAttributionChangedDelegate;
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.activityHandler = activityHandler;
    self.logger = ADJAdjustFactory.logger;
    self.attributionPackage = attributionPackage;
    self.paused = !startsSending;
    self.hasNeedsResponseDelegate = hasAttributionChangedDelegate;
    self.attributionTimer = [ADJTimerOnce timerWithBlock:^{ [self getAttributionInternal]; }
                                                   queue:self.internalQueue
                                                    name:kAttributionTimerName];

    return self;
}

- (void) checkSessionResponse:(ADJSessionResponseData *)sessionResponseData {
    dispatch_async(self.internalQueue, ^{
        [self checkSessionResponseInternal:sessionResponseData];
    });
}

- (void) checkAttributionResponse:(ADJAttributionResponseData *)attributionResponseData {
    dispatch_async(self.internalQueue, ^{
        [self checkAttributionResponseInternal:attributionResponseData];
    });
}

- (void) getAttributionWithDelay:(int)milliSecondsDelay {
    NSTimeInterval secondsDelay = milliSecondsDelay / 1000;
    NSTimeInterval nextAskIn = [self.attributionTimer fireIn];
    if (nextAskIn > secondsDelay) {
        return;
    }

    if (milliSecondsDelay > 0) {
        [self.logger debug:@"Waiting to query attribution in %d milliseconds", milliSecondsDelay];
    }

    // set the new time the timer will fire in
    [self.attributionTimer startIn:secondsDelay];
}

- (void) getAttribution {
    [self getAttributionWithDelay:0];
}

- (void) pauseSending {
    self.paused = YES;
}

- (void) resumeSending {
    self.paused = NO;
}

#pragma mark - internal
- (void) checkSessionResponseInternal:(ADJSessionResponseData *)sessionResponseData {
    [self checkAttributionInternal:sessionResponseData];

    [self.activityHandler launchSessionResponseTasks:sessionResponseData];
}

- (void) checkAttributionResponseInternal:(ADJAttributionResponseData *)attributionResponseData {
    [self checkAttributionInternal:attributionResponseData];

    [self.activityHandler launchAttributionResponseTasks:attributionResponseData];
}

- (void) checkAttributionInternal:(ADJResponseData *)responseData {
    if (responseData.jsonResponse == nil) {
        return;
    }

    NSNumber *timerMilliseconds = [responseData.jsonResponse objectForKey:@"ask_in"];

    if (timerMilliseconds != nil) {
        [self.activityHandler setAskingAttribution:YES];

        [self getAttributionWithDelay:[timerMilliseconds intValue]];

        return;
    }

    [self.activityHandler setAskingAttribution:NO];

    NSDictionary * jsonAttribution = [responseData.jsonResponse objectForKey:@"attribution"];
    responseData.attribution = [ADJAttribution dataWithJsonDict:jsonAttribution];
}

- (void) getAttributionInternal {
    if (!self.hasNeedsResponseDelegate) {
        return;
    }
    if (self.paused) {
        [self.logger debug:@"Attribution handler is paused"];
        return;
    }
    [self.logger verbose:@"%@", self.attributionPackage.extendedString];

    [ADJUtil sendRequest:[self request]
      prefixErrorMessage:@"Failed to get attribution"
         activityPackage:self.attributionPackage
     responseDataHandler:^(ADJResponseData * responseData)
    {
        if ([responseData isKindOfClass:[ADJAttributionResponseData class]]) {
            [self checkAttributionResponse:(ADJAttributionResponseData*)responseData];
        }
    }];
}

#pragma mark - private

- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self url]];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"GET";

    [request setValue:self.attributionPackage.clientSdk forHTTPHeaderField:@"Client-Sdk"];

    return request;
}

- (NSURL *)url {
    NSString *parameters = [ADJUtil queryString:self.attributionPackage.parameters];
    NSString *relativePath = [NSString stringWithFormat:@"%@?%@", self.attributionPackage.path, parameters];
    NSURL *baseUrl = [NSURL URLWithString:ADJUtil.baseUrl];
    NSURL *url = [NSURL URLWithString:relativePath relativeToURL:baseUrl];
    
    return url;
}

@end

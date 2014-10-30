//
//  AIAttributionHandler.m
//  adjust
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIAttributionHandler.h"
#import "AIAdjustFactory.h"
#import "AIUtil.h"
#import "AIActivityHandler.h"
#import "NSString+AIAdditions.h"
#import "AITimer.h"

static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second

@interface AIAttributionHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, assign) id<AIActivityHandler> activityHandler;
@property (nonatomic, assign) id<AILogger> logger;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) AITimer *timer;
@property (nonatomic, assign) double attributionMaxTime;

@end

static const double kRequestTimeout = 60; // 60 seconds

@implementation AIAttributionHandler

+ (id<AIAttributionHandler>)handlerWithActivityHandler:(id<AIActivityHandler>)activityHandler {
    return [[AIAttributionHandler alloc] initWithActivityHandler:activityHandler];
}

- (id)initWithActivityHandler:(id<AIActivityHandler>) activityHandler {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    self.activityHandler = activityHandler;
    self.logger = AIAdjustFactory.logger;
    self.url = [NSURL URLWithString:AIUtil.baseUrl];
    //TODO change baseURL

    return self;
}
// comunicate with server
- (void) getAttribution {
    dispatch_async(self.internalQueue, ^{
        [self getAttribution];
    });
}

#pragma mark - internal
-(void) checkAttributionInternal {
    NSMutableURLRequest *request = [self request];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;

    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                        returningResponse:&urlResponse
                                        error:&requestError];
    // connection error
    if (requestError != nil) {
        [self.logger error:@"Failed to get attribution. (%@)", requestError.localizedDescription];
        return;
    }

    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [AIUtil buildJsonDict:responseString];

    if (jsonDict == nil) {
        [self.logger error:@"Failed to parse json attribution response: %@", responseString.aiTrim];
        return;
    }

    // check if response contains attribution
    NSDictionary *jsonAttribution = [jsonDict objectForKey:@"attribution"];
    if (jsonAttribution == nil) {
        // read time to wait and set timer to re-try
        NSNumber * timer_seconds = [jsonDict objectForKey:@"timer"];
        uint64_t timer_nano = [timer_seconds intValue] * NSEC_PER_SEC;
        self.timer = [AITimer timerWithStart:timer_nano leeway:kTimerLeeway queue:self.internalQueue block:^{ [self checkAttributionInternal]; }];
        [self.timer resume];
        return;
    }

    // check if new attribution is different from previous
    AIAttribution * attributionResponse = [AIAttribution dataWithJsonDict:jsonAttribution];

    if ([attributionResponse isEqual:self.activityHandler.attribution]) {
        // TODO reset?
        return;
    }

    // if so, launch response delegate
    [self.activityHandler changedAttributionDelegate:attributionResponse];
}

#pragma mark - private

- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"GET";

    return request;
}

@end

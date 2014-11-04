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

    self.internalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    self.activityHandler = activityHandler;
    self.logger = AIAdjustFactory.logger;
    self.url = [NSURL URLWithString:AIUtil.baseUrl];
    //TODO change baseURL

    return self;
}

- (void) checkAttribution:(NSDictionary *)jsonDict {
    dispatch_async(self.internalQueue, ^{
        [self checkAttributionInternal:jsonDict];
    });
}

- (void) getAttribution {
    dispatch_async(self.internalQueue, ^{
        [self getAttributionInternal];
    });

}

#pragma mark - internal
-(void) checkAttributionInternal:(NSDictionary *)jsonDict {
    // compare if there is difference from current attribution at activity handler to launch the delegate
    [self compareAttribution:jsonDict];

    // check if response json contains instrunction to retry after some time
    NSNumber * timer_seconds = [jsonDict objectForKey:@"timer"];
    if (timer_seconds == nil) return;

    uint64_t timer_nano = [timer_seconds intValue] * NSEC_PER_SEC;
    self.timer = [AITimer timerWithStart:timer_nano leeway:kTimerLeeway queue:self.internalQueue block:^{ [self getAttributionInternal]; }];
    [self.timer resume];
}

-(void) getAttributionInternal {
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
    [self.logger verbose:@"attribution response: %@", responseString];

    NSDictionary *jsonDict = [AIUtil buildJsonDict:responseString];

    if (jsonDict == nil) {
        [self.logger error:@"Failed to parse json attribution response: %@", responseString.aiTrim];
        return;
    }

    [self checkAttributionInternal:jsonDict];
}

-(void)compareAttribution:(NSDictionary *)jsonDict {
    NSDictionary* jsonAttribution = [jsonDict objectForKey:@"attribution"];
    if (jsonAttribution == nil) return;

    AIAttribution * attribution = [AIAttribution dataWithJsonDict:jsonAttribution];

    if ([attribution isEqual:self.activityHandler.attribution]) {
        return;
    }

    [self.activityHandler changedAttributionDelegate:attribution];
}


#pragma mark - private

- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"GET";

    return request;
}

@end

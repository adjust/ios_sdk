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
#import "ADJTimer.h"

static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second

@interface ADJAttributionHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, assign) id<ADJActivityHandler> activityHandler;
@property (nonatomic, assign) id<ADJLogger> logger;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) ADJTimer *askInTimer;
@property (nonatomic, retain) ADJTimer *maxDelayTimer;

@end

static const double kRequestTimeout = 60; // 60 seconds

@implementation ADJAttributionHandler

+ (id<ADJAttributionHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler withMaxDelay:(NSNumber *)milliseconds{
    return [[ADJAttributionHandler alloc] initWithActivityHandler:activityHandler withMaxDelay:milliseconds];
}

- (id)initWithActivityHandler:(id<ADJActivityHandler>) activityHandler
                 withMaxDelay:(NSNumber* )milliseconds{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    self.activityHandler = activityHandler;
    self.logger = ADJAdjustFactory.logger;
    self.url = [NSURL URLWithString:ADJUtil.baseUrl];
    //TODO change baseURL

    if (milliseconds != nil) {
        uint64_t timer_nano = [milliseconds intValue] * NSEC_PER_MSEC;
        self.maxDelayTimer = [ADJTimer timerWithStart:timer_nano leeway:kTimerLeeway queue:self.internalQueue block:^{ [self.activityHandler launchAttributionDelegate]; }];
        [self.maxDelayTimer resume];
    }

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
    if (jsonDict == nil) return;

    NSDictionary* jsonAttribution = [jsonDict objectForKey:@"attribution"];
    ADJAttribution * attribution = [ADJAttribution dataWithJsonDict:jsonAttribution];

    NSNumber * timer_milliseconds = [jsonDict objectForKey:@"ask_in"];

    if (attribution != nil && timer_milliseconds == nil) {
        attribution.finalAttribution = YES;
    }

    [self.activityHandler updateAttribution:attribution];

    if (timer_milliseconds == nil) {
        [self.activityHandler launchAttributionDelegate];
        return;
    };

    uint64_t timer_nano = [timer_milliseconds intValue] * NSEC_PER_MSEC;
    self.askInTimer = [ADJTimer timerWithStart:timer_nano leeway:kTimerLeeway queue:self.internalQueue block:^{ [self getAttributionInternal]; }];
    [self.askInTimer resume];
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

    NSDictionary *jsonDict = [ADJUtil buildJsonDict:responseString];

    if (jsonDict == nil) {
        [self.logger error:@"Failed to parse json attribution response: %@", responseString.aiTrim];
        return;
    }

    [self checkAttributionInternal:jsonDict];
}

#pragma mark - private

- (NSMutableURLRequest *)request {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.timeoutInterval = kRequestTimeout;
    request.HTTPMethod = @"GET";

    return request;
}

@end

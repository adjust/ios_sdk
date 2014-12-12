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
static const char * const kInternalQueueName     = "com.adjust.AttributionQueue";

@interface ADJAttributionHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, assign) id<ADJActivityHandler> activityHandler;
@property (nonatomic, assign) id<ADJLogger> logger;
@property (nonatomic, retain) ADJTimer *askInTimer;
@property (nonatomic, retain) ADJTimer *maxDelayTimer;
@property (nonatomic, retain) ADJActivityPackage * attributionPackage;

@end

static const double kRequestTimeout = 60; // 60 seconds

@implementation ADJAttributionHandler

+ (id<ADJAttributionHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                           withMaxDelay:(NSNumber *)milliseconds
                                 withAttributionPackage:(ADJActivityPackage *) attributionPackage;
{
    return [[ADJAttributionHandler alloc] initWithActivityHandler:activityHandler
                                                     withMaxDelay:milliseconds
                                           withAttributionPackage:attributionPackage];
}

- (id)initWithActivityHandler:(id<ADJActivityHandler>) activityHandler
                 withMaxDelay:(NSNumber*) milliseconds
       withAttributionPackage:(ADJActivityPackage *) attributionPackage;
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.activityHandler = activityHandler;
    self.logger = ADJAdjustFactory.logger;
    self.attributionPackage = attributionPackage;

    if (milliseconds != nil) {
        uint64_t timerNano = [milliseconds intValue] * NSEC_PER_MSEC;
        self.maxDelayTimer = [ADJTimer timerWithStart:timerNano leeway:kTimerLeeway queue:self.internalQueue block:^{ [self.activityHandler launchAttributionDelegate]; }];
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
    if (jsonDict == nil || jsonDict == (id)[NSNull null]) return;

    NSDictionary* jsonAttribution = [jsonDict objectForKey:@"attribution"];
    ADJAttribution *attribution = [ADJAttribution dataWithJsonDict:jsonAttribution];

    NSNumber *timerMilliseconds = [jsonDict objectForKey:@"ask_in"];

    if (timerMilliseconds == nil) {
        BOOL updated = [self.activityHandler updateAttribution:attribution];

        if (updated) {
            [self.activityHandler launchAttributionDelegate];
        }

        [self.activityHandler setAskingAttribution:NO];

        return;
    };

    [self.activityHandler setAskingAttribution:YES];
    if (self.askInTimer != nil) {
        [self.askInTimer cancel];
    }

    [self.logger debug:@"Waiting to query attribution in %d milliseconds", [timerMilliseconds intValue]];

    uint64_t timer_nano = [timerMilliseconds intValue] * NSEC_PER_MSEC;
    self.askInTimer = [ADJTimer timerWithStart:timer_nano leeway:kTimerLeeway queue:self.internalQueue block:^{ [self getAttributionInternal]; }];
    [self.askInTimer resume];
}

-(void) getAttributionInternal {
    [self.logger verbose:@"%@", self.attributionPackage.extendedString];
    if (self.askInTimer != nil) {
        [self.askInTimer cancel];
        self.askInTimer = nil;
    }

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
    NSInteger statusCode = ((NSHTTPURLResponse*)urlResponse).statusCode;
    [self.logger verbose:@"status code %d for attribution response: %@", statusCode, responseString];

    NSDictionary *jsonDict = [ADJUtil buildJsonDict:responseString];

    if (jsonDict == nil || jsonDict == (id)[NSNull null]) {
        [self.logger error:@"Failed to parse json attribution response: %@", responseString.adjTrim];
        return;
    }

    NSString* messageResponse = [jsonDict objectForKey:@"message"];

    if (messageResponse == nil) {
        messageResponse = @"No message found";
    }

    if (statusCode == 200) {
        [self.logger debug:@"%@", messageResponse];
    } else {
        [self.logger error:@"%@", messageResponse];
    }

    [self checkAttributionInternal:jsonDict];
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

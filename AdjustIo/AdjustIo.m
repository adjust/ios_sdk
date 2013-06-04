//
//  AdjustIo.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AdjustIo.h"
#import "AIApiClient.h"

#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"
#import "NSData+AIAdditions.h"
#import "NSMutableDictionary+AIAdditions.h"


static const double kTimerInterval   = 3.0; // TODO: 60 seconds
static const double kSessionInterval = 1.0; // TODO: 30 minutes

static NSString * const kKeyLastActivity        = @"lastactivity"; // TODO: rename
static NSString * const kKeyLastSessionStart    = @"lastsessionstart";
static NSString * const kKeyLastSubsessionStart = @"lastsubsessionstart";
static NSString * const kKeySessionCount        = @"sessioncount";
static NSString * const kKeySubsessionCount     = @"subsessioncount";
static NSString * const kKeyTimeSpent           = @"timespent";
static NSString * const kKeyEventCount          = @"eventcount";

static AIApiClient *aiApiClient = nil;
static AELogger    *aiLogger    = nil;
static NSTimer     *aiTimer     = nil;

static NSString *aiAppToken         = nil;
static NSString *aiMacSha1          = nil;
static NSString *aiMacShortMd5      = nil;
static NSString *aiIdForAdvertisers = nil;
static NSString *aiFbAttributionId  = nil;


#pragma mark private interface
@interface AdjustIo()

+ (void)addNotificationObserver;
+ (void)removeNotificationObserver;
+ (void)startTimer;
+ (void)stopTimer;
+ (void)trackSessionStart;
+ (void)trackSessionEnd;
+ (void)trackEventPackage:(NSMutableDictionary *)event;
+ (void)timerFired:(NSTimer *)timer;
+ (void)enqueueTrackingPackage:(NSDictionary *)package;

+ (NSMutableDictionary *)sessionPackage;
+ (NSMutableDictionary *)eventPackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)parameters;
+ (NSMutableDictionary *)eventPackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)parameters amount:(float)amount;

@end


#pragma mark AdjustIo
@implementation AdjustIo

#pragma mark public

+ (void)appDidLaunch:(NSString *)yourAppToken {
    [aiLogger debug:@"appDidLaunch"];
    if (yourAppToken.length == 0) {
        [aiLogger error:@"Missing App Token."];
        return;
    }

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;

    aiAppToken         = yourAppToken;
    aiMacSha1          = macAddress.aiSha1;
    aiMacShortMd5      = macAddress.aiRemoveColons.aiMd5;
    aiIdForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    aiFbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;

    [self addNotificationObserver];
}

+ (void)trackEvent:(NSString *)eventToken {
    [self trackEvent:eventToken withParameters:nil];
}

// TODO: check eventToken format
+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters {
    NSMutableDictionary *eventPackage = [self eventPackageWithToken:eventToken parameters:parameters];
    [self trackEventPackage:eventPackage];
}

+ (void)trackRevenue:(float)amountInCents {
    [self trackRevenue:amountInCents forEvent:nil];
}

+ (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken {
    [self trackRevenue:amountInCents forEvent:eventToken withParameters:nil];
}

// TODO: don't allow zero amount
+ (void)trackRevenue:(float)amount forEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters {
    NSMutableDictionary *revenueEvent = [self eventPackageWithToken:eventToken parameters:parameters amount:amount];
    [self trackEventPackage:revenueEvent];
}

+ (void)setLogLevel:(AELogLevel)logLevel {
    aiLogger.logLevel = logLevel;
}

#pragma mark private

+ (void)initialize {
    if (aiLogger == nil) {
        aiLogger = [AELogger loggerWithTag:@"AdjustIo"];
    }
    if (aiApiClient == nil) {
        aiApiClient = [AIApiClient apiClientWithLogger:aiLogger];
    }
    [self startTimer];
}

+ (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center addObserver:self
               selector:@selector(trackSessionStart)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(trackSessionEnd)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(removeNotificationObserver)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
}

+ (void)removeNotificationObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}


+ (void)startTimer {
    if (aiTimer != nil) {
        [aiLogger verbose:@"timer was started already"];
    } else {
        [aiLogger verbose:@"starting timer"];
        aiTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
    }
}

+ (void)stopTimer {
    if (aiTimer == nil) {
        [aiLogger verbose:@"timer was stopped already"];
    } else {
        [aiLogger verbose:@"stopping timer"];
        [aiTimer invalidate];
        aiTimer = nil;
    }
}


+ (void)trackSessionStart {
    [self startTimer];

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDate *now = NSDate.date;

    int     sessionCount        = [defaults integerForKey:kKeySessionCount];
    int     subsessionCount     = [defaults integerForKey:kKeySubsessionCount];
    NSDate *lastSessionStart    = [defaults objectForKey:kKeyLastSessionStart];
    NSDate *lastSubsessionStart = [defaults objectForKey:kKeyLastSubsessionStart];
    NSDate *lastActivity        = [defaults objectForKey:kKeyLastActivity];
    double  timeSpent           = [defaults doubleForKey:kKeyTimeSpent];

    double  sessionLength = [lastActivity timeIntervalSinceDate:lastSessionStart];
    double  lastTimeSpent = [lastActivity timeIntervalSinceDate:lastSubsessionStart];
    double  lastInterval  = [now          timeIntervalSinceDate:lastActivity];

    timeSpent += lastTimeSpent;

    if (lastActivity == nil) { // new session without ancestors
        sessionCount = 1;

        NSMutableDictionary *sessionPackage    = [self sessionPackage];
        NSMutableDictionary *sessionParameters = [sessionPackage objectForKey:@"params"];
        [sessionParameters setObject:now           forKey:@"created_at"];
        [sessionParameters setInteger:sessionCount forKey:@"session_count"];
        [self enqueueTrackingPackage:sessionPackage];

        timeSpent = 0;
        subsessionCount = 1;
        lastSessionStart = now;

    } else if (lastInterval > kSessionInterval) { // new session
        sessionCount++;

        NSMutableDictionary *sessionPackage    = [self sessionPackage];
        NSMutableDictionary *sessionParameters = [sessionPackage objectForKey:@"params"];
        [sessionParameters setDate:now                     forKey:@"created_at"];
        [sessionParameters setInteger:sessionCount         forKey:@"session_id"];
        [sessionParameters setInteger:subsessionCount      forKey:@"subsession_count"];
        [sessionParameters setInteger:round(lastInterval)  forKey:@"last_interval"];
        [sessionParameters setInteger:round(sessionLength) forKey:@"session_length"];
        [sessionParameters setInteger:round(timeSpent)     forKey:@"time_spent"];
        [self enqueueTrackingPackage:sessionPackage];

        subsessionCount = 1;
        lastSessionStart = now;
        timeSpent = 0;

    } else { // new subsession
        subsessionCount++;

        [aiLogger verbose:@"subsession %d %f", subsessionCount, lastTimeSpent];
    }

    [defaults setInteger:sessionCount    forKey:kKeySessionCount];
    [defaults setInteger:subsessionCount forKey:kKeySubsessionCount];
    [defaults setObject:lastSessionStart forKey:kKeyLastSessionStart];
    [defaults setObject:now              forKey:kKeyLastSubsessionStart];
    [defaults setObject:now              forKey:kKeyLastActivity];
    [defaults setDouble:timeSpent        forKey:kKeyTimeSpent];
    [defaults synchronize];

    // NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
    //                                    aiAppToken,                 @"app_token",
    //                                    aiMacShortMd5,              @"mac",
    //                                    aiMacSha1,                  @"mac_sha1",
    //                                    aiIdForAdvertisers,         @"idfa",
    //                                    aiFbAttributionId,          @"fb_id",
    //                                    nil];
    // [aiApiClient postPath:@"/startup"
    //            parameters:parameters
    //               success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //                   [aiApiClient logSuccess:@"Tracked session."];
    //               }
    //               failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //                   [aiApiClient logFailure:@"Failed to track session." response:operation.responseString error:error];
    //               }];
}

+ (void)trackSessionEnd {
    [aiLogger verbose:@"session end updating last activity"];
    [NSUserDefaults.standardUserDefaults setObject:NSDate.date forKey:kKeyLastActivity];
    [NSUserDefaults.standardUserDefaults synchronize];
    [self stopTimer];
}

+ (void)trackEventPackage:(NSMutableDictionary *)eventPackage {
    [aiLogger debug:@"trackEvent"];

    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDate *now = NSDate.date;

    NSDate *lastSessionStart = [defaults objectForKey:kKeyLastSessionStart];
    double  sessionLength    = [now timeIntervalSinceDate:lastSessionStart];
    int     sessionCount     = [defaults integerForKey:kKeySessionCount];
    int     eventCount       = [defaults integerForKey:kKeyEventCount];

    eventCount++;

    NSMutableDictionary *eventParameters = [eventPackage objectForKey:@"params"];
    [eventParameters setInteger:eventCount    forKey:@"event_count"];
    [eventParameters setInteger:sessionCount  forKey:@"session_count"];
    [eventParameters setInteger:sessionLength forKey:@"session_length"];
    [self enqueueTrackingPackage:eventPackage];

    [defaults setInteger:eventCount forKey:kKeyEventCount];
    [defaults setObject:now         forKey:kKeyLastActivity];
    [defaults synchronize];

    return;

    // [aiApiClient postPath:@"/event" parameters:event
    //        successMessage:[NSString stringWithFormat:@"Tracked event %@.", eventToken]
    //        failureMessage:[NSString stringWithFormat:@"Failed to track event %@.", eventToken]];
    // [aiApiClient postPath:@"/revenue" parameters:revenueEvent
    //        successMessage:[NSString stringWithFormat:@"Tracked revenue (%.1f Cents).", amountInCents]
    //        failureMessage:[NSString stringWithFormat:@"Failed to track revenue (%.1f Cents).", amountInCents]];
}

+ (void)timerFired:(NSTimer *)timer {
    [aiLogger verbose:@"timer updating last activity"];
    [NSUserDefaults.standardUserDefaults setObject:NSDate.date forKey:kKeyLastActivity];
    [NSUserDefaults.standardUserDefaults synchronize];
}

+ (void)enqueueTrackingPackage:(NSDictionary *)package {
    // TODO: make calls asynchronously
    NSString *path           = [package objectForKey:@"path"];
    NSString *success        = [package objectForKey:@"success"];
    NSString *failure        = [package objectForKey:@"failure"];
    NSDictionary *parameters = [package objectForKey:@"params"];
    [aiApiClient postPath:path parameters:parameters successMessage:success failureMessage:failure];
}

+ (NSMutableDictionary *)sessionPackage {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:aiAppToken         forKey:@"app_token"];
    [parameters setObject:aiMacShortMd5      forKey:@"mac"]; // TODO: rename to mac_md5?
    [parameters setObject:aiIdForAdvertisers forKey:@"idfa"];
    [parameters setObject:aiMacSha1          forKey:@"mac_sha1"];
    [parameters setObject:aiFbAttributionId  forKey:@"fb_id"];

    NSString *success = @"Tracked session.";
    NSString *failure = @"Failed to track session.";

    NSMutableDictionary *sessionPackage = [NSMutableDictionary dictionary];
    [sessionPackage setObject:@"/startup" forKey:@"path"];
    [sessionPackage setObject:success     forKey:@"success"];
    [sessionPackage setObject:failure     forKey:@"failure"];
    [sessionPackage setObject:parameters  forKey:@"params"];

    return sessionPackage;
}

+ (NSMutableDictionary *)eventPackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)callbackParams {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:aiAppToken         forKey:@"app_token"];
    [parameters setObject:aiMacShortMd5      forKey:@"mac"];
    [parameters setObject:aiIdForAdvertisers forKey:@"idfa"];
    [parameters setObject:eventToken         forKey:@"event_id"];

    if (callbackParams != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParams options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    NSString *success = [NSString stringWithFormat:@"Tracked event: '%@'", eventToken];
    NSString *failure = [NSString stringWithFormat:@"Failed to track event: '%@'", eventToken];

    NSMutableDictionary *eventPackage = [NSMutableDictionary dictionary];
    [eventPackage setObject:@"/event"  forKey:@"path"];
    [eventPackage setObject:success    forKey:@"success"];
    [eventPackage setObject:failure    forKey:@"failure"];
    [eventPackage setObject:parameters forKey:@"params"];

    return eventPackage;
}

+ (NSMutableDictionary *)eventPackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)callbackParams amount:(float)amount {
    NSString *amountInMillis = [NSNumber numberWithInt:roundf(10 * amount)].stringValue;

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:aiAppToken         forKey:@"app_token"];
    [parameters setObject:aiMacShortMd5      forKey:@"mac"];
    [parameters setObject:aiIdForAdvertisers forKey:@"idfa"];
    [parameters setObject:amountInMillis     forKey:@"amount"];
    [parameters trySetObject:eventToken      forKey:@"event_id"];

    if (callbackParams != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParams options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    NSString *success = [NSString stringWithFormat:@"Tracked revenue: %.1f Cent", amount];
    NSString *failure = [NSString stringWithFormat:@"Failed to track revenue: %.1f Cent", amount];

    if (eventToken != nil) {
        NSString *eventString = [NSString stringWithFormat:@" (event: '%@')", eventToken];
        success = [success stringByAppendingString:eventString];
        failure = [failure stringByAppendingString:eventString];
    }

    NSMutableDictionary *eventPackage = [NSMutableDictionary dictionary];
    [eventPackage setObject:@"/event"  forKey:@"path"];
    [eventPackage setObject:success    forKey:@"success"];
    [eventPackage setObject:failure    forKey:@"failure"];
    [eventPackage setObject:parameters forKey:@"params"];

    return eventPackage;
}

@end

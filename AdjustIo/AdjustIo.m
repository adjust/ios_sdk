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


static const double kTimerInterval   = 5.0; // TODO: 60 seconds
static const double kSessionInterval = 1.0; // TODO: 30 minutes

static NSString * const kKeyLastActivity        = @"lastactivity"; // TODO: rename
static NSString * const kKeyLastSessionStart    = @"lastsessionstart";
static NSString * const kKeyLastSubsessionStart = @"lastsubsessionstart";
static NSString * const kKeySessionCount        = @"sessioncount";
static NSString * const kKeySubsessionCount     = @"subsessioncount";
static NSString * const kKeyTimeSpent           = @"timespent";
static NSString * const kKeyEventCount          = @"eventcount";
static NSString * const kKeyPackageQueue        = @"packagequeue";

static AIApiClient *aiApiClient  = nil;
static AELogger    *aiLogger     = nil;
static NSTimer     *aiTimer      = nil;
static NSLock      *trackingLock = nil;
static NSLock      *defaultsLock = nil;

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
+ (void)timerFired:(NSTimer *)timer;

+ (void)trackSessionStart;
+ (void)trackSessionEnd;
+ (void)trackEventPackage:(NSMutableDictionary *)event;

+ (void)handleFirstSession;
+ (void)handleNewSession;
+ (void)handleNewSubsession;

+ (void)enqueueTrackingPackage:(NSDictionary *)package;
+ (void)trackFirstPackage;
+ (void)removeFirstPackage:(NSDictionary *)package;
+ (void)trackingPackageSucceeded:(NSDictionary *)package;
+ (void)trackingPackageFailed:(NSDictionary *)package response:(NSString *)response error:(NSError *)error;

+ (NSMutableDictionary *)sessionPackage;
+ (NSMutableDictionary *)eventPackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)parameters;
+ (NSMutableDictionary *)revenuePackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)parameters amount:(float)amount;

@end


#pragma mark AdjustIo
@implementation AdjustIo

#pragma mark public

+ (void)appDidLaunch:(NSString *)yourAppToken {
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
// TODO: check appToken (is nil if appDidLaunch not called)
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
    NSMutableDictionary *revenueEvent = [self revenuePackageWithToken:eventToken parameters:parameters amount:amount];
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
    if (trackingLock == nil) {
        trackingLock = [[NSLock alloc] init];
    }
    if (defaultsLock == nil) {
        defaultsLock = [[NSLock alloc] init];
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
        [aiLogger verbose:@"Timer was started already."];
    } else {
        [aiLogger verbose:@"Starting timer."];
        aiTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                   target:self
                                                 selector:@selector(timerFired:)
                                                 userInfo:nil
                                                  repeats:YES];
    }
}

+ (void)stopTimer {
    if (aiTimer == nil) {
        [aiLogger verbose:@"Timer was stopped already."];
    } else {
        [aiLogger verbose:@"Stopping timer."];
        [aiTimer invalidate];
        aiTimer = nil;
    }
}

+ (void)timerFired:(NSTimer *)timer {
    [aiLogger verbose:@"Timer updating last activity."];

    [defaultsLock lock];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:NSDate.date forKey:kKeyLastActivity];
    [defaults synchronize];
    [defaultsLock unlock];
    [self trackFirstPackage];
}

+ (void)trackSessionEnd {
    [aiLogger verbose:@"Session end updating last activity."];

    [defaultsLock lock];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:NSDate.date forKey:kKeyLastActivity];
    [defaults synchronize];
    [defaultsLock unlock];
    [self stopTimer];
}

+ (void)trackSessionStart {
    [self startTimer];

    [defaultsLock lock];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDate *lastActivity     = [defaults objectForKey:kKeyLastActivity];

    if (lastActivity == nil) {
        [self handleFirstSession];
        [defaults synchronize];
        [defaultsLock unlock];
        [self trackFirstPackage];
        return;
    }

    NSDate *now = NSDate.date;
    double lastInterval = [now timeIntervalSinceDate:lastActivity];
    if (lastInterval > kSessionInterval) {
        [self handleNewSession];
        [defaults synchronize];
        [defaultsLock unlock];
        [self trackFirstPackage];
        return;

    } else {
        [self handleNewSubsession];
        [defaults synchronize];
        [defaultsLock unlock];
        return;
    }
}


+ (void)trackEventPackage:(NSMutableDictionary *)eventPackage {
    NSDate *now = NSDate.date;

    [defaultsLock lock];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
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
    [defaultsLock unlock];

    [self trackFirstPackage];
}

+ (void)handleFirstSession {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDate *now = NSDate.date;

    NSMutableDictionary *sessionPackage    = [self sessionPackage];
    NSMutableDictionary *sessionParameters = [sessionPackage objectForKey:@"params"];
    [sessionParameters setObject:now forKey:@"created_at"];
    [sessionParameters setInteger:1  forKey:@"session_count"];
    [self enqueueTrackingPackage:sessionPackage];

    [defaults setInteger:1  forKey:kKeySessionCount];
    [defaults setInteger:1  forKey:kKeySubsessionCount];
    [defaults setObject:now forKey:kKeyLastSessionStart];
    [defaults setObject:now forKey:kKeyLastSubsessionStart];
    [defaults setObject:now forKey:kKeyLastActivity];
    [defaults setDouble:0   forKey:kKeyTimeSpent];
}

+ (void)handleNewSession {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDate *now = NSDate.date;

    int     sessionCount        = [defaults integerForKey:kKeySessionCount] + 1;
    int     subsessionCount     = [defaults integerForKey:kKeySubsessionCount];
    NSDate *lastSessionStart    = [defaults objectForKey:kKeyLastSessionStart];
    NSDate *lastSubsessionStart = [defaults objectForKey:kKeyLastSubsessionStart];
    NSDate *lastActivity        = [defaults objectForKey:kKeyLastActivity];
    double  timeSpent           = [defaults doubleForKey:kKeyTimeSpent];
    double  sessionLength       = [lastActivity timeIntervalSinceDate:lastSessionStart];
    double  lastTimeSpent       = [lastActivity timeIntervalSinceDate:lastSubsessionStart];
    double  lastInterval        = [now timeIntervalSinceDate:lastActivity];

    timeSpent += lastTimeSpent;

    NSMutableDictionary *sessionPackage    = [self sessionPackage];
    NSMutableDictionary *sessionParameters = [sessionPackage objectForKey:@"params"];
    [sessionParameters setDate:now                     forKey:@"created_at"];
    [sessionParameters setInteger:sessionCount         forKey:@"session_id"];
    [sessionParameters setInteger:subsessionCount      forKey:@"subsession_count"];
    [sessionParameters setInteger:round(lastInterval)  forKey:@"last_interval"];
    [sessionParameters setInteger:round(sessionLength) forKey:@"session_length"];
    [sessionParameters setInteger:round(timeSpent)     forKey:@"time_spent"];
    [self enqueueTrackingPackage:sessionPackage];

    [defaults setInteger:sessionCount forKey:kKeySessionCount];
    [defaults setInteger:1            forKey:kKeySubsessionCount];
    [defaults setObject:now           forKey:kKeyLastSessionStart];
    [defaults setObject:now           forKey:kKeyLastSubsessionStart];
    [defaults setObject:now           forKey:kKeyLastActivity];
    [defaults setDouble:0             forKey:kKeyTimeSpent];
}

+ (void)handleNewSubsession {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSDate *now = NSDate.date;

    int     subsessionCount     = [defaults integerForKey:kKeySubsessionCount] + 1;
    NSDate *lastSubsessionStart = [defaults objectForKey:kKeyLastSubsessionStart];
    NSDate *lastActivity        = [defaults objectForKey:kKeyLastActivity];
    double  timeSpent           = [defaults doubleForKey:kKeyTimeSpent];

    double lastTimeSpent = [lastActivity timeIntervalSinceDate:lastSubsessionStart];
    timeSpent += lastTimeSpent;

    [defaults setInteger:subsessionCount forKey:kKeySubsessionCount];
    [defaults setObject:now              forKey:kKeyLastSubsessionStart];
    [defaults setObject:now              forKey:kKeyLastActivity];
    [defaults setDouble:timeSpent        forKey:kKeyTimeSpent];

    [aiLogger verbose:@"Subsession %d adds time spent %f.", subsessionCount, lastTimeSpent];
}

// TODO: in background?
+ (void)enqueueTrackingPackage:(NSDictionary *)package {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray *packageQueue = [defaults objectForKey:kKeyPackageQueue];

    NSMutableArray *mutableQueue;
    if (packageQueue != nil) {
        mutableQueue = [NSMutableArray arrayWithArray:packageQueue];
    } else {
        mutableQueue = [NSMutableArray array];
    }

    [mutableQueue addObject:package];
    [defaults setObject:mutableQueue forKey:kKeyPackageQueue];

    NSString *kind = [package objectForKey:@"kind"];
    int packageCount = mutableQueue.count;
    if (packageCount > 1) {
        [aiLogger debug:@"Added %@ package to tracking queue at position %d.", kind, packageCount];
    } else {
        [aiLogger debug:@"Added %@ package to tracking queue.", kind];
    }
}

+ (void)trackFirstPackage {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray *packageQueue = [defaults objectForKey:kKeyPackageQueue];
    if (packageQueue == nil || packageQueue.count == 0) {
        return;
    }

    if (![trackingLock tryLock]) {
        return;
    }

    NSDictionary *package = [packageQueue objectAtIndex:0];
    NSString     *path    = [package objectForKey:@"path"];
    NSDictionary *params  = [package objectForKey:@"params"];

    void (^success)(AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        [self trackingPackageSucceeded:package];
    };

    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self trackingPackageFailed:package response:operation.responseString error:error];
    };

    [aiApiClient postPath:path parameters:params success:success failure:failure];
}

// TODO: in background?
+ (void)removeFirstPackage:(NSDictionary *)package {
    [defaultsLock lock];
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray *packageQueue = [defaults objectForKey:kKeyPackageQueue];
    NSMutableArray *mutableQueue = [NSMutableArray arrayWithArray:packageQueue];
    [mutableQueue removeObjectAtIndex:0];
    [defaults setObject:mutableQueue forKey:kKeyPackageQueue];
    [defaults synchronize];
    [defaultsLock unlock];
}

+ (void)trackingPackageSucceeded:(NSDictionary *)package {
    NSString     *kind   = [package objectForKey:@"kind"];
    NSString     *suffix = [package objectForKey:@"suffix"];
    NSDictionary *params = [package objectForKey:@"params"];

    [aiLogger info:@"Tracked %@%@", kind, suffix];
    [aiLogger verbose:@"Request parameters: %@", params];

    [self removeFirstPackage:package];
    [trackingLock unlock];
    [self trackFirstPackage];
}

+ (void)trackingPackageFailed:(NSDictionary *)package response:(NSString *)response error:(NSError *)error {
    NSString *kind    = [package objectForKey:@"kind"];
    NSString *suffix  = [package objectForKey:@"suffix"];
    NSString *message = [NSString stringWithFormat:@"Failed to track %@%@", kind, suffix];

    if (response == nil || response.length == 0) {
        [trackingLock unlock];
        [aiLogger debug:@"%@ (%@ Will retry later)", message, error.localizedDescription];
        return;
    }

    NSDictionary *params = [package objectForKey:@"params"];
    [aiLogger warn:@"%@ (%@)", message, response.aiTrim];
    [aiLogger verbose:@"Request parameters: %@", params];

    [self removeFirstPackage:package];
    [trackingLock unlock];
    [self trackFirstPackage];
}

+ (NSMutableDictionary *)sessionPackage {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:aiAppToken         forKey:@"app_token"];
    [params setObject:aiMacShortMd5      forKey:@"mac"]; // TODO: rename to mac_md5?
    [params setObject:aiIdForAdvertisers forKey:@"idfa"];
    [params setObject:aiMacSha1          forKey:@"mac_sha1"];
    [params setObject:aiFbAttributionId  forKey:@"fb_id"];

    NSMutableDictionary *sessionPackage = [NSMutableDictionary dictionary];
    [sessionPackage setObject:@"/startup" forKey:@"path"];
    [sessionPackage setObject:@"session"  forKey:@"kind"];
    [sessionPackage setObject:@"."        forKey:@"suffix"];
    [sessionPackage setObject:params      forKey:@"params"];

    return sessionPackage;
}

+ (NSMutableDictionary *)eventPackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)callbackParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:aiAppToken         forKey:@"app_token"];
    [params setObject:aiMacShortMd5      forKey:@"mac"];
    [params setObject:aiIdForAdvertisers forKey:@"idfa"];
    [params setObject:eventToken         forKey:@"event_id"];

    if (callbackParams != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParams options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [params setValue:paramString forKey:@"params"];
    }

    NSString *suffix = [NSString stringWithFormat:@" '%@'.", eventToken];
    NSMutableDictionary *eventPackage = [NSMutableDictionary dictionary];
    [eventPackage setObject:@"/event"  forKey:@"path"];
    [eventPackage setObject:@"event"   forKey:@"kind"];
    [eventPackage setObject:suffix     forKey:@"suffix"];
    [eventPackage setObject:params     forKey:@"params"];

    return eventPackage;
}

+ (NSMutableDictionary *)revenuePackageWithToken:(NSString *)eventToken parameters:(NSDictionary *)callbackParams amount:(float)amount {
    NSString *amountInMillis = [NSNumber numberWithInt:roundf(10 * amount)].stringValue;

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:aiAppToken         forKey:@"app_token"];
    [params setObject:aiMacShortMd5      forKey:@"mac"];
    [params setObject:aiIdForAdvertisers forKey:@"idfa"];
    [params setObject:amountInMillis     forKey:@"amount"];
    [params trySetObject:eventToken      forKey:@"event_id"];

    if (callbackParams != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParams options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [params setValue:paramString forKey:@"params"];
    }

    NSString *suffix = [NSString stringWithFormat:@": %.1f Cent", amount];

    if (eventToken != nil) {
        suffix = [NSString stringWithFormat:@"%@ (event '%@')", suffix, eventToken];
    }

    NSMutableDictionary *eventPackage = [NSMutableDictionary dictionary];
    [eventPackage setObject:@"/revenue" forKey:@"path"];
    [eventPackage setObject:@"revenue"  forKey:@"kind"];
    [eventPackage setObject:suffix      forKey:@"suffix"];
    [eventPackage setObject:params      forKey:@"params"];

    return eventPackage;
}

@end

//
//  AESessionHandler.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 01.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AESessionHandler.h"
#import "AESessionState.h"
#import "AELogger.h"
#import "AETimer.h"

#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"

static NSString * const kSessionStateFilename = @"sessionstate7"; // TODO: rename

static const uint64_t kTimerInterval     = 3 * NSEC_PER_SEC; // TODO: 60 seconds
static const uint64_t kTimerLeeway       = 0 * NSEC_PER_SEC; // TODO: 1 second
static const double   kSessionInterval    = 5; // 5 seconds, TODO: 30 minutes
static const double   kSubsessionInterval = 1; // 1 second

#pragma mark private interface

@interface AESessionHandler() {
    dispatch_queue_t  sessionQueue;
    AESessionState *sessionState;
    AETimer *timer;

    NSString *appToken;
    NSString *macSha1;
    NSString *macShortMd5;
    NSString *idForAdvertisers;
    NSString *fbAttributionId;
    NSString *userAgent;
}

- (void)startInternal;
- (void)endInternal;

- (void)eventInternal:(NSString *)eventToken
           parameters:(NSDictionary *)parameters;

- (void)revenueInternal:(float)amount
                  event:(NSString *)eventToken
             parameters:(NSDictionary *)parameters;

- (void)updateSessionState;
- (void)readSessionState;
- (void)writeSessionState;
- (void)enqueueSessionPackage;

- (void)startTimer;
- (void)stopTimer;
- (void)timerFired;

- (void)addNotificationObserver;
- (void)removeNotificationObserver;

- (NSString *)sessionStateFilename;

+ (BOOL)checkSessionState:(AESessionState *)sessionState;
+ (BOOL)checkAppTokenNotNil:(NSString *)appToken;
+ (BOOL)checkAppTokenLength:(NSString *)appToken;
+ (BOOL)checkEventTokenNotNil:(NSString *)eventToken;
+ (BOOL)checkAmount:(float)amount;

@end


@implementation AESessionHandler

#pragma mark public implementation

+ (AESessionHandler *)contextWithAppToken:(NSString *)appToken {
    return [[AESessionHandler alloc] initWithAppToken:appToken];
}

- (id)initWithAppToken:(NSString *)yourAppToken {
    self = [super init];
    if (self == nil) return nil;

    [self addNotificationObserver];
    sessionQueue = dispatch_queue_create("io.adjust.sessiontest", DISPATCH_QUEUE_SERIAL);

    dispatch_async(sessionQueue, ^{
        [self initInternal:yourAppToken];
    });

    return self;
}

- (void)trackSubsessionStart {
    dispatch_async(sessionQueue, ^{
        [self startInternal];
    });
}

- (void)trackSubsessionEnd {
    dispatch_async(sessionQueue, ^{
        [self endInternal];
    });
}

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters
{
    dispatch_async(sessionQueue, ^{
        [self eventInternal:eventToken parameters:parameters];
    });
}

- (void)trackRevenue:(float)amount
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters
{
    dispatch_async(sessionQueue, ^{
        [self revenueInternal:amount event:eventToken parameters:parameters];
    });
}


#pragma mark private implementation

// internal methods run asynchronously

- (void)initInternal:(NSString *)yourAppToken {
    if (![self.class checkAppTokenNotNil:yourAppToken]) return;
    if (![self.class checkAppTokenLength:yourAppToken]) return;

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;

    appToken         = yourAppToken;
    macSha1          = macAddress.aiSha1;
    macShortMd5      = macAddress.aiRemoveColons.aiMd5;
    idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    fbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;

    [self readSessionState];
}

- (void)startInternal {
    if (![self.class checkAppTokenNotNil:appToken]) return;

    [self startTimer];

    double now = [NSDate.date timeIntervalSince1970];

    if (sessionState == nil) {
        [AELogger info:@"First session"];
        sessionState = [[AESessionState alloc] init];
        sessionState.sessionCount = 1; // this is the first session
        sessionState.createdAt = now;  // starting now

        [self enqueueSessionPackage];
        [self writeSessionState];
        return;
    }

    double lastInterval = now - sessionState.lastActivity;
    if (lastInterval < 0) {
        [AELogger error:@"Time travel!"];
        sessionState.lastActivity = now;
        [self writeSessionState];
        return;
    }

    // new session
    if (lastInterval > kSessionInterval) {
        sessionState.lastInterval = lastInterval;
        [self enqueueSessionPackage];
        [sessionState startNextSession:now];
        [self writeSessionState];
        return;
    }

    // new subsession
    if (lastInterval > kSubsessionInterval) {
        sessionState.subsessionCount++;
    }
    sessionState.sessionLength += lastInterval;
    sessionState.lastActivity = now;
    [self writeSessionState];
}

- (void)endInternal {
    if (![self.class checkAppTokenNotNil:appToken]) return;

    [self stopTimer];
    [self updateSessionState];
    [self writeSessionState];
}

- (void)eventInternal:(NSString *)eventToken
           parameters:(NSDictionary *)parameters
{
    if (![self.class checkAppTokenNotNil:appToken]) return;
    if (![self.class checkSessionState:sessionState]) return;

    [NSThread sleepForTimeInterval:0.5];
    NSLog(@"event");
}

- (void)revenueInternal:(float)amount
                  event:(NSString *)eventToken
             parameters:(NSDictionary *)parameters
{
    if (![self.class checkAppTokenNotNil:appToken]) return;
    if (![self.class checkSessionState:sessionState]) return;

    NSLog(@"revenue");
}

- (void)updateSessionState {
    if (![self.class checkSessionState:sessionState]) return;

    double now = [NSDate.date timeIntervalSince1970];
    double lastInterval = now - sessionState.lastActivity;
    if (lastInterval < 0) {
        [AELogger error:@"Time travel!"];
        sessionState.lastInterval = now;
        return;
    }

    // ignore late updates
    if (lastInterval > kSessionInterval) return;

    sessionState.sessionLength += lastInterval;
    sessionState.timeSpent += lastInterval;
    sessionState.lastActivity = now;
}

- (void)readSessionState {
    NSString *filename = [self sessionStateFilename];
    id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
    if ([object isKindOfClass:[AESessionState class]]) {
        sessionState = object;
        NSLog(@"Read session state: %@", sessionState);
    } else {
        NSLog(@"Failed to read session state");
    }
}

- (void)writeSessionState {
    NSString *filename = [self sessionStateFilename];
    BOOL result = [NSKeyedArchiver archiveRootObject:sessionState toFile:filename];
    if (result == YES) {
        NSLog(@"Wrote session state: %@", sessionState);
    } else {
        NSLog(@"Failed to write session state");
    }
}

- (void)enqueueSessionPackage {
    // TODO:
}

- (void)startTimer {
    NSLog(@"startTimer");
    if (timer == nil) {
        timer = [AETimer timerWithInterval:kTimerInterval
                                    leeway:kTimerLeeway
                                     queue:sessionQueue
                                     block:^{ [self timerFired]; }];
    }
    [timer resume];
}

- (void)stopTimer {
    [timer suspend];
}

- (void)timerFired {
    // [queueHandler trackFirstPackage]; // TODO: enable
    [self updateSessionState];
    [self writeSessionState];
}

- (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center removeObserver:self];
    [center addObserver:self
               selector:@selector(trackSubsessionStart)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(trackSubsessionEnd)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(removeNotificationObserver)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
}

- (void)removeNotificationObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (NSString *)sessionStateFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:kSessionStateFilename];
    return filename;
}

+ (BOOL)checkSessionState:(AESessionState *)sessionState {
    if (sessionState == nil) {
        [AELogger error:@"Missing session state."];
        return NO;
    }
    return YES;
}

+ (BOOL)checkAppTokenNotNil:(NSString *)appToken {
    if (appToken == nil) {
        [AELogger error:@"Missing App Token."];
        return NO;
    }
    return YES;
}

+ (BOOL)checkAppTokenLength:(NSString *)appToken {
    if (appToken.length != 12) {
        [AELogger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

+ (BOOL)checkEventTokenNotNil:(NSString *)eventToken {
    if (eventToken == nil) {
        [AELogger error:@"Missing Event Token"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkEventTokenLength:(NSString *)eventToken {
    if (eventToken == nil) {
        return YES;
    }
    if (eventToken.length != 6) {
        [AELogger error:@"Malformed Event Token '%@'", eventToken];
        return NO;
    }
    return YES;
}

+ (BOOL)checkAmount:(float)amount {
    if (amount <= 0.0f) {
        [AELogger error:@"Invalid amount %.1f", amount];
        return NO;
    }
    return YES;
}

@end

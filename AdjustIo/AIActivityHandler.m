//
//  AIActivityHandler.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 01.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIActivityHandler.h"
#import "AIActivityState.h"
#import "AIPackageBuilder.h"
#import "AIPackageHandler.h"
#import "AILogger.h"
#import "AITimer.h"

#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"

static NSString * const kActivityStateFilename = @"ActivityState1"; // TODO: rename
static const char * const kInternalQueueName = "io.adjust.ActivityQueue"; // TODO: rename

static const uint64_t kTimerInterval      = 3 * NSEC_PER_SEC; // TODO: 60 seconds
static const uint64_t kTimerLeeway        = 1 * NSEC_PER_SEC; // TODO: 1 second
static const double   kSessionInterval    = 5; // 5 seconds, TODO: 30 minutes
static const double   kSubsessionInterval = 1; // 1 second

#pragma mark private interface

// TODO: use private properties everywhere!
@interface AIActivityHandler() {
    dispatch_queue_t internalQueue;
    AIPackageHandler *packageHandler;
    AIActivityState *activityState;
    AITimer *timer;

    // TODO: should these be properties?
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

- (void)updateActivityState;
- (void)readActivityState;
- (void)writeActivityState;
- (void)transferSessionPackage;

- (void)startTimer;
- (void)stopTimer;
- (void)timerFired;

- (void)addNotificationObserver;
- (void)removeNotificationObserver;

- (NSString *)activityStateFilename;

+ (BOOL)checkActivityState:(AIActivityState *)activityState;
+ (BOOL)checkAppTokenNotNil:(NSString *)appToken;
+ (BOOL)checkAppTokenLength:(NSString *)appToken;
+ (BOOL)checkEventTokenNotNil:(NSString *)eventToken;
+ (BOOL)checkAmount:(float)amount;

@end


@implementation AIActivityHandler

#pragma mark public implementation

+ (AIActivityHandler *)handlerWithAppToken:(NSString *)appToken {
    return [[AIActivityHandler alloc] initWithAppToken:appToken];
}

- (id)initWithAppToken:(NSString *)yourAppToken {
    self = [super init];
    if (self == nil) return nil;

    [self addNotificationObserver];
    internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    dispatch_async(internalQueue, ^{
        [self initInternal:yourAppToken];
    });

    return self;
}

- (void)trackSubsessionStart {
    dispatch_async(internalQueue, ^{
        [self startInternal];
    });
}

- (void)trackSubsessionEnd {
    dispatch_async(internalQueue, ^{
        [self endInternal];
    });
}

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters
{
    dispatch_async(internalQueue, ^{
        [self eventInternal:eventToken parameters:parameters];
    });
}

- (void)trackRevenue:(float)amount
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters
{
    dispatch_async(internalQueue, ^{
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

    packageHandler = [[AIPackageHandler alloc] init];
    [self readActivityState];
}

- (void)startInternal {
    if (![self.class checkAppTokenNotNil:appToken]) return;

    [self startTimer];

    double now = [NSDate.date timeIntervalSince1970];

    if (activityState == nil) {
        [AILogger info:@"First session"];
        activityState = [[AIActivityState alloc] init];
        activityState.sessionCount = 1; // this is the first session
        activityState.createdAt = now;  // starting now

        [self transferSessionPackage];
        [self writeActivityState];
        return;
    }

    double lastInterval = now - activityState.lastActivity;
    if (lastInterval < 0) {
        [AILogger error:@"Time travel!"];
        activityState.lastActivity = now;
        [self writeActivityState];
        return;
    }

    // new session
    if (lastInterval > kSessionInterval) {
        activityState.lastInterval = lastInterval;
        [self transferSessionPackage];
        [activityState startNextSession:now];
        [self writeActivityState];
        return;
    }

    // new subsession
    if (lastInterval > kSubsessionInterval) {
        activityState.subsessionCount++;
    }
    activityState.sessionLength += lastInterval;
    activityState.lastActivity = now;
    [self writeActivityState];
}

- (void)endInternal {
    if (![self.class checkAppTokenNotNil:appToken]) return;

    [self stopTimer];
    [self updateActivityState];
    [self writeActivityState];
}

- (void)eventInternal:(NSString *)eventToken
           parameters:(NSDictionary *)parameters
{
    if (![self.class checkAppTokenNotNil:appToken]) return;
    if (![self.class checkActivityState:activityState]) return;
    if (![self.class checkEventTokenNotNil:eventToken]) return;
    if (![self.class checkEventTokenLength:eventToken]) return;

    AIPackageBuilder *eventBuilder = [[AIPackageBuilder alloc] init];
    eventBuilder.eventToken = eventToken;
    eventBuilder.callbackParameters = parameters;

    activityState.eventCount++;
    [self updateActivityState];
    [self injectGeneralAttributes:eventBuilder];
    [activityState injectEventAttributes:eventBuilder];

    AIActivityPackage *eventPackage = [eventBuilder buildEventPackage];
    [packageHandler addPackage:eventPackage];

    [self writeActivityState];
}

- (void)revenueInternal:(float)amount
                  event:(NSString *)eventToken
             parameters:(NSDictionary *)parameters
{
    if (![self.class checkAppTokenNotNil:appToken]) return;
    if (![self.class checkActivityState:activityState]) return;
    if (![self.class checkAmount:amount]) return;
    if (![self.class checkEventTokenLength:eventToken]) return;

    AIPackageBuilder *revenueBuilder = [[AIPackageBuilder alloc] init];
    revenueBuilder.amountInCents = amount;
    revenueBuilder.eventToken = eventToken;
    revenueBuilder.callbackParameters = parameters;

    activityState.eventCount++;
    [self updateActivityState];
    [self injectGeneralAttributes:revenueBuilder];
    [activityState injectEventAttributes:revenueBuilder];

    AIActivityPackage *revenuePackage = [revenueBuilder buildRevenuePackage];
    [packageHandler addPackage:revenuePackage];

    [self writeActivityState];
}

- (void)updateActivityState {
    if (![self.class checkActivityState:activityState]) return;

    double now = [NSDate.date timeIntervalSince1970];
    double lastInterval = now - activityState.lastActivity;
    if (lastInterval < 0) {
        [AILogger error:@"Time travel!"];
        activityState.lastInterval = now;
        return;
    }

    // ignore late updates
    if (lastInterval > kSessionInterval) return;

    activityState.sessionLength += lastInterval;
    activityState.timeSpent += lastInterval;
    activityState.lastActivity = now;
}

- (void)readActivityState {
    @try {
        NSString *filename = [self activityStateFilename];
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if ([object isKindOfClass:[AIActivityState class]]) {
            activityState = object;
            NSLog(@"Read activity state: %@", activityState);
            return;
        } else {
            NSLog(@"Failed to read activity state");
        }
    } @catch (NSException *ex ) {
        NSLog(@"Failed to read activity state (%@)", ex);
    }

    // start with a fresh activity state in case of any exception
    activityState = nil;
}

- (void)writeActivityState {
    [NSThread sleepForTimeInterval:0.3]; // TODO: remove

    NSString *filename = [self activityStateFilename];
    BOOL result = [NSKeyedArchiver archiveRootObject:activityState toFile:filename];
    if (result == YES) {
        NSLog(@"Wrote activity state: %@", activityState);
    } else {
        NSLog(@"Failed to write activity state");
    }
}

- (void)transferSessionPackage {
    AIPackageBuilder *sessionBuilder = [[AIPackageBuilder alloc] init];
    [self injectGeneralAttributes:sessionBuilder];
    [activityState injectSessionAttributes:sessionBuilder];
    AIActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage];
    [packageHandler addPackage:sessionPackage];
}

- (void)injectGeneralAttributes:(AIPackageBuilder *)builder {
    builder.userAgent = userAgent;
    builder.appToken = appToken;
    builder.macShortMd5 = macShortMd5;
    builder.macSha1 = macSha1;
    builder.idForAdvertisers = idForAdvertisers;
    builder.attributionId = fbAttributionId;
}

- (void)startTimer {
    NSLog(@"startTimer");
    if (timer == nil) {
        timer = [AITimer timerWithInterval:kTimerInterval
                                    leeway:kTimerLeeway
                                     queue:internalQueue
                                     block:^{ [self timerFired]; }];
    }
    [timer resume];
}

- (void)stopTimer {
    [timer suspend];
}

- (void)timerFired {
    [packageHandler sendFirstPackage];
    [self updateActivityState];
    [self writeActivityState];
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

- (NSString *)activityStateFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:kActivityStateFilename];
    return filename;
}

+ (BOOL)checkActivityState:(AIActivityState *)activityState {
    if (activityState == nil) {
        [AILogger error:@"Missing activity state."];
        return NO;
    }
    return YES;
}

+ (BOOL)checkAppTokenNotNil:(NSString *)appToken {
    if (appToken == nil) {
        [AILogger error:@"Missing App Token."];
        return NO;
    }
    return YES;
}

+ (BOOL)checkAppTokenLength:(NSString *)appToken {
    if (appToken.length != 12) {
        [AILogger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

+ (BOOL)checkEventTokenNotNil:(NSString *)eventToken {
    if (eventToken == nil) {
        [AILogger error:@"Missing Event Token"];
        return NO;
    }
    return YES;
}

+ (BOOL)checkEventTokenLength:(NSString *)eventToken {
    if (eventToken == nil) {
        return YES;
    }
    if (eventToken.length != 6) {
        [AILogger error:@"Malformed Event Token '%@'", eventToken];
        return NO;
    }
    return YES;
}

+ (BOOL)checkAmount:(float)amount {
    if (amount <= 0.0f) {
        [AILogger error:@"Invalid amount %.1f", amount];
        return NO;
    }
    return YES;
}

@end

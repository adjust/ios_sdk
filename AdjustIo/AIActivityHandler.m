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

@interface AIActivityHandler()

@property (nonatomic, retain) dispatch_queue_t internalQueue;
@property (nonatomic, retain) AIPackageHandler *packageHandler;
@property (nonatomic, retain) AIActivityState *activityState;
@property (nonatomic, retain) AITimer *timer;

@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, copy) NSString *macSha1;
@property (nonatomic, copy) NSString *macShortMd5;
@property (nonatomic, copy) NSString *idForAdvertisers;
@property (nonatomic, copy) NSString *fbAttributionId;
@property (nonatomic, copy) NSString *userAgent;

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
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    dispatch_async(self.internalQueue, ^{
        [self initInternal:yourAppToken];
    });

    return self;
}

- (void)trackSubsessionStart {
    dispatch_async(self.internalQueue, ^{
        [self startInternal];
    });
}

- (void)trackSubsessionEnd {
    dispatch_async(self.internalQueue, ^{
        [self endInternal];
    });
}

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters
{
    dispatch_async(self.internalQueue, ^{
        [self eventInternal:eventToken parameters:parameters];
    });
}

- (void)trackRevenue:(float)amount
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters
{
    dispatch_async(self.internalQueue, ^{
        [self revenueInternal:amount event:eventToken parameters:parameters];
    });
}


#pragma mark private implementation

// internal methods run asynchronously

- (void)initInternal:(NSString *)yourAppToken {
    if (![self.class checkAppTokenNotNil:yourAppToken]) return;
    if (![self.class checkAppTokenLength:yourAppToken]) return;

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;

    self.appToken         = yourAppToken;
    self.macSha1          = macAddress.aiSha1;
    self.macShortMd5      = macAddress.aiRemoveColons.aiMd5;
    self.idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    self.fbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;

    self.packageHandler = [[AIPackageHandler alloc] init];
    [self readActivityState];
}

- (void)startInternal {
    if (![self.class checkAppTokenNotNil:self.appToken]) return;

    [self startTimer];

    double now = [NSDate.date timeIntervalSince1970];

    if (self.activityState == nil) {
        [AILogger info:@"First session"];
        self.activityState = [[AIActivityState alloc] init];
        self.activityState.sessionCount = 1; // this is the first session
        self.activityState.createdAt = now;  // starting now

        [self transferSessionPackage];
        [self writeActivityState];
        return;
    }

    double lastInterval = now - self.activityState.lastActivity;
    if (lastInterval < 0) {
        [AILogger error:@"Time travel!"];
        self.activityState.lastActivity = now;
        [self writeActivityState];
        return;
    }

    // new session
    if (lastInterval > kSessionInterval) {
        self.activityState.lastInterval = lastInterval;
        [self transferSessionPackage];
        [self.activityState startNextSession:now];
        [self writeActivityState];
        return;
    }

    // new subsession
    if (lastInterval > kSubsessionInterval) {
        self.activityState.subsessionCount++;
    }
    self.activityState.sessionLength += lastInterval;
    self.activityState.lastActivity = now;
    [self writeActivityState];
}

- (void)endInternal {
    if (![self.class checkAppTokenNotNil:self.appToken]) return;

    [self stopTimer];
    [self updateActivityState];
    [self writeActivityState];
}

- (void)eventInternal:(NSString *)eventToken
           parameters:(NSDictionary *)parameters
{
    if (![self.class checkAppTokenNotNil:self.appToken]) return;
    if (![self.class checkActivityState:self.activityState]) return;
    if (![self.class checkEventTokenNotNil:eventToken]) return;
    if (![self.class checkEventTokenLength:eventToken]) return;

    AIPackageBuilder *eventBuilder = [[AIPackageBuilder alloc] init];
    eventBuilder.eventToken = eventToken;
    eventBuilder.callbackParameters = parameters;

    self.activityState.eventCount++;
    [self updateActivityState];
    [self injectGeneralAttributes:eventBuilder];
    [self.activityState injectEventAttributes:eventBuilder];

    AIActivityPackage *eventPackage = [eventBuilder buildEventPackage];
    [self.packageHandler addPackage:eventPackage];

    [self writeActivityState];
}

- (void)revenueInternal:(float)amount
                  event:(NSString *)eventToken
             parameters:(NSDictionary *)parameters
{
    if (![self.class checkAppTokenNotNil:self.appToken]) return;
    if (![self.class checkActivityState:self.activityState]) return;
    if (![self.class checkAmount:amount]) return;
    if (![self.class checkEventTokenLength:eventToken]) return;

    AIPackageBuilder *revenueBuilder = [[AIPackageBuilder alloc] init];
    revenueBuilder.amountInCents = amount;
    revenueBuilder.eventToken = eventToken;
    revenueBuilder.callbackParameters = parameters;

    self.activityState.eventCount++;
    [self updateActivityState];
    [self injectGeneralAttributes:revenueBuilder];
    [self.activityState injectEventAttributes:revenueBuilder];

    AIActivityPackage *revenuePackage = [revenueBuilder buildRevenuePackage];
    [self.packageHandler addPackage:revenuePackage];

    [self writeActivityState];
}

- (void)updateActivityState {
    if (![self.class checkActivityState:self.activityState]) return;

    double now = [NSDate.date timeIntervalSince1970];
    double lastInterval = now - self.activityState.lastActivity;
    if (lastInterval < 0) {
        [AILogger error:@"Time travel!"];
        self.activityState.lastInterval = now;
        return;
    }

    // ignore late updates
    if (lastInterval > kSessionInterval) return;

    self.activityState.sessionLength += lastInterval;
    self.activityState.timeSpent += lastInterval;
    self.activityState.lastActivity = now;
}

- (void)readActivityState {
    @try {
        NSString *filename = [self activityStateFilename];
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if ([object isKindOfClass:[AIActivityState class]]) {
            self.activityState = object;
            NSLog(@"Read activity state: %@", self.activityState);
            return;
        } else {
            NSLog(@"Failed to read activity state");
        }
    } @catch (NSException *ex ) {
        NSLog(@"Failed to read activity state (%@)", ex);
    }

    // start with a fresh activity state in case of any exception
    self.activityState = nil;
}

- (void)writeActivityState {
    [NSThread sleepForTimeInterval:0.3]; // TODO: remove

    NSString *filename = [self activityStateFilename];
    BOOL result = [NSKeyedArchiver archiveRootObject:self.activityState toFile:filename];
    if (result == YES) {
        NSLog(@"Wrote activity state: %@", self.activityState);
    } else {
        NSLog(@"Failed to write activity state");
    }
}

- (void)transferSessionPackage {
    AIPackageBuilder *sessionBuilder = [[AIPackageBuilder alloc] init];
    [self injectGeneralAttributes:sessionBuilder];
    [self.activityState injectSessionAttributes:sessionBuilder];
    AIActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage];
    [self.packageHandler addPackage:sessionPackage];
}

- (void)injectGeneralAttributes:(AIPackageBuilder *)builder {
    builder.userAgent = self.userAgent;
    builder.appToken = self.appToken;
    builder.macShortMd5 = self.macShortMd5;
    builder.macSha1 = self.macSha1;
    builder.idForAdvertisers = self.idForAdvertisers;
    builder.attributionId = self.fbAttributionId;
}

- (void)startTimer {
    NSLog(@"startTimer");
    if (self.timer == nil) {
        self.timer = [AITimer timerWithInterval:kTimerInterval
                                    leeway:kTimerLeeway
                                     queue:self.internalQueue
                                     block:^{ [self timerFired]; }];
    }
    [self.timer resume];
}

- (void)stopTimer {
    [self.timer suspend];
}

- (void)timerFired {
    [self.packageHandler sendFirstPackage];
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

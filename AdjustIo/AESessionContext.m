//
//  AESessionContext.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 01.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AESessionContext.h"
#import "AELogger.h"
#import "AETimer.h"

#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"


static const uint64_t kTimerInterval = 1ull * NSEC_PER_SEC; // TODO: 60 seconds
static const uint64_t kTimerLeeway   = 0ull * NSEC_PER_SEC; // TODO: 1 second

#pragma mark private interface

@interface AESessionContext() {
    dispatch_queue_t  sessionQueue;
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
- (void)eventInternal;
- (void)revenueInternal;

+ (BOOL)checkAppToken:(NSString *)appToken;

@end


@implementation AESessionContext

#pragma mark public implementation

+ (AESessionContext *)contextWithAppToken:(NSString *)appToken {
    return [[AESessionContext alloc] initWithAppToken:appToken];
}

- (id)initWithAppToken:(NSString *)yourAppToken {
    self = [super init];
    if (self == nil) return nil;

    sessionQueue = dispatch_queue_create("io.adjust.sessiontest", DISPATCH_QUEUE_SERIAL);

    dispatch_async(sessionQueue, ^{
        [self initInternal:yourAppToken];
    });

    return self;
}

- (void)trackSubsessionStart {
    dispatch_async(sessionQueue, ^{
        @try {
            [self startInternal];
        } @catch (NSException *e) {
            NSLog(@"exception");
        }
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
        [self eventInternal];
    });
}

- (void)trackRevenue:(float)amountInCents
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters
{
    dispatch_async(sessionQueue, ^{
        [self revenueInternal];
    });
}


#pragma mark private implementation

// internal methods run asynchronously

- (void)initInternal:(NSString *)yourAppToken {
    if (![self.class checkAppToken:yourAppToken]) return;

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;

    self->appToken         = yourAppToken;
    self->macSha1          = macAddress.aiSha1;
    self->macShortMd5      = macAddress.aiRemoveColons.aiMd5;
    self->idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    self->fbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;

    timer = [AETimer timerWithInterval:kTimerInterval
                                leeway:kTimerLeeway
                                 queue:sessionQueue
                                 block:^{ [self updateInternal]; }];

    [self addNotificationObserver];
}

- (void)startInternal {
    if (![self.class checkAppToken:appToken]) return;

    [timer resume];

    NSLog(@"start %@", appToken);
}

- (void)endInternal {
    if (![self.class checkAppToken:appToken]) return;

    [timer suspend];

    NSLog(@"end %@", appToken);
}

- (void)eventInternal {
    if (![self.class checkAppToken:appToken]) return;

    [NSThread sleepForTimeInterval:0.5];
    NSLog(@"event %@", appToken);
}

- (void)revenueInternal {
    if (![self.class checkAppToken:appToken]) return;

    NSLog(@"revenue %@", appToken);
}

- (void)updateInternal {
    if (![self.class checkAppToken:appToken]) return;

    NSLog(@"update");
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

+ (void)removeNotificationObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

+ (BOOL)checkAppToken:(NSString *)appToken {
    if (appToken == nil) {
        [AELogger error:@"Missing App Token."];
        return NO;
    } else if (appToken.length != 12) {
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

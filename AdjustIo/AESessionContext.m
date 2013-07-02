//
//  AESessionContext.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 01.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AESessionContext.h"
#import "AELogger.h"

#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"


#pragma mark private interface
@interface AESessionContext() {
    dispatch_queue_t sessionQueue;

    NSString *appToken;
    NSString *macSha1;
    NSString *macShortMd5;
    NSString *idForAdvertisers;
    NSString *fbAttributionId;
    NSString *userAgent;
}

- (id)initWithAppToken:(NSString *)appToken;
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

- (id)initWithAppToken:(NSString *)yourAppToken {
    self = [super init];
    if (self == nil) return nil;

    if (![self.class checkAppToken:yourAppToken]) return self;

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;

    self->appToken         = yourAppToken;
    self->macSha1          = macAddress.aiSha1;
    self->macShortMd5      = macAddress.aiRemoveColons.aiMd5;
    self->idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    self->fbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;

    // [self addNotificationObserver]; // TODO: move here

    sessionQueue = dispatch_queue_create("io.adjust.sessiontest", NULL);

    return self;
}

// internal methods run asynchronously

- (void)startInternal {
    NSLog(@"start %@", appToken);
}

- (void)endInternal {
    NSLog(@"end %@", appToken);
}

- (void)eventInternal {
    NSLog(@"event %@", appToken);
}

- (void)revenueInternal {
    NSLog(@"revenue %@", appToken);
}

+ (BOOL)checkAppToken:(NSString *)appToken {
    if (appToken == nil) {
        [AELogger error:@"Missing App Token."];
        return NO;
    } else if (appToken.length != 12) {
        [AELogger error:@"Malformed App Token %@", appToken];
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

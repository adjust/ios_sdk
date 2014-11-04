//
//  Adjust.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "AIActivityHandler.h"
#import "AIAdjustFactory.h"
#import "AILogger.h"

#if !__has_feature(objc_arc)
#error Adjust requires ARC
// see README for details
#endif
@interface Adjust()

@property (nonatomic, retain) id<AIActivityHandler> activityHandler;
@property (nonatomic, retain) id<AILogger> logger;
@end

#pragma mark -
@implementation Adjust

+ (void)appDidLaunch:(AdjustConfig *)adjustConfig {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance appDidLaunch:adjustConfig];
}

+ (void)trackEvent:(AIEvent *)event {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance trackEvent:event];
}

+ (void)trackSubsessionStart {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance trackSubsessionStart];
}

+ (void)trackSubsessionEnd {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance trackSubsessionEnd];
}

+ (void)setEnabled:(BOOL)enabled {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance setEnabled:enabled];
}

+ (BOOL)isEnabled {
    Adjust * defaultInstance = [Adjust getInstance];
    return [defaultInstance isEnabled];
}

+ (void)appWillOpenUrl:(NSURL *)url {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance appWillOpenUrl:url];
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance setDeviceToken:deviceToken];
}

+ (void)setOfflineMode:(BOOL)enabled {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance setOfflineMode:enabled];
}

+ (void)setDelegate:(NSObject<AdjustDelegate> *)delegate {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance setDelegate:delegate];
}

+ (void)addPermanentCallbackParameter:(NSString *)key
                             andValue:(NSString *)value {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance addPermanentCallbackParameter:key andValue:value];
}

+ (void)addPermanentPartnerParameter:(NSString *)key
                            andValue:(NSString *)value {
    Adjust * defaultInstance = [Adjust getInstance];
    [defaultInstance addPermanentPartnerParameter:key andValue:value];

}


+ (id)getInstance {
    static Adjust * defaultInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id) init {
    self = [super init];
    if (self == nil) return nil;

    self.activityHandler = nil;
    self.logger = [AIAdjustFactory logger];

    return self;
}

- (void)appDidLaunch:(AdjustConfig *)adjustConfig {
    if (self.activityHandler != nil) {
        [self.logger error:@"Adjust already initialized"];
        return;
    }

    self.activityHandler = [AIAdjustFactory activityHandlerWithConfig:adjustConfig];
}

- (void)trackEvent:(AIEvent *)event {
    if (![self checkActivityHandler]) return;
    [self.activityHandler trackEvent:event];
}

- (void)trackSubsessionStart {
    if (![self checkActivityHandler]) return;
    [self.activityHandler trackSubsessionStart];
}

- (void)trackSubsessionEnd {
    if (![self checkActivityHandler]) return;
    [self.activityHandler trackSubsessionEnd];
}

- (void)setEnabled:(BOOL)enabled {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setEnabled:enabled];
}

- (BOOL)isEnabled {
    if (![self checkActivityHandler]) return NO;
    return [self.activityHandler isEnabled];
}

- (void)appWillOpenUrl:(NSURL *)url {
    if (![self checkActivityHandler]) return;
    [self.activityHandler  appWillOpenUrl:url];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setDeviceToken:deviceToken];
}

- (void)setOfflineMode:(BOOL)enabled {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setOfflineMode:enabled];
}

- (void)setDelegate:(NSObject<AdjustDelegate> *)delegate {
    if (![self checkActivityHandler]) return;
    [self.activityHandler setDelegate:delegate];
}

- (void)addPermanentCallbackParameter:(NSString *)key
                             andValue:(NSString *)value {
    if (![self checkActivityHandler]) return;
    [self.activityHandler addPermanentCallbackParameter:key andValue:value];
}

- (void)addPermanentPartnerParameter:(NSString *)key
                            andValue:(NSString *)value {
    if (![self checkActivityHandler]) return;
    [self.activityHandler addPermanentPartnerParameter:key andValue:value];

}


#pragma mark - private

- (BOOL) checkActivityHandler {
    if (self.activityHandler == nil) {
        [self.logger error:@"Please initialize Adjust by calling 'appDidLaunch' before"];
        return NO;
    } else {
        return YES;
    }
}

@end

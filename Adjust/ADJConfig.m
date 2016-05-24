//
//  AdjustConfig.m
//  adjust
//
//  Created by Pedro Filipe on 30/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJConfig.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"
#import "ADJUtil.h"

@implementation ADJConfig

+ (ADJConfig *) configWithAppToken:(NSString *)appToken
                       environment:(NSString *)environment {
    return [[ADJConfig alloc] initWithAppToken:appToken environment:environment];
}

- (id) initWithAppToken:(NSString *)appToken
            environment:(NSString *)environment
{
    if (![self checkAppToken:appToken]) return self;
    if (![self checkEnvironment:environment]) return self;

    return [self initSelfWithAppToken:appToken environment:environment];
}

- (id) initWithoutCheckAppToken:(NSString *)appToken
                    environment:(NSString *)environment
{
    self = [super init];
    if (self == nil) return nil;

    return [self initSelfWithAppToken:appToken environment:environment];
}

- (id) initSelfWithAppToken:(NSString *)appToken
                environment:(NSString *)environment {
    _appToken = appToken;
    _environment = environment;

    // default values
    self.logLevel = ADJLogLevelInfo;
    _hasResponseDelegate = NO;
    _hasAttributionChangedDelegate = NO;
    self.eventBufferingEnabled = NO;

    return self;
}

- (void) setDelegate:(NSObject<AdjustDelegate> *)delegate {
    _hasResponseDelegate = NO;
    _hasAttributionChangedDelegate = NO;
    BOOL implementsDeeplinkCallback = NO;

    id<ADJLogger> logger = ADJAdjustFactory.logger;

    if ([ADJUtil isNull:delegate]) {
        [logger warn:@"Delegate is nil"];
        _delegate = nil;
        return;
    }

    if ([delegate respondsToSelector:@selector(adjustAttributionChanged:)]) {
        [logger debug:@"Delegate implements adjustAttributionChanged:"];

        _hasResponseDelegate = YES;
        _hasAttributionChangedDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustEventTrackingSucceeded:)]) {
        [logger debug:@"Delegate implements adjustEventTrackingSucceeded:"];

        _hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustEventTrackingFailed:)]) {
        [logger debug:@"Delegate implements adjustEventTrackingFailed:"];

        _hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustSessionTrackingSucceeded:)]) {
        [logger debug:@"Delegate implements adjustSessionTrackingSucceeded:"];

        _hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustSessionTrackingFailed:)]) {
        [logger debug:@"Delegate implements adjustSessionTrackingFailed:"];

        _hasResponseDelegate = YES;
    }

    if ([delegate respondsToSelector:@selector(adjustDeeplinkResponse:)]) {
        [logger debug:@"Delegate implements adjustDeeplinkResponse:"];

        // does not enable hasDelegate flag
        implementsDeeplinkCallback = YES;
    }

    if (!(self.hasResponseDelegate || implementsDeeplinkCallback)) {
        [logger error:@"Delegate does not implement any optional method"];
        _delegate = nil;
        return;
    }

    _delegate = delegate;
}

- (BOOL) checkEnvironment:(NSString *)environment
{
    id<ADJLogger> logger = ADJAdjustFactory.logger;
    if ([ADJUtil isNull:environment]) {
        [logger error:@"Missing environment"];
        return NO;
    }
    if ([environment isEqualToString:ADJEnvironmentSandbox]) {
        [logger assert:@"SANDBOX: Adjust is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to `production` before publishing"];
        return YES;
    } else if ([environment isEqualToString:ADJEnvironmentProduction]) {
        [logger assert:@"PRODUCTION: Adjust is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to `sandbox` if you want to test your app!"];
        return YES;
    }
    [logger error:@"Unknown environment '%@'", environment];
    return NO;
}

- (BOOL)checkAppToken:(NSString *)appToken {
    if ([ADJUtil isNull:appToken]) {
        [ADJAdjustFactory.logger error:@"Missing App Token"];
        return NO;
    }
    if (appToken.length != 12) {
        [ADJAdjustFactory.logger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

- (BOOL) isValid {
    return self.appToken != nil;
}

-(id)copyWithZone:(NSZone *)zone
{
    ADJConfig* copy = [[[self class] allocWithZone:zone]
                       initWithoutCheckAppToken:[self.appToken copyWithZone:zone]
                       environment:[self.environment copyWithZone:zone]];
    if (copy) {
        copy.logLevel = self.logLevel;
        copy.sdkPrefix = [self.sdkPrefix copyWithZone:zone];
        copy.defaultTracker = [self.defaultTracker copyWithZone:zone];
        copy.eventBufferingEnabled = self.eventBufferingEnabled;
        copy->_hasResponseDelegate = self.hasResponseDelegate;
        copy->_hasAttributionChangedDelegate = self.hasAttributionChangedDelegate;
        copy.sendInBackground = self.sendInBackground;
        copy.delayStart = self.delayStart;
        // adjust delegate not copied
    }

    return copy;
}

@end

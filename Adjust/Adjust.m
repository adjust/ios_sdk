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

#if !__has_feature(objc_arc)
#error Adjust requires ARC
// see README for details
#endif

static id<AIActivityHandler> activityHandler;
static id<AILogger> logger;

#pragma mark -
@implementation Adjust

+ (void)appDidLaunch:(NSString *)yourAppToken {
    activityHandler = [AIAdjustFactory activityHandlerWithAppToken:yourAppToken];
}

+ (void)setDelegate:(NSObject<AdjustDelegate> *)delegate {
    [activityHandler setDelegate:delegate];
}

+ (void)setSdkPrefix:(NSString *)sdkPrefix {
    [activityHandler setSdkPrefix:sdkPrefix];
}

+ (void)trackEvent:(AIEvent *)event {
    [activityHandler trackEvent:event];
}

+ (void)setLogLevel:(AILogLevel)logLevel {
    [AIAdjustFactory.logger setLogLevel:logLevel];
}

+ (void)setEnvironment:(NSString *)environment {
    id<AILogger> logger = AIAdjustFactory.logger;
    if (activityHandler == nil) {
        [logger error:@"Please call `setEnvironment` after `appDidLaunch`!"];
    } else if ([environment isEqualToString:AIEnvironmentSandbox]) {
        [activityHandler setEnvironment:environment];
        [logger assert:@"SANDBOX: Adjust is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to AIEnvironmentProduction before publishing!"];
    } else if ([environment isEqualToString:AIEnvironmentProduction]) {
        [activityHandler setEnvironment:environment];
        [logger assert:@"PRODUCTION: Adjust is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to AIEnvironmentSandbox if you want to test your app!"];
        [logger setLogLevel:AILogLevelAssert];
    } else {
        [activityHandler setEnvironment:@"malformed"];
        [logger error:@"Malformed environment '%@'", environment];
    }
}

+ (void)setEventBufferingEnabled:(BOOL)enabled {
    if (activityHandler == nil) {
        [AIAdjustFactory.logger error:@"Please call `setEventBufferingEnabled` after `appDidLaunch`!"];
        return;
    }

    [activityHandler setBufferEvents:enabled];
    if (enabled) [AIAdjustFactory.logger info:@"Event buffering is enabled"];
}

+ (void)setMacMd5TrackingEnabled:(BOOL)enabled {
    if (activityHandler == nil) {
        [AIAdjustFactory.logger error:@"Please call `setMacMd5TrackingEnabled` after `appDidLaunch`!"];
        return;
    }

    [activityHandler setTrackMacMd5:enabled];
    [AIAdjustFactory.logger info:@"Tracking of macMd5 is %@", enabled ? @"enabled" : @"disabled"];
}

+ (void)trackSubsessionStart {
    [activityHandler trackSubsessionStart];
}

+ (void)trackSubsessionEnd {
    [activityHandler trackSubsessionEnd];
}

+ (void)setEnabled:(BOOL)enabled {
    [activityHandler setEnabled:enabled];
}

+ (BOOL)isEnabled {
    return [activityHandler isEnabled];
}

+ (void)appWillOpenUrl:(NSURL *)url {
    [activityHandler readOpenUrl:url];
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    [activityHandler savePushToken:deviceToken];
}

+ (void)setAttributionMaxTime:(double)seconds {
    [activityHandler setAttributionMaxTime:seconds];
}

@end

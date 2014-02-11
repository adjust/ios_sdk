//
//  AdjustIo.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2013 adeven. All rights reserved.
//

#import "AdjustIo.h"
#import "AIActivityHandler.h"
#import "AIAdjustIoFactory.h"

#if !__has_feature(objc_arc)
#error AdjustIo requires ARC
// see README for details
#endif

static id<AIActivityHandler> activityHandler;
static id<AILogger> logger;

#pragma mark -
@implementation AdjustIo

+ (void)appDidLaunch:(NSString *)yourAppToken {
    activityHandler = [AIAdjustIoFactory activityHandlerWithAppToken:yourAppToken];
}

+ (void)setDelegate:(NSObject<AdjustIoDelegate> *)delegate {
    [activityHandler setDelegate:delegate];
}

+ (void)setSdkPrefix:(NSString *)sdkPrefix {
    [activityHandler setSdkPrefix:sdkPrefix];
}

+ (void)trackEvent:(NSString *)eventToken {
    [activityHandler trackEvent:eventToken withParameters:nil];
}

+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters {
    [activityHandler trackEvent:eventToken withParameters:parameters];
}

+ (void)trackRevenue:(double)amountInCents {
    [activityHandler trackRevenue:amountInCents forEvent:nil withParameters:nil];
}

+ (void)trackRevenue:(double)amountInCents forEvent:(NSString *)eventToken {
    [activityHandler trackRevenue:amountInCents forEvent:eventToken withParameters:nil];
}

+ (void)trackRevenue:(double)amountInCents
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters
{
    [activityHandler trackRevenue:amountInCents forEvent:eventToken withParameters:parameters];
}

+ (void)setLogLevel:(AILogLevel)logLevel {
    [AIAdjustIoFactory.logger setLogLevel:logLevel];
}

+ (void)setEnvironment:(NSString *)environment {
    id<AILogger> logger = AIAdjustIoFactory.logger;
    if (activityHandler == nil) {
        [logger error:@"Please call `setEnvironment` after `appDidLaunch`!"];
    } else if ([environment isEqualToString:AIEnvironmentSandbox]) {
        activityHandler.environment = environment;
        [logger assert:@"SANDBOX: AdjustIo is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to AIEnvironmentProduction before publishing!"];
    } else if ([environment isEqualToString:AIEnvironmentProduction]) {
        activityHandler.environment = environment;
        [logger assert:@"PRODUCTION: AdjustIo is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to AIEnvironmentSandbox if you want to test your app!"];
        [logger setLogLevel:AILogLevelAssert];
    } else {
        activityHandler.environment = @"malformed";
        [logger error:@"Malformed environment '%@'", environment];
    }
}

+ (void)setEventBufferingEnabled:(BOOL)enabled {
    if (activityHandler == nil) {
        [AIAdjustIoFactory.logger error:@"Please call `setEventBufferingEnabled` after `appDidLaunch`!"];
        return;
    }

    activityHandler.bufferEvents = enabled;
    if (enabled) [AIAdjustIoFactory.logger info:@"Event buffering is enabled"];
}

+ (void)setMacMd5TrackingEnabled:(BOOL)enabled {
    if (activityHandler == nil) {
        [AIAdjustIoFactory.logger error:@"Please call `setMacMd5TrackingEnabled` after `appDidLaunch`!"];
        return;
    }

    activityHandler.trackMacMd5 = enabled;
    [AIAdjustIoFactory.logger info:@"Tracking of macMd5 is %@", enabled ? @"enabled" : @"disabled"];
}

@end

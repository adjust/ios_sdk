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

#pragma mark -
@implementation Adjust

+ (void)appDidLaunch:(AdjustConfig *)adjustConfig {
    activityHandler = [AIAdjustFactory activityHandlerWithConfig:adjustConfig];
}

+ (void)trackEvent:(AIEvent *)event {
    [activityHandler trackEvent:event];
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

@end

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

@implementation ADJConfig

+ (ADJConfig *) configWithAppToken:(NSString *)appToken
                       environment:(NSString *)environment {
    return [[ADJConfig alloc] initWithAppToken:appToken environment:environment];
}

- (id) initWithAppToken:(NSString *)appToken
            environment:(NSString *)environment
{
    self = [super init];
    if (self == nil) return nil;

    if (![self checkAppTokenLength:appToken]) return nil;
    if (![self checkEnvironment:environment]) return nil;

    self.appToken = appToken;
    self.environment = environment;

    // default values
    self.logLevel = ADJLogLevelInfo;
    self.macMd5TrackingEnabled = YES;

    return self;
}

- (void) setDelegate:(NSObject<AdjustDelegate> *)delegate {
    if (delegate == nil) {
        _delegate = nil;
        self.hasDelegate = NO;
        return;
    }

    if (![delegate respondsToSelector:@selector(adjustAttributionChanged:)]) {
        id<ADJLogger> logger = ADJAdjustFactory.logger;
        [logger error:@"Delegate does not implement AdjustDelegate"];

        _delegate = nil;
        self.hasDelegate = NO;
        return;
    }

    _delegate = delegate;
    self.hasDelegate = YES;
}

- (BOOL) checkEnvironment:(NSString *)environment
{
    id<ADJLogger> logger = ADJAdjustFactory.logger;
    if ([environment isEqualToString:ADJEnvironmentSandbox]) {
        [logger assert:@"SANDBOX: Adjust will run in Sandbox mode. Use this setting for testing. Don't forget to set the environment to ADJEnvironmentProduction before publishing!"];
        return YES;
    } else if ([environment isEqualToString:ADJEnvironmentProduction]) {
        [logger assert:@"PRODUCTION: Adjust will run in Production mode. Use this setting only for the build that you want to publish. Set the environment to ADJEnvironmentSandbox if you want to test your app!"];
        return YES;
    }
    [logger error:@"Malformed environment '%@'", environment];
    return NO;
}

- (BOOL)checkAppTokenLength:(NSString *)appToken {
    if (appToken == nil || appToken.length != 12) {
        [ADJAdjustFactory.logger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

-(id)copyWithZone:(NSZone *)zone
{
    ADJConfig* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.appToken = [self.appToken copyWithZone:zone];
        copy.logLevel = self.logLevel;
        copy.environment = [self.environment copyWithZone:zone];
        copy.sdkPrefix = [self.environment copyWithZone:zone];
        copy.eventBufferingEnabled = self.eventBufferingEnabled;
        copy.macMd5TrackingEnabled = self.macMd5TrackingEnabled;
        copy.hasDelegate = self.hasDelegate;
        // adjust delegate not copied
    }
    
    return copy;
}

@end

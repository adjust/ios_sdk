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
                    andEnvironment:(NSString *)environment {
    return [[ADJConfig alloc] initWithAppToken:appToken andEnvironment:environment];
}

- (id) initWithAppToken:(NSString *)appToken
         andEnvironment:(NSString *)environment
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

- (BOOL) checkEnvironment:(NSString *)environment
{
    id<ADJLogger> logger = ADJAdjustFactory.logger;
    if ([environment isEqualToString:AIEnvironmentSandbox]) {
        [logger assert:@"SANDBOX: Adjust will run in Sandbox mode. Use this setting for testing. Don't forget to set the environment to AIEnvironmentProduction before publishing!"];
        return YES;
    } else if ([environment isEqualToString:AIEnvironmentProduction]) {
        [logger assert:@"PRODUCTION: Adjust will run in Production mode. Use this setting only for the build that you want to publish. Set the environment to AIEnvironmentSandbox if you want to test your app!"];
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
        // adjust delegate not copied
    }

    return copy;
}

@end

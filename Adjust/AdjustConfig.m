//
//  AdjustConfig.m
//  adjust
//
//  Created by Pedro Filipe on 30/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AdjustConfig.h"
#import "AIAdjustFactory.h"
#import "AILogger.h"

@implementation AdjustConfig

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
    self.logLevel = AILogLevelInfo;
    self.macMd5TrackingEnabled = YES;

    return self;
}

- (void) addPermanentCallbackParameter:(NSString *)key
                              andValue:(NSString *)value {
    if (_callbackPermanentParameters == nil) {
        _callbackPermanentParameters = [[NSMutableDictionary alloc] init];
    }

    [_callbackPermanentParameters setObject:value forKey:key];
}

- (void) addPermanentPartnerParameter:(NSString *)key
                             andValue:(NSString *)value {
    if (_partnerPermanentParameters == nil) {
        _partnerPermanentParameters = [[NSMutableDictionary alloc] init];
    }

    [_partnerPermanentParameters setObject:value forKey:key];
}

- (BOOL) checkEnvironment:(NSString *)environment
{
    id<AILogger> logger = AIAdjustFactory.logger;
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
        [AIAdjustFactory.logger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

-(id)copyWithZone:(NSZone *)zone
{
    AdjustConfig* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.appToken = [self.appToken copyWithZone:zone];
        copy.logLevel = self.logLevel;
        copy.environment = [self.environment copyWithZone:zone];
        copy.sdkPrefix = [self.environment copyWithZone:zone];
        copy.eventBufferingEnabled = self.eventBufferingEnabled;
        copy.macMd5TrackingEnabled = self.macMd5TrackingEnabled;
        copy.callbackPermanentParameters = [self.callbackPermanentParameters copyWithZone:zone];
        copy.partnerPermanentParameters = [self.partnerPermanentParameters copyWithZone:zone];
        // adjust delegate not copied
        copy.attributionMaxTime = self.attributionMaxTime;
    }

    return copy;
}

@end

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

@interface ADJConfig()

@property (nonatomic, weak) id<ADJLogger> logger;

@end

@implementation ADJConfig

- (nullable ADJConfig *)initWithAppToken:(nonnull NSString *)appToken
                             environment:(nonnull NSString *)environment {
    return [self initWithAppToken:appToken
                      environment:environment
                 suppressLogLevel:NO];
}

- (nullable ADJConfig *)initWithAppToken:(nonnull NSString *)appToken
                             environment:(nonnull NSString *)environment
                        suppressLogLevel:(BOOL)allowSuppressLogLevel {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.logger = ADJAdjustFactory.logger;

    if (allowSuppressLogLevel && [ADJEnvironmentProduction isEqualToString:environment]) {
        [self setLogLevel:ADJLogLevelSuppress environment:environment];
    } else {
        [self setLogLevel:ADJLogLevelInfo environment:environment];
    }

    if (![self checkEnvironment:environment]) {
        return self;
    }
    if (![self checkAppToken:appToken]) {
        return self;
    }

    _appToken = appToken;
    _environment = environment;
    
    // default values
    _isSendingInBackgroundEnabled = NO;
    _isAdServicesEnabled = YES;
    _isLinkMeEnabled = NO;
    _isIdfaReadingEnabled = YES;
    _isIdfvReadingEnabled = YES;
    _isSkanAttributionEnabled = YES;
    _eventDeduplicationIdsMaxSize = -1;
    _isDeviceIdsReadingOnceEnabled = NO;
    _isCostDataInAttributionEnabled = NO;
    _isCoppaComplianceEnabled = NO;

    return self;
}

- (void)setLogLevel:(ADJLogLevel)logLevel {
    [self setLogLevel:logLevel environment:self.environment];
}

- (void)setLogLevel:(ADJLogLevel)logLevel
        environment:(NSString *)environment {
    [self.logger setLogLevel:logLevel
     isProductionEnvironment:[ADJEnvironmentProduction isEqualToString:environment]];
}

- (void)disableIdfaReading {
    _isIdfaReadingEnabled = NO;
}

- (void)disableIdfvReading {
    _isIdfvReadingEnabled = NO;
}

- (void)disableSkanAttribution {
    _isSkanAttributionEnabled = NO;
}

- (void)enableLinkMe {
    _isLinkMeEnabled = YES;
}

- (void)enableDeviceIdsReadingOnce {
    _isDeviceIdsReadingOnceEnabled = YES;
}

- (void)enableSendingInBackground {
    _isSendingInBackgroundEnabled = YES;
}

- (void)disableAdServices {
    _isAdServicesEnabled = NO;
}

- (void)enableCostDataInAttribution {
    _isCostDataInAttributionEnabled = YES;
}

- (void)enableCoppaCompliance {
    _isCoppaComplianceEnabled = YES;
}

- (void)setUrlStrategy:(nullable NSArray *)urlStrategyDomains
         useSubdomains:(BOOL)useSubdomains
       isDataResidency:(BOOL)isDataResidency {
    if (urlStrategyDomains == nil) {
        return;
    }
    if (urlStrategyDomains.count == 0) {
        return;
    }

    if (_urlStrategyDomains == nil) {
        _urlStrategyDomains = [NSArray arrayWithArray:urlStrategyDomains];
    }

    _useSubdomains = useSubdomains;
    _isDataResidency = isDataResidency;
}

- (void)setDelegate:(NSObject<AdjustDelegate> *)delegate {
    BOOL hasResponseDelegate = NO;
    BOOL implementsDeeplinkCallback = NO;

    if ([ADJUtil isNull:delegate]) {
        [self.logger warn:@"Delegate is nil"];
        _delegate = nil;
        return;
    }

    if ([delegate respondsToSelector:@selector(adjustAttributionChanged:)]) {
        [self.logger debug:@"Delegate implements adjustAttributionChanged:"];
        hasResponseDelegate = YES;
    }
    if ([delegate respondsToSelector:@selector(adjustEventTrackingSucceeded:)]) {
        [self.logger debug:@"Delegate implements adjustEventTrackingSucceeded:"];
        hasResponseDelegate = YES;
    }
    if ([delegate respondsToSelector:@selector(adjustEventTrackingFailed:)]) {
        [self.logger debug:@"Delegate implements adjustEventTrackingFailed:"];
        hasResponseDelegate = YES;
    }
    if ([delegate respondsToSelector:@selector(adjustSessionTrackingSucceeded:)]) {
        [self.logger debug:@"Delegate implements adjustSessionTrackingSucceeded:"];
        hasResponseDelegate = YES;
    }
    if ([delegate respondsToSelector:@selector(adjustSessionTrackingFailed:)]) {
        [self.logger debug:@"Delegate implements adjustSessionTrackingFailed:"];
        hasResponseDelegate = YES;
    }
    if ([delegate respondsToSelector:@selector(adjustDeferredDeeplinkReceived:)]) {
        [self.logger debug:@"Delegate implements adjustDeferredDeeplinkReceived:"];
        // does not enable hasDelegate flag
        implementsDeeplinkCallback = YES;
    }
    if ([delegate respondsToSelector:@selector(adjustSkanUpdatedWithConversionData:)]) {
        [self.logger debug:@"Delegate implements adjustSkanUpdatedWithConversionData:"];
        hasResponseDelegate = YES;
    }

    if (!(hasResponseDelegate || implementsDeeplinkCallback)) {
        [self.logger error:@"Delegate does not implement any optional method"];
        _delegate = nil;
        return;
    }

    _delegate = delegate;
}

- (BOOL)checkEnvironment:(NSString *)environment {
    if ([ADJUtil isNull:environment]) {
        [self.logger error:@"Missing environment"];
        return NO;
    }
    if ([environment isEqualToString:ADJEnvironmentSandbox]) {
        [self.logger warnInProduction:@"SANDBOX: Adjust is running in Sandbox mode. Use this setting for testing. Don't forget to set the environment to `production` before publishing"];
        return YES;
    } else if ([environment isEqualToString:ADJEnvironmentProduction]) {
        [self.logger warnInProduction:@"PRODUCTION: Adjust is running in Production mode. Use this setting only for the build that you want to publish. Set the environment to `sandbox` if you want to test your app!"];
        return YES;
    }
    [self.logger error:@"Unknown environment '%@'", environment];
    return NO;
}

- (BOOL)checkAppToken:(NSString *)appToken {
    if ([ADJUtil isNull:appToken]) {
        [self.logger error:@"Missing App Token"];
        return NO;
    }
    if (appToken.length != 12) {
        [self.logger error:@"Malformed App Token '%@'", appToken];
        return NO;
    }
    return YES;
}

- (BOOL)isValid {
    return self.appToken != nil;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJConfig *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy->_appToken = [self.appToken copyWithZone:zone];
        copy->_environment = [self.environment copyWithZone:zone];
        copy.logLevel = self.logLevel;
        copy.sdkPrefix = [self.sdkPrefix copyWithZone:zone];
        copy.defaultTracker = [self.defaultTracker copyWithZone:zone];
        copy->_isSendingInBackgroundEnabled = self.isSendingInBackgroundEnabled;
        copy->_isAdServicesEnabled = self.isAdServicesEnabled;
        copy.attConsentWaitingInterval = self.attConsentWaitingInterval;
        copy.externalDeviceId = [self.externalDeviceId copyWithZone:zone];
        copy->_isCostDataInAttributionEnabled = self.isCostDataInAttributionEnabled;
        copy->_isCoppaComplianceEnabled = self.isCoppaComplianceEnabled;
        copy->_isSkanAttributionEnabled = self.isSkanAttributionEnabled;
        copy->_urlStrategyDomains = [self.urlStrategyDomains copyWithZone:zone];
        copy->_useSubdomains = self.useSubdomains;
        copy->_isDataResidency = self.isDataResidency;
        copy->_isLinkMeEnabled = self.isLinkMeEnabled;
        copy->_isIdfaReadingEnabled = self.isIdfaReadingEnabled;
        copy->_isIdfvReadingEnabled = self.isIdfvReadingEnabled;
        copy->_isDeviceIdsReadingOnceEnabled = self.isDeviceIdsReadingOnceEnabled;
        copy.eventDeduplicationIdsMaxSize = self.eventDeduplicationIdsMaxSize;
        // AdjustDelegate not copied
    }

    return copy;
}

@end

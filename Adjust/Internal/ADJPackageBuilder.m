//
//  ADJPackageBuilder.m
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 3rd July 2013.
//  Copyright (c) 2013-2018 Adjust GmbH. All rights reserved.
//

#include <string.h>

#import "ADJUtil.h"
#import "ADJAttribution.h"
#import "ADJAdjustFactory.h"
#import "ADJPackageBuilder.h"
#import "ADJActivityPackage.h"
#import "ADJAdditions.h"
#import "ADJUserDefaults.h"
#import "ADJAdRevenue.h"
#import "ADJAppStorePurchase.h"
#import "ADJAppStoreSubscription.h"
#import "ADJSKAdNetwork.h"

NSString * const ADJAttributionTokenParameter = @"attribution_token";

@interface ADJPackageBuilder()

@property (nonatomic, assign) double createdAt;

@property (nonatomic, weak) ADJConfig *adjustConfig;

@property (nonatomic, weak) ADJPackageParams *packageParams;

@property (nonatomic, copy) ADJActivityState *activityState;

@property (nonatomic, weak) ADJGlobalParameters *globalParameters;

@property (nonatomic, weak) ADJTrackingStatusManager *trackingStatusManager;

@end

@implementation ADJPackageBuilder

#pragma mark - Object lifecycle methods

- (id)initWithPackageParams:(ADJPackageParams * _Nullable)packageParams
              activityState:(ADJActivityState * _Nullable)activityState
                     config:(ADJConfig * _Nullable)adjustConfig
           globalParameters:(ADJGlobalParameters * _Nullable)globalParameters
      trackingStatusManager:(ADJTrackingStatusManager * _Nullable)trackingStatusManager
                  createdAt:(double)createdAt {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.createdAt = createdAt;
    self.packageParams = packageParams;
    self.adjustConfig = adjustConfig;
    self.activityState = activityState;
    self.globalParameters = globalParameters;
    self.trackingStatusManager = trackingStatusManager;

    return self;
}

#pragma mark - Public methods

- (ADJActivityPackage *)buildSessionPackage {
    NSMutableDictionary *parameters = [self getSessionParameters];
    ADJActivityPackage *sessionPackage = [self defaultActivityPackage];
    sessionPackage.path = @"/session";
    sessionPackage.activityKind = ADJActivityKindSession;
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;
    sessionPackage.parameters = [ADJUtil deepCopyOfDictionary:sessionPackage.parameters];

    return sessionPackage;
}

- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event {
    NSMutableDictionary *parameters = [self getEventParameters:event];
    ADJActivityPackage *eventPackage = [self defaultActivityPackage];
    eventPackage.path = @"/event";
    eventPackage.activityKind = ADJActivityKindEvent;
    eventPackage.suffix = [self eventSuffix:event];
    eventPackage.parameters = parameters;
    eventPackage.callbackParameters = [ADJUtil deepCopyOfDictionary:event.callbackParameters];
    eventPackage.partnerParameters = [ADJUtil deepCopyOfDictionary:event.partnerParameters];
    eventPackage.parameters = [ADJUtil deepCopyOfDictionary:eventPackage.parameters];

    return eventPackage;
}

- (ADJActivityPackage *)buildInfoPackage:(NSString *)infoSource {
    NSMutableDictionary *parameters = [self getInfoParameters:infoSource];
    ADJActivityPackage *infoPackage = [self defaultActivityPackage];
    infoPackage.path = @"/sdk_info";
    infoPackage.activityKind = ADJActivityKindInfo;
    infoPackage.suffix = @"";
    infoPackage.parameters = parameters;
    infoPackage.parameters = [ADJUtil deepCopyOfDictionary:infoPackage.parameters];

    return infoPackage;
}

- (ADJActivityPackage *)buildAdRevenuePackage:(ADJAdRevenue *)adRevenue {
    NSMutableDictionary *parameters = [self getAdRevenueParameters:adRevenue];
    ADJActivityPackage *adRevenuePackage = [self defaultActivityPackage];
    adRevenuePackage.path = @"/ad_revenue";
    adRevenuePackage.activityKind = ADJActivityKindAdRevenue;
    adRevenuePackage.suffix = @"";
    adRevenuePackage.parameters = parameters;
    adRevenuePackage.callbackParameters = [ADJUtil deepCopyOfDictionary:adRevenue.callbackParameters];
    adRevenuePackage.partnerParameters = [ADJUtil deepCopyOfDictionary:adRevenue.partnerParameters];
    adRevenuePackage.parameters = [ADJUtil deepCopyOfDictionary:adRevenuePackage.parameters];

    return adRevenuePackage;
}

- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource extraParameters:(NSDictionary *)extraParameters {
    NSMutableDictionary *parameters = [self getClickParameters:clickSource];
    if (extraParameters != nil) {
        [parameters addEntriesFromDictionary:extraParameters];
    }
    
    ADJActivityPackage *clickPackage = [self defaultActivityPackage];
    clickPackage.path = @"/sdk_click";
    clickPackage.activityKind = ADJActivityKindClick;
    clickPackage.suffix = @"";
    clickPackage.parameters = parameters;
    clickPackage.parameters = [ADJUtil deepCopyOfDictionary:clickPackage.parameters];

    return clickPackage;
}

- (ADJActivityPackage *)buildAttributionPackage:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [self getAttributionParameters:initiatedBy];
    ADJActivityPackage *attributionPackage = [self defaultActivityPackage];
    attributionPackage.path = @"/attribution";
    attributionPackage.activityKind = ADJActivityKindAttribution;
    attributionPackage.suffix = @"";
    attributionPackage.parameters = parameters;
    attributionPackage.parameters = [ADJUtil deepCopyOfDictionary:attributionPackage.parameters];

    return attributionPackage;
}

- (ADJActivityPackage *)buildGdprPackage {
    NSMutableDictionary *parameters = [self getGdprParameters];
    ADJActivityPackage *gdprPackage = [self defaultActivityPackage];
    gdprPackage.path = @"/gdpr_forget_device";
    gdprPackage.activityKind = ADJActivityKindGdpr;
    gdprPackage.suffix = @"";
    gdprPackage.parameters = parameters;
    gdprPackage.parameters = [ADJUtil deepCopyOfDictionary:gdprPackage.parameters];

    return gdprPackage;
}

- (ADJActivityPackage *)buildThirdPartySharingPackage:(nonnull ADJThirdPartySharing *)thirdPartySharing {
    NSMutableDictionary *parameters = [self getThirdPartySharingParameters:thirdPartySharing];
    ADJActivityPackage *tpsPackage = [self defaultActivityPackage];
    tpsPackage.path = @"/third_party_sharing";
    tpsPackage.activityKind = ADJActivityKindThirdPartySharing;
    tpsPackage.suffix = @"";
    tpsPackage.parameters = parameters;
    tpsPackage.parameters = [ADJUtil deepCopyOfDictionary:tpsPackage.parameters];

    return tpsPackage;
}

- (ADJActivityPackage *)buildMeasurementConsentPackage:(BOOL)enabled {
    NSMutableDictionary *parameters = [self getMeasurementConsentParameters:enabled];
    ADJActivityPackage *mcPackage = [self defaultActivityPackage];
    mcPackage.path = @"/measurement_consent";
    mcPackage.activityKind = ADJActivityKindMeasurementConsent;
    mcPackage.suffix = @"";
    mcPackage.parameters = parameters;
    mcPackage.parameters = [ADJUtil deepCopyOfDictionary:mcPackage.parameters];

    return mcPackage;
}

- (ADJActivityPackage *)buildSubscriptionPackage:(ADJAppStoreSubscription *)subscription {
    NSMutableDictionary *parameters = [self getSubscriptionParameters:subscription];
    ADJActivityPackage *subscriptionPackage = [self defaultActivityPackage];
    subscriptionPackage.path = @"/v2/purchase";
    subscriptionPackage.activityKind = ADJActivityKindSubscription;
    subscriptionPackage.suffix = @"";
    subscriptionPackage.parameters = parameters;
    subscriptionPackage.callbackParameters = [ADJUtil deepCopyOfDictionary:subscription.callbackParameters];
    subscriptionPackage.partnerParameters = [ADJUtil deepCopyOfDictionary:subscription.partnerParameters];
    subscriptionPackage.parameters = [ADJUtil deepCopyOfDictionary:subscriptionPackage.parameters];

    return subscriptionPackage;
}

- (ADJActivityPackage *)buildPurchaseVerificationPackageWithExtraParams:(NSDictionary *)extraParameters {
    NSMutableDictionary *parameters = [self getPurchaseVerificationParameters];
    if (extraParameters != nil) {
        [parameters addEntriesFromDictionary:extraParameters];
    }

    ADJActivityPackage *purchaseVerificationPackage = [self defaultActivityPackage];
    purchaseVerificationPackage.path = @"/verify";
    purchaseVerificationPackage.activityKind = ADJActivityKindPurchaseVerification;
    purchaseVerificationPackage.suffix = @"";
    purchaseVerificationPackage.parameters = parameters;
    purchaseVerificationPackage.parameters = [ADJUtil deepCopyOfDictionary:purchaseVerificationPackage.parameters];

    return purchaseVerificationPackage;
}

- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource {
    return [self buildClickPackage:clickSource extraParameters:nil];
}

- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource
                                    token:(NSString *)token
                          errorCodeNumber:(NSNumber *)errorCodeNumber {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (token != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:token
                               forKey:ADJAttributionTokenParameter];
    }
    if (errorCodeNumber != nil) {
        [ADJPackageBuilder parameters:parameters
                               setInt:errorCodeNumber.intValue
                               forKey:@"error_code"];
    }

    return [self buildClickPackage:clickSource extraParameters:parameters];
}

- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource
                                linkMeUrl:(NSString * _Nullable)linkMeUrl {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (linkMeUrl != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:linkMeUrl
                               forKey:@"content"];
    }

    return [self buildClickPackage:clickSource extraParameters:parameters];
}

- (ADJActivityPackage * _Nullable)buildPurchaseVerificationPackageWithPurchase:(ADJAppStorePurchase * _Nullable)purchase {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (purchase.transactionId != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:purchase.transactionId
                               forKey:@"transaction_id"];
    }
    if (purchase.productId != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:purchase.productId
                               forKey:@"product_id"];
    }

    return [self buildPurchaseVerificationPackageWithExtraParams:parameters];
}

- (ADJActivityPackage * _Nullable)buildPurchaseVerificationPackageWithEvent:(ADJEvent *)event {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    if (event.transactionId != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:event.transactionId
                               forKey:@"transaction_id"];
    }
    if (event.productId != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:event.productId
                               forKey:@"product_id"];
    }
    if (event.eventToken != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:event.eventToken
                               forKey:@"event_token"];
    }
    if (event.revenue != nil) {
        [ADJPackageBuilder parameters:parameters
                            setNumber:event.revenue
                               forKey:@"revenue"];
    }
    if (event.currency != nil) {
        [ADJPackageBuilder parameters:parameters
                            setString:event.currency
                               forKey:@"currency"];
    }

    return [self buildPurchaseVerificationPackageWithExtraParams:parameters];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (dictionary == nil) {
        return;
    }
    if (dictionary.count == 0) {
        return;
    }

    NSDictionary *convertedDictionary = [ADJUtil convertDictionaryValues:dictionary];
    [ADJPackageBuilder parameters:parameters setDictionaryJson:convertedDictionary forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setString:(NSString *)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value == nil || [value isEqualToString:@""]) {
        return;
    }
    [parameters setObject:value forKey:key];
}

#pragma mark - Private & helper methods

- (NSMutableDictionary *)getSessionParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.partnerParameters copy] forKey:@"partner_params"];

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindSession];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getEventParameters:(ADJEvent *)event {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:event.currency forKey:@"currency"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:event.callbackId forKey:@"event_callback_id"];
    [ADJPackageBuilder parameters:parameters setString:event.eventToken forKey:@"event_token"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setNumber:event.revenue forKey:@"revenue"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    [ADJPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    [ADJPackageBuilder parameters:parameters setString:event.deduplicationId forKey:@"deduplication_id"];
    [ADJPackageBuilder parameters:parameters setString:event.productId forKey:@"product_id"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.eventCount forKey:@"event_count"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    NSDictionary *mergedCallbackParameters = [ADJUtil mergeParameters:[self.globalParameters.callbackParameters copy]
                                                               source:[event.callbackParameters copy]
                                                        parameterName:@"Callback"];
    NSDictionary *mergedPartnerParameters = [ADJUtil mergeParameters:[self.globalParameters.partnerParameters copy]
                                                              source:[event.partnerParameters copy]
                                                       parameterName:@"Partner"];
    [ADJPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindEvent];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getInfoParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setString:source forKey:@"source"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    if (self.attribution != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.attribution.adgroup forKey:@"adgroup"];
        [ADJPackageBuilder parameters:parameters setString:self.attribution.campaign forKey:@"campaign"];
        [ADJPackageBuilder parameters:parameters setString:self.attribution.creative forKey:@"creative"];
        [ADJPackageBuilder parameters:parameters setString:self.attribution.trackerName forKey:@"tracker"];
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindInfo];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAdRevenueParameters:(ADJAdRevenue *)adRevenue {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    [ADJPackageBuilder parameters:parameters setString:adRevenue.source forKey:@"source"];
    [ADJPackageBuilder parameters:parameters setNumberWithoutRounding:adRevenue.revenue forKey:@"revenue"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.currency forKey:@"currency"];
    [ADJPackageBuilder parameters:parameters setNumberInt:adRevenue.adImpressionsCount forKey:@"ad_impressions_count"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.adRevenueNetwork forKey:@"ad_revenue_network"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.adRevenueUnit forKey:@"ad_revenue_unit"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.adRevenuePlacement forKey:@"ad_revenue_placement"];

    NSDictionary *mergedCallbackParameters = [ADJUtil mergeParameters:[self.globalParameters.callbackParameters copy]
                                                               source:[adRevenue.callbackParameters copy]
                                                        parameterName:@"Callback"];
    NSDictionary *mergedPartnerParameters = [ADJUtil mergeParameters:[self.globalParameters.partnerParameters copy]
                                                              source:[adRevenue.partnerParameters copy]
                                                       parameterName:@"Partner"];
    [ADJPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindAdRevenue];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getClickParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setString:self.referrer forKey:@"referrer"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setString:source forKey:@"source"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    if (self.attribution != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.attribution.adgroup forKey:@"adgroup"];
        [ADJPackageBuilder parameters:parameters setString:self.attribution.campaign forKey:@"campaign"];
        [ADJPackageBuilder parameters:parameters setString:self.attribution.creative forKey:@"creative"];
        [ADJPackageBuilder parameters:parameters setString:self.attribution.trackerName forKey:@"tracker"];
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindClick];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAttributionParameters:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setString:initiatedBy forKey:@"initiated_by"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.adjustConfig.isCostDataInAttributionEnabled) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isCostDataInAttributionEnabled forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindAttribution];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getGdprParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindGdpr];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getThirdPartySharingParameters:(nonnull ADJThirdPartySharing *)thirdPartySharing {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    // Third Party Sharing
    if (thirdPartySharing.enabled != nil) {
        NSString *enableValue = thirdPartySharing.enabled.boolValue ? @"enable" : @"disable";
        [ADJPackageBuilder parameters:parameters setString:enableValue forKey:@"sharing"];
    }
    [ADJPackageBuilder parameters:parameters
                setDictionaryJson:thirdPartySharing.granularOptions
                           forKey:@"granular_third_party_sharing_options"];
    [ADJPackageBuilder parameters:parameters
                setDictionaryJson:thirdPartySharing.partnerSharingSettings
                           forKey:@"partner_sharing_settings"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindThirdPartySharing];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getMeasurementConsentParameters:(BOOL)enabled {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.reftag forKey:@"reftag"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    // Measurement Consent
    NSString *enableValue = enabled ? @"enable" : @"disable";
    [ADJPackageBuilder parameters:parameters
                        setString:enableValue
                           forKey:@"measurement"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindMeasurementConsent];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}
- (NSMutableDictionary *)getSubscriptionParameters:(ADJAppStoreSubscription *)subscription {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    NSDictionary *mergedCallbackParameters = [ADJUtil mergeParameters:self.globalParameters.callbackParameters
                                                               source:subscription.callbackParameters
                                                        parameterName:@"Callback"];
    NSDictionary *mergedPartnerParameters = [ADJUtil mergeParameters:self.globalParameters.partnerParameters
                                                              source:subscription.partnerParameters
                                                       parameterName:@"Partner"];
    [ADJPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
    
    [ADJPackageBuilder parameters:parameters setNumber:subscription.price forKey:@"revenue"];
    [ADJPackageBuilder parameters:parameters setString:subscription.currency forKey:@"currency"];
    [ADJPackageBuilder parameters:parameters setString:subscription.transactionId forKey:@"transaction_id"];
    [ADJPackageBuilder parameters:parameters setDate:subscription.transactionDate forKey:@"transaction_date"];
    [ADJPackageBuilder parameters:parameters setString:subscription.salesRegion forKey:@"sales_region"];

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindSubscription];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getPurchaseVerificationParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[ADJUserDefaults getControlParams] forKey:@"control_params"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.globalParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.pushToken forKey:@"push_token"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.sessionCount forKey:@"session_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.sessionLength forKey:@"session_length"];
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.subsessionCount forKey:@"subsession_count"];
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.timeSpent forKey:@"time_spent"];
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self addTrackingDataToParameters:parameters];
    [self addConsentDataToParameters:parameters forActivityKind:ADJActivityKindPurchaseVerification];
    [self addIdfvIfPossibleToParameters:parameters];
    [self injectFeatureFlagsWithParameters:parameters];
    [self injectLastSkanUpdateWithParameters:parameters];

    return parameters;
}

- (void)addIdfvIfPossibleToParameters:(NSMutableDictionary *)parameters {
    if (self.adjustConfig.isIdfvReadingEnabled == NO) {
        return;
    }
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
}

- (void)injectFeatureFlagsWithParameters:(NSMutableDictionary *)parameters {
    [ADJPackageBuilder parameters:parameters
                          setBool:self.adjustConfig.isSendingInBackgroundEnabled
                           forKey:@"send_in_background_enabled"];
    if (self.internalState != nil) {
        [ADJPackageBuilder parameters:parameters 
                              setBool:self.internalState.isOffline
                               forKey:@"offline_mode_enabled"];
        if (self.internalState.isInForeground == YES) {
            [ADJPackageBuilder parameters:parameters
                                  setBool:YES
                                   forKey:@"foreground"];
        } else {
            [ADJPackageBuilder parameters:parameters
                                  setBool:YES
                                   forKey:@"background"];
        }
    }
    if (self.adjustConfig.isCoppaComplianceEnabled == YES) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_coppa"];
    }
    if (self.adjustConfig.isSkanAttributionEnabled == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_skadn_disabled"];
    }
    if (self.adjustConfig.isIdfaReadingEnabled == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_idfa_disabled"];
    }
    if (self.adjustConfig.isAdServicesEnabled == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_adserv_disabled"];
    }
    if (self.adjustConfig.isAppTrackingTransparencyUsageEnabled == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_att_disabled"];
    }
}

- (void)injectLastSkanUpdateWithParameters:(NSMutableDictionary *)parameters {
    NSDictionary *lastSkanUpdateData = [[ADJSKAdNetwork getInstance] lastSkanUpdateData];
    if (lastSkanUpdateData != nil) {
        [ADJPackageBuilder parameters:parameters setDictionaryJson:lastSkanUpdateData forKey:@"last_skan_update"];
    }
}

- (ADJActivityPackage *)defaultActivityPackage {
    ADJActivityPackage *activityPackage = [[ADJActivityPackage alloc] init];
    activityPackage.clientSdk = self.packageParams.clientSdk;
    return activityPackage;
}

- (NSString *)eventSuffix:(ADJEvent *)event {
    if (event.revenue == nil) {
        return [NSString stringWithFormat:@"'%@'", event.eventToken];
    } else {
        return [NSString stringWithFormat:@"(%.5f %@, '%@')", [event.revenue doubleValue], event.currency, event.eventToken];
    }
}

+ (void)parameters:(NSMutableDictionary *)parameters setInt:(int)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value < 0) {
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%d", value];
    [ADJPackageBuilder parameters:parameters setString:valueString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDouble:(double)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value <= 0.0) {
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%.2f", value];
    [ADJPackageBuilder parameters:parameters setString:valueString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDate1970:(double)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value < 0) {
        return;
    }
    NSString *dateString = [ADJUtil formatSeconds1970:value];
    [ADJPackageBuilder parameters:parameters setString:dateString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDate:(NSDate *)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value == nil) {
        return;
    }
    NSString *dateString = [ADJUtil formatDate:value];
    [ADJPackageBuilder parameters:parameters setString:dateString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDuration:(double)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value < 0) {
        return;
    }
    int intValue = round(value);
    [ADJPackageBuilder parameters:parameters setInt:intValue forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDictionaryJson:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (dictionary == nil) {
        return;
    }
    if (dictionary.count == 0) {
        return;
    }
    if (![NSJSONSerialization isValidJSONObject:dictionary]) {
        return;
    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *dictionaryString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [ADJPackageBuilder parameters:parameters setString:dictionaryString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setBool:(BOOL)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    int valueInt = [[NSNumber numberWithBool:value] intValue];
    [ADJPackageBuilder parameters:parameters setInt:valueInt forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumber:(NSNumber *)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value == nil) {
        return;
    }
    NSString *numberString = [NSString stringWithFormat:@"%.5f", [value doubleValue]];
    [ADJPackageBuilder parameters:parameters setString:numberString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumberWithoutRounding:(NSNumber *)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value == nil) {
        return;
    }
    NSString *numberString = [value stringValue];
    [ADJPackageBuilder parameters:parameters setString:numberString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumberInt:(NSNumber *)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value == nil) {
        return;
    }
    [ADJPackageBuilder parameters:parameters setInt:[value intValue] forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setData:(NSData *)value forKey:(NSString *)key {
    if (parameters == nil) {
        return;
    }
    if (value == nil) {
        return;
    }
    [ADJPackageBuilder parameters:parameters
                        setString:[[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding]
                           forKey:key];
}

+ (BOOL)isAdServicesPackage:(ADJActivityPackage *)activityPackage {
    NSString *source = activityPackage.parameters[@"source"];
    return ([ADJUtil isNotNull:source] && [source isEqualToString:ADJAdServicesPackageKey]);
}

#pragma mark - Consent params

+ (void)addConsentDataToParameters:(NSMutableDictionary * _Nullable)parameters
                   forActivityKind:(ADJActivityKind)activityKind
                     withAttStatus:(int)attStatus
                     configuration:(ADJConfig * _Nullable)adjConfig
                     packageParams:(ADJPackageParams * _Nullable)packageParams
                     activityState:(ADJActivityState *_Nullable)activityState
{

    if (![ADJUtil shouldUseConsentParamsForActivityKind:activityKind
                                           andAttStatus:attStatus]) {
        return;
    }

    // idfa
    if (!adjConfig.isIdfaReadingEnabled) {
        [[ADJAdjustFactory logger] info:@"Cannot read IDFA because it's forbidden by ADJConfig setting"];
        return;
    }
    if (adjConfig.isCoppaComplianceEnabled) {
        [[ADJAdjustFactory logger] info:@"Cannot read IDFA with COPPA enabled"];
        return;
    }

    __block NSString *idfa = nil;
    [ADJUtil launchSynchronisedWithObject:[ADJPackageBuilder class] block:^{
        // read once && IDFA not cached
        if (adjConfig.isDeviceIdsReadingOnceEnabled && packageParams.idfaCached != nil) {
            idfa = packageParams.idfaCached;
        } else {
            // read IDFA
            idfa = [ADJUtil idfa];
            if (idfa == nil ||
                idfa.length == 0 ||
                [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"])
            {
                idfa = nil;
            } else {
                // cache IDFA
                packageParams.idfaCached = idfa;
            }
        }
    }];

    if (idfa != nil) {
        // add IDFA to payload
        [ADJPackageBuilder parameters:parameters setString:idfa forKey:@"idfa"];
    }
}

+ (void)removeConsentDataFromParameters:(nonnull NSMutableDictionary *)parameters {
    [parameters removeObjectForKey:@"idfa"];
}

+ (void)updateAttStatus:(int)attStatus inParameters:(nonnull NSMutableDictionary *)parameters {
    [ADJPackageBuilder parameters:parameters setInt:attStatus forKey:@"att_status"];
}

+ (void)removeAttStatusFromParameters:(nonnull NSMutableDictionary *)parameters {
    [parameters removeObjectForKey:@"att_status"];
}

- (void)addConsentDataToParameters:(NSMutableDictionary *)parameters
                   forActivityKind:(ADJActivityKind)activityKind {

    int attStatus = ([self.trackingStatusManager isAttSupported]) ?
    [self.trackingStatusManager updateAndGetAttStatus] : -1;

    [ADJPackageBuilder addConsentDataToParameters:parameters
                                  forActivityKind:activityKind
                                    withAttStatus:attStatus
                                    configuration:self.adjustConfig
                                    packageParams:self.packageParams
                                    activityState:self.activityState];
}

- (void)addTrackingDataToParameters:(NSMutableDictionary *)parameters {
    int attStatus = -1;
    if ([self.trackingStatusManager isAttSupported]) {
        attStatus = [self.trackingStatusManager updateAndGetAttStatus];
        if (attStatus >= 0) {
            [ADJPackageBuilder parameters:parameters setInt:attStatus forKey:@"att_status"];
        }
    } else {
        [ADJPackageBuilder parameters:parameters
                              setBool:[self.trackingStatusManager isTrackingEnabled]
                               forKey:@"tracking_enabled"];
    }
}
@end

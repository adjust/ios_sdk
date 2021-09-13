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
#import "NSData+ADJAdditions.h"
#import "ADJUserDefaults.h"

NSString * const ADJAttributionTokenParameter = @"attribution_token";

@interface ADJPackageBuilder()

@property (nonatomic, assign) double createdAt;

@property (nonatomic, weak) ADJConfig *adjustConfig;

@property (nonatomic, weak) ADJPackageParams *packageParams;

@property (nonatomic, copy) ADJActivityState *activityState;

@property (nonatomic, weak) ADJSessionParameters *sessionParameters;

@property (nonatomic, weak) ADJTrackingStatusManager *trackingStatusManager;

@end

@implementation ADJPackageBuilder

#pragma mark - Object lifecycle methods

- (id)initWithPackageParams:(ADJPackageParams * _Nullable)packageParams
              activityState:(ADJActivityState * _Nullable)activityState
                     config:(ADJConfig * _Nullable)adjustConfig
          sessionParameters:(ADJSessionParameters * _Nullable)sessionParameters
      trackingStatusManager:(ADJTrackingStatusManager * _Nullable)trackingStatusManager
                  createdAt:(double)createdAt
{
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.createdAt = createdAt;
    self.packageParams = packageParams;
    self.adjustConfig = adjustConfig;
    self.activityState = activityState;
    self.sessionParameters = sessionParameters;
    self.trackingStatusManager = trackingStatusManager;

    return self;
}

#pragma mark - Public methods

- (ADJActivityPackage *)buildSessionPackage:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getSessionParameters:isInDelay];
    ADJActivityPackage *sessionPackage = [self defaultActivityPackage];
    sessionPackage.path = @"/session";
    sessionPackage.activityKind = ADJActivityKindSession;
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;

    [self signWithSigV2Plugin:sessionPackage];

    return sessionPackage;
}

- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event
                                isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getEventParameters:isInDelay forEventPackage:event];
    ADJActivityPackage *eventPackage = [self defaultActivityPackage];
    eventPackage.path = @"/event";
    eventPackage.activityKind = ADJActivityKindEvent;
    eventPackage.suffix = [self eventSuffix:event];
    eventPackage.parameters = parameters;

    if (isInDelay) {
        eventPackage.callbackParameters = event.callbackParameters;
        eventPackage.partnerParameters = event.partnerParameters;
    }

    [self signWithSigV2Plugin:eventPackage];

    return eventPackage;
}

- (ADJActivityPackage *)buildInfoPackage:(NSString *)infoSource
{
    NSMutableDictionary *parameters = [self getInfoParameters:infoSource];

    ADJActivityPackage *infoPackage = [self defaultActivityPackage];
    infoPackage.path = @"/sdk_info";
    infoPackage.activityKind = ADJActivityKindInfo;
    infoPackage.suffix = @"";
    infoPackage.parameters = parameters;

    [self signWithSigV2Plugin:infoPackage];

    return infoPackage;
}

- (ADJActivityPackage *)buildAdRevenuePackage:(NSString *)source payload:(NSData *)payload {
    NSMutableDictionary *parameters = [self getAdRevenueParameters:source payload:payload];
    ADJActivityPackage *adRevenuePackage = [self defaultActivityPackage];
    adRevenuePackage.path = @"/ad_revenue";
    adRevenuePackage.activityKind = ADJActivityKindAdRevenue;
    adRevenuePackage.suffix = @"";
    adRevenuePackage.parameters = parameters;

    [self signWithSigV2Plugin:adRevenuePackage];

    return adRevenuePackage;
}

- (ADJActivityPackage *)buildAdRevenuePackage:(ADJAdRevenue *)adRevenue isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getAdRevenueParameters:adRevenue isInDelay:isInDelay];
    ADJActivityPackage *adRevenuePackage = [self defaultActivityPackage];
    adRevenuePackage.path = @"/ad_revenue";
    adRevenuePackage.activityKind = ADJActivityKindAdRevenue;
    adRevenuePackage.suffix = @"";
    adRevenuePackage.parameters = parameters;

    [self signWithSigV2Plugin:adRevenuePackage];

    return adRevenuePackage;
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

- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource extraParameters:(NSDictionary *)extraParameters {
    NSMutableDictionary *parameters = [self getClickParameters:clickSource];
    if (extraParameters != nil) {
        [parameters addEntriesFromDictionary:extraParameters];
    }
    
    if ([clickSource isEqualToString:ADJiAdPackageKey]) {
        // send iAd errors in the parameters
        NSDictionary<NSString *, NSNumber *> *iAdErrors = [ADJUserDefaults getiAdErrors];
        if (iAdErrors) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:iAdErrors options:0 error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            parameters[@"iad_errors"] = jsonStr;
        }
    }
    
    ADJActivityPackage *clickPackage = [self defaultActivityPackage];
    clickPackage.path = @"/sdk_click";
    clickPackage.activityKind = ADJActivityKindClick;
    clickPackage.suffix = @"";
    clickPackage.parameters = parameters;

    [self signWithSigV2Plugin:clickPackage];

    return clickPackage;
}

- (ADJActivityPackage *)buildAttributionPackage:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [self getAttributionParameters:initiatedBy];
    ADJActivityPackage *attributionPackage = [self defaultActivityPackage];
    attributionPackage.path = @"/attribution";
    attributionPackage.activityKind = ADJActivityKindAttribution;
    attributionPackage.suffix = @"";
    attributionPackage.parameters = parameters;

    [self signWithSigV2Plugin:attributionPackage];

    return attributionPackage;
}

- (ADJActivityPackage *)buildGdprPackage {
    NSMutableDictionary *parameters = [self getGdprParameters];
    ADJActivityPackage *gdprPackage = [self defaultActivityPackage];
    gdprPackage.path = @"/gdpr_forget_device";
    gdprPackage.activityKind = ADJActivityKindGdpr;
    gdprPackage.suffix = @"";
    gdprPackage.parameters = parameters;

    [self signWithSigV2Plugin:gdprPackage];

    return gdprPackage;
}

- (ADJActivityPackage *)buildDisableThirdPartySharingPackage {
    NSMutableDictionary *parameters = [self getDisableThirdPartySharingParameters];
    ADJActivityPackage *dtpsPackage = [self defaultActivityPackage];
    dtpsPackage.path = @"/disable_third_party_sharing";
    dtpsPackage.activityKind = ADJActivityKindDisableThirdPartySharing;
    dtpsPackage.suffix = @"";
    dtpsPackage.parameters = parameters;

    [self signWithSigV2Plugin:dtpsPackage];

    return dtpsPackage;
}


- (ADJActivityPackage *)buildThirdPartySharingPackage:(nonnull ADJThirdPartySharing *)thirdPartySharing {
    NSMutableDictionary *parameters = [self getThirdPartySharingParameters:thirdPartySharing];
    ADJActivityPackage *tpsPackage = [self defaultActivityPackage];
    tpsPackage.path = @"/third_party_sharing";
    tpsPackage.activityKind = ADJActivityKindThirdPartySharing;
    tpsPackage.suffix = @"";
    tpsPackage.parameters = parameters;

    [self signWithSigV2Plugin:tpsPackage];

    return tpsPackage;
}

- (ADJActivityPackage *)buildMeasurementConsentPackage:(BOOL)enabled {
    NSMutableDictionary *parameters = [self getMeasurementConsentParameters:enabled];
    ADJActivityPackage *mcPackage = [self defaultActivityPackage];
    mcPackage.path = @"/measurement_consent";
    mcPackage.activityKind = ADJActivityKindMeasurementConsent;
    mcPackage.suffix = @"";
    mcPackage.parameters = parameters;

    [self signWithSigV2Plugin:mcPackage];

    return mcPackage;
}

- (ADJActivityPackage *)buildSubscriptionPackage:(ADJSubscription *)subscription
                                       isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [self getSubscriptionParameters:isInDelay forSubscriptionPackage:subscription];
    ADJActivityPackage *subscriptionPackage = [self defaultActivityPackage];
    subscriptionPackage.path = @"/v2/purchase";
    subscriptionPackage.activityKind = ADJActivityKindSubscription;
    subscriptionPackage.suffix = @"";
    subscriptionPackage.parameters = parameters;

    if (isInDelay) {
        subscriptionPackage.callbackParameters = subscription.callbackParameters;
        subscriptionPackage.partnerParameters = subscription.partnerParameters;
    }

    [self signWithSigV2Plugin:subscriptionPackage];

    return subscriptionPackage;
}

+ (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
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
    if (value == nil || [value isEqualToString:@""]) {
        return;
    }
    [parameters setObject:value forKey:key];
}

#pragma mark - Private & helper methods

- (void)signWithSigV2Plugin:(ADJActivityPackage *)activityPackage {
    Class signerClass = NSClassFromString(@"ADJSigner");
    if (signerClass == nil) {
        return;
    }
    SEL signSEL = NSSelectorFromString(@"sign:withActivityKind:withSdkVersion:");
    if (![signerClass respondsToSelector:signSEL]) {
        return;
    }

    NSMutableDictionary *parameters = activityPackage.parameters;
    const char *activityKindChar = [[ADJActivityKindUtil activityKindToString:activityPackage.activityKind] UTF8String];
    const char *sdkVersionChar = [activityPackage.clientSdk UTF8String];

    // Stack allocated strings to ensure their lifetime stays until the next iteration
    static char activityKind[64], sdkVersion[64];
    strncpy(activityKind, activityKindChar, strlen(activityKindChar) + 1);
    strncpy(sdkVersion, sdkVersionChar, strlen(sdkVersionChar) + 1);

    // NSInvocation setArgument requires lvalue references with exact matching types to the executed function signature.
    // With this usage we ensure that the lifetime of the object remains until the next iteration, as it points to the
    // stack allocated string where we copied the buffer.
    const char *lvalActivityKind = activityKind;
    const char *lvalSdkVersion = sdkVersion;

    /*
     [ADJSigner sign:parameters
    withActivityKind:activityKindChar
      withSdkVersion:sdkVersionChar];
     */

    NSMethodSignature *signMethodSignature = [signerClass methodSignatureForSelector:signSEL];
    NSInvocation *signInvocation = [NSInvocation invocationWithMethodSignature:signMethodSignature];
    [signInvocation setSelector:signSEL];
    [signInvocation setTarget:signerClass];

    [signInvocation setArgument:&parameters atIndex:2];
    [signInvocation setArgument:&lvalActivityKind atIndex:3];
    [signInvocation setArgument:&lvalSdkVersion atIndex:4];

    [signInvocation invoke];

    SEL getVersionSEL = NSSelectorFromString(@"getVersion");
    if (![signerClass respondsToSelector:getVersionSEL]) {
        return;
    }
    /*
     NSString *signerVersion = [ADJSigner getVersion];
     */
    IMP getVersionIMP = [signerClass methodForSelector:getVersionSEL];
    if (!getVersionIMP) {
        return;
    }
    id (*getVersionFunc)(id, SEL) = (void *)getVersionIMP;
    id signerVersion = getVersionFunc(signerClass, getVersionSEL);
    if (![signerVersion isKindOfClass:[NSString class]]) {
        return;
    }

    NSString *signerVersionString = (NSString *)signerVersion;
    [ADJPackageBuilder parameters:parameters
                           setString:signerVersionString
                           forKey:@"native_version"];
}

- (NSMutableDictionary *)getSessionParameters:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    if (!isInDelay) {
        [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
        [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    }

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getEventParameters:(BOOL)isInDelay forEventPackage:(ADJEvent *)event {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:event.currency forKey:@"currency"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:event.callbackId forKey:@"event_callback_id"];
    [ADJPackageBuilder parameters:parameters setString:event.eventToken forKey:@"event_token"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setNumber:event.revenue forKey:@"revenue"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setInt:self.activityState.eventCount forKey:@"event_count"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    if (!isInDelay) {
        NSDictionary *mergedCallbackParameters = [ADJUtil mergeParameters:[self.sessionParameters.callbackParameters copy]
                                                                   source:[event.callbackParameters copy]
                                                            parameterName:@"Callback"];
        NSDictionary *mergedPartnerParameters = [ADJUtil mergeParameters:[self.sessionParameters.partnerParameters copy]
                                                                  source:[event.partnerParameters copy]
                                                           parameterName:@"Partner"];

        [ADJPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
        [ADJPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
    }

    if (event.emptyReceipt) {
        NSString *emptyReceipt = @"empty";
        [ADJPackageBuilder parameters:parameters setString:emptyReceipt forKey:@"receipt"];
        [ADJPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    } else if (event.receipt != nil) {
        NSString *receiptBase64 = [event.receipt adjEncodeBase64];
        [ADJPackageBuilder parameters:parameters setString:receiptBase64 forKey:@"receipt"];
        [ADJPackageBuilder parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    }

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getInfoParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    [ADJPackageBuilder parameters:parameters setString:source forKey:@"source"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAdRevenueParameters:(NSString *)source payload:(NSData *)payload {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    [ADJPackageBuilder parameters:parameters setString:source forKey:@"source"];
    [ADJPackageBuilder parameters:parameters setData:payload forKey:@"payload"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAdRevenueParameters:(ADJAdRevenue *)adRevenue isInDelay:(BOOL)isInDelay {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    
    [ADJPackageBuilder parameters:parameters setString:adRevenue.source forKey:@"source"];
    [ADJPackageBuilder parameters:parameters setNumberWithoutRounding:adRevenue.revenue forKey:@"revenue"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.currency forKey:@"currency"];
    [ADJPackageBuilder parameters:parameters setNumberInt:adRevenue.adImpressionsCount forKey:@"ad_impressions_count"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.adRevenueNetwork forKey:@"ad_revenue_network"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.adRevenueUnit forKey:@"ad_revenue_unit"];
    [ADJPackageBuilder parameters:parameters setString:adRevenue.adRevenuePlacement forKey:@"ad_revenue_placement"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }
    
    if (!isInDelay) {
        NSDictionary *mergedCallbackParameters = [ADJUtil mergeParameters:[self.sessionParameters.callbackParameters copy]
                                                                   source:[adRevenue.callbackParameters copy]
                                                            parameterName:@"Callback"];
        NSDictionary *mergedPartnerParameters = [ADJUtil mergeParameters:[self.sessionParameters.partnerParameters copy]
                                                                  source:[adRevenue.partnerParameters copy]
                                                           parameterName:@"Partner"];

        [ADJPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
        [ADJPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getClickParameters:(NSString *)source {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    [ADJPackageBuilder parameters:parameters setString:source forKey:@"source"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getAttributionParameters:(NSString *)initiatedBy {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setString:initiatedBy forKey:@"initiated_by"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getGdprParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.activityState != nil) {
        if (self.activityState.isPersisted) {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"primary_dedupe_token"];
        } else {
            [ADJPackageBuilder parameters:parameters setString:self.activityState.dedupeToken forKey:@"secondary_dedupe_token"];
        }
    }

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getDisableThirdPartySharingParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }
    
    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getThirdPartySharingParameters:(nonnull ADJThirdPartySharing *)thirdPartySharing {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
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

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (NSMutableDictionary *)getMeasurementConsentParameters:(BOOL)enabled {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.callbackParameters copy] forKey:@"callback_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.clickTime forKey:@"click_time"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.deeplink forKey:@"deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.attributionDetails forKey:@"details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setDictionary:self.deeplinkParameters forKey:@"params"];
    [ADJPackageBuilder parameters:parameters setDictionary:[self.sessionParameters.partnerParameters copy] forKey:@"partner_params"];
    [ADJPackageBuilder parameters:parameters setDate:self.purchaseTime forKey:@"purchase_time"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];

    // Measurement Consent
    NSString *enableValue = enabled ? @"enable" : @"disable";
    [ADJPackageBuilder parameters:parameters
                        setString:enableValue
                           forKey:@"measurement"];

    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}
- (NSMutableDictionary *)getSubscriptionParameters:(BOOL)isInDelay forSubscriptionPackage:(ADJSubscription *)subscription {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appSecret forKey:@"app_secret"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.appToken forKey:@"app_token"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.buildNumber forKey:@"app_version"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.versionNumber forKey:@"app_version_short"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"attribution_deeplink"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.bundleIdentifier forKey:@"bundle_id"];
    [ADJPackageBuilder parameters:parameters setDate1970:self.createdAt forKey:@"created_at"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceName forKey:@"device_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.deviceType forKey:@"device_type"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.environment forKey:@"environment"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.externalDeviceId forKey:@"external_device_id"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.fbAnonymousId forKey:@"fb_anon_id"];
    [self addIdfaIfPossibleToParameters:parameters];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.idfv forKey:@"idfv"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.installedAt forKey:@"installed_at"];
    [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"needs_response_details"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osName forKey:@"os_name"];
    [ADJPackageBuilder parameters:parameters setString:self.packageParams.osVersion forKey:@"os_version"];
    [ADJPackageBuilder parameters:parameters setString:self.adjustConfig.secretId forKey:@"secret_id"];
    [ADJPackageBuilder parameters:parameters setDate:[ADJUserDefaults getSkadRegisterCallTimestamp] forKey:@"skadn_registered_at"];
    [ADJPackageBuilder parameters:parameters setDate1970:(double)self.packageParams.startedAt forKey:@"started_at"];
    
    if ([self.trackingStatusManager canGetAttStatus]) {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.attStatus
                               forKey:@"att_status"];
    } else {
        [ADJPackageBuilder parameters:parameters setInt:self.trackingStatusManager.trackingEnabled
                               forKey:@"tracking_enabled"];
    }

    if (self.adjustConfig.isDeviceKnown) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.isDeviceKnown forKey:@"device_known"];
    }
    if (self.adjustConfig.needsCost) {
        [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.needsCost forKey:@"needs_cost"];
    }

    if (self.activityState != nil) {
        [ADJPackageBuilder parameters:parameters setString:self.activityState.deviceToken forKey:@"push_token"];
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

    if (!isInDelay) {
        NSDictionary *mergedCallbackParameters = [ADJUtil mergeParameters:self.sessionParameters.callbackParameters
                                                                   source:subscription.callbackParameters
                                                            parameterName:@"Callback"];
        NSDictionary *mergedPartnerParameters = [ADJUtil mergeParameters:self.sessionParameters.partnerParameters
                                                                  source:subscription.partnerParameters
                                                           parameterName:@"Partner"];

        [ADJPackageBuilder parameters:parameters setDictionary:mergedCallbackParameters forKey:@"callback_params"];
        [ADJPackageBuilder parameters:parameters setDictionary:mergedPartnerParameters forKey:@"partner_params"];
    }
    
    [ADJPackageBuilder parameters:parameters setNumber:subscription.price forKey:@"revenue"];
    [ADJPackageBuilder parameters:parameters setString:subscription.currency forKey:@"currency"];
    [ADJPackageBuilder parameters:parameters setString:subscription.transactionId forKey:@"transaction_id"];
    [ADJPackageBuilder parameters:parameters setString:[subscription.receipt adjEncodeBase64] forKey:@"receipt"];
    [ADJPackageBuilder parameters:parameters setString:subscription.billingStore forKey:@"billing_store"];
    [ADJPackageBuilder parameters:parameters setDate:subscription.transactionDate forKey:@"transaction_date"];
    [ADJPackageBuilder parameters:parameters setString:subscription.salesRegion forKey:@"sales_region"];

    [self injectFeatureFlagsWithParameters:parameters];

    return parameters;
}

- (void)addIdfaIfPossibleToParameters:(NSMutableDictionary *)parameters {
    if (! self.adjustConfig.allowIdfaReading) {
        return;
    }

    NSString *idfa = [ADJUtil idfa];

    if (idfa == nil
        || idfa.length == 0
        || [idfa isEqualToString:@"00000000-0000-0000-0000-000000000000"])
    {
        return;
    }

    [ADJPackageBuilder parameters:parameters setString:idfa forKey:@"idfa"];
}

- (void)injectFeatureFlagsWithParameters:(NSMutableDictionary *)parameters {
    [ADJPackageBuilder parameters:parameters setBool:self.adjustConfig.eventBufferingEnabled
                           forKey:@"event_buffering_enabled"];

    if (self.adjustConfig.isSKAdNetworkHandlingActive == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_skadn_disabled"];
    }
    if (self.adjustConfig.allowIdfaReading == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_idfa_disabled"];
    }
    if (self.adjustConfig.allowiAdInfoReading == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_iad_disabled"];
    }
    if (self.adjustConfig.allowAdServicesInfoReading == NO) {
        [ADJPackageBuilder parameters:parameters setBool:YES forKey:@"ff_adserv_disabled"];
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
    if (value < 0) {
        return;
    }
    NSString *valueString = [NSString stringWithFormat:@"%d", value];
    [ADJPackageBuilder parameters:parameters setString:valueString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDate1970:(double)value forKey:(NSString *)key {
    if (value < 0) {
        return;
    }
    NSString *dateString = [ADJUtil formatSeconds1970:value];
    [ADJPackageBuilder parameters:parameters setString:dateString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDate:(NSDate *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    NSString *dateString = [ADJUtil formatDate:value];
    [ADJPackageBuilder parameters:parameters setString:dateString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDuration:(double)value forKey:(NSString *)key {
    if (value < 0) {
        return;
    }
    int intValue = round(value);
    [ADJPackageBuilder parameters:parameters setInt:intValue forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setDictionaryJson:(NSDictionary *)dictionary forKey:(NSString *)key {
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
    int valueInt = [[NSNumber numberWithBool:value] intValue];
    [ADJPackageBuilder parameters:parameters setInt:valueInt forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumber:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    NSString *numberString = [NSString stringWithFormat:@"%.5f", [value doubleValue]];
    [ADJPackageBuilder parameters:parameters setString:numberString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumberWithoutRounding:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    NSString *numberString = [value stringValue];
    [ADJPackageBuilder parameters:parameters setString:numberString forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setNumberInt:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) {
        return;
    }
    [ADJPackageBuilder parameters:parameters setInt:[value intValue] forKey:key];
}

+ (void)parameters:(NSMutableDictionary *)parameters setData:(NSData *)value forKey:(NSString *)key {
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

@end

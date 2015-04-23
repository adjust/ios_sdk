//
//  ADJPackageBuilder.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJPackageBuilder.h"
#import "ADJActivityPackage.h"
#import "ADJUtil.h"
#import "ADJAttribution.h"
#import "NSData+ADJAdditions.h"

#pragma mark -
@implementation ADJPackageBuilder

- (id)initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
           activityState:(ADJActivityState *)activityState
                  config:(ADJConfig *)adjustConfig
{
    self = [super init];
    if (self == nil) return nil;

    self.deviceInfo = deviceInfo;
    self.activityState = activityState;
    self.adjustConfig = adjustConfig;

    return self;
}

- (ADJActivityPackage *)buildSessionPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
    [self parameters:parameters setString:self.adjustConfig.defaultTracker forKey:@"default_tracker"];
    
    ADJActivityPackage *sessionPackage = [self defaultActivityPackage];
    sessionPackage.path = @"/session";
    sessionPackage.activityKind = ADJActivityKindSession;
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;

    return sessionPackage;
}

- (ADJActivityPackage *)buildEventPackage:(ADJEvent *) event{
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setInt:self.activityState.eventCount forKey:@"event_count"];
    [self parameters:parameters setNumber:event.revenue forKey:@"revenue"];
    [self parameters:parameters setString:event.currency forKey:@"currency"];
    [self parameters:parameters setString:event.eventToken forKey:@"event_token"];

    [self parameters:parameters setDictionaryJson:event.callbackParameters forKey:@"callback_params"];
    [self parameters:parameters setDictionaryJson:event.partnerParameters forKey:@"partner_params"];

    if (event.emptyReceipt) {
        NSString *emptyReceipt = @"empty";
        [self parameters:parameters setString:emptyReceipt forKey:@"receipt"];
        [self parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    }
    else if (event.receipt != nil) {
        NSString *receiptBase64 = [event.receipt adjEncodeBase64];
        [self parameters:parameters setString:receiptBase64 forKey:@"receipt"];
        [self parameters:parameters setString:event.transactionId forKey:@"transaction_id"];
    }

    ADJActivityPackage *eventPackage = [self defaultActivityPackage];
    eventPackage.path = @"/event";
    eventPackage.activityKind = ADJActivityKindEvent;
    eventPackage.suffix = [self eventSuffix:event];
    eventPackage.parameters = parameters;

    return eventPackage;
}

- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource{
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setString:clickSource                     forKey:@"source"];
    [self parameters:parameters setDictionaryJson:self.deeplinkParameters forKey:@"params"];
    [self parameters:parameters setDate:self.clickTime                    forKey:@"click_time"];
    [self parameters:parameters setDate:self.purchaseTime                 forKey:@"purchase_time"];

    if (self.attribution != nil) {
        [self parameters:parameters setString:self.attribution.trackerName forKey:@"tracker"];
        [self parameters:parameters setString:self.attribution.campaign forKey:@"campaign"];
        [self parameters:parameters setString:self.attribution.adgroup forKey:@"adgroup"];
        [self parameters:parameters setString:self.attribution.creative forKey:@"creative"];
    }

    ADJActivityPackage *clickPackage = [self defaultActivityPackage];
    clickPackage.path = @"/sdk_click";
    clickPackage.activityKind = ADJActivityKindClick;
    clickPackage.suffix = @"";
    clickPackage.parameters = parameters;

    return clickPackage;
}

- (ADJActivityPackage *)buildAttributionPackage {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [self parameters:parameters setString:self.deviceInfo.macSha1          forKey:@"mac_sha1"];
    [self parameters:parameters setString:self.deviceInfo.idForAdvertisers forKey:@"idfa"];
    [self parameters:parameters setString:self.deviceInfo.vendorId         forKey:@"idfv"];
    [self parameters:parameters setString:self.deviceInfo.macShortMd5      forKey:@"mac_md5"];
    [self parameters:parameters setString:self.adjustConfig.appToken       forKey:@"app_token"];
    [self parameters:parameters setString:self.adjustConfig.environment    forKey:@"environment"];
    [self parameters:parameters setString:self.activityState.uuid          forKey:@"ios_uuid"];
    [self parameters:parameters setBool:self.adjustConfig.hasDelegate      forKey:@"needs_attribution_data"];

    ADJActivityPackage *attributionPackage = [self defaultActivityPackage];
    attributionPackage.path = @"/attribution";
    attributionPackage.parameters = parameters;

    return attributionPackage;
}

#pragma mark private
- (ADJActivityPackage *)defaultActivityPackage {
    ADJActivityPackage *activityPackage = [[ADJActivityPackage alloc] init];
    activityPackage.clientSdk = self.deviceInfo.clientSdk;
    return activityPackage;
}

- (NSMutableDictionary *)defaultParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [self injectDeviceInfo:self.deviceInfo config:self.adjustConfig intoParameters:parameters];
    [self injectActivityState:self.activityState intoParamters:parameters];
    [self parameters:parameters setBool:self.adjustConfig.hasDelegate forKey:@"needs_attribution_data"];

    return parameters;
}

- (void) injectDeviceInfo:(ADJDeviceInfo *)deviceInfo
                   config:(ADJConfig*) adjustConfig
           intoParameters:(NSMutableDictionary *) parameters
{
    [self parameters:parameters setString:deviceInfo.macSha1           forKey:@"mac_sha1"];
    [self parameters:parameters setString:deviceInfo.idForAdvertisers  forKey:@"idfa"];
    [self parameters:parameters setString:deviceInfo.fbAttributionId   forKey:@"fb_id"];
    [self parameters:parameters setInt:deviceInfo.trackingEnabled      forKey:@"tracking_enabled"];
    [self parameters:parameters setString:deviceInfo.vendorId          forKey:@"idfv"];
    [self parameters:parameters setString:deviceInfo.pushToken         forKey:@"push_token"];
    [self parameters:parameters setString:deviceInfo.bundeIdentifier   forKey:@"bundle_id"];
    [self parameters:parameters setString:deviceInfo.bundleVersion     forKey:@"app_version"];
    [self parameters:parameters setString:deviceInfo.deviceType        forKey:@"device_type"];
    [self parameters:parameters setString:deviceInfo.deviceName        forKey:@"device_name"];
    [self parameters:parameters setString:deviceInfo.osName            forKey:@"os_name"];
    [self parameters:parameters setString:deviceInfo.systemVersion     forKey:@"os_version"];
    [self parameters:parameters setString:deviceInfo.languageCode      forKey:@"language"];
    [self parameters:parameters setString:deviceInfo.countryCode       forKey:@"country"];
    [self parameters:parameters setString:deviceInfo.networkType       forKey:@"network_type"];
    [self parameters:parameters setString:deviceInfo.mobileCountryCode forKey:@"mobile_country_code"];
    [self parameters:parameters setString:deviceInfo.mobileNetworkCode forKey:@"mobile_network_code"];


    if (adjustConfig.macMd5TrackingEnabled) {
        [self parameters:parameters setString:deviceInfo.macShortMd5   forKey:@"mac_md5"];
    }

    [self parameters:parameters setString:adjustConfig.appToken        forKey:@"app_token"];
    [self parameters:parameters setString:adjustConfig.environment     forKey:@"environment"];
}

- (void) injectActivityState:(ADJActivityState *)activityState
               intoParamters:(NSMutableDictionary *)parameters {
    [self parameters:parameters setDate1970:activityState.createdAt     forKey:@"created_at"];
    [self parameters:parameters setInt:activityState.sessionCount       forKey:@"session_count"];
    [self parameters:parameters setInt:activityState.subsessionCount    forKey:@"subsession_count"];
    [self parameters:parameters setDuration:activityState.sessionLength forKey:@"session_length"];
    [self parameters:parameters setDuration:activityState.timeSpent     forKey:@"time_spent"];
    [self parameters:parameters setString:activityState.uuid            forKey:@"ios_uuid"];

}

- (NSString *)eventSuffix:(ADJEvent*)event {
    if (event.revenue == nil) {
        return [NSString stringWithFormat:@" '%@'", event.eventToken];
    } else {
        return [NSString stringWithFormat:@" (%.4f %@, '%@')", [event.revenue doubleValue], event.currency, event.eventToken];
    }
}

- (void)parameters:(NSMutableDictionary *)parameters setString:(NSString *)value forKey:(NSString *)key {
    if (value == nil || [value isEqualToString:@""]) return;

    [parameters setObject:value forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setInt:(int)value forKey:(NSString *)key {
    if (value < 0) return;

    NSString *valueString = [NSString stringWithFormat:@"%d", value];
    [self parameters:parameters setString:valueString forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDate1970:(double)value forKey:(NSString *)key {
    if (value < 0) return;

    NSString *dateString = [ADJUtil formatSeconds1970:value];
    [self parameters:parameters setString:dateString forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDate:(NSDate *)value forKey:(NSString *)key {
    if (value == nil) return;

    NSString *dateString = [ADJUtil formatDate:value];
    [self parameters:parameters setString:dateString forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDuration:(double)value forKey:(NSString *)key {
    if (value < 0) return;

    int intValue = round(value);
    [self parameters:parameters setInt:intValue forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDictionaryJson:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (dictionary == nil) return;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *dictionaryString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self parameters:parameters setString:dictionaryString forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setBool:(BOOL)value forKey:(NSString *)key {
    int valueInt = [[NSNumber numberWithBool:value] intValue];

    [self parameters:parameters setInt:valueInt forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setNumberBool:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) return;

    BOOL boolValue = [value boolValue];

    [self parameters:parameters setBool:boolValue forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setNumber:(NSNumber *)value forKey:(NSString *)key {
    if (value == nil) return;

    NSString *numberString = [value stringValue];

    [self parameters:parameters setString:numberString forKey:key];
}


- (NSMutableDictionary *) joinParamters:(NSMutableDictionary *)permanentParameters
                             parameters:(NSMutableDictionary *)parameters {
    if (permanentParameters == nil) {
        return parameters;
    }
    if (parameters == nil) {
        return permanentParameters;
    }

    NSMutableDictionary *joinedParameters = [[NSMutableDictionary alloc] initWithDictionary:permanentParameters];
    [joinedParameters addEntriesFromDictionary:parameters];
    
    return joinedParameters;
}
@end


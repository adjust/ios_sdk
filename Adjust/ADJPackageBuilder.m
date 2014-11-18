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

#pragma mark -
@implementation ADJPackageBuilder

- (id)initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
        andActivityState:(ADJActivityState *)activityState
               andConfig:(ADJConfig *)adjustConfig
{
    self = [super init];
    if (self == nil) return nil;

    self.deviceInfo = deviceInfo;
    self.activityState = activityState;
    self.adjustConfig = adjustConfig;

    if (adjustConfig.delegate) {
        self.hasDelegate = YES;
    } else {
        self.hasDelegate = NO;
    }

    return self;
}

- (ADJActivityPackage *)buildSessionPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setDuration:self.activityState.lastInterval forKey:@"callback_params"];
    [self parameters:parameters setDictionaryJson:self.adjustConfig.callbackPermanentParameters forKey:@"callback_params"];
    [self parameters:parameters setDictionaryJson:self.adjustConfig.partnerPermanentParameters forKey:@"partner_params"];

    ADJActivityPackage *sessionPackage = [self defaultActivityPackage];
    sessionPackage.path = @"/startup";
    sessionPackage.activityKind = ADJActivityKindSession;
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;

    return sessionPackage;
}

- (ADJActivityPackage *)buildEventPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setInt:self.activityState.eventCount forKey:@"event_count"];
    [self parameters:parameters setString:self.amountString forKey:@"amount"];
    [self parameters:parameters setString:self.event.currency forKey:@"currency"];
    [self parameters:parameters setString:self.event.eventToken forKey:@"event_token"];

    // join the permanent parameters with the ones from the event
    NSMutableDictionary * callbackParameters = [self joinParamters:self.adjustConfig.callbackPermanentParameters parameters:self.event.callbackParameters];
    [self parameters:parameters setDictionaryJson:callbackParameters forKey:@"callback_params"];

    NSMutableDictionary * partnerParamters = [self joinParamters:self.adjustConfig.partnerPermanentParameters parameters:self.event.partnerParameters];
    [self parameters:parameters setDictionaryJson:partnerParamters forKey:@"partner_params"];

    ADJActivityPackage *eventPackage = [self defaultActivityPackage];
    eventPackage.path = @"/event";
    eventPackage.activityKind = ADJActivityKindEvent;
    eventPackage.suffix = self.eventSuffix;
    eventPackage.parameters = parameters;

    return eventPackage;
}

- (ADJActivityPackage *)buildClickPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setDictionaryJson:self.deeplinkParameters forKey:@"deeplink_params"];
    [self parameters:parameters setBool:self.deviceInfo.isIad             forKey:@"is_iad"];

    ADJActivityPackage *reattributionPackage = [self defaultActivityPackage];
    reattributionPackage.path = @"/sdk_click";
    reattributionPackage.activityKind = ADJActivityKindClick;
    reattributionPackage.suffix = @"";
    reattributionPackage.parameters = parameters;

    return reattributionPackage;
}

#pragma mark private
- (ADJActivityPackage *)defaultActivityPackage {
    ADJActivityPackage *activityPackage = [[ADJActivityPackage alloc] init];
    activityPackage.clientSdk = self.deviceInfo.clientSdk;
    return activityPackage;
}

- (NSMutableDictionary *)defaultParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [self constructDeviceInfo:self.deviceInfo withParameter:parameters andConfig:self.adjustConfig];
    [self constructActivityState:self.activityState withParamters:parameters];
    [self parameters:parameters setBool:self.hasDelegate forKey:@"has_delegate"];

    return parameters;
}

- (void) constructDeviceInfo:(ADJDeviceInfo *)deviceInfo
               withParameter:(NSMutableDictionary *) parameters
                   andConfig:(ADJConfig*) adjustConfig{

    [self constructUserAgent:deviceInfo.userAgent withParameters:parameters];

    [self parameters:parameters setString:deviceInfo.macSha1          forKey:@"mac_sha1"];
    [self parameters:parameters setString:deviceInfo.idForAdvertisers forKey:@"idfa"];
    [self parameters:parameters setString:deviceInfo.fbAttributionId  forKey:@"fb_id"];
    [self parameters:parameters setInt:deviceInfo.trackingEnabled     forKey:@"tracking_enabled"];
    [self parameters:parameters setString:deviceInfo.vendorId         forKey:@"idfv"];
    [self parameters:parameters setString:deviceInfo.pushToken        forKey:@"push_token"];

    if (adjustConfig.macMd5TrackingEnabled) {
        [self parameters:parameters setString:deviceInfo.macShortMd5  forKey:@"mac_md5"];
    }

    [self parameters:parameters setString:adjustConfig.appToken    forKey:@"app_token"];
    [self parameters:parameters setString:adjustConfig.environment forKey:@"environment"];
}

- (void) constructActivityState:(ADJActivityState *)activityState
                  withParamters:(NSMutableDictionary *)parameters {
    [self parameters:parameters setDate:activityState.createdAt            forKey:@"created_at"];
    [self parameters:parameters setInt:activityState.sessionCount          forKey:@"session_count"];
    [self parameters:parameters setInt:activityState.subsessionCount       forKey:@"subsession_count"];
    [self parameters:parameters setDuration:activityState.sessionLength    forKey:@"session_length"];
    [self parameters:parameters setDuration:activityState.timeSpent        forKey:@"time_spent"];
    [self parameters:parameters setString:activityState.uuid               forKey:@"ios_uuid"];

}

- (void) constructUserAgent:(ADJUserAgent *)userAgent
             withParameters:(NSMutableDictionary *) parameters {
    [self parameters:parameters setString:userAgent.bundeIdentifier forKey:@"bundle_id"];
    [self parameters:parameters setString:userAgent.bundleVersion   forKey:@"app_version"];
    [self parameters:parameters setString:userAgent.deviceType      forKey:@"device_type"];
    [self parameters:parameters setString:userAgent.deviceName      forKey:@"device_name"];
    [self parameters:parameters setString:userAgent.osName          forKey:@"os_name"];
    [self parameters:parameters setString:userAgent.systemVersion   forKey:@"os_version"];
    [self parameters:parameters setString:userAgent.languageCode    forKey:@"language"];
    [self parameters:parameters setString:userAgent.countryCode     forKey:@"country"];
    [self parameters:parameters setString:userAgent.networkType     forKey:@"network_type"];
    [self parameters:parameters setString:userAgent.mobileCountryCode forKey:@"mobile_country_code"];
    [self parameters:parameters setString:userAgent.mobileNetworkCode forKey:@"mobile_network_code"];
}


- (NSString *)amountString {
    if (self.event.revenue == nil || [self.event.revenue doubleValue] == 0) {
        return nil;
    }
    double revenue = [self.event.revenue doubleValue];
    int amountInMillis = round(1000 * revenue);
    self.event.revenue = [NSNumber  numberWithDouble:(amountInMillis / 1000.0)]; // now rounded to one decimal point
    NSString *amountString = [NSNumber numberWithInt:amountInMillis].stringValue;
    return amountString;
}

- (NSString *)eventSuffix {
    if (self.event.revenue == nil) {
        return [NSString stringWithFormat:@" '%@'", self.event.eventToken];
    } else {
        return [NSString stringWithFormat:@" (%.3f cent, '%@')", [self.event.revenue doubleValue], self.event.eventToken];
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

- (void)parameters:(NSMutableDictionary *)parameters setDate:(double)value forKey:(NSString *)key {
    if (value < 0) return;

    NSString *dateString = [ADJUtil dateFormat:value];
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
    if (value < 0) return;

    int valueInt = [[NSNumber numberWithBool:value] intValue];

    [self parameters:parameters setInt:valueInt forKey:key];
}

- (NSMutableDictionary *) joinParamters:(NSMutableDictionary *)permanentParameters
                             parameters:(NSMutableDictionary *)parameters {
    if (permanentParameters == nil) {
        return parameters;
    }
    if (parameters == nil) {
        return permanentParameters;
    }
    [permanentParameters addEntriesFromDictionary:parameters];

    return permanentParameters;
}
@end


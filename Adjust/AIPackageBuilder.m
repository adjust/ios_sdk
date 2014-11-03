//
//  AIPackageBuilder.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "AIPackageBuilder.h"
#import "AIActivityPackage.h"
#import "AIUtil.h"

#pragma mark -
@implementation AIPackageBuilder

- (AIActivityPackage *)buildSessionPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setDuration:self.activityState.lastInterval forKey:@"last_interval"];
    [self parameters:parameters setDictionaryJson:self.deviceInfo.adjustConfig.callbackPermanentParameters forKey:@"callback_params"];
    [self parameters:parameters setDictionaryJson:self.deviceInfo.adjustConfig.partnerPermanentParameters forKey:@"partner_params"];

    AIActivityPackage *sessionPackage = [self defaultActivityPackage];
    sessionPackage.path = @"/startup";
    sessionPackage.activityKind = AIActivityKindSession;
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;

    return sessionPackage;
}

- (AIActivityPackage *)buildEventPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setInt:self.activityState.eventCount forKey:@"event_count"];
    [self parameters:parameters setString:self.amountString forKey:@"amount"];
    [self parameters:parameters setString:self.event.currency forKey:@"currency"];
    [self parameters:parameters setString:self.event.eventToken forKey:@"event_token"];

    // join the permanent parameters with the ones from the event
    NSMutableDictionary * callbackParameters = [self joinParamters:self.deviceInfo.adjustConfig.callbackPermanentParameters parameters:self.event.callbackParameters];
    [self parameters:parameters setDictionaryJson:callbackParameters forKey:@"callback_params"];

    NSMutableDictionary * partnerParamters = [self joinParamters:self.deviceInfo.adjustConfig.partnerPermanentParameters parameters:self.event.partnerParameters];
    [self parameters:parameters setDictionaryJson:partnerParamters forKey:@"partner_params"];

    AIActivityPackage *eventPackage = [self defaultActivityPackage];
    eventPackage.path = @"/event";
    eventPackage.activityKind = AIActivityKindEvent;
    eventPackage.suffix = self.eventSuffix;
    eventPackage.parameters = parameters;

    return eventPackage;
}

- (AIActivityPackage *)buildClickPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setDictionaryJson:self.deeplinkParameters forKey:@"deeplink_parameters"];
    [self parameters:parameters setBool:self.deviceInfo.isIad             forKey:@"is_iad"];

    AIActivityPackage *reattributionPackage = [self defaultActivityPackage];
    reattributionPackage.path = @"/reattribute";
    reattributionPackage.activityKind = AIActivityKindReattribution;
    reattributionPackage.suffix = @"";
    reattributionPackage.parameters = parameters;

    return reattributionPackage;
}

#pragma mark private
- (AIActivityPackage *)defaultActivityPackage {
    AIActivityPackage *activityPackage = [[AIActivityPackage alloc] init];
    activityPackage.clientSdk = self.deviceInfo.clientSdk;
    return activityPackage;
}

- (NSMutableDictionary *)defaultParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    [self constructDeviceInfo:self.deviceInfo withParameter:parameters];
    [self constructActivityState:self.activityState withParamters:parameters];

    return parameters;
}

- (void) constructDeviceInfo:(AIDeviceInfo *)deviceInfo
               withParameter:(NSMutableDictionary *) parameters{

    [self constructUserAgent:deviceInfo.userAgent withParameters:parameters];

    [self parameters:parameters setString:deviceInfo.macSha1          forKey:@"mac_sha1"];
    [self parameters:parameters setString:deviceInfo.idForAdvertisers forKey:@"idfa"];
    [self parameters:parameters setString:deviceInfo.fbAttributionId  forKey:@"fb_id"];
    [self parameters:parameters setInt:deviceInfo.trackingEnabled     forKey:@"tracking_enabled"];
    [self parameters:parameters setString:deviceInfo.vendorId         forKey:@"idfv"];
    [self parameters:parameters setString:deviceInfo.pushToken        forKey:@"push_token"];

    if (deviceInfo.adjustConfig.macMd5TrackingEnabled) {
        [self parameters:parameters setString:deviceInfo.macShortMd5          forKey:@"mac_md5"];
    }

    [self parameters:parameters setString:deviceInfo.adjustConfig.appToken    forKey:@"app_token"];
    [self parameters:parameters setString:deviceInfo.adjustConfig.environment forKey:@"environment"];
}

- (void) constructActivityState:(AIActivityState *)activityState
                  withParamters:(NSMutableDictionary *)parameters {
    [self parameters:parameters setDate:activityState.createdAt            forKey:@"created_at"];
    [self parameters:parameters setInt:activityState.sessionCount          forKey:@"session_count"];
    [self parameters:parameters setInt:activityState.subsessionCount       forKey:@"subsession_count"];
    [self parameters:parameters setDuration:activityState.sessionLength    forKey:@"session_length"];
    [self parameters:parameters setDuration:activityState.timeSpent        forKey:@"time_spent"];
    [self parameters:parameters setString:activityState.uuid               forKey:@"ios_uuid"];

}

- (void) constructUserAgent:(AIUserAgent *)userAgent
             withParameters:(NSMutableDictionary *) parameters {
    [self parameters:parameters setString:userAgent.bundeIdentifier forKey:@"bundle_identifier"];
    [self parameters:parameters setString:userAgent.bundleVersion   forKey:@"bundle_version"];
    [self parameters:parameters setString:userAgent.deviceType      forKey:@"device_type"];
    [self parameters:parameters setString:userAgent.deviceName      forKey:@"device_name"];
    [self parameters:parameters setString:userAgent.osName          forKey:@"os_name"];
    [self parameters:parameters setString:userAgent.systemVersion   forKey:@"system_version"];
    [self parameters:parameters setString:userAgent.languageCode    forKey:@"language_code"];
    [self parameters:parameters setString:userAgent.countryCode     forKey:@"country_code"];
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

    NSString *dateString = [AIUtil dateFormat:value];
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


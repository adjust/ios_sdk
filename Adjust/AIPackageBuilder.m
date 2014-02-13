//
//  AIPackageBuilder.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIPackageBuilder.h"
#import "AIActivityPackage.h"
#import "NSData+AIAdditions.h"

static NSString * const kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'Z";
static NSDateFormatter * dateFormat;

#pragma mark -
@implementation AIPackageBuilder

- (AIActivityPackage *)buildSessionPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setDuration:self.lastInterval forKey:@"last_interval"];

    AIActivityPackage *sessionPackage = [self defaultActivityPackage];
    sessionPackage.path = @"/startup";
    sessionPackage.activityKind = AIActivityKindSession;
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;

    return sessionPackage;
}

- (AIActivityPackage *)buildEventPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self injectEventParameters:parameters];

    AIActivityPackage *eventPackage = [self defaultActivityPackage];
    eventPackage.path = @"/event";
    eventPackage.activityKind = AIActivityKindEvent;
    eventPackage.suffix = self.eventSuffix;
    eventPackage.parameters = parameters;

    return eventPackage;
}

- (AIActivityPackage *)buildRevenuePackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self parameters:parameters setString:self.amountString forKey:@"amount"];
    [self injectEventParameters:parameters];

    AIActivityPackage *revenuePackage = [self defaultActivityPackage];
    revenuePackage.path = @"/revenue";
    revenuePackage.activityKind = AIActivityKindRevenue;
    revenuePackage.suffix = self.revenueSuffix;
    revenuePackage.parameters = parameters;

    return revenuePackage;
}

#pragma mark private
- (AIActivityPackage *)defaultActivityPackage {
    AIActivityPackage *activityPackage = [[AIActivityPackage alloc] init];
    activityPackage.userAgent = self.userAgent;
    activityPackage.clientSdk = self.clientSdk;
    return activityPackage;
}

- (NSMutableDictionary *)defaultParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    // general
    [self parameters:parameters setDate:self.createdAt          forKey:@"created_at"];
    [self parameters:parameters setString:self.appToken         forKey:@"app_token"];
    [self parameters:parameters setString:self.macSha1          forKey:@"mac_sha1"];
    [self parameters:parameters setString:self.macShortMd5      forKey:@"mac_md5"];
    [self parameters:parameters setString:self.uuid             forKey:@"ios_uuid"];
    [self parameters:parameters setString:self.idForAdvertisers forKey:@"idfa"];
    [self parameters:parameters setString:self.fbAttributionId  forKey:@"fb_id"];
    [self parameters:parameters setString:self.environment      forKey:@"environment"];
    [self parameters:parameters setInt:self.trackingEnabled     forKey:@"tracking_enabled"];

    // session related (used for events as well)
    [self parameters:parameters setInt:self.sessionCount         forKey:@"session_count"];
    [self parameters:parameters setInt:self.subsessionCount      forKey:@"subsession_count"];
    [self parameters:parameters setDuration:self.sessionLength   forKey:@"session_length"];
    [self parameters:parameters setDuration:self.timeSpent       forKey:@"time_spent"];

    return parameters;
}

- (void)injectEventParameters:(NSMutableDictionary *)parameters {
    // event specific
    [self parameters:parameters setInt:self.eventCount                forKey:@"event_count"];
    [self parameters:parameters setString:self.eventToken             forKey:@"event_token"];
    [self parameters:parameters setDictionary:self.callbackParameters forKey:@"params"];
}

- (NSString *)amountString {
    int amountInMillis = round(10 * self.amountInCents);
    self.amountInCents = amountInMillis / 10.0; // now rounded to one decimal point
    NSString *amountString = [NSNumber numberWithInt:amountInMillis].stringValue;
    return amountString;
}

- (NSString *)eventSuffix {
    return [NSString stringWithFormat:@" '%@'", self.eventToken];
}

- (NSString *)revenueSuffix {
    if (self.eventToken != nil) {
        return [NSString stringWithFormat:@" (%.1f cent, '%@')", self.amountInCents, self.eventToken];
    } else {
        return [NSString stringWithFormat:@" (%.1f cent)", self.amountInCents];
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

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];
    NSString *dateString = [self.dateFormat stringFromDate:date];
    [self parameters:parameters setString:dateString forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDuration:(double)value forKey:(NSString *)key {
    if (value < 0) return;

    int intValue = round(value);
    [self parameters:parameters setInt:intValue forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (dictionary == nil) return;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *dictionaryString = jsonData.aiEncodeBase64;
    [self parameters:parameters setString:dictionaryString forKey:key];
}

- (NSDateFormatter *)dateFormat {
    if (dateFormat == nil) {
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:kDateFormat];
    }
    return dateFormat;
}

@end


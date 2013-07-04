//
//  AIPackageBuilder.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 03.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIPackageBuilder.h"
#import "AIActivityPackage.h"
#import "NSData+AIAdditions.h"

@implementation AIPackageBuilder

- (AIActivityPackage *)buildSessionPackage {
    NSMutableDictionary *parameters = [self defaultParameters];

    AIActivityPackage *sessionPackage = [[AIActivityPackage alloc] init];
    sessionPackage.path = @"/startup";
    sessionPackage.kind = @"session start";
    sessionPackage.suffix = @"";
    sessionPackage.parameters = parameters;
    sessionPackage.userAgent = self.userAgent;

    return sessionPackage;
}

- (AIActivityPackage *)buildEventPackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self injectEventParameters:parameters];

    AIActivityPackage *eventPackage = [[AIActivityPackage alloc] init];
    eventPackage.path = @"/event";
    eventPackage.kind = @"event";
    eventPackage.suffix = self.eventSuffix;
    eventPackage.parameters = parameters;
    eventPackage.userAgent = self.userAgent;

    return eventPackage;
}

- (AIActivityPackage *)buildRevenuePackage {
    NSMutableDictionary *parameters = [self defaultParameters];
    [self injectEventParameters:parameters];
    [self parameters:parameters setString:self.amountString forKey:@"amount"];

    AIActivityPackage *revenuePackage = [[AIActivityPackage alloc] init];
    revenuePackage.path = @"/revenue";
    revenuePackage.kind = @"revenue";
    revenuePackage.suffix = self.revenueSuffix;
    revenuePackage.parameters = parameters;
    revenuePackage.userAgent = self.userAgent;

    return revenuePackage;
}

#pragma mark private

- (NSMutableDictionary *)defaultParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

    // general
    [self parameters:parameters setDate:self.createdAt forKey:@"created_at"];
    [self parameters:parameters setString:self.appToken forKey:@"app_token"];
    [self parameters:parameters setString:self.macSha1 forKey:@"mac_sha1"];
    [self parameters:parameters setString:self.macShortMd5 forKey:@"mac"]; // TODO: rename parameter
    [self parameters:parameters setString:self.idForAdvertisers forKey:@"idfa"];
    [self parameters:parameters setString:self.attributionId forKey:@"fb_id"];

    // session related (used for events as well)
    [self parameters:parameters setInt:self.sessionCount forKey:@"session_id"]; // TODO: rename parameters
    [self parameters:parameters setInt:self.subsessionCount forKey:@"subsession_count"];
    [self parameters:parameters setDuration:self.sessionLength forKey:@"session_length"];
    [self parameters:parameters setDuration:self.timeSpent forKey:@"time_spent"];
    [self parameters:parameters setDuration:self.lastInterval forKey:@"last_interval"];

    return parameters;
}

- (void)injectEventParameters:(NSMutableDictionary *)parameters {
    // event specific
    [self parameters:parameters setInt:self.eventCount forKey:@"event_count"];
    [self parameters:parameters setString:self.eventToken forKey:@"event_id"]; // TODO: rename parameters
    [self parameters:parameters setDictionary:self.callbackParameters forKey:@"params"];
}

- (NSString *)amountString {
    int amountInMillis = roundf(10 * self.amountInCents);
    self.amountInCents = amountInMillis / 10.0f; // now rounded to one decimal point
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
    NSString *dateString = date.description; // TODO: format
    [self parameters:parameters setString:dateString forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDuration:(double)value forKey:(NSString *)key {
    if (value < 0) return;

    int intValue = (int)round(value);   // TODO: test rounding
    [self parameters:parameters setInt:intValue forKey:key];
}

- (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key {
    if (dictionary == nil) return;

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString *dictionaryString = jsonData.aiEncodeBase64;
    [self parameters:parameters setString:dictionaryString forKey:key];
}

@end

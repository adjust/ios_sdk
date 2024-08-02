//
//  ADJResponseData.m
//  adjust
//
//  Created by Pedro Filipe on 07/12/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import "ADJResponseData.h"
#import "ADJActivityKind.h"

@implementation ADJResponseData

- (id)init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    return self;
}

+ (ADJResponseData *)responseData {
    return [[ADJResponseData alloc] init];
}

+ (id)buildResponseData:(ADJActivityPackage *)activityPackage {
    ADJActivityKind activityKind;
    
    if (activityPackage == nil) {
        activityKind = ADJActivityKindUnknown;
    } else {
        activityKind = activityPackage.activityKind;
    }

    ADJResponseData *responseData = nil;

    switch (activityKind) {
        case ADJActivityKindSession:
            responseData = [[ADJSessionResponseData alloc] init];
            break;
        case ADJActivityKindClick:
            responseData = [[ADJSdkClickResponseData alloc] init];
            responseData.sdkClickPackage = activityPackage;
            break;
        case ADJActivityKindEvent:
            responseData = [[ADJEventResponseData alloc]
                                initWithEventToken:
                                    [activityPackage.parameters
                                        objectForKey:@"event_token"]
                                callbackId:
                                    [activityPackage.parameters
                                        objectForKey:@"event_callback_id"]];
            break;
        case ADJActivityKindAttribution:
            responseData = [[ADJAttributionResponseData alloc] init];
            break;
        case ADJActivityKindPurchaseVerification:
            responseData = [[ADJPurchaseVerificationResponseData alloc] init];
            responseData.purchaseVerificationPackage = activityPackage;
            break;
        default:
            responseData = [[ADJResponseData alloc] init];
            break;
    }

    responseData.sdkPackage = activityPackage;
    responseData.activityKind = activityKind;

    return responseData;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ adid:%@ success:%d willRetry:%d attribution:%@ trackingState:%d, json:%@",
            self.message, self.timestamp, self.adid, self.success, self.willRetry, self.attribution, self.trackingState, self.jsonResponse];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ADJResponseData* copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.message = [self.message copyWithZone:zone];
        copy.timestamp = [self.timestamp copyWithZone:zone];
        copy.adid = [self.adid copyWithZone:zone];
        copy.continueInMilli = [self.continueInMilli copyWithZone:zone];
        copy.retryInMilli = [self.retryInMilli copyWithZone:zone];
        copy.willRetry = self.willRetry;
        copy.trackingState = self.trackingState;
        copy.jsonResponse = [self.jsonResponse copyWithZone:zone];
        copy.attribution = [self.attribution copyWithZone:zone];
        copy.errorCode = [self.errorCode copyWithZone:zone];
    }

    return copy;
}

@end

@implementation ADJSessionResponseData

- (ADJSessionSuccess *)successResponseData {
    ADJSessionSuccess *successResponseData = [[ADJSessionSuccess alloc] init];

    successResponseData.message = self.message;
    successResponseData.timestamp = self.timestamp;
    successResponseData.adid = self.adid;
    successResponseData.jsonResponse = self.jsonResponse;

    return successResponseData;
}

- (ADJSessionFailure *)failureResponseData {
    ADJSessionFailure *failureResponseData = [[ADJSessionFailure alloc] init];

    failureResponseData.message = self.message;
    failureResponseData.timestamp = self.timestamp;
    failureResponseData.adid = self.adid;
    failureResponseData.willRetry = self.willRetry;
    failureResponseData.jsonResponse = self.jsonResponse;

    return failureResponseData;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJSessionResponseData* copy = [super copyWithZone:zone];
    return copy;
}

@end

@implementation ADJSdkClickResponseData

@end

@implementation ADJPurchaseVerificationResponseData

@end

@implementation ADJEventResponseData

- (id)initWithEventToken:(NSString *)eventToken
       callbackId:(NSString *)callbackId
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }

    self.eventToken = eventToken;
    self.callbackId = callbackId;

    return self;
}

- (ADJEventSuccess *)successResponseData {
    ADJEventSuccess *successResponseData = [[ADJEventSuccess alloc] init];

    successResponseData.message = self.message;
    successResponseData.timestamp = self.timestamp;
    successResponseData.adid = self.adid;
    successResponseData.eventToken = self.eventToken;
    successResponseData.callbackId = self.callbackId;
    successResponseData.jsonResponse = self.jsonResponse;

    return successResponseData;
}

- (ADJEventFailure *)failureResponseData {
    ADJEventFailure *failureResponseData = [[ADJEventFailure alloc] init];

    failureResponseData.message = self.message;
    failureResponseData.timestamp = self.timestamp;
    failureResponseData.adid = self.adid;
    failureResponseData.eventToken = self.eventToken;
    failureResponseData.callbackId = self.callbackId;
    failureResponseData.willRetry = self.willRetry;
    failureResponseData.jsonResponse = self.jsonResponse;

    return failureResponseData;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ adid:%@ eventToken:%@ success:%d willRetry:%d attribution:%@ json:%@",
            self.message, self.timestamp, self.adid, self.eventToken, self.success, self.willRetry, self.attribution, self.jsonResponse];
}

- (id)copyWithZone:(NSZone *)zone {
    ADJEventResponseData *copy = [super copyWithZone:zone];

    if (copy) {
        copy.eventToken = [self.eventToken copyWithZone:zone];
    }

    return copy;
}

@end

@implementation ADJAttributionResponseData

- (id)copyWithZone:(NSZone *)zone {
    ADJAttributionResponseData *copy = [super copyWithZone:zone];
    
    return copy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ adid:%@ success:%d willRetry:%d attribution:%@ deeplink:%@ json:%@",
            self.message, self.timestamp, self.adid, self.success, self.willRetry, self.attribution, self.deeplink, self.jsonResponse];
}

@end


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

+ (ADJResponseData *)responseDataWithActivityPackage:(ADJActivityPackage *)activityPackage {
    return [[ADJResponseData alloc] initWithActivityPackage:activityPackage];
}

- (id)initWithActivityPackage:(ADJActivityPackage *)activityPackage {
    self = [super init];
    if (self == nil) return nil;

    self.activityKind = activityPackage.activityKind;
    self.eventToken = [activityPackage.parameters objectForKey:@"event_token"];

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ adid:%@ eventToken:%@ success:%d willRetry:%d attribution:%@ json:%@",
            self.message, self.timeStamp, self.adid, self.eventToken, self.success, self.willRetry, self.attribution, self.jsonResponse];
}

- (ADJSuccessResponseData *)successResponseData {
    ADJSuccessResponseData * successResponseData = [ADJSuccessResponseData successResponseData];
    successResponseData.activityKindString = [ADJActivityKindUtil activityKindToString:self.activityKind];
    successResponseData.message = self.message;
    successResponseData.timeStamp = self.timeStamp;
    successResponseData.adid = self.adid;
    successResponseData.eventToken = self.eventToken;
    successResponseData.jsonResponse = self.jsonResponse;

    return successResponseData;
}

- (ADJFailureResponseData *)failureResponseData {
    ADJFailureResponseData * failureResponseData = [ADJFailureResponseData failureResponseData];
    failureResponseData.activityKindString = [ADJActivityKindUtil activityKindToString:self.activityKind];
    failureResponseData.message = self.message;
    failureResponseData.timeStamp = self.timeStamp;
    failureResponseData.adid = self.adid;
    failureResponseData.eventToken = self.eventToken;
    failureResponseData.willRetry = self.willRetry;
    failureResponseData.jsonResponse = self.jsonResponse;

    return failureResponseData;
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    ADJResponseData* copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.activityKind = self.activityKind;
        copy.message      = [self.message copyWithZone:zone];
        copy.timeStamp    = [self.timeStamp copyWithZone:zone];
        copy.adid         = [self.adid copyWithZone:zone];
        copy.eventToken   = [self.eventToken copyWithZone:zone];
        copy.success      = self.success;
        copy.willRetry    = self.willRetry;
        copy.jsonResponse = [self.jsonResponse copyWithZone:zone];
        copy.attribution  = [self.attribution copyWithZone:zone];
    }

    return copy;
}

@end
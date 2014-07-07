//
//  AIResponseData.m
//  Adjust
//
//  Created by Christian Wellenbrock on 07.02.14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIResponseData.h"
#import "NSString+AIAdditions.h"

@implementation AIResponseData

+ (AIResponseData *)dataWithJsonDict:(NSDictionary *)jsonDict jsonString:(NSString *)jsonString {
    return [[AIResponseData alloc] initWithJsonDict:jsonDict jsonString:jsonString];
}

+ (AIResponseData *)dataWithError:(NSString *)error {
    return [[AIResponseData alloc] initWithError:error];
}

- (id)initWithJsonDict:(NSDictionary *)jsonDict jsonString:(NSString *)jsonString {
    self = [super init];
    if (self == nil) return nil;

    if (jsonDict == nil) {
        self.error = [NSString stringWithFormat:@"Failed to parse json response: %@", jsonString.aiTrim];
        return self;
    }

    self.error        = [jsonDict objectForKey:@"error"];
    self.trackerToken = [jsonDict objectForKey:@"tracker_token"];
    self.trackerName  = [jsonDict objectForKey:@"tracker_name"];
    self.network      = [jsonDict objectForKey:@"network"];
    self.campaign     = [jsonDict objectForKey:@"campaign"];
    self.adgroup      = [jsonDict objectForKey:@"adgroup"];
    self.creative     = [jsonDict objectForKey:@"creative"];

    return self;
}

- (id)initWithError:(NSString *)error {
    self = [super init];
    if (self == nil) return nil;

    self.success = NO;
    self.error   = error;

    return self;
}

- (NSString *)activityKindString {
    return AIActivityKindToString(self.activityKind);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[kind:%@ success:%d willRetry:%d "
                                        "error:%@ trackerToken:%@ trackerName:%@ "
                                        "network:%@ campaign:%@ adgroup:%@ creative:%@]",
            self.activityKindString,
            self.success,
            self.willRetry,
            self.error.aiQuote,
            self.trackerToken,
            self.trackerName.aiQuote,
            self.network.aiQuote,
            self.campaign.aiQuote,
            self.adgroup.aiQuote,
            self.creative.aiQuote];
}

- (NSDictionary *)dictionary {
    NSMutableDictionary * responseDataDic = [NSMutableDictionary dictionaryWithDictionary:@{
        @"activityKind" : self.activityKindString,
        @"success" : (self.success ? @"true" : @"false"),
        @"willRetry" : (self.willRetry ? @"true" : @"false"),
    }];

    if (self.error != nil) {
        [responseDataDic setObject:self.error forKey:@"error"];
    }

    if (self.trackerToken != nil) {
        [responseDataDic setObject:self.trackerToken forKey:@"trackerToken"];
    }

    if (self.trackerName != nil) {
        [responseDataDic setObject:self.trackerName forKey:@"trackerName"];
    }

    if (self.network != nil) {
        [responseDataDic setObject:self.network forKey:@"network"];
    }

    if (self.campaign != nil) {
        [responseDataDic setObject:self.campaign forKey:@"campaign"];
    }

    if (self.adgroup != nil) {
        [responseDataDic setObject:self.adgroup forKey:@"adgroup"];
    }

    if (self.creative != nil) {
        [responseDataDic setObject:self.creative forKey:@"creative"];
    }

    return responseDataDic;
}

@end

//
//  AIResponseData.m
//  Adjust
//
//  Created by Christian Wellenbrock on 07.02.14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIResponseData.h"
#import "NSString+AIAdditions.h"

@implementation AIResponseData

+ (AIResponseData *)dataWithJsonString:(NSString *)string {
    return [[AIResponseData alloc] initWithJsonString:string];
}

+ (AIResponseData *)dataWithError:(NSString *)error {
    return [[AIResponseData alloc] initWithError:error];
}

- (id)initWithJsonString:(NSString *)jsonString {
    self = [super init];
    if (self == nil) return nil;

    NSError *error = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (error != nil) {
        self.error = [NSString stringWithFormat:@"Failed to parse json response: %@", jsonString.aiTrim];
        return self;
    }

    self.error        = [jsonDict objectForKey:@"error"];
    self.trackerToken = [jsonDict objectForKey:@"tracker_token"];
    self.trackerName  = [jsonDict objectForKey:@"tracker_name"];

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
    return [NSString stringWithFormat:@"[kind:%@ success:%d willRetry:%d error:%@ trackerToken:%@ trackerName:%@]",
            self.activityKindString,
            self.success,
            self.willRetry,
            self.error.aiQuote,
            self.trackerToken,
            self.trackerName.aiQuote];
}

@end

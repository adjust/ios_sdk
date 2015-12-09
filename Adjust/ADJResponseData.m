//
//  ADJResponseData.m
//  adjust
//
//  Created by Pedro Filipe on 07/12/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import "ADJResponseData.h"

@implementation ADJResponseData

+ (ADJResponseData *)responseData {
    return [[ADJResponseData alloc] init];
}

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"message:%@ timestamp:%@ json:%@",
            self.message, self.timeStamp, self.jsonResponse];
}

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    ADJResponseData* copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy.message      = [self.message copyWithZone:zone];
        copy.timeStamp    = [self.timeStamp copyWithZone:zone];
        copy.jsonResponse = [self.jsonResponse copyWithZone:zone];
    }

    return copy;
}

@end
//
//  NSNumber+ADJAdditions.m
//  Adjust SDK
//
//  Created by Uglješa Erceg (@uerceg) on 26th March 2021.
//  Copyright (c) 2021 Adjust GmbH. All rights reserved.
//

#import "NSNumber+ADJAdditions.h"

@implementation NSNumber(ADJAdditions)

+ (BOOL)adjIsEqual:(NSNumber *)first toNumber:(NSNumber *)second {
    if (first == nil && second == nil) {
        return YES;
    }
    return [first isEqualToNumber:second];
}

@end

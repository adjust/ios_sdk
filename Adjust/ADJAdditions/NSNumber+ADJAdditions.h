//
//  NSNumber+ADJAdditions.h
//  Adjust SDK
//
//  Created by Uglješa Erceg (@uerceg) on 26th March 2021.
//  Copyright (c) 2021 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber(ADJAdditions)

+ (BOOL)adjIsEqual:(NSNumber *)first toNumber:(NSNumber *)second;

@end

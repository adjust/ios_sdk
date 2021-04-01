//
//  NSString+ADJAdditions.h
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 23rd July 2012.
//  Copyright (c) 2012-2021 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(ADJAdditions)

- (NSString *)adjSha256;
- (NSString *)adjTrim;
- (NSString *)adjUrlEncode;
- (NSString *)adjUrlDecode;

+ (NSString *)adjJoin:(NSString *)strings, ...;
+ (BOOL) adjIsEqual:(NSString *)first toString:(NSString *)second;

@end

//
//  ADJAdditions.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on 29th May 2024
//  Copyright © 2024 Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJAdditions : NSObject

+ (NSString *)adjJoin:(NSString *)strings, ...;

+ (NSString *)adjTrim:(NSString *)stringToTrim;

+ (NSString *)adjUrlEncode:(NSString *)stringToEncode;

+ (NSString *)adjUrlDecode:(NSString *)stringToDecode;

+ (NSString *)adjEncodeBase64:(NSData *)dataToEncode;

+ (BOOL)adjIsStringEqual:(NSString *)first toString:(NSString *)second;

+ (BOOL)adjIsNumberEqual:(NSNumber *)first toNumber:(NSNumber *)second;

@end

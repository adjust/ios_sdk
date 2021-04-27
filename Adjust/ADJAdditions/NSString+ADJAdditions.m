//
//  NSString+ADJAdditions.m
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 23rd July 2012.
//  Copyright (c) 2012-2021 Adjust GmbH. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>

#import "NSString+ADJAdditions.h"

@implementation NSString(ADJAdditions)

+ (NSString *)adjJoin:(NSString *)first, ... {
    NSString *iter, *result = first;
    va_list strings;
    va_start(strings, first);
    while ((iter = va_arg(strings, NSString*))) {
        NSString *capitalized = iter.capitalizedString;
        result = [result stringByAppendingString:capitalized];
    }
    va_end(strings);
    return result;
}

+ (BOOL)adjIsEqual:(NSString *)first toString:(NSString *)second {
    if (first == nil && second == nil) {
        return YES;
    }
    return [first isEqualToString:second];
}

- (NSString *)adjTrim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)adjUrlEncode {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                 NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
#pragma clang diagnostic pop
    // Alternative:
    // return [self stringByAddingPercentEncodingWithAllowedCharacters:
    //        [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "]];
}

- (NSString *)adjUrlDecode {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(
                                                                                 kCFAllocatorDefault,
                                                                                 (CFStringRef)self,
                                                                                 CFSTR("")));
}

- (NSString *)adjSha256 {
    const char* str = [self UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (CC_LONG)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i<CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end

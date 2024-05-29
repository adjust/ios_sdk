//
//  ADJAdditions.m
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on 29th May 2024
//  Copyright © 2024 Adjust. All rights reserved.
//

#import "ADJAdditions.h"

@implementation ADJAdditions

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

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

+ (NSString *)adjTrim:(NSString *)stringToTrim {
    return [stringToTrim stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)adjUrlEncode:(NSString *)stringToEncode {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)stringToEncode,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
#pragma clang diagnostic pop
    // Alternative:
    // return [self stringByAddingPercentEncodingWithAllowedCharacters:
    //        [NSCharacterSet characterSetWithCharactersInString:@"!*'\"();:@&=+$,/?%#[]% "]];
}

+ (NSString *)adjUrlDecode:(NSString *)stringToDecode {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault,
                                                                                     (CFStringRef)stringToDecode,
                                                                                     CFSTR("")));
}

// http://stackoverflow.com/a/4727124
+ (NSString *)adjEncodeBase64:(NSData *)dataToEncode {
    const unsigned char* objRawData = dataToEncode.bytes;
    char* objPointer;
    char* strResult;

    // get the raw data length and ensure we actually have data
    NSUInteger intLength = dataToEncode.length;
    if (intLength == 0) {
        return nil;
    }

    // setup the string-based result placeholder and pointer within that placeholder
    strResult = (char *)calloc((((intLength + 2) / 3) * 4) + 1, sizeof(char));
    objPointer = strResult;

    // iterate through everything
    while (intLength > 2) { // keep going until we have less than 24 bits
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
        *objPointer++ = _base64EncodingTable[((objRawData[1] & 0x0f) << 2) + (objRawData[2] >> 6)];
        *objPointer++ = _base64EncodingTable[objRawData[2] & 0x3f];

        // we just handled 3 octets (24 bits) of data
        objRawData += 3;
        intLength -= 3;
    }

    // now deal with the tail end of things
    if (intLength != 0) {
        *objPointer++ = _base64EncodingTable[objRawData[0] >> 2];
        if (intLength > 1) {
            *objPointer++ = _base64EncodingTable[((objRawData[0] & 0x03) << 4) + (objRawData[1] >> 4)];
            *objPointer++ = _base64EncodingTable[(objRawData[1] & 0x0f) << 2];
            *objPointer++ = '=';
        } else {
            *objPointer++ = _base64EncodingTable[(objRawData[0] & 0x03) << 4];
            *objPointer++ = '=';
            *objPointer++ = '=';
        }
    }

    // terminate the string-based result
    *objPointer = '\0';

    // return the results as an NSString object
    NSString *encodedString = [NSString stringWithCString:strResult encoding:NSASCIIStringEncoding];
    free(strResult);
    return encodedString;
}

+ (BOOL)adjIsStringEqual:(NSString *)first toString:(NSString *)second {
    if (first == nil && second == nil) {
        return YES;
    }
    return [first isEqualToString:second];
}

+ (BOOL)adjIsNumberEqual:(NSNumber *)first toNumber:(NSNumber *)second {
    if (first == nil && second == nil) {
        return YES;
    }
    return [first isEqualToNumber:second];
}

@end

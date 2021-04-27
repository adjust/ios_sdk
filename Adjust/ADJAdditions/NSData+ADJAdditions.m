//
//  NSData+ADJAdditions.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 26th March 2015.
//  Copyright (c) 2015-2021 Adjust GmbH. All rights reserved.
//

#import "NSData+ADJAdditions.h"

@implementation NSData(ADJAdditions)

static const char _base64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

// http://stackoverflow.com/a/4727124
- (NSString *)adjEncodeBase64 {
    const unsigned char* objRawData = self.bytes;
    char* objPointer;
    char* strResult;

    // get the raw data length and ensure we actually have data
    NSUInteger intLength = self.length;
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

@end

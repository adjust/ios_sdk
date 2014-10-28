//
//  AIUtil.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "AIUtil.h"
#import "AILogger.h"
#import "UIDevice+AIAdditions.h"
#import "AIAdjustFactory.h"
#import "NSString+AIAdditions.h"

#include <sys/xattr.h>

static NSString * const kBaseUrl   = @"https://app.adjust.io";
static NSString * const kClientSdk = @"ios4.0.0";

static NSString * const kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'Z";
static NSDateFormatter * dateFormat;


#pragma mark -
@implementation AIUtil

+ (NSString *)baseUrl {
    return kBaseUrl;
}

+ (NSString *)clientSdk {
    return kClientSdk;
}

+ (AIUserAgent *)userAgent {

    AIUserAgent * userAgent = [[AIUserAgent alloc] init];

    UIDevice *device = UIDevice.currentDevice;
    NSLocale *locale = NSLocale.currentLocale;
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;

    userAgent.bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    userAgent.bundleVersion   = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    userAgent.languageCode    = [locale objectForKey:NSLocaleLanguageCode];
    userAgent.countryCode     = [locale objectForKey:NSLocaleCountryCode];
    userAgent.osName          = @"ios";

    userAgent.deviceType      = device.aiDeviceType;
    userAgent.deviceName      = device.aiDeviceName;
    userAgent.systemVersion   = device.systemVersion;

    return userAgent;
}

#pragma mark - sanitization
+ (NSString *)sanitizeU:(NSString *)string {
    return [self.class sanitize:string defaultString:@"unknown"];
}

+ (NSString *)sanitizeZ:(NSString *)string {
    return [self.class sanitize:string defaultString:@"zz"];
}

+ (NSString *)sanitize:(NSString *)string defaultString:(NSString *)defaultString {
    if (string == nil) {
        return defaultString;
    }

    NSString *result = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (result.length == 0) {
        return defaultString;
    }

    return result;
}

// inspired by https://gist.github.com/kevinbarrett/2002382
+ (void)excludeFromBackup:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    id<AILogger> logger = AIAdjustFactory.logger;

    if (&NSURLIsExcludedFromBackupKey == nil) { // iOS 5.0.1 and lower
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result != 0) {
            [logger debug:@"Failed to exclude '%@' from backup", url.lastPathComponent];
        }
    } else { // iOS 5.0 and higher
        // First try and remove the extended attribute if it is present
        ssize_t result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                [logger debug:@"Removed extended attribute on file '%@'", url];
            }
        }

        // Set the new key
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES]
                                      forKey:NSURLIsExcludedFromBackupKey
                                       error:&error];
        if (!success) {
            [logger debug:@"Failed to exclude '%@' from backup (%@)", url.lastPathComponent, error.localizedDescription];
        }
    }
}

+ (NSString *)dateFormat:(double) value {
    if (dateFormat == nil) {
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:kDateFormat];
    }

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];

    return [dateFormat stringFromDate:date];
}

+ (NSDictionary *)buildJsonDict:(NSString *)jsonString {
    NSError *error = nil;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error != nil) {
        return nil;
    }

    return jsonDict;
}

@end

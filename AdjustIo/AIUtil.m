//
//  AIUtil.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIUtil.h"
#import "AILogger.h"
#import "UIDevice+AIAdditions.h"

static NSString * const kBaseUrl   = @"https://app.adjust.io";
static NSString * const kClientSdk = @"ios2.1.0";


#pragma mark -
@implementation AIUtil

+ (NSString *)baseUrl {
    return kBaseUrl;
}

+ (NSString *)clientSdk {
    return kClientSdk;
}

+ (NSString *)userAgent {
    UIDevice *device = UIDevice.currentDevice;
    NSLocale *locale = NSLocale.currentLocale;
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;

    NSString *bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    NSString *bundleVersion   = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *languageCode    = [locale objectForKey:NSLocaleLanguageCode];
    NSString *countryCode     = [locale objectForKey:NSLocaleCountryCode];
    NSString *osName          = @"ios";

    NSString *userAgent = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@",
                           [self.class sanitizeU:bundeIdentifier],
                           [self.class sanitizeU:bundleVersion],
                           [self.class sanitizeU:device.aiDeviceType],
                           [self.class sanitizeU:device.aiDeviceName],
                           [self.class sanitizeU:osName],
                           [self.class sanitizeU:device.systemVersion],
                           [self.class sanitizeZ:languageCode],
                           [self.class sanitizeZ:countryCode]];

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

+ (void)excludeFromBackup:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];

    if (!success) {
        [AILogger debug:@"Failed to exclude '%@' from backup (%@)", url.lastPathComponent, error.localizedDescription];
    }
}

@end

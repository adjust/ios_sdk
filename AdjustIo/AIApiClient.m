//
//  AIApiClient.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 06.08.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AIApiClient.h"
#import "AELogger.h"

#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"

static NSString * const kBaseUrl = @"https://app.adjust.io";
static NSString * const kClientSdk = @"ios1.6";


#pragma mark private interface
@interface AIApiClient()

- (NSString *)sanitizeU:(NSString *)string;
- (NSString *)sanitizeZ:(NSString *)string;
- (NSString *)sanitize:(NSString *)string defaultString:(NSString *)defaultString;;

@property (retain) AELogger *logger;

@end


#pragma mark AIApiClient
@implementation AIApiClient

#pragma mark public

+ (AIApiClient *)apiClientWithLogger:(AELogger *)logger {
    AIApiClient *apiClient = [[AIApiClient alloc] init];
    apiClient.logger = logger;
    return apiClient;
}

- (id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    if (self == nil) return nil;

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
                           [self sanitizeU:bundeIdentifier],
                           [self sanitizeU:bundleVersion],
                           [self sanitizeU:device.aiDeviceType],
                           [self sanitizeU:device.aiDeviceName],
                           [self sanitizeU:osName],
                           [self sanitizeU:device.systemVersion],
                           [self sanitizeZ:languageCode],
                           [self sanitizeZ:countryCode]];

    [self setDefaultHeader:@"User-Agent" value:userAgent];
    [self setDefaultHeader:@"Client-SDK" value:kClientSdk];

    return self;
}

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
  successMessage:(NSString *)successMessage
  failureMessage:(NSString *)failureMessage
{
    [self postPath:path
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self logSuccess:successMessage];
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               [self logFailure:failureMessage response:operation.responseString error:error];
           }];
}

- (void)logSuccess:(NSString *)message {
    [self.logger info:message];
}

- (void)logFailure:(NSString *)message response:(NSString *)response error:(NSError *)error {
    NSString *errorString = response.aiTrim;
    if (errorString == nil) {
        errorString = error.localizedDescription;
    }
    [self.logger warn:@"%@ (%@)", message, errorString];
}


#pragma mark private

- (NSString *)sanitizeU:(NSString *)string {
    return [self sanitize:string defaultString:@"unknown"];
}

- (NSString *)sanitizeZ:(NSString *)string {
    return [self sanitize:string defaultString:@"zz"];
}

- (NSString *)sanitize:(NSString *)string defaultString:(NSString *)defaultString; {
    if (string == nil) {
        return defaultString;
    }

    NSString *result = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (result.length == 0) {
        return defaultString;
    }

    return result;
}

@end

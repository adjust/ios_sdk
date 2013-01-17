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

static NSString * const kBaseUrl = @"http://app.adjust.io";
static NSString * const kClientSdk = @"ios1.4";


#pragma mark private interface
@interface AIApiClient()

@property (assign) BOOL loggingEnabled;
@property (retain) AELogger *logger;

@end


#pragma mark AIApiClient
@implementation AIApiClient

#pragma mark public

+ (AIApiClient *)apiClientWithLogger:(AELogger *)logger {
    AIApiClient *apiClient = [[[AIApiClient alloc] init] autorelease];
    apiClient.logger = logger;
    return apiClient;
}

- (id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    if (self == nil) return nil;

    NSBundle *bundle = NSBundle.mainBundle;
    UIDevice *device = UIDevice.currentDevice;
    NSLocale *locale = NSLocale.currentLocale;

    NSString *userAgent = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@",
                           [bundle.infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey],
                           [bundle.infoDictionary objectForKey:(NSString *)kCFBundleVersionKey],
                           device.aiDeviceType,
                           device.aiDeviceName,
                           @"ios",
                           device.systemVersion,
                           [locale objectForKey:NSLocaleLanguageCode],
                           [locale objectForKey:NSLocaleCountryCode]];

    [self setDefaultHeader:@"User-Agent" value:userAgent];
    [self setDefaultHeader:@"Client-SDK" value:kClientSdk];

    return self;
}

- (void)postPath:(NSString *)path success:(NSString *)successMessage failure:(NSString *)failureMessage parameters:(NSDictionary *)parameters {
    [self postPath:path
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self.logger log:successMessage];
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSString *errorString = operation.responseString.aiTrim;
               if (errorString == nil) {
                   errorString = error.localizedDescription;
               }
               [self.logger log:@"%@ (%@)", failureMessage, errorString];
           }];
}

@end

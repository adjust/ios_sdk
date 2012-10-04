//
//  AIApiClient.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 06.08.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AIApiClient.h"

static NSString * const kBaseUrl = @"http://app.adjust.io/";

@implementation AIApiClient

+ (AIApiClient *)apiClient {
    return [[[AIApiClient alloc] init] autorelease];
}

- (id)init {
    self = [super initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    if (self == nil) return nil;
    
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)",
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey],
                           [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey],
                           [[UIDevice currentDevice] model],
                           [[UIDevice currentDevice] systemName],
                           [[UIDevice currentDevice] systemVersion],
                           [[NSLocale currentLocale] localeIdentifier]];
    
    [self setDefaultHeader:@"User-Agent" value:userAgent];
    
    return self;
}

@end

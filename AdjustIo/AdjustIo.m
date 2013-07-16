//
//  AdjustIo.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AdjustIo.h"
#import "AIActivityHandler.h"

#if !__has_feature(objc_arc)
#error AdjustIo requires ARC
// see README for details
#endif

static AIActivityHandler *activityHandler;


#pragma mark -
@implementation AdjustIo

+ (void)appDidLaunch:(NSString *)yourAppToken {
    activityHandler = [AIActivityHandler handlerWithAppToken:yourAppToken];
}

+ (void)trackEvent:(NSString *)eventToken {
    [activityHandler trackEvent:eventToken withParameters:nil];
}

+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters {
    [activityHandler trackEvent:eventToken withParameters:parameters];
}

+ (void)trackRevenue:(double)amountInCents {
    [activityHandler trackRevenue:amountInCents forEvent:nil withParameters:nil];
}

+ (void)trackRevenue:(double)amountInCents forEvent:(NSString *)eventToken {
    [activityHandler trackRevenue:amountInCents forEvent:eventToken withParameters:nil];
}

+ (void)trackRevenue:(double)amountInCents
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters
{
    [activityHandler trackRevenue:amountInCents forEvent:eventToken withParameters:parameters];
}

+ (void)setLogLevel:(AILogLevel)logLevel {
    [AILogger setLogLevel:logLevel];
}

@end

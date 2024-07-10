//
//  AdjustTrackingHelper.m
//  AdjustExample-iWatch
//
//  Created by Uglješa Erceg (@uerceg) on 6th April 2016
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdjustTrackingHelper.h"
#import <AdjustSdk/AdjustSdk.h>

@implementation AdjustTrackingHelper

+ (id)sharedInstance {
    static AdjustTrackingHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    
    return sharedHelper;
}

- (void)initialize:(NSObject<AdjustDelegate> *)delegate {
    NSString *yourAppToken = @"2fm9gkqubvpc";
    NSString *environment = ADJEnvironmentSandbox;
    ADJConfig *adjustConfig = [[ADJConfig alloc] initWithAppToken:yourAppToken
                                                      environment:environment];

    // Change the log level.
    [adjustConfig setLogLevel:ADJLogLevelVerbose];
    
    // Set an attribution delegate.
    [adjustConfig setDelegate:delegate];
    
    [Adjust initSdk:adjustConfig];
}

- (void)trackSimpleEvent {
    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"g3mfiw"];

    [Adjust trackEvent:event];
}

- (void)trackRevenueEvent {
    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"a4fd35"];

    // Add revenue 15 cent of an euro.
    [event setRevenue:0.015 currency:@"EUR"];
    
    [Adjust trackEvent:event];
}

- (void)trackCallbackEvent {
    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"34vgg9"];

    // Add callback parameters to this event.
    [event addCallbackParameter:@"key" value:@"value"];
    
    [Adjust trackEvent:event];
}

- (void)trackPartnerEvent {
    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"w788qs"];

    // Add partner parameteres to this event.
    [event addPartnerParameter:@"foo" value:@"bar"];
    
    [Adjust trackEvent:event];
}

@end

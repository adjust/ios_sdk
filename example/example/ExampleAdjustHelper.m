//
//  AdjustInit.m
//  example
//
//  Created by Pedro Filipe on 18/11/14.
//  Copyright (c) 2014 adjust. All rights reserved.
//

#import "ExampleAdjustHelper.h"
#import "Adjust.h"
#import "ADJLogger.h"
#import "ADJEvent.h"

@implementation ExampleAdjustHelper

+ (void) initAdjust: (NSObject<AdjustDelegate> *) adjustDelegate {
    NSString * yourAppToken = @"dgau42x652ul";
    NSString * enviroment = AIEnvironmentSandbox;
    ADJConfig * adjustConfig = [ADJConfig configWithAppToken:yourAppToken andEnvironment:enviroment];

    // change the log level
    [adjustConfig setLogLevel:ADJLogLevelVerbose];

    // enable event buffering
    //[adjustConfig setEventBufferingEnabled:YES];

    // disable MAC MD5 tracking
    //[adjustConfig setMacMd5TrackingEnabled:NO];

    // set an attribution delegate
    [adjustConfig setDelegate:adjustDelegate];

    Adjust * adjust = [Adjust getInstance];
    [adjust appDidLaunch:adjustConfig];
}

+ (void) triggerEvent {

    ADJEvent * event = [ADJEvent eventWithEventToken:@"gd6a8u"];

    // add revenue 1 cent of an euro
    [event setRevenue:0.015 currency:@"EUR"];

    // add callback parameters to this parameter
    [event addCallbackParameter:@"keyEvent" andValue:@"value"];

    // add partner parameteres to all events and sessions
    [event addPartnerParameter:@"fooEvent" andValue:@"bar"];

    Adjust * adjust = [Adjust getInstance];
    [adjust trackEvent:event];
}

@end

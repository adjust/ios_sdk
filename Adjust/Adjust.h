//
//  Adjust.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "AILogger.h"
#import "AIResponseData.h"
#import "AIEvent.h"
#import "AIAttribution.h"
#import "AdjustConfig.h"

/**
 * Constants for our supported tracking environments.
 */
static NSString * const AIEnvironmentSandbox    = @"sandbox";
static NSString * const AIEnvironmentProduction = @"production";

/**
 * The main interface to Adjust.
 *
 * Use the methods of this class to tell Adjust about the usage of your app.
 * See the README for details.
 */
@interface Adjust : NSObject

/**
 * Tell Adjust that the application did launch.
 *
 * This is required to initialize Adjust. Call this in the didFinishLaunching
 * method of your AppDelegate.
 *
 * @param appToken The App Token of your app. This unique identifier can
 *     be found it in your dashboard at http://adjust.com and should always
 *     be 12 characters long.
 */
+ (void)appDidLaunch:(AdjustConfig *)adjustConfig;

/**
 * Tell Adjust that a particular event has happened.
 *
 * In your dashboard at http://adjust.com you can assign a callback URL to each
 * event type. That URL will get called every time the event is triggered. On
 * top of that you can pass a set of parameters to the following method that
 * will be forwarded to these callbacks.
 *
 * The event can contain some revenue. The amount is measured in units and 
 * rounded to the decimal cent point.
 *
 * A transaction ID can be used to avoid duplicate revenue events. The last ten 
 * transaction identifiers are remembered.
 *
 * @param event The Event object for this kind of event. It needs a event token 
 * that is  created in the dashboard at http://adjust.com and should be six 
 * characters long.
 */
+ (void)trackEvent:(AIEvent *)event;

/**
 * Tell adjust that the application resumed.
 *
 * Only necessary if the native notifications can't be used
 */
+ (void)trackSubsessionStart;

/**
 * Tell adjust that the application paused.
 *
 * Only necessary if the native notifications can't be used
 */
+ (void)trackSubsessionEnd;

/**
 * Enable or disable the adjust SDK
 *
 * @param enabled The flag to enable or disable the adjust SDK
 */
+ (void)setEnabled:(BOOL)enabled;

/**
 * Check if the SDK is enabled or disabled
 */
+ (BOOL)isEnabled;

/**
 * Read the URL that opened the application to search for
 * an adjust deep link
 */
+ (void)appWillOpenUrl:(NSURL *)url;

/**
 * Set the device token used by push notifications
 */
+ (void)setDeviceToken:(NSData *)deviceToken;


@end


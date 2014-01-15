//
//  AdjustIo.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2013 adeven. All rights reserved.
//

#import "AILogger.h"

/**
 * Constants for our supported tracking environments.
 */
static NSString * const AIEnvironmentSandbox    = @"sandbox";
static NSString * const AIEnvironmentProduction = @"production";

/**
 * The main interface to AdjustIo.
 *
 * Use the methods of this class to tell AdjustIo about the usage of your app.
 * See the README for details.
 */
@interface AdjustIo : NSObject

/**
 * Tell AdjustIo that the application did launch.
 *
 * This is required to initialize AdjustIo. Call this in the didFinishLaunching
 * method of your AppDelegate.
 *
 * @param appToken The App Token of your app. This unique identifier can
 *     be found it in your dashboard at http://adjust.io and should always
 *     be 12 characters long.
 */
+ (void)appDidLaunch:(NSString *)appToken;

/**
 * Tell AdjustIo that a particular event has happened.
 *
 * In your dashboard at http://adjust.io you can assign a callback URL to each
 * event type. That URL will get called every time the event is triggered. On
 * top of that you can pass a set of parameters to the following method that
 * will be forwarded to these callbacks.
 *
 * @param eventToken The Event Token for this kind of event. They are created
 *     in the dashboard at http://adjust.io and should be six characters long.
 * @param parameters An optional dictionary containing the callback parameters.
 *     Provide key-value-pairs to be forwarded to your callbacks.
 */
+ (void)trackEvent:(NSString *)eventToken;
+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

/**
 * Tell AdjustIo that a user generated some revenue.
 *
 * The amount is measured in cents and rounded to on digit after the
 * decimal point. If you want to differentiate between several revenue
 * types, you can do so by using different event tokens. If your revenue
 * events have callbacks, you can also pass in parameters that will be
 * forwarded to your end point.
 *
 * @param amountInCents The amount in cents (example: 1.5 means one and a half cents)
 * @param eventToken The token for this revenue event (optional, see above)
 * @param parameters Parameters for this revenue event (optional, see above)
 */
+ (void)trackRevenue:(double)amountInCents;
+ (void)trackRevenue:(double)amountInCents forEvent:(NSString *)eventToken;
+ (void)trackRevenue:(double)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

/**
 * Change the verbosity of AdjustIo's logs.
 *
 * You can increase or reduce the amount of logs from AdjustIo by passing
 * one of the following parameters. Use Log.ASSERT to disable all logging.
 *
 * @param logLevel The desired minimum log level (default: info)
 *     Must be one of the following:
 *      - AILogLevelVerbose (enable all logging)
 *      - AILogLevelDebug   (enable more logging)
 *      - AILogLevelInfo    (the default)
 *      - AILogLevelWarn    (disable info logging)
 *      - AILogLevelError   (disable warnings as well)
 *      - AILogLevelAssert  (disable errors as well)
 */
+ (void)setLogLevel:(AILogLevel)logLevel;

/**
 * Set the tracking environment to sandbox or production.
 *
 * Use sandbox for testing and production for the final build that you release.
 *
 * @param environment The new environment. Supported values:
 *     - AIEnvironmentSandbox
 *     - AIEnvironmentProduction
 */
+ (void)setEnvironment:(NSString *)environment;

/**
 * Enable or disable event buffering.
 *
 * Enable event buffering if your app triggers a lot of events.
 * When enabled, events get buffered and only get tracked each
 * minute. Buffered events are still persisted, of course.
 */
+ (void)setEventBufferingEnabled:(BOOL)enabled;

/**
 * Enable or disable tracking of the MD5 hash of the MAC address
 *
 * Disable macMd5 tracking if your privacy constraints require it.
 */
+ (void)setMacMd5TrackingEnabled:(BOOL)enabled;

// Special method used by SDK wrappers such as Adobe Air SDK.
+ (void)setSdkPrefix:(NSString *)sdkPrefix __attribute__((deprecated));

@end

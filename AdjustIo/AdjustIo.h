//
//  AdjustIo.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AILogger.h"

// TODO: add comment
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

// TODO: add comment
// sets logLevel to Assert
// should be called after appDidLaunch and setLogLevel
+ (void)setEnvironment:(NSString *)environment;

// TODO: add comment
// should be called after appDidLaunch
+ (void)setEventBufferingEnabled:(BOOL)enabled;

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

@end

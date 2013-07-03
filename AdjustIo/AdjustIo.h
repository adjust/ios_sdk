//
//  AdjustIo.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AILogger.h"

/**
 * The main interface to AdjustIo.
 *
 * Use the methods of this class to tell AdjustIo about the usage of your app.
 * See the README for details.
 *
 * @author wellle
 * @since 23.07.12
 */
@interface AdjustIo : NSObject

/**
 * Tell AdjustIo that the application did finish launching.
 *
 * This is required to initialize AdjustIo.
 * Call this in the didFinishLaunching method of your AppDelegate.
 *
 * @param appToken The app token of your app
 *     You can find it in your dashboard at http://www.adjust.io
 */
+ (void)appDidLaunch:(NSString *)appToken;

/**
 * Track any kind of event.
 *
 * You can assign a callback url to the event which will get called every time
 * the event is reported. You can provide parameters that will be forwarded
 * to these callbacks.
 *
 * @param eventToken The token for this kind of event
 *     It must be exactly six characters long
 *     You create them in your dashboard at http://www.adjust.io
 * @param parameters An optional dictionary containing callback parameters
 *     Provide key-value-pairs to be forwarded to your callbacks
 */
+ (void)trackEvent:(NSString *)eventToken;
+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

/**
 * Tell AdjustIo that the current user generated some revenue.
 *
 * The amount is measured in cents and rounded to on digit after the decimal
 * point. If you want to differentiate between various types of revenues you
 * can do so by providing different event tokens. If your revenue events have
 * callbacks, you can pass in parameters that will be forwarded to your server.
 *
 * @param amountInCents The amount in cents (example: 1.5f means one and a half cents)
 * @param eventToken The token for this revenue event (see above)
 * @param parameters Parameters for this revenue event (see above)
 */
+ (void)trackRevenue:(float)amountInCents;
+ (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken;
+ (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

/**
 * Change the verbosity of AdjustIo's logs
 *
 * @param logLevel The desired minimum log level (default: info)
 *     Must be one of the following:
 *      - AILogLevelVerbose (enable all logging)
 *      - AILogLevelDebug
 *      - AILogLevelInfo    (the default)
 *      - AILogLevelWarn    (disable info logging)
 *      - AILogLevelError   (disable warnings as well)
 *      - AILogLevelAssert  (disable errors as well)
 */
+ (void)setLogLevel:(AILogLevel)logLevel;

@end

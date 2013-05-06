//
//  AdjustIo.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

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
 * @param appId The appId of your app
 */
+ (void)appDidLaunch:(NSString *)appId;

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

// TODO: add logLevels like on Android for version 2.0
/**
 * If you want to see debug logs while you integrate some features, call setLoggingEnabled:YES.
 * Turn it off again by calling setLoggingEnabled:NO, which is the default.
 */
+ (void)setLoggingEnabled:(BOOL)loggingEnabled;

@end

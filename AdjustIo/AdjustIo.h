//
//  AdjustIo.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdjustIo : NSObject

// Tell AdjustIo that the application did finish launching. This is required
// to initialize AdjustIo. Call this in the didFinishLaunching method of your AppDelegate.
+ (void)appDidLaunch:(NSString *)appId;

// Track any kind of event. You can assign a callback url to the event which
// will get called every time the event is reported. You can also provide
// parameters that will be forwarded to these callbacks.
+ (void)trackEvent:(NSString *)eventToken;
+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

// Tell AdjustIo that the current user generated some revenue. The amount is
// measured in cents and rounded to on digit after the decimal point. If you
// want to differentiate between various types of revenues you can do so by
// providing different event tokens. If your revenue events have callbacks, you
// can also pass in parameters that will be forwarded to your server.
+ (void)userGeneratedRevenue:(float)amountInCents;
+ (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventToken;
+ (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

// If you want to see debug logs while you integrate some features, call setLoggingEnabled:YES.
// Turn it off again by calling setLoggingEnabled:NO, which is the default.
+ (void)setLoggingEnabled:(BOOL)loggingEnabled;

@end

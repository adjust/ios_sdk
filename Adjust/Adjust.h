//
//  Adjust.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "AILogger.h"
#import "AIResponseData.h"

@protocol AdjustDelegate;

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
+ (void)appDidLaunch:(NSString *)appToken;

/**
 * Set the optional delegate that will get informed about tracking results
 *
 * See the AdjustDelegate declaration below for details
 *
 * @param delegate The delegate that might implement the optional delegate
 *     methods like adjustFinishedTrackingWithResponse:
 */
+ (void)setDelegate:(id<AdjustDelegate>)delegate;

/**
 * Tell Adjust that a particular event has happened.
 *
 * In your dashboard at http://adjust.com you can assign a callback URL to each
 * event type. That URL will get called every time the event is triggered. On
 * top of that you can pass a set of parameters to the following method that
 * will be forwarded to these callbacks.
 *
 * @param eventToken The Event Token for this kind of event. They are created
 *     in the dashboard at http://adjust.com and should be six characters long.
 * @param parameters An optional dictionary containing the callback parameters.
 *     Provide key-value-pairs to be forwarded to your callbacks.
 */
+ (void)trackEvent:(NSString *)eventToken;
+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

/**
 * Tell Adjust that a user generated some revenue.
 *
 * The amount is measured in cents and rounded to on digit after the
 * decimal point. If you want to differentiate between several revenue
 * types, you can do so by using different event tokens. If your revenue
 * events have callbacks, you can also pass in parameters that will be
 * forwarded to your end point.
 *
 * A transaction ID can be used to avoid duplicate revenue events. The last ten transaction identifiers are remembered.
 * This is useful for in-app purchase tracking where you can pass in the identifier of the reported transaction.
 *
 * @param amountInCents The amount in cents (example: 1.5 means one and a half cents)
 * @param transactionIdentifier The identifier used to avoid duplicate revenue events (optional, see above)
 * @param eventToken The token for this revenue event (optional, see above)
 * @param parameters Parameters for this revenue event (optional, see above)
 */
+ (void)trackRevenue:(double)amountInCents;
+ (void)trackRevenue:(double)amountInCents forEvent:(NSString *)eventToken;
+ (void)trackRevenue:(double)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

+ (void)trackRevenue:(double)amountInCents transactionId:(NSString *)transactionId;
+ (void)trackRevenue:(double)amountInCents transactionId:(NSString *)transactionId forEvent:(NSString *)eventToken;
+ (void)trackRevenue:(double)amountInCents
       transactionId:(NSString *)transactionId
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters;

/**
 * Change the verbosity of Adjust's logs.
 *
 * You can increase or reduce the amount of logs from Adjust by passing
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

// Special method used by wrapper JS bridge. Do not call directly.
+ (void)setSdkPrefix:(NSString *)sdkPrefix;

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
@end


@class AIActivityPackage;
@class AIResponseData;

#pragma mark -
/**
 * Optional delegate that will get informed about tracking results
 */
@protocol  AdjustDelegate
@optional

/**
 * Optional delegate method that will get called when a tracking attempt finished
 *
 * @param responseData The response data containing information about the activity
 *     and it's server response. See AIResponseData for details.
 */
- (void)adjustFinishedTrackingWithResponse:(AIResponseData *)responseData;

@end

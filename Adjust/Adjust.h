//
//  Adjust.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-07-23.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "ADJLogger.h"
#import "ADJEvent.h"
#import "ADJAttribution.h"
#import "ADJConfig.h"

/**
 * Constants for our supported tracking environments.
 */
static NSString * const ADJEnvironmentSandbox    = @"sandbox";
static NSString * const ADJEnvironmentProduction = @"production";

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
 * Enable event buffering if your app triggers a lot of events.
 * When enabled, events get buffered and only get tracked each
 * minute. Buffered events are still persisted, of course.
 *
 * Disable macMd5 tracking if your privacy constraints require it.
 *
 * @param adjustConfig The configuration object that includes the environment 
 *     and the App Token of your app. This unique identifier can
 *     be found it in your dashboard at http://adjust.com and should always
 *     be 12 characters long.
 */
+ (void)appDidLaunch:(ADJConfig *)adjustConfig;

/**
 * Tell Adjust that a particular event has happened.
 *
 * In your dashboard at http://adjust.com you can assign a callback URL to each
 * event type. That URL will get called every time the event is triggered. On
 * top of that you can pass a set of parameters to the following method that
 * will be forwarded to these callbacks.
 *
 * TODO: Partner parameter ...
 *
 * The event can contain some revenue. The amount revenue is measured in units. 
 * It must include a currency in the ISO 4217 format.
 *
 * A transaction ID can be used to avoid duplicate revenue events. The last ten 
 * transaction identifiers are remembered.
 *
 * @param event The Event object for this kind of event. It needs a event token 
 * that is  created in the dashboard at http://adjust.com and should be six 
 * characters long.
 */
+ (void)trackEvent:(ADJEvent *)event;

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
 * Enable or disable the adjust SDK. This setting is saved
 * for future sessions
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

/**
 * Enable or disable offline mode. Activities won't be sent
 * but they are saved when offline mode is disabled. This 
 * feature is not saved for future sessions
 */
+ (void)setOfflineMode:(BOOL)enabled;

/**
 * Obtain singleton Adjust object
 */
+ (id)getInstance;

- (void)appDidLaunch:(ADJConfig *)adjustConfig;
- (void)trackEvent:(ADJEvent *)event;
- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (void)appWillOpenUrl:(NSURL *)url;
- (void)setDeviceToken:(NSData *)deviceToken;
- (void)setOfflineMode:(BOOL)enabled;

@end


//
//  ADJConfig.h
//  adjust
//
//  Created by Pedro Filipe on 30/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJLogger.h"
#import "ADJAttribution.h"

/**
 * Optional delegate that will get informed about tracking results
 */
@protocol  AdjustDelegate
@optional

/**
 * Optional delegate method that gets called when the attribution information changed
 *
 * @param attribution The attribution information. See ADJAttribution for details.
 */
- (void)adjustAttributionChanged:(ADJAttribution *)attribution;

@end

@interface ADJConfig : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString *appToken;
@property (nonatomic, assign) ADJLogLevel logLevel;
@property (nonatomic, copy, readonly) NSString *environment;
@property (nonatomic, copy) NSString *sdkPrefix;
@property (nonatomic, copy) NSString *defaultTracker;

/**
 * Configuration object for the initialization of the Adjust SDK.
 *
 * @param appToken The App Token of your app. This unique identifier can
 *     be found it in your dashboard at http://adjust.com and should always
 *     be 12 characters long.
 * @param environment The current environment your app. We use this environment to
 *     distinguish between real traffic and artificial traffic from test devices.
 *     It is very important that you keep this value meaningful at all times!
 *     Especially if you are tracking revenue.
 */
+ (ADJConfig*)configWithAppToken:(NSString *)appToken environment:(NSString *)environment;
- (id)initWithAppToken:(NSString *)appToken environment:(NSString *)environment;

/**
 * Enable event buffering if your app triggers a lot of events.
 * When enabled, events get buffered and only get tracked each
 * minute. Buffered events are still persisted, of course.
 *
 * @param eventBufferingEnabled Enable or disable event buffering
 */
@property (nonatomic, assign) BOOL eventBufferingEnabled;

/**
 * Disable macMd5 tracking if your privacy constraints require it.
 *
 * @param macMd5TrackingEnabled Enable or disable tracking of
 * the MD5 hash of the MAC address
 */
@property (nonatomic, assign) BOOL macMd5TrackingEnabled;

/**
 * Set the optional delegate that will inform you about attribution
 *
 * See the AdjustDelegate declaration above for details
 *
 * @param delegate The delegate that might implement the optional delegate
 *     methods like adjustAttributionChanged:
 */
@property (nonatomic, retain) NSObject<AdjustDelegate> *delegate;
@property (nonatomic, assign) BOOL hasDelegate;

- (BOOL) isValid;
@end

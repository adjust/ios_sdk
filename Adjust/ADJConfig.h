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
#import "ADJEventSuccess.h"
#import "ADJEventFailure.h"
#import "ADJSessionSuccess.h"
#import "ADJSessionFailure.h"

/**
 * @brief Optional delegate that will get informed about tracking results.
 */
@protocol AdjustDelegate

@optional

/**
 * @brief Optional delegate method that gets called when the attribution information changed.
 *
 * @param attribution The attribution information.
 *
 * @note See ADJAttribution for details.
 */
- (void)adjustAttributionChanged:(nullable ADJAttribution *)attribution;

/**
 * @brief Optional delegate method that gets called when an event is tracked with success.
 *
 * @param eventSuccessResponseData The response information from tracking with success
 *
 * @note See ADJEventSuccess for details.
 */
- (void)adjustEventTrackingSucceeded:(nullable ADJEventSuccess *)eventSuccessResponseData;

/**
 * @brief Optional delegate method that gets called when an event is tracked with failure.
 *
 * @param eventFailureResponseData The response information from tracking with failure
 *
 * @note See ADJEventFailure for details.
 */
- (void)adjustEventTrackingFailed:(nullable ADJEventFailure *)eventFailureResponseData;

/**
 * @brief Optional delegate method that gets called when an session is tracked with success.
 *
 * @param sessionSuccessResponseData The response information from tracking with success
 *
 * @note See ADJSessionSuccess for details.
 */
- (void)adjustSessionTrackingSucceeded:(nullable ADJSessionSuccess *)sessionSuccessResponseData;

/**
 * @brief Optional delegate method that gets called when an session is tracked with failure.
 *
 * @param sessionFailureResponseData The response information from tracking with failure
 *
 * @note See ADJSessionFailure for details.
 */
- (void)adjustSessionTrackingFailed:(nullable ADJSessionFailure *)sessionFailureResponseData;

/**
 * @brief Optional delegate method that gets called when a deferred deep link is about to be opened by the adjust SDK.
 *
 * @param deeplink The deep link url that was received by the adjust SDK to be opened.
 *
 * @return Boolean that indicates whether the deep link should be opened by the adjust SDK or not.
 */
- (BOOL)adjustDeeplinkResponse:(nullable NSURL *)deeplink;

/**
 * @brief Optional SKAdNetwork delegate method that gets called when Adjust SDK updates conversion value for the user.
 *        The conversionData dictionary will contain string representation for the values set by Adjust SDK and
 *        possible API invocation error.
 *        Avalable keys are "conversion_value", "coarse_value", "lock_window" and "error".
 *        Example: {"conversion_value":"1",  "coarse_value":"low", "lock_window":"false"}
 *        You can use this callback even while using pre 4.0 SKAdNetwork.
 *        In that case the dictionary will contain only "conversion_value" key.
 *
 * @param data Conversion parameters set by Adjust SDK
 */
- (void)adjustSkanUpdatedWithConversionData:(nonnull NSDictionary<NSString *, NSString *> *)data;
@end

/**
 * @brief Adjust configuration object class.
 */
@interface ADJConfig : NSObject<NSCopying>

/**
 * @brief SDK prefix.
 *
 * @note Not to be used by users, intended for non-native adjust SDKs only.
 */
@property (nonatomic, copy, nullable) NSString *sdkPrefix;

/**
 * @brief Default tracker to attribute organic installs to (optional).
 */
@property (nonatomic, copy, nullable) NSString *defaultTracker;

@property (nonatomic, copy, nullable) NSString *externalDeviceId;

/**
 * @brief Adjust app token.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *appToken;

/**
 * @brief Adjust environment variable.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *environment;

/**
 * @brief Change the verbosity of Adjust's logs.
 *
 * @note You can increase or reduce the amount of logs from Adjust by passing
 *       one of the following parameters. Use ADJLogLevelSuppress to disable all logging.
 *       The desired minimum log level (default: info)
 *       Must be one of the following:
 *         - ADJLogLevelVerbose    (enable all logging)
 *         - ADJLogLevelDebug      (enable more logging)
 *         - ADJLogLevelInfo       (the default)
 *         - ADJLogLevelWarn       (disable info logging)
 *         - ADJLogLevelError      (disable warnings as well)
 *         - ADJLogLevelAssert     (disable errors as well)
 *         - ADJLogLevelSuppress   (suppress all logging)
 */
@property (nonatomic, assign) ADJLogLevel logLevel;

/**
 * @brief Set the optional delegate that will inform you about attribution or events.
 *
 * @note See the AdjustDelegate declaration above for details.
 */
@property (nonatomic, weak, nullable) NSObject<AdjustDelegate> *delegate;

/**
 * @brief Enables sending in the background.
 */
@property (nonatomic, assign) BOOL sendInBackground;

/**
 * @brief Enables/disables reading of AdServices framework data needed for attribution.
 */
@property (nonatomic, assign) BOOL allowAdServicesInfoReading;

/**
 * @brief Enables/disables reading of IDFA parameter.
 */
@property (nonatomic, assign) BOOL allowIdfaReading;

/**
 * @brief Enables delayed start of the SDK.
 */
@property (nonatomic, assign) double delayStart;

/**
 * @brief Define how many seconds to wait for ATT status before sending the first data.
 */
@property (nonatomic, assign) NSUInteger attConsentWaitingInterval;

/**
 * @brief Set if cost data is needed in attribution response.
 */
@property (nonatomic, assign) BOOL needsCost;


@property (nonatomic, assign, readonly) BOOL isSKAdNetworkHandlingActive;

- (void)deactivateSKAdNetworkHandling;

/**
 * @brief Adjust url strategy.
 */
@property (nonatomic, copy, readwrite, nullable) NSString *urlStrategy;

@property (nonatomic, assign, readonly) BOOL isLinkMeEnabled;

/**
 * @brief Enables linkMe
 */
- (void)enableLinkMe;

/**
 * @brief Get configuration object for the initialization of the Adjust SDK.
 *
 * @param appToken The App Token of your app. This unique identifier can
 *                 be found it in your dashboard at http://adjust.com and should always
 *                 be 12 characters long.
 * @param environment The current environment your app. We use this environment to
 *                    distinguish between real traffic and artificial traffic from test devices.
 *                    It is very important that you keep this value meaningful at all times!
 *                    Especially if you are tracking revenue.
 *
 * @returns Adjust configuration object.
 */
+ (nullable ADJConfig *)configWithAppToken:(nonnull NSString *)appToken
                               environment:(nonnull NSString *)environment;

- (nullable id)initWithAppToken:(nonnull NSString *)appToken
                    environment:(nonnull NSString *)environment;

/**
 * @brief Configuration object for the initialization of the Adjust SDK.
 *
 * @param appToken The App Token of your app. This unique identifier can
 *                 be found it in your dashboard at http://adjust.com and should always
 *                 be 12 characters long.
 * @param environment The current environment your app. We use this environment to
 *                    distinguish between real traffic and artificial traffic from test devices.
 *                    It is very important that you keep this value meaningful at all times!
 *                    Especially if you are tracking revenue.
 * @param allowSuppressLogLevel If set to true, it allows usage of ADJLogLevelSuppress
 *                              and replaces the default value for production environment.
 *
 * @returns Adjust configuration object.
 */
+ (nullable ADJConfig *)configWithAppToken:(nonnull NSString *)appToken
                               environment:(nonnull NSString *)environment
                     allowSuppressLogLevel:(BOOL)allowSuppressLogLevel;

- (nullable id)initWithAppToken:(nonnull NSString *)appToken
                    environment:(nonnull NSString *)environment
          allowSuppressLogLevel:(BOOL)allowSuppressLogLevel;

/**
 * @brief Check if adjust configuration object is valid.
 *
 * @return Boolean indicating whether adjust config object is valid or not.
 */
- (BOOL)isValid;
 
/**
 * @brief Enable COPPA (Children's Online Privacy Protection Act) compliant for the application.
 */
@property (nonatomic, assign) BOOL coppaCompliantEnabled;

/**
 * @brief Enables caching of device ids to read it only once
 */
@property (nonatomic, assign) BOOL readDeviceInfoOnceEnabled;

@end

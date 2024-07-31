//
//  ADJConfig.h
//  adjust
//
//  Created by Pedro Filipe on 30/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJLogger;
@class ADJAttribution;
@class ADJEventSuccess;
@class ADJEventFailure;
@class ADJSessionSuccess;
@class ADJSessionFailure;
typedef NS_ENUM(NSUInteger, ADJLogLevel);

#pragma mark - AdjustDelegate methods

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
 * @param eventSuccessResponse The response information from tracking with success
 *
 * @note See ADJEventSuccess for details.
 */
- (void)adjustEventTrackingSucceeded:(nullable ADJEventSuccess *)eventSuccessResponse;

/**
 * @brief Optional delegate method that gets called when an event is tracked with failure.
 *
 * @param eventFailureResponse The response information from tracking with failure
 *
 * @note See ADJEventFailure for details.
 */
- (void)adjustEventTrackingFailed:(nullable ADJEventFailure *)eventFailureResponse;

/**
 * @brief Optional delegate method that gets called when a session is tracked with success.
 *
 * @param sessionSuccessResponse The response information from tracking with success
 *
 * @note See ADJSessionSuccess for details.
 */
- (void)adjustSessionTrackingSucceeded:(nullable ADJSessionSuccess *)sessionSuccessResponse;

/**
 * @brief Optional delegate method that gets called when a session is tracked with failure.
 *
 * @param sessionFailureResponse The response information from tracking with failure
 *
 * @note See ADJSessionFailure for details.
 */
- (void)adjustSessionTrackingFailed:(nullable ADJSessionFailure *)sessionFailureResponse;

/**
 * @brief Optional delegate method that gets called when a deferred deep link is about to be 
 *        opened by the Adjust SDK.
 *
 * @param deeplink The deferred deep link URL that was received by the Adjust SDK to be opened.
 *
 * @return Boolean that indicates whether the deep link should be opened by the Adjust SDK or not.
 */
- (BOOL)adjustDeferredDeeplinkReceived:(nullable NSURL *)deeplink;

/**
 * @brief Optional SKAdNetwork delegate method that gets called when Adjust SDK updates conversion
 *        value for the user.
 *        The conversionData dictionary will contain string representation for the values set by
 *        Adjust SDK and possible API invocation error.
 *        Avalable keys are "conversion_value", "coarse_value", "lock_window" and "error".
 *        Example: {"conversion_value":"1", "coarse_value":"low", "lock_window":"false"}
 *        You can use this callback even while using pre 4.0 SKAdNetwork.
 *        In that case the dictionary will contain only "conversion_value" key.
 *
 * @param data Conversion parameters set by Adjust SDK.
 */
- (void)adjustSkanUpdatedWithConversionData:(nonnull NSDictionary<NSString *, NSString *> *)data;

@end

/**
 * @brief Adjust configuration object class.
 */
@interface ADJConfig : NSObject<NSCopying>

#pragma mark - ADJConfig readonly properties

/**
 * @brief Adjust app token.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *appToken;

/**
 * @brief Adjust environment variable.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *environment;

/**
 * @brief Indicator of whether sending in the background is enabled or not.
 *
 * @note It is disabled by default.
 */
@property (nonatomic, readonly) BOOL isSendingInBackgroundEnabled;

/**
 * @brief Indicator of whether reading of AdServices.framework data is enabled or not.
 *
 * @note It is enabled by default.
 */
@property (nonatomic, readonly) BOOL isAdServicesEnabled;

/**
 * @brief Indicator of whether reading of IDFA is enabled or not.
 *
 * @note It is enabled by default.
 */
@property (nonatomic, readonly) BOOL isIdfaReadingEnabled;

/**
 * @brief Indicator of whether reading of IDFV is enabled or not.
 *
 * @note It is enabled by default.
 */
@property (nonatomic, readonly) BOOL isIdfvReadingEnabled;

/**
 * @brief Indicator of whether SKAdNetwork (SKAN) attribution is enabled or not.
 *
 * @note It is enabled by default.
 */
@property (nonatomic, readonly) BOOL isSkanAttributionEnabled;

/**
 * @brief Set if cost data is needed in attribution response.
 *
 * @note It is disabled by default.
 */
@property (nonatomic, readonly) BOOL isCostDataInAttributionEnabled;

/**
 * @brief Indicator of whether LinkMe feature is enabled or not.
 *
 * @note It is disabled by defailt.
 */
@property (nonatomic, readonly) BOOL isLinkMeEnabled;

/**
 * @brief Enables caching of device IDs to read it only once.
 *
 * @note It is disabled by default.
 */
@property (nonatomic, readonly) BOOL isDeviceIdsReadingOnceEnabled;

/**
 * @brief Array of domains to be used as part of the URL strategy.
 */
@property (nonatomic, copy, readonly, nullable) NSArray *urlStrategyDomains;

/**
 * @brief Indicator of whether Adjust-like subdomains should be made out of custom set domains.
 */
@property (nonatomic, readonly) BOOL useSubdomains;

/**
 * @brief Indicator of whether URL strategy is a data residency one or not.
 */
@property (nonatomic, readonly) BOOL isDataResidency;

/**
 * @brief Indicator of whether SDK should start in COPPA compliant mode or not.
 */
@property (nonatomic, readonly) BOOL isCoppaComplianceEnabled;

#pragma mark - AdjustConfig assignable properties

/**
 * @brief Set the optional delegate that will inform you about attribution or events.
 *
 * @note See the AdjustDelegate declaration above for details.
 */
@property (nonatomic, weak, nullable) NSObject<AdjustDelegate> *delegate;

/**
 * @brief SDK prefix.
 *
 * @note Not to be used by users, intended for non-native adjust SDKs only.
 */
@property (nonatomic, copy, nullable) NSString *sdkPrefix;

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
 * @brief Default tracker to attribute organic installs to (optional).
 */
@property (nonatomic, copy, nullable) NSString *defaultTracker;

/**
 * @brief Custom defined unique device ID (optional).
 *
 * @note Make sure to have a UNIQUE external ID for each user / device.
 */
@property (nonatomic, copy, nullable) NSString *externalDeviceId;

/**
 * @brief Define how many seconds to wait for ATT status before sending the first data.
 */
@property (nonatomic, assign) NSUInteger attConsentWaitingInterval;

/**
 * @brief Maximum number of deduplication IDs to be stored by the SDK.
 *
 * @note If not set, maximum is 10.
 */
@property (nonatomic, assign) NSInteger eventDeduplicationIdsMaxSize;

# pragma mark - AdjustConfig construtors

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

- (nullable ADJConfig *)initWithAppToken:(nonnull NSString *)appToken
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
- (nullable ADJConfig *)initWithAppToken:(nonnull NSString *)appToken
                             environment:(nonnull NSString *)environment
                        suppressLogLevel:(BOOL)allowSuppressLogLevel;

#pragma mark - AdjustConfig instance methods

/**
 * @brief Check if Adjust configuration object is valid.
 *
 * @return Boolean indicating whether Adjust config object is valid or not.
 */
- (BOOL)isValid;

/**
 * @brief A method for disabling SDK's handling of AdServices.framework.
 */
- (void)disableAdServices;

/**
 * @brief A method for disabling the reading of IDFA parameter.
 */
- (void)disableIdfaReading;

/**
 * @brief A method for disabling the reading of IDFV parameter.
 */
- (void)disableIdfvReading;

/**
 * @brief A method for disabling SKAdNetwork (SKAN) attribution.
 */
- (void)disableSkanAttribution;

/**
 * @brief A method for enabling of sending in the background.
 */
- (void)enableSendingInBackground;

/**
 * @brief A method to enable LinkMe feature.
 */
- (void)enableLinkMe;

/**
 * @brief A method to enable reading of the device IDs just once.
 */
- (void)enableDeviceIdsReadingOnce;

/**
 * @brief A method to enable obtaining of cost data inside of the attribution callback.
 */
- (void)enableCostDataInAttribution;

/**
 * @brief A method to configure SDK to start in COPPA compliant mode.
 */
- (void)enableCoppaCompliance;

/**
 * @brief A method to set custom URL strategy.
 *
 * @param urlStrategyDomains Array of domains to be used as part of the URL strategy.
 * @param useSubdomains Array of domains to be used as part of the URL strategy.
 * @param isDataResidency Indicator of whether URL strategy is a data residency one or not.
 *
 * @note If not set, by default SDK will attempt to send traffic to:
 *           - {analytics,consent}.adjust.com
 *           - {analytics,consent}.adjust.world
 */
- (void)setUrlStrategy:(nullable NSArray *)urlStrategyDomains
         useSubdomains:(BOOL)useSubdomains
       isDataResidency:(BOOL)isDataResidency;

@end

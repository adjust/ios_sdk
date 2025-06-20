//
//  Adjust.h
//  Adjust SDK
//
//  V5.4.1
//  Created by Christian Wellenbrock (@wellle) on 23rd July 2013.
//  Copyright (c) 2012-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADJEvent;
@class ADJConfig;
@class ADJAttribution;
@class ADJAppStoreSubscription;
@class ADJThirdPartySharing;
@class ADJAdRevenue;
@class ADJLinkResolution;
@class ADJAppStorePurchase;
@class ADJPurchaseVerificationResult;
@class ADJDeeplink;

typedef void(^ADJResolvedDeeplinkBlock)(NSString * _Nullable resolvedLink);
typedef void(^ADJAttributionGetterBlock)(ADJAttribution * _Nullable attribution);
typedef void(^ADJIdfaGetterBlock)(NSString * _Nullable idfa);
typedef void(^ADJIdfvGetterBlock)(NSString * _Nullable idfv);
typedef void(^ADJSdkVersionGetterBlock)(NSString * _Nullable sdkVersion);
typedef void(^ADJLastDeeplinkGetterBlock)(NSURL * _Nullable lastDeeplink);
typedef void(^ADJAdidGetterBlock)(NSString * _Nullable adid);
typedef void(^ADJIsEnabledGetterBlock)(BOOL isEnabled);
typedef void(^ADJVerificationResultBlock)(ADJPurchaseVerificationResult * _Nonnull verificationResult);

/**
 * Constants for our supported tracking environments.
 */
extern NSString * __nonnull const ADJEnvironmentSandbox;
extern NSString * __nonnull const ADJEnvironmentProduction;

/**
 * @brief The main interface to Adjust.
 *
 * @note Use the methods of this class to tell Adjust about the usage of your app.
 *       See the README for details.
 */
@interface Adjust : NSObject

/**
 * @brief Tell Adjust that the application did launch.
 *        This is required to initialize Adjust. Call this in the didFinishLaunching
 *        method of your AppDelegate.
 *
 * @note See ADJConfig.h for more configuration options
 *
 * @param adjustConfig The configuration object that includes the environment
 *                     and the App Token of your app. This unique identifier can
 *                     be found it in your dashboard at http://adjust.com and should always
 *                     be 12 characters long.
 */
+ (void)initSdk:(nullable ADJConfig *)adjustConfig;

/**
 * @brief Tell Adjust that a particular event has happened.
 *
 * @note See ADJEvent.h for more event options.
 *
 * @param event The Event object for this kind of event. It needs a event token
 *              that is created in the dashboard at http://adjust.com and should be six
 *              characters long.
 */
+ (void)trackEvent:(nullable ADJEvent *)event;

/**
 * @brief Enable Adjust SDK. This setting is saved for future sessions.
 */
+ (void)enable;

/**
 * @brief Disable Adjust SDK. This setting is saved for future sessions.
 */
+ (void)disable;

/**
 * @brief Check if the SDK is enabled or disabled through a callback.
 *
 * @param completion Completion block to be pinged with the enabled state of the SDK.
 */
+ (void)isEnabledWithCompletionHandler:(nonnull ADJIsEnabledGetterBlock)completion;

/**
 * @brief Read the URL that opened the application to search for an adjust deep link.
 *
 * @param deeplink Deeplink object which contains info about adjust deep link.
 */
+ (void)processDeeplink:(nonnull ADJDeeplink *)deeplink;

/**
 * @brief Process the deep link that has opened an app and potentially get a resolved link.
 *
 * @param deeplink URL object which contains info about adjust deep link.
 * @param completion Completion block where either resolved or echoed deep link will be sent.
 */
+ (void)processAndResolveDeeplink:(nonnull ADJDeeplink *)deeplink
            withCompletionHandler:(nonnull ADJResolvedDeeplinkBlock)completion;

/**
 * @brief Set the APNs push token.
 *
 * @param pushToken APNs push token.
 */
+ (void)setPushToken:(nonnull NSData *)pushToken;

/**
 * @brief Set the APNs push token as stirng.
 *        This method is only used by Adjust non native SDKs. Don't use it anywhere else.
 *
 * @param pushToken APNs push token as string.
 */
+ (void)setPushTokenAsString:(nonnull NSString *)pushToken;

/**
 * @brief Enable offline mode. Activities won't be sent but they are saved when
 *        offline mode is disabled. This feature is not saved for future sessions.
 */
+ (void)switchToOfflineMode;

/**
 * @brief Disable offline mode. Activities won't be sent but they are saved when
 *        offline mode is disabled. This feature is not saved for future sessions.
 */
+ (void)switchBackToOnlineMode;

/**
 * @brief Retrieve iOS device IDFA value through a callback.
 *
 * @param completion Completion block to get IDFA value delivered to.
 */
+ (void)idfaWithCompletionHandler:(nonnull ADJIdfaGetterBlock)completion;

/**
 * @brief Retrieve iOS device IDFV value through a callback.
 *
 * @param completion Completion block to get the IDFV value delivered to.
 */
+ (void)idfvWithCompletionHandler:(nonnull ADJIdfvGetterBlock)completion;

/**
 * @brief Get current adjust identifier for the user through a callback.
 *
 * @param completion Completion block to get the adid value delivered to.
 *
 * @note Adjust identifier is available only after installation has been successfully tracked.
 */
+ (void)adidWithCompletionHandler:(nonnull ADJAdidGetterBlock)completion;

/**
 * @brief Get current attribution for the user through a callback.
 *
 * @note Attribution information is available only after installation has been successfully tracked
 *       and attribution information arrived after that from the backend.
 */
+ (void)attributionWithCompletionHandler:(nonnull ADJAttributionGetterBlock)completion;

/**
 * @brief Get current Adjust SDK version string through a callback.
 *
 * @param completion Completion block to get the Adjust SDK version string (iosX.Y.Z) delivered to.
 */
+ (void)sdkVersionWithCompletionHandler:(nonnull ADJSdkVersionGetterBlock)completion;

/**
 * @brief Convert a universal link style URL to a deeplink style URL with the corresponding scheme.
 *
 * @param url URL object which contains info about adjust deep link.
 * @param scheme Desired scheme to which you want your resulting URL object to be prefixed with.
 *
 * @return URL object in custom URL scheme style prefixed with given scheme name.
 */
+ (nullable NSURL *)convertUniversalLink:(nonnull NSURL *)url withScheme:(nonnull NSString *)scheme;

/**
 * @brief Add default callback parameter key-value pair which is going to be sent with each tracked session and event.
 *
 * @param param Default callback parameter value.
 * @param key Default callback parameter key.
 */
+ (void)addGlobalCallbackParameter:(nonnull NSString *)param forKey:(nonnull NSString *)key;

/**
 * @brief Add default partner parameter key-value pair which is going to be sent with each tracked session.
 *
 * @param param Default partner parameter value.
 * @param key Default partner parameter key.
 */
+ (void)addGlobalPartnerParameter:(nonnull NSString *)param forKey:(nonnull NSString *)key;

/**
 * @brief Remove default callback parameter from the tracked session and event packages.
 *
 * @param key Default callback parameter key.
 */
+ (void)removeGlobalCallbackParameterForKey:(nonnull NSString *)key;

/**
 * @brief Remove default partner parameter from the tracked session and event packages.
 *
 * @param key Default partner parameter key.
 */
+ (void)removeGlobalPartnerParameterForKey:(nonnull NSString *)key;

/**
 * @brief Remove all default callback parameters from the tracked session and event packages.
 */
+ (void)removeGlobalCallbackParameters;

/**
 * @brief Remove all default partner parameters from the tracked session and event packages.
 */
+ (void)removeGlobalPartnerParameters;

/**
 * @brief Give right user to be forgotten in accordance with GDPR law.
 */
+ (void)gdprForgetMe;

/**
 * @brief Track third party sharing with possibility to allow or disallow it.
 *
 * @param thirdPartySharing Third party sharing choice.
 */
+ (void)trackThirdPartySharing:(nonnull ADJThirdPartySharing *)thirdPartySharing;

/**
 * @brief Track measurement consent.
 *
 * @param enabled Value of the consent.
 */
+ (void)trackMeasurementConsent:(BOOL)enabled;

/**
 * @brief Track ad revenue.
 *
 * @param adRevenue Ad revenue object instance containing all the relevant ad revenue tracking data.
 */
+ (void)trackAdRevenue:(nonnull ADJAdRevenue *)adRevenue;

/**
 * @brief Track subscription.
 *
 * @param subscription Subscription object.
 */
+ (void)trackAppStoreSubscription:(nonnull ADJAppStoreSubscription *)subscription;

/**
 * @brief Adjust wrapper for requestTrackingAuthorizationWithCompletionHandler: method of ATTrackingManager.
 *
 * @param completion Block which value of tracking authorization status will be delivered to.
 */
+ (void)requestAppTrackingAuthorizationWithCompletionHandler:(void (^_Nullable)(NSUInteger status))completion;

/**
 * @brief Getter for app tracking authorization status.
 *
 * @return Value of app tracking authorization status.
 */
+ (int)appTrackingAuthorizationStatus;

/**
 * @brief Adjust wrapper for all SKAdNetwork's update conversion value methods.
 *        Pass in all the required parameters for the supported SKAdNetwork version and nil for the rest.
 *
 * @param conversionValue Conversion value you would like SDK to set for given user.
 * @param coarseValue One of the possible SKAdNetworkCoarseConversionValue values.
 * @param lockWindow NSNumber wrapped Boolean value that indicates whether to send the postback before the conversion window ends.
 * @param completion Completion handler you can provide to catch and handle any errors.
 */
+ (void)updateSkanConversionValue:(NSInteger)conversionValue
                      coarseValue:(nullable NSString *)coarseValue
                       lockWindow:(nullable NSNumber *)lockWindow
            withCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion;

/**
 * @brief Get the last deep link which has opened the app through a callback.
 *
 * @param completion Completion block to get the last opened deep link delivered to.
 */
+ (void)lastDeeplinkWithCompletionHandler:(nonnull ADJLastDeeplinkGetterBlock)completion;

/**
 * @brief Enable COPPA (Children's Online Privacy Protection Act) compliant for the application when is in first session delay
 */
+ (void)enableCoppaComplianceInDelay;

/**
 * @brief Disable COPPA (Children's Online Privacy Protection Act) compliant for the application when is in first session delay
 */
+ (void)disableCoppaComplianceInDelay;

/**
 * @brief Custom defined unique device ID (optional) when is in first session delay.
 *
 * @note Make sure to have a UNIQUE external ID for each user / device.
 */
+ (void)setExternalDeviceIdInDelay:(nullable NSString *)externalDeviceId;

/**
 * @brief Verify in-app-purchase.
 *
 * @param purchase   Purchase object.
 * @param completion Callback where verification result will be reported.
 */
+ (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(nonnull ADJVerificationResultBlock)completion;

/**
 * @brief Verify in-app-purchase and track event upon successfully completed verification.
 *
 * @param event      Adjust event to be tracked.
 * @param completion Callback where verification result will be reported.
 */
+ (void)verifyAndTrackAppStorePurchase:(nonnull ADJEvent *)event
                 withCompletionHandler:(nonnull ADJVerificationResultBlock)completion;

/**
 * @brief End the first session delay that can be configured on ADJConfig instance.
 */
+ (void)endFirstSessionDelay;

/**
 * Obtain singleton Adjust object.
 */
+ (nullable instancetype)getInstance;

#pragma mark - Methods for testing (do not use in your app)

/**
 * @brief Method used for internal testing only. Don't use it in your app.
 */
+ (void)setTestOptions:(nullable NSDictionary *)testOptions;

/**
 * @brief Method used for internal testing only. Don't use it in your app.
 */
+ (void)trackSubsessionStart;

/**
 * @brief Method used for internal testing only. Don't use it in your app.
 */
+ (void)trackSubsessionEnd;

@end

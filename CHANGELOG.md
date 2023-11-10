### Version 4.35.3 (13th November 2023)
#### Added
- Added support for `TopOn` and `ADX` ad revenue sources.
- Added a new type of URL strategy called `ADJUrlStrategyCnOnly`. This URL strategy represents `ADJUrlStrategyCn` strategy, but without fallback domains.

---

### Version 4.35.2 (9th October 2023)
#### Added
- Added sending of `event_callback_id` parameter (if set) with the event payload.

---

### Version 4.35.1 (2nd October 2023)
#### Fixed
- Fixed issue with signing requests post ATT delay timer exipry.

---

### Version 4.35.0 (12th September 2023)
#### Added
- Added support for SigV3 library. Update authorization header building logic to use `adj_signing_id`.

---

### Version 4.34.2 (6th September 2023)
#### Added
- Added more logging around ATT delay timer feature to indicate that it's activated.

#### Fixed
- Fixed issue where subsequent calls to active state callback would make ATT delay timer elapse sooner.

---

### Version 4.34.1 (18th August 2023)
#### Fixed
- Fixed `ADJPurchase.h` file not found issue via SPM installation (https://github.com/adjust/ios_sdk/issues/673).

---

### Version 4.34.0 (17th August 2023)
#### Added
- Added ability to delay SDK start in order to wait for an answer to the ATT dialog. You can set the number of seconds to wait (capped internally to 120) by calling the `setAttConsentWaitingInterval:` method of the `ADJConfig` instance.
- Added support for purchase verification. In case you are using this feature, you can now use it by calling `verifyPurchase:completionHandler:` method of the `Adjust` instance.

---

### Version 4.33.6 (25th July 2023)
#### Fixed
- Fixed memory leak occurrences when tracking events (https://github.com/adjust/ios_sdk/issues/668).

---

### Version 4.33.5 (13th July 2023)
#### Changed
- Replaced the usage of `drand48()` with `arc4random_uniform` method.

---

### Version 4.33.4 (9th February 2023)
#### Changed
- Removed usage of `iAd.framework` logic. As of February 7th 2023 the iAd framework has stopped attributing downloads from Apple Ads campaigns.

---

### Version 4.33.3 (29th December 2022)
#### Fixed
- Excluded SKAdNetwork flow from being executed on tvOS target (https://github.com/adjust/ios_sdk/issues/647).

---

### Version 4.33.2 (6th December 2022)
#### Fixed
- Added additional checks to make sure that non-existing selectors for given platform don't attempt to be executed (https://github.com/adjust/ios_sdk/issues/641).

---

### Version 4.33.1 (28th November 2022)
#### Added
- Added support for setting a new China URL Strategy. You can choose this setting by calling `setUrlStrategy:` method of `ADJConfig` instance with `ADJUrlStrategyCn` parameter.
- Added support to `convertUniversalLink:scheme:` method to be able to parse data residency universal links.

---

### Version 4.33.0 (November 19th 2022)
#### Added
- Added support for SKAdNetwork 4.0.

---

### Version 4.32.1 (26th September 2022)
#### Fixed
- Fixed memory issue when continuously writing to a file (https://github.com/adjust/ios_sdk/pull/626).
- Added missing `WKNavigationDelegate`'s missing `didCommitNavigation` method handling inside of the `WKWebViewJavascriptBridge` (https://github.com/adjust/ios_sdk/pull/570).

---

### Version 4.32.0 (7th September 2022)
#### Added
- Added partner sharing settings to the third party sharing feature.
- Added `lastDeeplink` getter to `Adjust` API to be able to get last tracked deep link by the SDK.

---

### Version 4.31.0 (18th July 2022)
#### Added
- Added support for `LinkMe` feature.
- Added ability to build SDKs as `xcframework`s.

---

### Version 4.30.0 (3rd May 2022)
#### Added
- Added ability to mark your app as COPPA compliant. You can enable this setting by calling `setCoppaCompliantEnabled` method of `AdjustConfig` instance with boolean parameter `true`.
- Added `checkForNewAttStatus` into Adjust API whose purpose is to allow users to instruct to SDK to check if `att_status` might have changed in the meantime.
- Added support for `Generic` ad revenue tracking.

#### Fixed
- Fixed wrong ATT dialog method signature in iOS web bridge.

---

### Version 4.29.7 (8th February 2022)
#### Added
- Added support for `Unity` ad revenue tracking.
- Added support for `Helium Chartboost` ad revenue tracking.

#### Changed
- Updated iOS deployment target to `9.0`.

---

### Version 4.29.6 (13th September 2021)
#### Added
- Added support for AdMost ad revenue source.
- Added sending of various feature flags.

---

### Version 4.29.5 (19th August 2021)
#### Added
- Added sending of information when was the call to `registerAppForAdNetworkAttribution` method made.

#### Fixed
- Fixed issue with insufficient buffer size for storing SDK prefix (https://github.com/adjust/react_native_sdk/issues/140).

---

### Version 4.29.4 (9th August 2021)
#### Fixed
- Fixed new Xcode 13 beta compile time errors for extensions targets (https://github.com/adjust/ios_sdk/pull/559).
- Improved dummy iAd attribution responses filtering (https://github.com/adjust/ios_sdk/pull/524).
- Fixed SPM warnnings about `ADJLinkResolution.h` not being part of umbrella header (https://github.com/adjust/ios_sdk/pull/557).
- Fixed some static code analysis warnings (https://github.com/adjust/ios_sdk/pull/558).

---

### Version 4.29.3 (16th June 2021)
#### Fixed
- Fixed compile time errors with Xcode 13 beta (thanks to @yhkaplan).

---

### Version 4.29.2 (12th May 2021)
#### Added
- [beta] Added data residency support for US region. You can choose this setting by calling `setUrlStrategy:` method of `ADJConfig` instance with `ADJDataResidencyUS` parameter.
- Added helper class `ADJLinkResolution` to assist with resolution of links which are wrapping Adjust deep link.

#### Fixed
- Removed 5 decimal places formatting for ad revenue value.

---

### Version 4.29.1 (28th April 2021)
#### Fixed
- Fixed missing header error for SPM users from v4.29.0.

---

### Version 4.29.0 (27th April 2021)
#### Added
- Added `adjustConversionValueUpdated:` callback which can be used to get information when Adjust SDK updates conversion value for the user.
- [beta] Added data residency support for Turkey region. You can choose this setting by calling `setUrlStrategy:` method of `ADJConfig` instance with `ADJDataResidencyTR` parameter.
- Added `trackAdRevenue:` method to `Adjust` interface to allow tracking of ad revenue by passing `ADJAdRevenue` object as parameter.
- Added support for `AppLovin MAX` ad revenue tracking.

#### Changed
- Removed unused ad revenue constants.

---

### Version 4.28.0 (1th April 2021)
#### Changed
- Removed legacy code.

---

### Version 4.27.1 (27th March 2021)
#### Fixed
- Fixed attribution value comparison logic which might cause same attribution value to be delivered into attribution callback.

---

### Version 4.27.0 (17th March 2021)
#### Added
- Added data residency feature. Support for EU data residency region is added. You can choose this setting by calling `setUrlStrategy:` method of `ADJConfig` instance with `ADJDataResidencyEU` parameter.

#### Changed
- Changed the measurement consent parameter name from `sharing` to `measurement`.

---

### Version 4.26.1 (5th February 2021)
#### Fixed
- Fixed nullability warnings.

---

### Version 4.26.0 (3rd February 2021)
#### Added
- Added wrapper method `updateConversionValue:` method to `Adjust` API to allow updating SKAdNetwork conversion value via SDK API.

#### Fixed
- Fixed nullability warnings.

---

### Version 4.25.2 (1st February 2021)
#### Added
- Added Facebook audience network ad revenue source string.

---

### Version 4.25.1 (18th January 2021)
#### Fixed
- Fixed missing header error for SPM users from v4.25.0.

---

### Version 4.25.0 (16th January 2021)
#### Added
- Added support for Apple Search Ads attribution with usage of `AdServices.framework`.
- Added `appTrackingAuthorizationStatus` getter to `Adjust` instance to be able to get current app tracking status.
- Added improved measurement consent management and third party sharing system.

---

### Version 4.24.0 (9th December 2020)
#### Added
- Added possibility to get cost data information in attribution callback.
- Added `setNeedsCost:` method to `ADJConfig` to indicate if cost data is needed in attribution callback (by default cost data will not be part of attribution callback if not enabled with this setter method).
- Enabled position independent code generation.

#### Changed
- Improved logging.
- Addressed Xcode warnings regarding deprecated API usage.
- Removed some obsolete and unused API.

#### Public PRs
- Updated README (https://github.com/adjust/ios_sdk/pull/472).
- Replaced `malloc` with more secure `calloc` calls (https://github.com/adjust/ios_sdk/pull/432).

---

### Version 4.23.2 (28th September 2020)
#### Added
- Added support for Swift Package Manager (thanks to @mstfy).

---

### Version 4.23.1 (16th September 2020)
#### Fixed
- Fixed warning about storing negative value to `NSUInteger` data type.
- Fixed duplicated `ADJURLStrategy` symbols error when using static framework.

---

### Version 4.23.0 (19th August 2020)
#### Added
- Added communication with SKAdNetwork framework by default on iOS 14.
- Added method `deactivateSKAdNetworkHandling` to `ADJConfig` to switch off default communication with SKAdNetwork framework.
- Added wrapper method `requestTrackingAuthorizationWithCompletionHandler:` to `Adjust` to allow immediate propagation of user's choice to backend.
- Added handling of new iAd framework error codes introduced in iOS 14.
- Added sending of value of user's consent to be tracked with each package.
- Added `setUrlStrategy:` method in `ADJConfig` class to allow selection of URL strategy for specific market.

⚠️ **Note**: iOS 14 beta versions prior to 5 appear to have an issue when trying to use iAd framework API like described in [here](https://github.com/adjust/ios_sdk/issues/452). For testing of v4.23.0 version of SDK, please make sure you're using **iOS 14 beta 5 or later**.

---

### Version 4.22.2 (24th July 2020)
#### Added
- Added collection iAd framework communication errors metrics.

---

### Version 4.22.1 (5th June 2020)
#### Fixed
- Fixed `copyWithZone:` method implementation in `ADJSubscription.m` (thanks to @atilimcetin).

---

### Version 4.22.0 (29th May 2020)
#### Added
- Added subscription tracking feature.

### Changed
- Refactored networking part and moved it to request handler.
- Added additional synchronisation in various cases of access to package queue and activity state.

---

### Version 4.21.3 (22nd April 2020)
#### Changed
- Added copying of each injected mutable property of `ADJEvent` class.
- Synchronised access to callback/partner parameters in `ADJEvent` class.
- Synchronised access to public API methods in `Adjust` class.

#### Fixed
- Removed iAd timer.
- Removed activity package mutation scenarios after package has been created.

---

### Version 4.21.2 (15th April 2020)
#### Fixed
- Added check for timer source and block existence prior to starting it.

---

### Version 4.21.1 (9th April 2020)
#### Added
- Added support for Mac Catalyst (thanks to @rjchatfield).

#### Changed
- Replaced `available` attribute with a macro for non native SDKs compatibility.
- Synchronised writing to package queue.
- Updated communication flow with `iAd.framework`.

#### Fixed
- Added nullability check for path being written onto (thanks to @sidepelican).

---

### Version 4.21.0 (19th March 2020)
#### Added
- Added support for signature library as a plugin.
- Added more aggressive sending retry logic for install session package.
- Added additional parameters to `ad_revenue` package payload.

#### Changed
- Replaced deprecated methods in iOS 13 for (un)archiving objects.

#### Fixed
- Added nullability check for `NSString` object returned by `adjUrlDecode` method (thanks to @marinofelipe).

---

### Version 4.20.0 (15th January 2020)
#### Added
- Added external device ID support.

---

### Version 4.19.0 (9th December 2019)
#### Added
- Added `disableThirdPartySharing` method to `Adjust` interface to allow disabling of data sharing with third parties outside of Adjust ecosystem.

---

### Version 4.18.3 (27th September 2019)
#### Changed
- Removed reading of Facebook advertising identifier which sometimes caused blocking of the main thread.

---

### Version 4.18.2 (11th September 2019)
#### Changed
- Removed methods from Adjust SDK web view bridge which are dealing with `UIWebView` objects to address `ITMS-90809`. Please, check web views [migration guide](doc/english/web_view_migration.md) to see how to migrate to `v4.18.2` and also check our [web view example app](examples/AdjustExample-WebView) to see how current Adjust web view SDK should be implemented.
- Replaced deprecated API for better iOS 13 compatibility.

---

### Version 4.18.1 (2nd September 2019)
#### Fixed
- Fixed device token parsing to string, changed in iOS 13.

---

### Version 4.18.0 (26th June 2019)
#### Added
- Added `trackAdRevenue:payload:` method to `Adjust` interface to allow tracking of ad revenue. With this release added support for `MoPub` ad revenue tracking.
- Added reading of Facebook anonymous ID if available.

---

### Version 4.17.3 (24th May 2019)
#### Changed
- SDK will check for iAd information upon re-enabling.

---

### Version 4.17.2 (21st March 2019)
#### Added
- Added `modulemap` file to static framework target to make it usable from Swift apps (https://github.com/adjust/ios_sdk/issues/361).

#### Fixed
- Fixed issue with Adjust pod due to `BITCODE_GENERATION_MODE` option absence (https://github.com/adjust/ios_sdk/issues/368).

---

### Version 4.17.1 (10th December 2018)
#### Fixed
- Fixed issue with printing of certain skipped deep links to debug console output in sandbox mode (https://github.com/adjust/ios_sdk/issues/362).

---

### Version 4.17.0 (4th December 2018)
#### Added
- Added `sdkVersion` getter to `Adjust` interface to obtain current SDK version string.

#### Changed
- Removed posting of `kNetworkReachabilityChangedNotification` notification from forked `ADJReachability` class. In case you were using it, please rely only on obtaining it from official `Reachability` class.

---

### Version 4.16.0 (7th November 2018)
#### Added
- Added sending of UUID string with each attribution request.

---

### Version 4.15.0 (31st August 2018)
#### Added
- Added `setCallbackId` method on `ADJEvent` object for users to set custom ID on event object which will later be reported in event success/failure callbacks.
- Added `callbackId` property to `ADJEventSuccess` class.
- Added `callbackId` property to `ADJEventFailure` class.
- Added support for tracking Facebook Pixel events with iOS web view SDK.
- Aligned feature set of iOS web view SDK with native iOS SDK.
- Added example app which demonstrates how iOS web view SDK can be used to track Facebook Pixel events.

#### Changed
- SDK will now fire attribution request each time upon session tracking finished in case it lacks attribution info.

#### Fixed
- Web bridge callbacks can now be called more than once

---

### Version 4.14.3 (16th August 2018)
#### Changed
- Changed deployment target of iMessage dynamic framework target back to 8.0.
- Changed deployment target of web bridge dynamic framework target back to 8.0.

#### Fixed
- Removed signing settings from dynamic framework targets (thanks to @Igor-Palaguta).

---

### Version 4.14.2 (15th August 2018)
#### Added
- Added support for iMessage target.
- Added iMessage framework to releases page.
- Added Web Bridge framework to releases page.

#### Changed
- Updated web view SDK (`v4.14.0`) and way of how it's being added to your iOS apps with web views. Please, make sure to check iOS web views SDK guide for more details.

---

### Version 4.14.1 (18th June 2018)
#### Added
- Added `setPushToken:` method to `Adjust` interface to use push token as `NSString` data type. This method is intended only to be used by Adjust non native SDKs and you should not be using it in your native iOS app. Please, continue with usage of `setDeviceToken:` method as stated in `README`.

---

### Version 4.14.0 (8th June 2018)
#### Added
- Added deep link caching in case `appWillOpenUrl` method is called before SDK is initialised.

---

### Version 4.13.0 (27th April 2018)
#### Added
- Added `gdprForgetMe` method to `Adjust` interface to enable possibility for user to be forgotten in accordance with GDPR law.

---

### Version 4.12.3 (23rd February 2018)
#### Added
- Added `AdjustTestLibraryStatic` target to the project.

#### Changed
- Stopped creating session packages in case SDK is initialised in suspended app state.
- Started to send install session package right away in case of delayed SDK initialisation.

---

### Version 4.12.2 (13th February 2018)
#### Changed
- Improved SDK logging to indicate the presence/absence of `iAd.framework` inside of the app.

#### Fixed
- Added handling of occasional `nil` file paths when attempting to write to file.

---

### Version 4.12.1 (13th December 2017)
#### Fixed
- Fixed compatibility of Adjust SDK with apps that are already using `Reachability` class (https://github.com/adjust/ios_sdk/issues/315) (thanks to @fedetrim).

---

### Version 4.12.0 (13th December 2017)
#### Added
- Added reading of MCC.
- Added reading of MNC.
- Added reading of network type.
- Added reading of connectivity type.
- Added usage of app secret in authorization header.

#### Changed
- Improved push token handling.
- Migrated Adjust internal files from `Documents` to `Application Support` directory.
- Deprecated `iAd v2` handling.
- Updated `WebViewJavascriptBridge` to `6.0.2`.
- Updated instructions for iOS SDK web bridge integration.

#### Fixed
- Fixed data race in `ADJAttributionHandler` (https://github.com/adjust/ios_sdk/issues/303) (thanks to @mindbrix).
- Fixed potential deadlock in shared access to `UIPasteboard` with Facebook SDK (https://github.com/adjust/ios_sdk/pull/310) (thanks to @sanekgusev).

---

### Version 4.11.5 (21st September 2017)
#### Fixed
- Fixed `WKWebViewJavascriptBridge` bug (https://github.com/marcuswestin/WebViewJavascriptBridge/issues/267).

#### Changed
- Improved iOS 11 compatibility.
- Removed connection validity checks.

---
### Version 4.11.4 (5th May 2017)
#### Added
- Added check if `sdk_click` package response contains attribution information.
- Added sending of attributable parameters with every `sdk_click` package.

#### Changed
- Replaced `assert` level logs with `warn` level.

---

### Version 4.11.3 (23rd March 2017)
#### Changed
- Performing connection validity checks only on main package queue.

---

### Version 4.11.2 (14th March 2017)
#### Changed
- Changed key name used to save persistent UUID to be unique per app.

---

### Version 4.11.1 (13th March 2017)
#### Added
- Added sending of the app's install time.
- Added sending of the app's update time.
- Added nullability annotations to public headers for Swift 3.0 compatibility.
- Added `BITCODE_GENERATION_MODE` to iOS framework for `Carthage` support.
- Added support for iOS 10.3.
- Added connection validity checks.

#### Changed
- Changed some variable types to enable compilation of SDK even if `Sign Comparison` option is turned on in Xcode.

#### Fixed
- Fixed not processing of `sdk_info` package type causing logs not to print proper package name once tracked.
- Fixed random occurrence of attribution request being fired before session request.

---

### Version 4.11.0 (27th December 2016)
#### Added
- Added `adid` field to the attribution callback response.
- Added accessor `[Adjust adid]` to be able to get `adid` value at any time after obtaining it, not only when session/event callbacks have been triggered.
- Added accessor `[Adjust attribution]` to be able to get current attribution value at any time after obtaining it, not only when attribution callback has been triggered.
- Added `AdjustSdkTv` scheme to shared ones in order to allow `Carthage` build for `tvOS`.

#### Changed
- Updated Criteo plugin:
    - Added new partner parameter `user_segment` to be sent in `injectUserSegmentIntoCriteoEvents` (for all Criteo events).
    - Moved `customer_id` to be sent in `injectCustomerIdIntoCriteoEvents` (for all Criteo events).
    - Added new partner parameter `new_customer` to be sent in `injectTransactionConfirmedIntoEvent`.
- Firing attribution request as soon as install has been tracked, regardless of presence of attribution callback implementation in user's app.
- Saveing iAd/AdSearch details to prevent sending duplicated `sdk_click` packages.
- Updated docs.

#### Fixed
- Now reading push token value from activity state file when sending package.
- Fixed memory leak by closing network session.
- Fixed `TARGET_OS_TV` pre processer check.

---

### Version 4.10.3 (18th November 2016)
#### Added
- Added sending of `os_build` parameter.
- Added adjust SDK version information to `Adjust.h` header file.

#### Fixed
- Replaced `NSLog` in `ADJSystemProfile` with the adjust logger.
- It is no longer necessary to have attribution delegate implemented to get deferred deep links.
- Sending `os_build` or permenent version, not both.

---

### Version 4.10.2 (30th September 2016)
#### Fixed
- Added checks if all CPU families are defined.

---

### Version 4.10.1 (12th September 2016)
#### Changed
- Reverted deployment target to `iOS 6.0`.

#### Fixed
- Removed `NSURLSessionConfiguration` with `backgroundSessionConfigurationWithIdentifier`.

---

### Version 4.10.0 (8th September 2016)
#### Changed
- SDK updated due to an update to the Apple App Store Review Guidelines (https://developer.apple.com/app-store/review/guidelines/ chapter 5.1.1 iv).
- Removed functionality of `sendAdWordsRequest` method because of the reason mentioned above.

---

### Version 4.9.0 (7th September 2016)
#### Added
- Added `ADJLogLevelSuppress` to disable all log output messages.
- Added possibility to delay the start of the first session.
- Added support for session parameters which are going to be sent with each session/event:
    - Callback parameters
    - Partner parameters
- Added sending of install receipt.
- Added iOS 10 compatibility.
- Added `AdjustSdkTv.framework` to releases page.

#### Changed
- Deferred deep link info is now delivered as part of the `attribution` answer from the backend.
- Removed optional `adjust_redirect` parameter from resulting URL string when using `convertUniversalLink:scheme` method.
- Normalized properties attributes.
- Changed naming of background blocks.
- Using `weakself strongself` pattern for background blocks.
- Moving log level to the ADJConfig object.
- Accessing private properties directly when copying.
- Removed static framework build with no Bitcode support from releases page.
- Updated docs.

#### Fixed
- Allow foreground/background timer to work in offline mode.
- Use `synchronized` blocks to prevent write deadlock/contention.
- Don't create/use background timer if the option is not configured.
- Replace strong references with weak when possible.
- Use background session configuration for `NSURLSession` when the option is set.

---

### Version 4.8.5 (30th August 2016)
#### Fixed
- Not using `SFSafariViewController` on iOS devices with iOS version lower than 9.

---

### Version 4.8.4 (18th August 2016)
#### Added
- Added support for making Google AdWords request in iOS 10.

---

### Version 4.8.3 (10th August 2016)
#### Added
- Added support to convert shorten universal links.

---

### Version 4.8.2 (5th August 2016)
#### Fixed
- Added initialisation of static vars to prevent dealloc.

---

### Version 4.8.1 (3rd August 2016)
#### Added
- Added Safari Framework in the example app.

### Fixed
- Replaced sleeping background thread with delayed execution.

---

### Version 4.8.0 (25th July 2016)
#### Added
- Added tracking support for native web apps (no SDK version change).

### Changed
- Updated docs.

---

### Version 4.8.0 (18th July 2016)
#### Added
- Added `sendAdWordsRequest` method on `Adjust` instance to support AdWords Search and Mobile Web tracking.

---

### Version 4.7.3 (12th July 2016)
#### Changed
- Added #define for `CPUFAMILY_INTEL_YONAH` due to its deprecation in iOS 10.
- Added #define for `CPUFAMILY_INTEL_MEROM` due to its deprecation in iOS 10.

---

### Version 4.7.2 (9th July 2016)
#### Changed
- Re-enabled SDK auto-start upon initialisation.

---

### Version 4.7.1 (20th June 2016)
#### Added
- Added `CHANGELOG.md` to repository.

#### Fixed
- Re-added support for `iOS 8.0` as minimal deployment target for dynamic framework.

---

### Version 4.7.0 (22nd May 2016)
#### Added
- Added `adjustDeeplinkResponse` method to `AdjustDelegate` to get info when deferred deep link info is received.
- Added possibility to choose with return value of `adjustDeeplinkResponse` whether deferred deep link should be launched or not.
- Added sending of full deep link with `sdk_click` package.

#### Changed
- Updated docs.
- Disabled SDK auto-start upon initialisation.
- Added separate handler for `sdk_click` which is sending those packages immediately after they are created.

#### Fixed
- Fixed situation where SDK does not start immediately when is put to enabled/disabled or online/offline mode.

---

### Version 4.6.0 (15th March 2016)
#### Added
- Added `adjustEventTrackingSucceeded` method to `AdjustDelegate` to get info when event is successfully tracked.
- Added `adjustEventTrackingFailed` method to `AdjustDelegate` to get info when event tracking failed.
- Added `adjustSessionTrackingSucceeded` method to `AdjustDelegate` to get info when session is successfully tracked.
- Added `adjustSessionTrackingFailed` method to `AdjustDelegate` to get info when session tracking failed.

#### Changed
- Updated docs.

---

### Version 4.5.4 (5th February 2016)
#### Added
- Added method for conversion from universal to old style custom URL scheme deep link.

#### Changed
- Updated docs.

#### Fixed
- Fixed documentation warning.
- Fixed `-fembed-bitcode` warnings.

---

### Version 4.5.3 (3rd February 2016)
#### Added
- Added Bitcode flag for static library.

---

### Version 4.5.2 (1st February 2016)
#### Added
- Added `idfa` method on `Adjust` instance to get access to device's `IDFA` value.

#### Changed
- Updated docs.

---

### Version 4.5.1 (20th January 2016)
#### Added
- Added decoding of deep link URL.

---

### Version 4.5.0 (9th December 2015)
#### Added
- Added support for `Carthage`.
- Added dynamic framework SDK target called `AdjustSdk.framework`.
- Added option to forget device from example apps in repository.

#### Changed
- Improved iAd logging.
- Changed name of static framework from `Adjust.framework` to `AdjustSdk.framework`.
- Changed `Adjust` podspec iOS deployment target from `iOS 5.0` to `iOS 6.0`.
- Updated and redesigned example apps in repository.
- Updated docs.

---

### Version 4.4.5 (7th December 2015)
#### Added
- Added support for `iAd v3`.

---

### Version 4.4.4 (30th November 2015)
#### Changed
- Updated `Criteo` plugin to send deep link information.
- Updated docs.

---

### Version 4.4.3 (16th November 2015)
#### Added
- Added support for `Trademob` plugin.

#### Changed
- Updated docs.

---

### Version 4.4.2 (13th November 2015)
#### Added
- Added `Bitcode` support by default.

#### Changed
- Changed minimal target for SDK to `iOS 6`.
- Removed reading of `MAC address`.

#### Fixed
- Fixed tvOS macro for iAd.

---

### Version 4.4.1 (23rd October 2015)
#### Fixed
- Replaced deprecated method `stringByAddingPercentEscapesUsingEncoding` in `Criteo` plugin due to `tvOS` platform.
- Added missing ADJLogger.h header to public headers in static framework.

---

### Version 4.4.0 (13th October 2015)
#### Added
- Added support for `tvOS apps`.
- Added new example apps to repository.

#### Changed
- Updated docs.

#### Fixed
- Removed duplicated ADJLogger.h header in static framework.
- Removed code warnings.

---

### Version 4.3.0 (11th September 2015)
#### Fixed
- Fixed errors on `pre iOS 8` due to accessing `calendarWithIdentifier` method.

---

### Version 4.2.9 (10th September 2015)
#### Changed
- Changed deployment target to `iOS 5.0`.
- Changed delegate reference to be `weak`.
- Replaced `NSURLConnection` with `NSURLSession` for iOS 9 compatibility.

#### Fixed
- Fixed errors with not default date settings.

---

### Version 4.2.8 (21st August 2015)
#### Added
- Added sending of short app version field.

#### Changed
- Updating deep linking handling to be comaptible with iOS 9.
- Updated docs.

#### Fixed
- Fixed memory leak caused by timer.

---

### Version 4.2.7 (30th June 2015)
#### Added
- Added `Sociomantic` plugin `partner ID` parameter.

#### Changed
- Updated docs.

#### Fixed
- Fixed display of revenue values in logs.

---

### Version 4.2.6 (24th June 2015)
#### Changed
- Refactoring to sync with the Android SDK.
- Renamed conditional compilation flag to ADJUST_NO_IAD
- Lowering number of requests to get attribution info.
- Various stability improvements.

---

### Version 4.2.5 (5th June 2015)
#### Added
- Added `Sociomantic` plugin parameters encoding.
- Added new optional `Criteo` plugin `partner ID` parameter.

#### Changed
- Moving `Criteo` and `Sociomantic` plugins in different subspecs.
- Updated docs.

---

### Version 4.2.4 (12th May 2015)
#### Added
- Support for Xamarin SDK bindings.

---

### Version 4.2.3 (30th April 2015)
#### Added
- Added sending of empty receipts.

#### Changed
- Added prefix to `Sociomantic` plugin parameters to avoid possible ambiguities.
- Updated `Criteo` plugin.
- Updated docs.

#### Fixed
- Remove warnings about missing iAd dependencies.

---

### Version 4.2.2 (22nd April 2015)
#### Added
- Added method `setDefaultTracker` to enable setting of default tracker for apps which were not distributed through App Store.

#### Changed
- Updated docs.

#### Fixed
- Removed XCode warnings issues (#96).
- Fixed Swift issue (#74).
- Fixed framework and static library builds.

---

### Version 4.2.1 (16th April 2015)
#### Fixed
- Preventing possible JSON string parsing exception.

---

### Version 4.2.0 (9th April 2015)
#### Added
- Added the click label parameter in attribution response object.

#### Changed
- Updated docs.

---

### Version 4.1.1 (31st March 2015)
#### Added
- Added support for `Sociomantic`.
- Added framework target with support for all architectures.

#### Changed
- Updated docs.

---

### Version 4.1.0 (27th March 2015)
#### Added
- Added server side In-App Purchase verification support.

#### Changed
- Updated docs.

---

### Version 4.0.8 (23rd March 2015)
#### Changed
- Updated `Criteo` plugin.

#### Changed
- Updated docs.

---

### Version 4.0.7 (2nd March 2015)
#### Added
- Added support for `Criteo`.

#### Changed
- Updated docs.

---

### Version 4.0.6 (6th February 2015)
#### Fixed
- Fixed deep link attribution.
- Fixed iAd attribution.

---

### Version 4.0.5 (5th January 2015)
#### Added
- Added `categories` to static SDK library.

#### Changed
- Improved iAd handling (check if iAd call is available instead of trying it with exception handling).

---

### Version 4.0.4 (15th December 2014)
#### Changed
- Removed iAd click sending from events.
- Removed warning when delegate methods are not being set.

#### Fixed
- Prevent errors once migrating class names.

---

### Version 4.0.3 (13th December 2014)
#### Added
- Added deep link click time.

#### Changed
- Changed `ADJConfig` fields `appToken` and `environment` to be `readonly`.
- Removed `CoreTelephony.framework` and `SystemConfiguration.framework`.
- Updated unit tests.
- Updated docs.

---

### Version 4.0.2 (10th December 2014)
#### Fixed
- Fixed problems with reading activity state.

---

### Version 4.0.1 (9th December 2014)
#### Fixed
- Fixed problems with adding callback and partner parameters to the events.

---

### Version 4.0.0 (8th December 2014)
#### Added
- Added config object used for SDK initialisation.
- Added possibility send currency together with revenue in the event.
- Added posibility to track parameters for client callbacks.
- Added posibility to track parameters for partner networks.
- Added `setOfflineMode` method to allow you to put SDK in offline mode.

#### Changed
- Replaced `Response Data delegate` with `Attribution changed delegate`.
- Updated docs.

---

### Version 3.4.0 (17th July 2014)
#### Added
- Added support for handling deferred deep links.

#### Changed
- Removed static dependancy on `ADClient`.

---

### Version 3.3.5 (3rd July 2014)
#### Added
- Added support to send push notification token.

#### Changed
- Updated docs.

---

### Version 3.3.4 (19th June 2014)
#### Added
- Added tracker information to response data.
- Addded support for `Mixpanel`.

#### Changed
- Updated docs.

---

### Version 3.3.3 (13th June 2014)
#### Fixed
- Re-added support to `iOS 5.0.1` devices by sending `vendor ID` only if possible.

---

### Version 3.3.2 (27th May 2014)
#### Added
- Added Javascript bridge for native web apps.

#### Changed
- Updated docs.

---

### Version 3.3.1 (2nd May 2014)
#### Added
- Added `iAd.framework` support.
- Added sending of `vendor ID`.

#### Changed
- Updated docs.

---

### Version 3.3.0 (16th April 2014)
#### Added
- Added handling of `deep link` parameters.

#### Changed
- Updated docs.

---

### Version 3.2.1 (9th April 2014)
#### Changed
- Changed `AdSupport.framework` dependency to `weak`.

---

### Version 3.2.0 (7th April 2014)
#### Added
- Added `setEnabled` method to enable/disable SDK.
- Added `isEnabled` method to check if SDK is enabled or disabled.

#### Changed
- Updated docs.

---

### Version 3.1.0 (4th March 2014)
#### Added
- Added possibility to pass `transactionId` to the event once tracking In-App Purchase revenue.

#### Changed
- Updated docs.

---

### Version 3.0.0 (14th February 2014)
#### Added
- Added delegate method to support in-app source access.
- Added unit tests.

#### Changed
- Renamed `AdjustIo` to `Adjust`.
- Refactored code.
- Various stability improvements.
- Updated docs.

---

### Version 2.2.0 (4th February 2014)
#### Added
- Added reading of `UUID`.

#### Changed
- Updated docs.

---

### Version 2.1.4 (15th January 2014)
#### Added
- Added method to disable `MAC MD5` tracking.

---

### Version 2.1.3 (13th January 2014)
#### Fixed
- Avoid crash on `iOS 5.0.1 and lower` due to lack of `NSURLIsExcludedFromBackupKey` presence.

---

### Version 2.1.2 (7th January 2014)
#### Changed
- `AILogger` is now static class.

#### Fixed
- Removed race condition.

---

### Version 2.1.1 (21th November 2013)
#### Added
- Added support for Unity and Adobe AIR SDKs.

#### Changed
- Removed local files from backups.
- Removed unused code.

---

### Version 2.1.0 (16th September 2013)
#### Added
- Added event buffering feature.
- Added `sandbox` environment.
- Added sending of `tracking_enabled` parameter.

---

### Version 2.0.1 (29th July 2013)
#### Added
- Added support for `Cocoapods`.

#### Changed
- Replaced `AFNetworking` with `NSMutableUrlRequests`.
- Removed `AFNetworking` dependency.

#### Fixed
- Re-added support `iOS 4.3` (recent AFNetworking required iOS 5.0).

---

### Version 2.0 (16th July 2013)
#### Added
- Added support for `iOS 7`.
- Added offline tracking.
- Added persisted storage.
- Addud multi threading.

---

### Version 1.6 (8th March 2013)
#### Added
- Added sending of `MAC MD5` and `MAC SHA1`.

---

### Version 1.5 (28th February 2013)
#### Added
- Added support for `HTTPS` protocol.

#### Changed
- Improved session tracking mechanism.

---

### Version 1.4 (17th January 2013)
#### Added
- Added session IDs and interval to last session event to session starts and ends.
- Added facebook attribution ID to installs for facebook install ads.

---

### Version 1.3 (8th January 2013)
#### Added
- Added tracking of session end.
- Added tracking of `IDFA`.
- Added tracking of `device type` and `device name`.
- Added tracking `AELogger` class.

#### Changed
- Improved revenue event tracking logs.
- Updated documentation.

---

### Version 1.2 (4th October 2012)
#### Added
- Added tracking of events with parameters.
- Added tracking of events with revenue.

#### Changed
- Updated documentation.

---

### Version 1.1 (6th August 2012)
#### Changed
- Replaced `ASIHTTPRequest` wih `AFNetworking`.
- Updated documentation.

---

### Version 1.0.0 (30th July 2012)
#### Added
- Initial release of the adjust SDK for iOS.

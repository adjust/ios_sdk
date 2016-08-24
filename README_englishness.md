## Summary

This is the iOS SDK of adjust™. You can read more about adjust™ at
[adjust.com].

If your app is an app which uses web views you would
like to use adjust tracking from Javascript code, please consult our
[iOS web views SDK guide][ios-web-views-guide].

## Table of contents

* [Example apps](#example-apps)
* [Basic integration](#basic-integration)
    * [Get the SDK](#sdk-get)
    * [Add the SDK to your project](#sdk-add)
    * [Add the AdSupport and iAd framework](#sdk-frameworks)
    * [Integrate the SDK into your app](#sdk-integrate)
        * [Import statement](#import-statement)
        * [Basic setup](#basic-setup)
        * [Adjust logging](#adjust-logging)
    * [Build your app](#build-the-app)
* [Additional features](#additional-features)
    * [Event tracking](#event-tracking)
        * [Revenue tracking](#revenue-tracking)
            * [Revenue deduplication](#revenue-deduplication)
            * [In-App Purchase verification](#iap-verification)
        * [Callback parameters](#callback-parameters)
        * [Partner parameters](#partner-parameters)
    * [Session parameters](#session-parameters)
        * [Session callback parameters](#session-callback-parameters)
        * [Session partner parameters](#session-partner-parameters)
        * [External device id](#external-device-id)
        * [Delay start](#delay-start)
    * [Deeplink reattributions](#deeplink-reattributions)
        * [Universal links](#universal-links)
            * [Enable universal links in the dashboard](#ulinks-dashboard)
            * [Enable your iOS app to handle universal links](#ulinks-ios-app)
        * [Support deeplinks for all iOS versions supported by the adjust SDK](#ulinks-support-all)
    * [Event buffering](#event-buffering)
    * [Background tracking](#background-tracking)
    * [Attribution callback](#attribution-callback)
    * [Event and session callbacks](#event-session-callbacks)
    * [Deferred deeplink callback](#deferred-deeplink-callback)
    * [Disable tracking](#disable-tracking)
    * [Offline mode](#offline-mode)
    * [Device IDs](#device-ids)
    * [Push token](#push-token)
    * [AdWords Search and Mobile Web tracking](#adwords)
* [Troubleshooting](#troubleshooting)
   * [Issues with delayed SDK initialisation](#ts-delayed-init)
   * [I'm seeing "Adjust requires ARC" error](#ts-arc)
   * [I'm seeing "\[UIDevice adjTrackingEnabled\]: unrecognized selector sent to instance" error](#ts-categories)
   * [I'm seeing the "Session failed (Ignoring too frequent session.)" error](#ts-session-failed)
   * [I'm not seeing "Install tracked" in the logs](#ts-install-tracked)
   * [I'm seeing "Unattributable SDK click ignored" message](#ts-iad-sdk-click)
   * [I'm seeing wrong revenue data in the adjust dashboard](#ts-wrong-revenue-amount)
* [License](#license)

## <a id="example-apps"></a>Example apps

There are example apps inside the [`examples` directory][examples] for [`iOS (Objective-C)`][example-ios-objc], 
[`iOS (Swift)`][example-ios-swift], [`tvOS`][example-tvos] and [`Apple Watch`][example-iwatch]. You can open any of these 
Xcode projects to see an example of how the adjust SDK can be integrated.

## <a id="basic-integration">Basic integration

We will describe the steps to integrate the adjust SDK into your iOS project. We are going to assume that you are using Xcode for
your iOS development.

If you're using [CocoaPods][cocoapods], you can add the following line to your `Podfile` and continue from 
[this step](#sdk-integrate):

```ruby
pod 'Adjust', '~> 4.8.2'
```

or:

```ruby
pod 'Adjust', :git => 'https://github.com/adjust/ios_sdk.git', :tag => 'v4.8.2'
```

If you're using [Carthage][carthage], you can add following line to your `Cartfile` and continue from 
[this step](#sdk-frameworks):

```ruby
github "adjust/ios_sdk"
```

You can also choose to integrate the adjust SDK by adding it to your project as a framework. On the 
[releases page][releases] you can find the following three archives:

* `AdjustSdkStatic.framework.zip`
* `AdjustSdkDynamic.framework.zip`
* `AdjustSdkStaticNoBitcode.framework.zip`

Since the release of iOS 8, Apple has introduced dynamic frameworks (also known as embedded frameworks). If your app is 
targeting iOS 8 or higher, you can use the adjust SDK dynamic framework. Choose which framework you want to use – static or
dynamic – and add it to your project.

In case you want to use the static adjust SDK framework without Bitcode support added to it, you can choose the 
`AdjustSdkStaticNoBitcode.framework.zip` file and add it to your project.

If you have chosen one of these ways to integrate the adjust SDK, you may continue from [this step](#sdk-frameworks). If 
you want to add the adjust SDK by adding its source files to your project, you can continue from [this step](#sdk-get).

### <a id="sdk-get"></a>1. Get the SDK

Download the latest adjust SDK version from our [releases page][releases]. Extract the archive into a directory of your choice.

### <a id="sdk-add">2. Add the SDK to your project

In Xcode's Project Navigator locate the `Supporting Files` group (or any other group of your choice). From Finder, drag the
`Adjust` subdirectory into Xcode's `Supporting Files` group.

![][drag]

In the dialog `Choose options for adding these files` make sure to check the checkbox to `Copy items if needed` and select 
the radio button to `Create groups`.

![][add]

### <a id="sdk-frameworks"></a>3. Add the AdSupport and iAd framework

Select your project in the Project Navigator. In the left hand side of the main view, select your target. In the tab 
`Build Phases`, expand the group `Link Binary with Libraries`. On the bottom of that section click on the `+` button. 
Select the `AdSupport.framework` and click the `Add` button. Unless you 
are using tvOS, repeat the same steps to add the `iAd.framework`. Change the `Status` of both frameworks to `Optional`.

![][framework]

### <a id="sdk-integrate"></a>4. Integrate the SDK into your app

#### <a id="import-statement">Import statement

If you added the adjust SDK from the source or via a Pod repository, you should use one of the following import statements:

```objc
#import "Adjust.h"
```

or

```objc
#import <Adjust/Adjust.h>
```

If you added the adjust SDK as a framework or via Carthage, you should use the following import statement:

```objc
#import <AdjustSdk/Adjust.h>
```

Next, we'll set up basic session tracking.

#### <a id="basic-setup">Basic setup

In the Project Navigator, open the source file of your application delegate. Add the `import` statement at the top of the 
file, then add the following call to `Adjust` in the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your 
app delegate:

```objc
#import "Adjust.h"
// or #import <Adjust/Adjust.h>
// or #import <AdjustSdk/Adjust.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJEnvironmentSandbox;
ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                            environment:environment];
[Adjust appDidLaunch:adjustConfig];
```
![][delegate]

**Note**: Initialising the adjust SDK like this is `very important`. Otherwise, you may encounter different kinds of 
issues as described in our [troubleshooting section](#ts-delayed-init).

Replace `{YourAppToken}` with your app token. You can find this in your [dashboard].

Depending on whether you build your app for testing or for production, you must set `environment` with one of these values:

```objc
NSString *environment = ADJEnvironmentSandbox;
NSString *environment = ADJEnvironmentProduction;
```

**Important:** This value should be set to `ADJEnvironmentSandbox` if and only if you or someone else is testing your app. 
Make sure to set the environment to `ADJEnvironmentProduction` just before you publish the app. Set it back to 
`ADJEnvironmentSandbox` when you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic from test devices. It is very important that 
you keep this value meaningful at all times! This is especially important if you are tracking revenue.

#### <a id="adjust-logging">Adjust logging

You can increase or decrease the amount of logs that you see during testing by calling `setLogLevel:` on your `ADJConfig` instance with
one of the following parameters:

```objc
[adjustConfig setLogLevel:ADJLogLevelVerbose]; // enable all logging
[adjustConfig setLogLevel:ADJLogLevelDebug];   // enable more logging
[adjustConfig setLogLevel:ADJLogLevelInfo];    // the default
[adjustConfig setLogLevel:ADJLogLevelWarn];    // disable info logging
[adjustConfig setLogLevel:ADJLogLevelError];   // disable warnings as well
[adjustConfig setLogLevel:ADJLogLevelAssert];  // disable errors as well
```

### <a id="build-the-app">5. Build your app

Build and run your app. If the build succeeds, you should carefully read the SDK logs in the console. After the app launches
for the first time, you should see the info log `Install tracked`.

![][run]

## <a id="additional-feature">Additional features

Once you integrate the adjust SDK into your project, you can take advantage of the following features.

### <a id="event-tracking">Event tracking

You can use adjust to track events. Lets say you want to track every tap on a particular button. You would create a new 
event token in your [dashboard], which has an associated event token - looking something like `abc123`. In your button's 
`buttonDown` method you would then add the following lines to track the tap:

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[Adjust trackEvent:event];
```

When tapping the button you should now see `Event tracked` in the logs.

The event instance can be used to configure the event further before tracking it:

#### <a id="revenue-tracking">Revenue tracking

If your users can generate revenue by tapping on advertisements or making in-app purchases you can track those revenues with
events. Lets say a tap is worth one Euro cent. You could then track the revenue event like this:

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[event setRevenue:0.01 currency:@"EUR"];
[Adjust trackEvent:event];
```

This can be combined with callback parameters of course.

When you set a currency token, adjust will automatically convert the incoming revenues into a reporting revenue of your 
choice. Read more about [currency conversion here.][currency-conversion]

You can read more about revenue and event tracking in the [event tracking guide]
(https://docs.adjust.com/en/event-tracking/#reference-tracking-purchases-and-revenues).

##### <a id="revenue-deduplication"></a> Revenue deduplication

You can also pass in an optional transaction ID to avoid tracking duplicate revenues. The last ten transaction IDs are 
remembered and revenue events with duplicate transaction IDs are skipped. This is especially useful for in-app purchase 
tracking. See an example below.

If you want to track in-app purchases, please make sure to call `trackEvent` after `finishTransaction` in 
`paymentQueue:updatedTransaction` only if the state changed to `SKPaymentTransactionStatePurchased`. That way you can avoid 
tracking revenue that is not actually being generated.

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self finishTransaction:transaction];

                ADJEvent *event = [ADJEvent eventWithEventToken:...];
                [event setRevenue:... currency:...];
                [event setTransactionId:transaction.transactionIdentifier]; // avoid duplicates
                [Adjust trackEvent:event];

                break;
            // more cases
        }
    }
}
```

##### <a id="iap-verification">In-App Purchase verification

If you want to check the validity of In-App Purchases made in your app using Purchase Verification, adjust's server side 
receipt verification tool, then check out our iOS purchase SDK and read more about it [here][ios-purchase-verification].

#### <a id="callback-parameters">Callback parameters

You can register a callback URL for your events in your [dashboard]. We will send a GET request to that URL whenever the 
event is tracked. You can add callback parameters to that event by calling `addCallbackParameter` to the event before 
tracking it. We will then append these parameters to your callback URL.

For example, suppose you have registered the URL
`http://www.mydomain.com/callback` then track an event like this:

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[event addCallbackParameter:@"key" value:@"value"];
[event addCallbackParameter:@"foo" value:@"bar"];
[Adjust trackEvent:event];
```

In that case we would track the event and send a request to:

    http://www.mydomain.com/callback?key=value&foo=bar

It should be mentioned that we support a variety of placeholders like `{idfa}` that can be used as parameter values. In the 
resulting callback this placeholder would be replaced with the ID for Advertisers of the current device. Also note that we 
don't store any of your custom parameters, but only append them to your callbacks, thus without a callback they will not be saved nor sent to you.

You can read more about using URL callbacks, including a full list of available values, in our 
[callbacks guide][callbacks-guide].

#### <a id="partner-parameters">Partner parameters

You can also add parameters to be transmitted to network partners, which have been activated in your 
adjust dashboard.

This works similarly to the callback parameters mentioned above, but can be added by calling the `addPartnerParameter` 
method on your `ADJEvent` instance.

```objc
ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[event addPartnerParameter:@"key" value:@"value"];
[Adjust trackEvent:event];
```

You can read more about special partners and these integrations in our [guide to special partners][special-partners].

In that case we would track the event and send a request to:

    http://www.adjust.com/callback?key=value&foo=bar

It should be mentioned that we support a variety of placeholders like `{idfa}` that can be used as parameter values. In the 
resulting callback this placeholder would be replaced with the ID for Advertisers of the current device. Also note that we 
don't store any of your custom parameters, but only append them to your callbacks. If you haven't registered a callback for 
an event, these parameters won't even be read.

You can read more about using URL callbacks, including a full list of available placeholders, in our 
[callbacks guide][callbacks-guide].

### <a id="session-parameters">Set up session parameters

Some parameters are saved to be send in every event and session of the adjust SDK.
Once you have add any of these parameters, you don't need to add them every time, since they will be saved locally.
If you add the same parameter twice, there will be no effect.

These session parameters can be called before the adjust SDK is launched to make sure they are send even on install.
If you need to send them with an install, but can only obtain the needed values after launch, it's possible to [delay](#delay-start) the first launch of the adjust SDK to allow this behaviour.

#### <a id="session-callback-parameters"> Session callback parameters

The same callback parameters that are registered for [events](#callback-parameters) can be also saved to be sent in every event or session of the adjust SDK.

The session callback parameters have a similar interface of the event callback parameters. 
Instead of adding the key and it's value to an event, it's added through a call to `Adjust` method `addSessionCallbackParameter:value:`:

```objc
[Adjust addSessionCallbackParameter:@"foo" value:@"bar"];
```

The session callback parameters will be merged with the callback parameters added to an event.
The callback parameters added to an event have precedence over the session callback parameters. 
Meaning that, when adding a callback parameter to an event with the same key to one added from the session, the value that prevails is the callback parameter added to the event.

It's possible to remove a specific session callback parameter by passing the desiring key to the method `removeSessionCallbackParameter`.

```objc
[Adjust removeSessionCallbackParameter:@"foo"];
```

If you wish to remove all key and values from the session callback parameters, you can reset it with the method `resetSessionCallbackParameters`.

```objc
[Adjust resetSessionCallbackParameters];
```

#### <a id="session-partner-parameters"> Session partner parameters

In the same way that there is [session callback parameters](#session-callback-parameters) that are send every in event or session of the adjust SDK, there is also session partner parameters.

These will be transmitted to network partners, for the integrations that have been activated in your adjust [dashboard].

The session partner parameters have a similar interface of the event partner parameters. 
Instead of adding the key and it's value to an event, it's added through a call to `Adjust` method `addSessionPartnerParameter:value:`:

```objc
[Adjust addSessionPartnerParameter:@"foo" value:@"bar"];
```

The session partner parameters will be merged with the partner parameters added to an event.
The partner parameters added to an event have precedence over the session partner parameters. 
Meaning that, when adding a partner parameter to an event with the same key to one added from the session, the value that prevails is the partner parameter added to the event.

It's possible to remove a specific session partner parameter by passing the desiring key to the method `removeSessionPartnerParameter`.

```objc
[Adjust removeSessionPartnerParameter:@"foo"];
```

If you wish to remove all key and values from the session partner parameters, you can reset it with the method `resetSessionPartnerParameters`.

```objc
[Adjust resetSessionPartnerParameters];
```

#### <a id="external-device-id"> External device id

XXX(better context/explanation?)

The adjust SDK uses device ids that are available from iOS, but your app might have other sources of identifiers that can help features like ad conversion.

To save your unique identifier in the session parameters that are send in every request and session, call the `addExternalDeviceId` method:

```objc
[Adjust addExternalDeviceId:@"customDeviceId"];
```

It's also possible to remove the saved unique identifier by calling the method `resetExternalDeviceId`:

```objc
[Adjust resetExternalDeviceId];
```

#### <a id="delay-start"> Delay start

Delaying the start of the adjust SDK allows your app some time to obtain session parameters, such as unique identifiers, to be send on install.

Set the initial delay time in seconds with the method `setDelayStart` in the `ADJConfig` instance:

```objc
[adjustConfig setDelayStart:5.5];
```

In this case this will make the adjust SDK not send the initial install session and any event created for 5.5 seconds.
After this time is expired or if you call `[Adjust sendFirstPackages]` in the meanwhile, every session parameter will be added to the delayed install session and events and the adjust SDK will resume as usual.

The maximum delay start time of the adjust SDK is 10 seconds.

### <a id="deeplink-reattributions">Deeplink reattributions

You can set up the adjust SDK to handle deeplinks that are used to open your app via a custom URL scheme. We will only read 
certain adjust specific parameters. This is essential if you are planning to run retargeting or re-engagement campaigns with
deeplinks.

If you are planning to run retargeting or re-engagement campaigns with deep links, you should put the adjust campaign 
specific parameter into your deep link. For more information on how to run retargeting or re-engagement campaigns with deep 
links, check our [official docs][reattribution-deeplinks].

In the Project Navigator open the source file your Application Delegate. Find or add the method `openURL` and add the 
following call to adjust:

```objc
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [Adjust appWillOpenUrl:url];
    
    // Your code goes here
    BOOL canHandle = [self someLogic:url];
    return canHandle;
}
```

**Important**: Tracker URLs with `deep_link` parameters and your custom URL scheme in it are no longer supported in 
`iOS 9 and higher` and clicks on them will not cause your app to be opened nor will the `openURL` method get triggered. Apple 
dropped  support for this way of deeplinking into the app in favour of `universal links`. However, this approach will 
`still works for devices with iOS 8 and lower`.

#### <a id="universal-links">Universal links

**Note**: Universal links are supported `since iOS 9`.

If you want to support [universal links][universal-links], then follow these next steps.

##### <a id="ulinks-dashboard">Enable universal links in the dashboard

In order to enable universal links for your app, go to the adjust dashboard and select the `Universal Linking` option in your 
`Platform Settings` for iOS.

![][universal-links-dashboard]

<a id="ulinks-setup">You will need to fill in your `iOS Bundle ID` and `iOS Team ID`.

![][universal-links-dashboard-values]

You can find your iOS Team ID in the `Apple Developer Center`.

![][adc-ios-team-id]

After you have entered these two values, a universal link for your app will be generated and will look like this:

```
applinks:[hash].ulink.adjust.com
```

##### <a id="ulinks-ios-app">Enable your iOS app to handle universal links

In the Apple Developer Center, you should enable the required `Associated Domains` for your app.

![][adc-associated-domains]

**Important**: Usually, `iOS Team ID` is the same as the `Prefix` value (above picture)  for your app. In some cases, it can
happen that these two values differ. If this is the case, please go back to this [step](#ulinks-setup) and use the `Prefix` 
value for `iOS Team ID` field in the adjust dashboard.

Once you have done this, you should enable `Associated Domains` in your app's Xcode project settings, and copy the generated
universal link from the dashboard into the `Domains` section.

![][xcode-associated-domains]

Next, find or add the method `application:continueUserActivity:restorationHandler:` in your Application Delegate. In that 
method, add the following call to adjust:

``` objc
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity 
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [Adjust appWillOpenUrl:[userActivity webpageURL]];
    }

    // Your code goes here
    BOOL canHandle = [self someLogic:[userActivity webpageURL]];
    return canHandle;
}
```

For example, if you were setting your `deep_link` parameter like this:

```
example://path/?key=foo&value=bar
```

the adjust backend will convert it to a universal link, which looks like this:

```
https://[hash].ulink.adjust.com/ulink/path/?key=foo&value=bar
```

We provide a helper function that allows you to convert a universal link to a deeplink url.

```objc
NSURL *deeplink = [Adjust convertUniversalLink:[userActivity webpageURL] scheme:@"example"];
```

You can read more about implementing universal links in our [guide to universal links][universal-links-guide].

#### <a id="ulinks-support-all">Support deeplinks for all iOS versions supported by the adjust SDK

If you are using iOS 9 or higher with your app, universal links are all you need in order to enable deeplinking for your 
app. But, in case you want to support deeplinking on iOS 8 and lower devices as well, you need to build an adjust style 
universal link like described in [here][adjust-universal-links].

Also, you should have both methods implemented in your Application Delegate class - `openURL` and 
`application:continueUserActivity:restorationHandler:` because based on device iOS version, (`iOS 8 and lower` or 
`iOS 9 and higher`) different methods will be triggered for deeplinked content delivered into your app for you to parse it and 
decide where to navigate the user.

For instructions on how to test your implementation, please read our [guide][universal-links-testing].

### <a id="event-buffering">Event buffering

If your app makes heavy use of event tracking, you might want to delay some HTTP requests in order to send them in one batch
every minute. You can enable event buffering with your `ADJConfig` instance:

```objc
[adjustConfig setEventBufferingEnabled:YES];
```

### <a id="background-tracking">Background tracking

The default behaviour of the adjust SDK is to pause sending HTTP requests while the app is in the background. You can change
this in your `AdjustConfig` instance:

```objc
[adjustConfig setSendInBackground:YES];
```

### <a id="attribution-callback">Attribution callback

You can register a delegate callback to be notified of tracker attribution changes. Due to the different sources considered 
for attribution, this information can not by provided synchronously. Follow these steps to implement the optional delegate 
protocol in your app delegate:

Please make sure to consider our [applicable attribution data policies.][attribution-data]

1. Open `AppDelegate.h` and add the import and the `AdjustDelegate` declaration.

    ```objc
    #import "Adjust.h"
    // or #import <Adjust/Adjust.h>
    // or #import <AdjustSdk/Adjust.h>

    @interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>
    ```

2. Open `AppDelegate.m` and add the following delegate callback function to your app delegate implementation.

    ```objc
    - (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    }
    ```

3. Set the delegate with your `ADJConfig` instance:

    ```objc
    [adjustConfig setDelegate:self];
    ```
    
As the delegate callback is configured using the `ADJConfig` instance, you should call `setDelegate` before calling 
`[Adjust appDidLaunch:adjustConfig]`.

The delegate function will be available after the SDK receives the final attribution data. Within the delegate function you have access to
the `attribution` parameters. Here is a quick summary of its properties:

- `NSString trackerToken` the tracker token of the current install.
- `NSString trackerName` the tracker name of the current install.
- `NSString network` the network grouping level of the current install.
- `NSString campaign` the campaign grouping level of the current install.
- `NSString adgroup` the ad group grouping level of the current install.
- `NSString creative` the creative grouping level of the current install.
- `NSString clickLabel` the click label of the current install.

### <a id="event-session-callbacks">Event and session callbacks

You can register a delegate callback to be notified of successful and failed tracked events and/or sessions.

The same optional protocol `AdjustDelegate` used for the [attribution callback](#attribution-callback) is used.

Follow the same steps and implement the following delegate callback function for successful tracked events:

```objc
- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
}
```

The following delegate callback function for failed tracked events:

```objc
- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
}
```

For successful tracked sessions:

```objc
- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
}
```

And for failed tracked sessions:

```objc
- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
}
```

The delegate functions will be called after the SDK tries to send a package to the server. Within the delegate callback you 
have access to a response data object specifically for the delegate callback. Here is a quick summary of the session 
response data properties:

- `NSString message` the message from the server or the error logged by the SDK.
- `NSString timeStamp` timestamp from the server.
- `NSString adid` a unique device identifier provided by adjust.
- `NSDictionary jsonResponse` the JSON object with the response from the server.

Both event response data objects contain:

- `NSString eventToken` the event token, if the package tracked was an event.

And both event and session failed objects also contain:

- `BOOL willRetry` indicates that there will be an attempt to resend the package at a later time.

### <a id="deferred-deeplink-callback">Deferred deeplink callback

You can register a delegate callback to be notified before a deferred deeplink is opened and decide if the adjust SDK will 
open it.

The same optional protocol `AdjustDelegate` used for the [attribution callback](#attribution-callback) and for 
[event and session callbacks](#event-session-callbacks) is used.

Follow the same steps and implement the following delegate callback function for deferred deeplinks:

```objc
// evaluate deeplink to be launched
- (void)adjustDeeplinkResponse:(NSURL *)deeplink {
     // ...
     if ([self allowAdjustSDKToOpenDeeplink:deeplink]) {
         return YES;
     } else {
         return NO;
     }
}
```

The callback function will be called after the SDK receives a deffered deeplink from our server and before opening it.  
Within the callback function you have access to the deeplink. The returned boolean value determines if the SDK will launch 
the deeplink. You could, for example, not allow the SDK to open the deeplink at the current moment, save it, and open it yourself 
later.

### <a id="disable-tracking">Disable tracking

You can disable the adjust SDK from tracking any activities of the current device by calling `setEnabled` with parameter 
`NO`. **This setting is remembered between sessions**, but it can only be activated after the first session.

```objc
[Adjust setEnabled:NO];
```

<a id="is-enabled">You can check if the adjust SDK is currently enabled by calling the function `isEnabled`. It is always 
possible to activate the adjust SDK by invoking `setEnabled` with the enabled parameter as `YES`.

### <a id="offline-mode">Offline mode

You can put the adjust SDK in offline mode to suspend transmission to our servers while retaining tracked data to be sent 
later. While in offline mode, all information is saved in a file, so be careful not to trigger too many events while in 
offline mode.

You can activate offline mode by calling `setOfflineMode` with the parameter `YES`.

```objc
[Adjust setOfflineMode:YES];
```

Conversely, you can deactivate offline mode by calling `setOfflineMode` with `NO`. When the adjust SDK is put back in online
mode, all saved information is sent to our servers with the correct time information.

Unlike disabling tracking, this setting is **not remembered** bettween sessions. This means that the SDK is in online mode 
whenever it is started, even if the app was terminated in offline mode.

### <a id="device-ids">Device IDs

Certain services (such as Google Analytics) require you to coordinate device and client IDs in order to prevent duplicate 
reporting.

To obtain the device identifier IDFA, call the function `idfa`:

```objc
NSString *idfa = [Adjust idfa];
```

### <a id="push-token">Push token

To send us the push notification token, add the following call to `Adjust` in the 
`didRegisterForRemoteNotificationsWithDeviceToken` of your app delegate:

```objc
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Adjust setDeviceToken:deviceToken];
}
```

### <a id="adwords">17. AdWords Search and Mobile Web tracking

To support deterministic tracking for all AdWords web inventories, you simply need to call the `sendAdWordsRequest` on the 
adjust instance **before** initialising the SDK.

```objc
#import "Adjust.h"
// or #import <Adjust/Adjust.h>
// or #import <AdjustSdk/Adjust.h>

// ...

NSString *yourAppToken = @"{YourAppToken}";
NSString *environment = ADJEnvironmentSandbox;
ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                            environment:environment];
                                            
[Adjust sendAdWordsRequest];
[Adjust appDidLaunch:adjustConfig];
```

## <a id="troubleshooting">Troubleshooting

#### <a id="ts-delayed-init">Issues with delayed SDK initialisation

As described in the [basic setup step](#basic-setup), we strongly advise you to initialise the adjust SDK in the 
`didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate. It is imperative to initialise 
the adjust SDK in as soon as possible so that you can use all the features of the SDK.

Deciding not to initialise the adjust SDK immediately can have all kinds of impacts on the tracking in your app: 
**In order to perform any kind of tracking in your app, the adjust SDK *must* be initialised.**

If you decide to perform any of these actions:

* [Event tracking](#event-tracking)
* [Deeplink reattributions](#deeplink-reattributions)
* [Disable tracking](#disable-tracking)
* [Offline mode](#offline-mode)

before initialising the SDK, `they won't be performed`.

If you want any of these actions to be tracked with the adjust SDK before its actual initialisation, 
you must build a `custom actions queueing mechanism` inside your app. You need to queue all the actions you want our SDK to perform and perform them once the SDK is initialised.

Offline mode state won't be changed, tracking enabled/disabled state won't be changed, deeplink reattributions will not be 
possible to happen, any of tracked events will be `dropped`.

Another thing which might be affected by delayed SDK initialisation is session tracking. The adjust SDK can't start to collect any 
session length info before it is actually initialised. This can affect your DAU numbers in the dashboard which might not be 
tracked properly.

As an example, let's assume this scenario: You are initialising the adjust SDK when some specific view or view controller is 
loaded and let's say that this is not the splash nor the first screen in your app, but user has to navigate to it from the home 
screen. If user downloads your app and opens it, the home screen will be displayed. At this moment, this user has made an 
install which should be tracked. However, the adjust SDK doesn't know anything about this, because the user 
needs to navigate to the screen mentioned previously where you decided to initialise the adjust SDK. Further, if the user decides that he/she doesn't 
like the app and uninstalls it right after seeing home screen, all the information mentioned above will never be tracked by 
our SDK, nor displayed in the dashboard.


##### Event tracking

For the events you want to track, queue them with some internal queueing mechanism and track them after SDK is 
initialised. Tracking events before initialising SDK will cause the events to be `dropped` and `permanently lost`, so make 
sure you are tracking them once SDK is `initialised` and [`enabled`](#is-enabled).

##### Offline mode and enable/disable tracking

Offline mode is not the feature which is persisted between SDK initialisations, so it is set to `false` by default. If you 
try to enable offline mode before initialising SDK, it will still be set to `false` when you eventually initialise the SDK.

Enabling/disabling tracking is the setting which is persisted between the SDK initialisations. If you try to toggle this 
value before initialising the SDK, toggle attempt will be ignored. Once initialised, SDK will be in the state (enabled or 
disabled) like before this toggle attempt.

##### Deeplink reattributions

As described in [above](#deeplink-reattributions), when handling deeplink reattributions, depending
on deeplinking mechanism you are using (old style vs. universal links), you will obtain `NSURL` object after which you need 
to make following call:

```objc
[Adjust appWillOpenUrl:url]
```

If you make this call before the SDK has been initialised, information about the attribution information from the deeplink URL 
will be permanetly lost. If you want the adjust SDK to successfully reattribute 
your user, you would need to queue this `NSURL` object information and trigger `appWillOpenUrl` method once the SDK has been 
initialised.

##### Session tracking

Session tracking is something what the adjust SDK performs automatically and is beyond reach of an app developer. For proper
session tracking it is crucial to have the adjust SDK initialised as advised in this README. Not doing so can have 
unpredicted influences on proper session tracking and DAU numbers in the dashboard. 

For example:
* A user opens but then deletes your app before the SDK was even inialised, causing the install and session to have never been tracked, thus never reported in the dashboard.
* If a user downloads and opens your app before midnight, and the adjust SDK gets initialised after midnight, all queued install and session data will be reported on wrong day.
* If a user didn't use your app on some day but opens it shortly after midnight and the SDK gets initialised after midnight, causing DAU to be reported on another day from the day of the app opening.

For all these reasons, please follow the instructions in this document and initialise the adjust SDK in the 
`didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate.

#### <a id="ts-arc">I'm seeing "Adjust requires ARC" error

If your build failed with the error `Adjust requires ARC`, it looks like your project is not using [ARC][arc]. In that case 
we recommend [transitioning your project][transition] so that it does use ARC. If you don't want to use ARC, you have to enable ARC for 
all source files of adjust in the target's Build Phases:

Expand the `Compile Sources` group, select all adjust files and change the `Compiler Flags` to `-fobjc-arc` (Select all and 
press the `Return` key to change all at once).

#### <a id="ts-categories">I'm seeing "[UIDevice adjTrackingEnabled]: unrecognized selector sent to instance" error

This error can occur when you are adding the adjust SDK framework to your app. The adjust SDK contains `categories` among it's
source files and for this reason, if you have chosen this SDK integration approach, you need to add `-ObjC` flags to `Other 
Linker Flags` in your Xcode project settings. Adding this flag will fix this error.

#### <a id="ts-session-failed">I'm seeing the "Session failed (Ignoring too frequent session.)" error

This error typically occurs when testing installs. Uninstalling and reinstalling the app is not enough to trigger a new 
install. The servers will determine that the SDK has lost its locally aggregated session data and ignore the erroneous 
message, given the information available on the servers about the device.

This behaviour can be cumbersome during tests, but is necessary in order to have the sandbox behaviour match production as 
much as possible.

You can reset the session data of the device in our servers. Check the error message in the logs:

```
Session failed (Ignoring too frequent session. Last session: YYYY-MM-DDTHH:mm:ss, this session: YYYY-MM-DDTHH:mm:ss, interval: XXs, min interval: 20m) (app_token: {yourAppToken}, adid: {adidValue})
```

<a id="forget-device">With the `{yourAppToken}` and `{adidValue}` values filled in below, open the following link:

```
http://app.adjust.com/forget_device?app_token={yourAppToken}&adid={adidValue}
```

When the device is forgotten, the link just returns `Forgot device`. If the device was already forgotten or the values were 
incorrect, the link returns `Device not found`.

#### <a id="ts-install-tracked">I'm not seeing "Install tracked" in the logs

If you want to simulate the installation scenario of your app on your test device, it is not enough if you just re-run the app 
from the Xcode on your test device. Re-running the app from the Xcode doesn't cause app 
data to be wiped out and all internal files that our SDK is keeping inside your app will still be there, so upon re-run, our SDK 
will see those files and think of your app was already installed (and that SDK was already launched in it) but just 
opened for another time rather than being opened for the first time.

In order to run app the installation scenario, you need to do following:

* Uninstall app from your device (completely remove it)
* Forget your test device from the adjust backend like explained in the issue [above](#forget-device)
* Run your app from the Xcode on the test device and you will see log message "Install tracked"

#### <a id="ts-iad-sdk-click">I'm seeing the "Unattributable SDK click ignored" message

You may notice this message while testing your app in `sandbox` envoronment. It is related to some changes Apple introduced 
in `iAd.framework` version 3. With this, a user can be directed to your app from a click on iAd banner and this will cause our SDK to 
send an `sdk_click` package to the adjust backend informing it about the content of the clicked URL. For some reason, Apple 
decided that if the app was opened without clicking on iAd banner, they will artificially generate an iAd banner URL click with 
some random values. Our SDK won't be able to distinguish if the iAd banner click was genuine or artificially generated and will 
send an `sdk_click` package regardless to the adjust backend. If you have your log level set to `verbose` level, you will see this 
`sdk_click` package looking something like this:

```
[Adjust]d: Added package 1 (click)
[Adjust]v: Path:      /sdk_click
[Adjust]v: ClientSdk: ios4.8.2
[Adjust]v: Parameters:
[Adjust]v:      app_token              {YourAppToken}
[Adjust]v:      created_at             2016-04-15T14:25:51.676Z+0200
[Adjust]v:      details                {"Version3.1":{"iad-lineitem-id":"1234567890","iad-org-name":"OrgName","iad-creative-name":"CreativeName","iad-click-date":"2016-04-15T12:25:51Z","iad-campaign-id":"1234567890","iad-attribution":"true","iad-lineitem-name":"LineName","iad-creative-id":"1234567890","iad-campaign-name":"CampaignName","iad-conversion-date":"2016-04-15T12:25:51Z"}}
[Adjust]v:      environment            sandbox
[Adjust]v:      idfa                   XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
[Adjust]v:      idfv                   YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY
[Adjust]v:      needs_response_details 1
[Adjust]v:      source                 iad3
```

If for some reason this `sdk_click` would be accepted, it would mean that a user who has opened your app 
by clicking on some other campaign URL or even as an organic user, will get attributed to this unexisting iAd source.
This is the reason why our backend ignores it and informs you with this message:

```
[Adjust]v: Response: {"message":"Unattributable SDK click ignored."}
[Adjust]i: Unattributable SDK click ignored.
```

So, this message doesn't indicate any issue with your SDK integration but it's simply informing you that our backend has ignored
this artificially created `sdk_click` which could have lead to your user being wrongly attributed/reattributed.

#### <a id="ts-wrong-revenue-amount">I'm seeing incorrect revenue data in the adjust dashboard

The adjust SDK tracks what you tell it to track. If you are attaching revenue to your event, the number you write as an amount 
is the only amount which will reach the adjust backend and be displayed in the dashboard. Our SDK does not manipulate your 
amount value, nor does our backend. So, if you see wrong amount being tracked, it's because our SDK was told to track that 
amount.

Usually, a user's code for tracking revenue event looks something like this:

```objc
// ...

- (double)someLogicForGettingRevenueAmount {
    // This method somehow handles how user determines 
    // what's the revenue value which should be tracked.
    
    // It is maybe making some calculations to determine it.
    
    // Or maybe extracting the info from In-App purchase which
    // was successfully finished.
    
    // Or maybe returns some predefined double value.
    
    double amount; // double amount = some double value
    
    return amount;
}

// ...

- (void)someRandomMethodInTheApp {
    double amount = [self someLogicForGettingRevenueAmount];
    
    ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
    [event setRevenue:amount currency:@"EUR"];
    [Adjust trackEvent:event];
}

```

If you are seing any value in the dashboard other than what you expected to be tracked, **please, check your logic for 
determining amount value**.

[adjust.com]: http://adjust.com
[cocoapods]: http://cocoapods.org
[carthage]: https://github.com/Carthage/Carthage
[dashboard]: http://adjust.com
[ios-web-views-guide]: https://github.com/adjust/ios_sdk/tree/master/doc/web_views.md
[examples]: http://github.com/adjust/ios_sdk/tree/master/examples
[example-ios-objc]: http://github.com/adjust/ios_sdk/tree/master/examples/AdjustExample-iOS
[example-ios-swift]: http://github.com/adjust/ios_sdk/tree/master/examples/AdjustExample-Swift
[example-tvos]: http://github.com/adjust/ios_sdk/tree/master/examples/AdjustExample-tvOS
[example-iwatch]: http://github.com/adjust/ios_sdk/tree/master/examples/AdjustExample-iWatch
[releases]: https://github.com/adjust/ios_sdk/releases
[arc]: http://en.wikipedia.org/wiki/Automatic_Reference_Counting
[transition]: http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
[drag]: https://raw.github.com/adjust/sdks/master/Resources/ios/drag5.png
[universal-links-dashboard]: https://raw.github.com/adjust/sdks/master/Resources/ios/universal-links-dashboard5.png
[universal-links-dashboard-values]: https://raw.github.com/adjust/sdks/master/Resources/ios/universal-links-dashboard-values5.png
[adc-ios-team-id]: https://raw.github.com/adjust/sdks/master/Resources/ios/adc-ios-team-id5.png
[adc-associated-domains]: https://raw.github.com/adjust/sdks/master/Resources/ios/adc-associated-domains5.png
[xcode-associated-domains]: https://raw.github.com/adjust/sdks/master/Resources/ios/xcode-associated-domains5.png
[add]: https://raw.github.com/adjust/sdks/master/Resources/ios/add5.png
[framework]: https://raw.github.com/adjust/sdks/master/Resources/ios/framework5.png
[delegate]: https://raw.github.com/adjust/sdks/master/Resources/ios/delegate5.png
[run]: https://raw.github.com/adjust/sdks/master/Resources/ios/run5.png
[AEPriceMatrix]: https://github.com/adjust/AEPriceMatrix
[attribution-data]: https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
[callbacks-guide]: https://docs.adjust.com/en/callbacks
[event-tracking]: https://docs.adjust.com/en/event-tracking
[special-partners]: https://docs.adjust.com/en/special-partners
[currency-conversion]: https://docs.adjust.com/en/event-tracking/#tracking-purchases-in-different-currencies
[universal-links-guide]: https://docs.adjust.com/en/universal-links/
[universal-links]: https://developer.apple.com/library/ios/documentation/General/Conceptual/AppSearch/UniversalLinks.html
[adjust-universal-links]: https://docs.adjust.com/en/universal-links/#redirecting-to-universal-links-directly
[universal-links-testing]: https://docs.adjust.com/en/universal-links/#testing-universal-link-implementations
[ios-purchase-verification]: https://github.com/adjust/ios_purchase_sdk
[reattribution-deeplinks]: https://docs.adjust.com/en/deeplinking/#manually-appending-attribution-data-to-a-deep-link

## <a id="license">License

The adjust SDK is licensed under the MIT License.

Copyright (c) 2012-2016 adjust GmbH,
http://www.adjust.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

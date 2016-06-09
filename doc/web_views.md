## Summary

This is the guide to the iOS SDK of adjust.com™ for iOS apps which are using web views. 
You can read more about adjust.com™ at [adjust.com].

It provides a bridge from Javascript to native Objective-C calls (and vice versa) by using 
the [WebViewJavascriptBridge] plugin. This plugin is also licensed under `MIT License`.

## Basic Installation

### 1. Add native adjust iOS SDK

In oder to use adjust SDK in your web views, you need to add native adjust iOS SDK to your app.
To install native iOS SDK of adjust, follow the `Basic integration` chapter of our 
[iOS SDK README][basic_integration].

### 2. Add the Javascript bridge to your project

In Xcode's `Project Navigator` locate the `Supporting Files` group (or any other
group of your choice). From Finder drag the `AdjustBridge` subdirectory into
Xcode's `Supporting Files` group.

![][bridge_drag]

In the dialog `Choose options for adding these files` make sure to check the
checkbox to `Copy items into destination group's folder` and select the upper
radio button to `Create groups for any added folders`.

![][bridge_add]

### 3. Integrate AdjustBridge into your app

In the Project Navigator open the source file your View Controller. Add
the `import` statement at the top of the file. In the `viewDidLoad` or
`viewWillAppear` method of your Web View Delegate add the following
calls to `AdjustBridge`:

```objc
#import "Adjust.h"
// Or #import <AdjustSdk/Adjust.h>
// (depends on the way you have chosen to add our native iOS SDK.
// ...

UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
// or with WKWebView:
// WKWebView *webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];

AdjustBridge *adjustBridge = [[AdjustBridge alloc] init];
[adjustBridge loadUIWebViewBridge:webView];
// or with WKWebView:
// [_adjustBridge loadWKWebViewBridge:webView];

// ...
```

![][bridge_init_objc]

### 4. Integrate AdjustBrige into your web view

To use the Javascript bridge of on your web view, it must be configured like the 
[WebViewJavascriptBridge plugin README][wvjsb_readme] is advising in section `4`.
Include the following Javascript code to intialize the adjust iOS web bridge:

```js
function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) {
        return callback(WebViewJavascriptBridge);
    }

    if (window.WVJBCallbacks) {
        return window.WVJBCallbacks.push(callback);
    }

    window.WVJBCallbacks = [callback];

    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'wvjbscheme://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);

    setTimeout(function() { document.documentElement.removeChild(WVJBIframe) }, 0)
}

setupWebViewJavascriptBridge(function(bridge) {
    // AdjustBridge initialisation will be added in this method.
})
```

![][bridge_init_js]

#### <a id="basic-setup">Basic Setup

In your HTML file, add references to the adjust Javascript files:

```html
<script type="text/javascript" src="adjust.js"></script>
<script type="text/javascript" src="adjust_event.js"></script>
<script type="text/javascript" src="adjust_config.js"></script>
```

Once you added references to Javascript files, you can use them in your
HTML file to initialise the adjust SDK:

```js
setupWebViewJavascriptBridge(function(bridge) {
    // ...

    var yourAppToken = '{YourAppToken}'
    var environment = AdjustConfig.EnvironmentSandbox
    var adjustConfig = new AdjustConfig(bridge, yourAppToken, environment)

    Adjust.appDidLaunch(adjustConfig)

    // ...
)}
```

![][bridge_init_js_xcode]

Replace `{YourAppToken}` with your app token. You can find this in your
[dashboard].

Depending on whether you build your app for testing or for production, you must
set `environment` with one of these values:

```js
var environment = AdjustConfig.EnvironmentSandbox
var environment = AdjustConfig.EnvironmentProduction
```

**Important:** This value should be set to `AdjustConfig.EnvironmentSandbox` if 
and only if you or someone else is testing your app. Make sure to set the environment 
to `AdjustConfig.EnvironmentProduction` just before you publish the app. Set it back 
to `AdjustConfig.EnvironmentSandbox` when you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic
from test devices. It is very important that you keep this value meaningful at
all times! This is especially important if you are tracking revenue.

#### <a id="adjust-logging">Adjust Logging

You can increase or decrease the amount of logs you see in tests by calling
`setLogLevel` on your `AdjustConfig` instance with one of the following
parameters:

```objc
adjustConfig.setLogLevel(AdjustConfig.LogLevelVerbose) // enable all logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelDebug)   // enable more logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelInfo)    // the default
adjustConfig.setLogLevel(AdjustConfig.LogLevelWarn)    // disable info logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelError)   // disable warnings as well
adjustConfig.setLogLevel(AdjustConfig.LogLevelAssert)  // disable errors as well
```

### <a id="step5">5. Build your app

Build and run your app. If the build succeeds, you should carefully read the
SDK logs in the console. After the app launches for the first time, you should
see the info log `Install tracked`.

![][bridge_install_tracked]

## <a id="additional-feature">Additional features

Once you integrate the adjust SDK into your project, you can take advantage of
the following features.

### <a id="step6">6. Set up event tracking

You can use adjust to track events. Lets say you want to track every tap on a
particular button. You would create a new event token in your [dashboard],
which has an associated event token - looking something like `abc123`. In your
button's `onclick` method you would then add the following lines to track
the tap:

```js
var adjustEvent = new AdjustEvent('abc123')
Adjust.trackEvent(adjustEvent)
```

When tapping the button you should now see `Event tracked` in the logs.

The event instance can be used to configure the event even more before tracking
it.

#### <a id="track-revenue">Track revenue

If your users can generate revenue by tapping on advertisements or making
in-app purchases you can track those revenues with events. Lets say a tap is
worth one Euro cent. You could then track the revenue event like this:

```js
var adjustEvent = new AdjustEvent('abc123')
adjustEvent.setRevenue(0.01, 'EUR')

Adjust.trackEvent(adjustEvent)
```

This can be combined with callback parameters of course.

When you set a currency token, adjust will automatically convert the incoming revenues 
into a reporting revenue of your choice. Read more about [currency conversion here.][currency-conversion]

You can read more about revenue and event tracking in the [event tracking guide]
(https://docs.adjust.com/en/event-tracking/#reference-tracking-purchases-and-revenues).

#### <a id="callback-parameters">Callback parameters

You can register a callback URL for your events in your [dashboard]. We will
send a GET request to that URL whenever the event gets tracked. You can add
callback parameters to that event by calling `addCallbackParameter` on the
event before tracking it. We will then append these parameters to your callback
URL.

For example, suppose you have registered the URL
`http://www.adjust.com/callback` then track an event like this:

```js
var adjustEvent = new AdjustEvent('abc123')
adjustEvent.addCallbackParameter('key', 'value')
adjustEvent.addCallbackParameter('foo', 'bar')

Adjust.trackEvent(adjustEvent)
```

#### <a id="partner-parameters">Partner parameters

You can also add parameters to be transmitted to network partners, for the
integrations that have been activated in your adjust dashboard.

This works similarly to the callback parameters mentioned above, but can
be added by calling the `addPartnerParameter` method on your `AdjustEvent`
instance.

```js
var adjustEvent = new AdjustEvent('abc123')
adjustEvent.addPartnerParameter('key', 'value')
adjustEvent.addPartnerParameter('foo', 'bar')

Adjust.trackEvent(adjustEvent)
```

You can read more about special partners and these integrations in our
[guide to special partnersd.][special-partners]

In that case we would track the event and send a request to:

    http://www.adjust.com/callback?key=value&foo=bar

It should be mentioned that we support a variety of placeholders like `{idfa}`
that can be used as parameter values. In the resulting callback this
placeholder would be replaced with the ID for Advertisers of the current
device. Also note that we don't store any of your custom parameters, but only
append them to your callbacks. If you haven't registered a callback for an
event, these parameters won't even be read.

You can read more about using URL callbacks, including a full list of available
values, in our [callbacks guide][callbacks-guide].

<!--
### <a id="step7">7. Set up deep link reattributions

You can set up the adjust SDK to handle deep links that are used to open your
app via a custom URL scheme. We will only read certain adjust specific
parameters. This is essential if you are planning to run retargeting or
re-engagement campaigns with deep links.

In the Project Navigator open the source file your Application Delegate. Find
or add the `openURL` and `application:continueUserActivity:restorationHandler:` 
and add the call to the `AdjustBridge` reference which exists in your view controller
which is displaying the web view:

```objc
#import "Adjust.h"
// Or #import <AdjustSdk/Adjust.h>
// (depends on the way you have chosen to add our native iOS SDK.
// ...

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // 
    [uiWebViewExampleController.adjustBridge sendDeeplinkToWebView:url];
    
    // Your code goes here
    BOOL canHandle = [self someLogic:url];
    return canHandle;
}
```

**Important**: Tracker URLs with `deep_link` parameter and your custom URL scheme
in it are no longer supported in `iOS 8 and higher` and clicks on them will not 
cause your app to be opened nor `openURL` method to get triggered. Apple dropped 
support for this way of deep linking into the app in favour of `universal links`. 
However, this approach will `still works for devices with iOS 7 and lower`.

#### <a id="universal-links">Universal Links

**Note**: Universal links are supported `since iOS 8`.

If you want to support [universal links][universal-links], then follow these next steps.

##### <a id="ulinks-dashboard">Enable universal links in the dashboard

In order to enable universal links for your app, go to the adjust dashboard and select
`Universal Linking` option in your `Platform Settings` for iOS.

![][universal-links-dashboard]

<a id="ulinks-setup">You will need to fill in your `iOS Bundle ID` and `iOS Team ID`.

![][universal-links-dashboard-values]

You can find your iOS Team ID in the `Apple Developer Center`.

![][adc-ios-team-id]

After you entered these two values, a universal link for your app will be generated and will
look like this:

```
applinks:[hash].ulink.adjust.com
```

##### <a id="ulinks-ios-app">Enable your iOS app to handle Universal Links

In Apple Developer Center, you should enable `Associated Domains` for your app.

![][adc-associated-domains]

**Important**: Usually, `iOS Team ID` is the same as the `Prefix` value (above picture) 
for your app. In some cases, it can happen that these two values differ. If this is the case, 
please go back to this [step](#ulink-setup) and use `Prefix` value for `iOS Team ID` field
in the adjust dashboard.

Once you have done this, you should enable `Associated Domains` in your app's Xcode 
project settings, and copy the generated universal link from the dashboard into the 
`Domains` section.

![][xcode-associated-domains]

Next, find or add the method `application:continueUserActivity:restorationHandler:` 
in your Application Delegate. In that method, add the following call to adjust:

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

You can read more about implementing universal links in our
[guide to universal links][universal-links-guide].

#### <a id="ulinks-support-all">Support deep linking for all iOS versions supported by the adjust SDK

If you are aiming iOS 8 and higher with your app, universal links are all you need in order
to enable deep linking for your app. But, in case you want to support deep linking on iOS 6
and iOS 7 devices as well, you need to build adjust style universal link like described in
[here][adjust-universal-links].

Also, you should have both methods implemented in your Application Delegate class - `openURL`
and `application:continueUserActivity:restorationHandler:` because based on device iOS version,
one (`iOS 6 and iOS 7`) or another (`iOS 8 and higher`) method will be triggered and deep link
content delivered in your app for you to parse it and decide where to navigate the user.

For instructions how to test your implementation, please read our [guide][universal-links-testing].

### <a id="step8">8. Event buffering

If your app makes heavy use of event tracking, you might want to delay some
HTTP requests in order to send them in one batch every minute. You can enable
event buffering with your `ADJConfig` instance:

```objc
[adjustConfig setEventBufferingEnabled:YES];
```

### <a id="step9">9. Send in the background

The default behaviour of the adjust SDK is to pause sending HTTP requests while the app is on the background.
You can change this in your `AdjustConfig` instance:

```objc
[adjustConfig setSendInBackground:YES];
```

### <a id="step10">10. Attribution callback

You can register a delegate callback to be notified of tracker attribution
changes. Due to the different sources considered for attribution, this
information can not by provided synchronously. Follow these steps to implement
the optional delegate protocol in your app delegate:

Please make sure to consider our [applicable attribution data
policies.][attribution-data]

1. Open `AppDelegate.h` and add the import and the `AdjustDelegate`
   declaration.

    ```objc
    #import "Adjust.h"
    // or #import <Adjust/Adjust.h>
    // or #import <AdjustSdk/Adjust.h>

    @interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>
    ```

2. Open `AppDelegate.m` and add the following delegate callback function to
   your app delegate implementation.

    ```objc
    - (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    }
    ```

3. Set the delegate with your `ADJConfig` instance:

    ```objc
    [adjustConfig setDelegate:self];
    ```
    
As the delegate callback is configured using the `ADJConfig` instance, you
should call `setDelegate` before calling `[Adjust appDidLaunch:adjustConfig]`.

The delegate function will get when the SDK receives final attribution data.
Within the delegate function you have access to the `attribution` parameter.
Here is a quick summary of its properties:

- `NSString trackerToken` the tracker token of the current install.
- `NSString trackerName` the tracker name of the current install.
- `NSString network` the network grouping level of the current install.
- `NSString campaign` the campaign grouping level of the current install.
- `NSString adgroup` the ad group grouping level of the current install.
- `NSString creative` the creative grouping level of the current install.
- `NSString clickLabel` the click label of the current install.

### <a id="step11">11. Callbacks for tracked events and sessions

You can register a delegate callback to be notified of successful and failed tracked 
events and/or sessions.

The same optional protocol `AdjustDelegate` used for the [attribution changed callback] 
(#step10) is used.

Follow the same steps and implement the following delegate callback function for 
successful tracked events:

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

The delegate functions will be called after the SDK tries to send a package to the server. 
Within the delegate callback you have access to a response data object specifically for the 
delegate callback. Here is a quick summary of the session response data properties:

- `NSString message` the message from the server or the error logged by the SDK.
- `NSString timeStamp` timestamp from the server.
- `NSString adid` a unique device identifier provided by adjust.
- `NSDictionary jsonResponse` the JSON object with the response from the server.

Both event response data objects contain:

- `NSString eventToken` the event token, if the package tracked was an event.

And both event and session failed objects also contain:

- `BOOL willRetry` indicates there will be an attempt to resend the package at a later time.

### <a id="step12">12. Callbacks for deferred deeplinks

You can register a delegate callback to be notified before a deferred deeplink is opened and decide if the adjust SDK will open it.

The same optional protocol `AdjustDelegate` used for the [attribution changed callback] 
(#step10) and for [tracked events and sessions](#step11) is used.

Follow the same steps and implement the following delegate callback function for 
deferred deeplinks:

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

The callback function will be called after the SDK receives a deffered deeplink from ther server and before open it. 
Within the callback function you have access to the deeplink and the boolean that you return determines if the SDK will launch the deeplink.
You could, for example, not allow the SDK open the deeplink at the moment, save it, and open it yourself later.

### <a id="step13">13. Disable tracking

You can disable the adjust SDK from tracking any activities of the current
device by calling `setEnabled` with parameter `NO`. **This setting is remembered
between sessions**, but it can only be activated after the first session.

```objc
[Adjust setEnabled:NO];
```

<a id="is-enabled">You can check if the adjust SDK is currently enabled by calling 
the function `isEnabled`. It is always possible to activate the adjust SDK by invoking
`setEnabled` with the enabled parameter as `YES`.

### <a id="step14">14. Offline mode

You can put the adjust SDK in offline mode to suspend transmission to our servers 
while retaining tracked data to be sent later. While in offline mode, all information is saved
in a file, so be careful not to trigger too many events while in offline mode.

You can activate offline mode by calling `setOfflineMode` with the parameter `YES`.

```objc
[Adjust setOfflineMode:YES];
```

Conversely, you can deactivate offline mode by calling `setOfflineMode` with `NO`.
When the adjust SDK is put back in online mode, all saved information is send to our servers 
with the correct time information.

Unlike disabling tracking, this setting is *not remembered*
bettween sessions. This means that the SDK is in online mode whenever it is started,
even if the app was terminated in offline mode.

### <a id="step15">15. Device IDs

Certain services (such as Google Analytics) require you to coordinate Device and Client 
IDs in order to prevent duplicate reporting. 

To obtain the device identifier IDFA, call the function `idfa`:

```objc
NSString *idfa = [Adjust idfa];
```

### <a id="step16">16. Push token

To send us the push notification token, then add the following call to `Adjust` in the `didRegisterForRemoteNotificationsWithDeviceToken` of your app delegate:

```objc
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Adjust setDeviceToken:deviceToken];
}
```

[adjust.com]: http://adjust.com
[dashboard]: http://adjust.com
[WebViewJavascriptBridge]: https://github.com/marcuswestin/WebViewJavascriptBridge
[wvjsb_readme]: https://github.com/marcuswestin/WebViewJavascriptBridge#usage
[basic_integration]: https://github.com/adjust/ios_sdk/#basic-integration
[web_drag]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/drag_bridge.png
[web_add]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/add_bridge.png
[delegate_bridge]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/delegate_bridge.png
[bridge_js]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge_js.png
[js_setup]: https://github.com/marcuswestin/WebViewJavascriptBridge#setup--examples-ios--osx
-->

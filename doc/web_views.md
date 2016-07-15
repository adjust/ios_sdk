## Summary

This is the guide to the iOS SDK of adjust.com™ for iOS apps which are using web views. You can read more about adjust.com™ 
at [adjust.com].

It provides a bridge from Javascript to native Objective-C calls (and vice versa) by using the 
[WebViewJavascriptBridge][web_view_js_bridge] plugin. This plugin is also licensed under `MIT License`.

## Table of contents

* [Basic integration](#basic-integration)
    * [Add native adjust iOS SDK](#native-add)
    * [Add the AdjustBridge to your project](#bridge-add)
    * [Integrate the AdjustBridge into your app](#bridge-integrate-app)
    * [Integrate the AdjustBridge into your web view](#bridge-integrate-web)
        * [Basic setup](#basic-setup)
        * [Adjust logging](#adjust-logging)
    * [Build your app](#build-the-app)
* [Additional features](#additional-features)
    * [Event tracking](#event-tracking)
        * [Revenue tracking](#revenue-tracking)
        * [Callback parameters](#callback-parameters)
        * [Partner parameters](#partner-parameters)
    * [Event buffering](#event-buffering)
    * [Disable tracking](#disable-tracking)
    * [Offline mode](#offline-mode)
    * [Background tracking](#background-tracking)
    * [Device IDs](#device-ids)
    * [Attribution callback](#attribution-callback)
    * [Event and session callbacks](#event-session-callbacks)
    * [Deep linking](#deeplink)
    * [Deferred deeplink callback](#deferred-deeplink-callback)
* [License](#license)

## <a id="basic-integration">Basic integration

### <a id="native-add">1. Add native adjust iOS SDK

In oder to use adjust SDK in your web views, you need to add native adjust iOS SDK to your app. To install native iOS SDK 
of adjust, follow the `Basic integration` chapter of our [iOS SDK README][basic_integration].

### <a id="bridge-add">2. Add the AdjustBridge to your project

In Xcode's `Project Navigator` locate the `Supporting Files` group (or any other group of your choice). From Finder drag 
the `AdjustBridge` subdirectory into Xcode's `Supporting Files` group.

![][bridge_drag]

In the dialog `Choose options for adding these files` make sure to check the checkbox to 
`Copy items into destination group's folder` and select the upper radio button to `Create groups for any added folders`.

![][bridge_add]

### <a id="bridge-integrate-app">3. Integrate the AdjustBridge into your app

In the Project Navigator open the source file your View Controller. Add the `import` statement at the top of the file. In 
the `viewDidLoad` or `viewWillAppear` method of your Web View Delegate add the following calls to `AdjustBridge`:

```objc
#import "Adjust.h"
// Or #import <AdjustSdk/Adjust.h>
// (depends on the way you have chosen to add our native iOS SDK)
// ...

- (void)viewWillAppear:(BOOL)animated {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    // or with WKWebView:
    // WKWebView *webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];

    AdjustBridge *adjustBridge = [[AdjustBridge alloc] init];
    [adjustBridge loadUIWebViewBridge:webView];
    // or with WKWebView:
    // [adjustBridge loadWKWebViewBridge:webView];
}

// ...
```

![][bridge_init_objc]

### <a id="bridge-integrate-web">4. Integrate the AdjustBrige into your web view

To use the Javascript bridge of on your web view, it must be configured like the `WebViewJavascriptBridge` plugin 
[README][wvjsb_readme] is advising in section `4`. Include the following Javascript code to intialize the adjust iOS web 
bridge:

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

#### <a id="basic-setup">Basic setup

In your HTML file, add references to the adjust Javascript files:

```html
<script type="text/javascript" src="adjust.js"></script>
<script type="text/javascript" src="adjust_event.js"></script>
<script type="text/javascript" src="adjust_config.js"></script>
```

Once you added references to Javascript files, you can use them in your HTML file to initialise the adjust SDK:

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

Replace `{YourAppToken}` with your app token. You can find this in your [dashboard].

Depending on whether you build your app for testing or for production, you must set `environment` with one of these values:

```js
var environment = AdjustConfig.EnvironmentSandbox
var environment = AdjustConfig.EnvironmentProduction
```

**Important:** This value should be set to `AdjustConfig.EnvironmentSandbox` if and only if you or someone else is testing 
your app. Make sure to set the environment to `AdjustConfig.EnvironmentProduction` just before you publish the app. Set it 
back to `AdjustConfig.EnvironmentSandbox` when you start developing and testing it again.

We use this environment to distinguish between real traffic and test traffic from test devices. It is very important that 
you keep this value meaningful at all times! This is especially important if you are tracking revenue.

#### <a id="adjust-logging">Adjust logging

You can increase or decrease the amount of logs you see in tests by calling `setLogLevel` on your `AdjustConfig` instance 
with one of the following parameters:

```objc
adjustConfig.setLogLevel(AdjustConfig.LogLevelVerbose) // enable all logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelDebug)   // enable more logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelInfo)    // the default
adjustConfig.setLogLevel(AdjustConfig.LogLevelWarn)    // disable info logging
adjustConfig.setLogLevel(AdjustConfig.LogLevelError)   // disable warnings as well
adjustConfig.setLogLevel(AdjustConfig.LogLevelAssert)  // disable errors as well
```

### <a id="build-the-app">5. Build your app

Build and run your app. If the build succeeds, you should carefully read the SDK logs in the console. After the app launches
for the first time, you should see the info log `Install tracked`.

![][bridge_install_tracked]

## <a id="additional-features">Additional features

Once you integrate the adjust SDK into your project, you can take advantage of the following features.

### <a id="event-tracking">6. Event tracking

You can use adjust to track events. Lets say you want to track every tap on a particular button. You would create a new 
event token in your [dashboard], which has an associated event token - looking something like `abc123`. In your button's 
`onclick` method you would then add the following lines to track the tap:

```js
var adjustEvent = new AdjustEvent('abc123')
Adjust.trackEvent(adjustEvent)
```

When tapping the button you should now see `Event tracked` in the logs.

The event instance can be used to configure the event even more before tracking it.

#### <a id="revenue-tracking">Revenue tracking

If your users can generate revenue by tapping on advertisements or making in-app purchases you can track those revenues with
events. Lets say a tap is worth one Euro cent. You could then track the revenue event like this:

```js
var adjustEvent = new AdjustEvent('abc123')
adjustEvent.setRevenue(0.01, 'EUR')

Adjust.trackEvent(adjustEvent)
```

This can be combined with callback parameters of course.

When you set a currency token, adjust will automatically convert the incoming revenues into a reporting revenue of your 
choice. Read more about [currency conversion here.][currency-conversion]

You can read more about revenue and event tracking in the [event tracking guide][event-tracking-guide].

#### <a id="callback-parameters">Callback parameters

You can register a callback URL for your events in your [dashboard]. We will send a GET request to that URL whenever the 
event gets tracked. You can add callback parameters to that event by calling `addCallbackParameter` on the event before 
tracking it. We will then append these parameters to your callback URL.

For example, suppose you have registered the URL `http://www.adjust.com/callback` then track an event like this:

```js
var adjustEvent = new AdjustEvent('abc123')
adjustEvent.addCallbackParameter('key', 'value')
adjustEvent.addCallbackParameter('foo', 'bar')

Adjust.trackEvent(adjustEvent)
```

#### <a id="partner-parameters">Partner parameters

You can also add parameters to be transmitted to network partners, for the integrations that have been activated in your 
adjust dashboard.

This works similarly to the callback parameters mentioned above, but can be added by calling the `addPartnerParameter` 
method on your `AdjustEvent` instance.

```js
var adjustEvent = new AdjustEvent('abc123')
adjustEvent.addPartnerParameter('key', 'value')
adjustEvent.addPartnerParameter('foo', 'bar')

Adjust.trackEvent(adjustEvent)
```

You can read more about special partners and these integrations in our [guide to special partnersd.][special-partners]

In that case we would track the event and send a request to:

    http://www.adjust.com/callback?key=value&foo=bar

It should be mentioned that we support a variety of placeholders like `{idfa}` that can be used as parameter values. In the 
resulting callback this placeholder would be replaced with the ID for Advertisers of the current device. Also note that we 
don't store any of your custom parameters, but only append them to your callbacks. If you haven't registered a callback for 
an event, these parameters won't even be read.

You can read more about using URL callbacks, including a full list of available values, in our 
[callbacks guide][callbacks-guide].

### <a id="event-buffering">7. Event buffering

If your app makes heavy use of event tracking, you might want to delay some HTTP requests in order to send them in one batch
every minute. You can enable event buffering with your `AdjustConfig` instance:

```js
adjustConfig.setEventBufferingEnabled(true)
```

### <a id="disable-tracking">8. Disable tracking

You can disable the adjust SDK from tracking any activities of the current device by calling `setEnabled` with parameter 
`false`. **This setting is remembered between sessions**, but it can only be activated after the first session.

```js
Adjust.setEnabled(false)
```

<a id="is-enabled">You can check if the adjust SDK is currently enabled by calling the function `isEnabled`. It is always 
possible to activate the adjust SDK by invoking `setEnabled` with the enabled parameter as `true`.

```js
Adjust.isEnabled(function(isEnabled) {
    if (isEnabled) {
        // SDK is enabled.    
    } else {
        // SDK is disabled.
    }
})
```

### <a id="offline-mode">9. Offline mode

You can put the adjust SDK in offline mode to suspend transmission to our servers while retaining tracked data to be sent 
later. While in offline mode, all information is saved in a file, so be careful not to trigger too many events while in 
offline mode.

You can activate offline mode by calling `setOfflineMode` with the parameter `true`.

```js
Adjust.setOfflineMode(true)
```

Conversely, you can deactivate offline mode by calling `setOfflineMode` with `false`. When the adjust SDK is put back in 
online mode, all saved information is send to our servers with the correct time information.

Unlike disabling tracking, this setting is **not remembered bettween sessions**. This means that the SDK is in online mode 
whenever it is started, even if the app was terminated in offline mode.

### <a id="background-tracking">10. Background tracking

The default behaviour of the adjust SDK is to pause sending HTTP requests while the app is on the background. You can change
this behaviour in your `AdjustConfig` instance:

```js
adjustConfig.setSendInBackground(true)
```

### <a id="device-ids">11. Device IDs

Certain services (such as Google Analytics) require you to coordinate Device and Client IDs in order to prevent duplicate 
reporting. 

To obtain the device identifier IDFA, call the function `getIdfa`:

```js
Adjust.getIdfa(function(idfa) {
    // ...
});
```

### <a id="attribution-callback">12. Attribution callback

You can register a callback method to be notified of tracker attribution changes. Due to the different sources considered 
for attribution, this information can not by provided synchronously.

Please make sure to consider our [applicable attribution data policies][attribution-data].

As the callback method is configured using the `AdjustConfig` instance, you should call `setAttributionCallback` before 
calling `Adjust.appDidLaunch(adjustConfig)`.

```js
adjustConfig.setAttributionCallback(function(attribution) {
    // In this example, we're just displaying alert with attribution content.
    alert('Tracker token = ' + attribution.trackerToken + '\n' +
          'Tracker name = ' + attribution.trackerName + '\n' +
          'Network = ' + attribution.network + '\n' +
          'Campaign = ' + attribution.campaign + '\n' +
          'Adgroup = ' + attribution.adgroup + '\n' +
          'Creative = ' + attribution.creative + '\n' +
          'Click label = ' + attribution.clickLabel)
})
```

The callback method will get triggered when the SDK receives final attribution data. Within the callback you have access to 
the `attribution` parameter. Here is a quick summary of its properties:

- `var trackerToken` the tracker token of the current install.
- `var trackerName` the tracker name of the current install.
- `var network` the network grouping level of the current install.
- `var campaign` the campaign grouping level of the current install.
- `var adgroup` the ad group grouping level of the current install.
- `var creative` the creative grouping level of the current install.
- `var clickLabel` the click label of the current install.

### <a id="event-session-callbacks">13. Event and session callbacks

You can register a callback method to be notified of successful and failed tracked events and/or sessions.

Follow these steps and implement the following callback methods for successful tracked events:

```js
adjustConfig.setEventSuccessCallback(function(eventSuccess) {
    // ...
})
```

The following delegate callback function for failed tracked events:

```js
adjustConfig.setEventFailureCallback(function(eventFailure) {
    // ...
})
```

For successful tracked sessions:

```js
adjustConfig.setSessionSuccessCallback(function(sessionSuccess) {
    // ...
})
```

And for failed tracked sessions:

```js
adjustConfig.setSessionFailureCallback(function(sessionFailure) {
    // ...
})
```

The callback methods will be called after the SDK tries to send a package to the server. Within the callback methods you 
have access to a response data object specifically for that callback. Here is a quick summary of the session response data 
properties:

- `var message` the message from the server or the error logged by the SDK.
- `var timeStamp` timestamp from the server.
- `var adid` a unique device identifier provided by adjust.
- `var jsonResponse` the JSON object with the response from the server.

Both event response data objects contain:

- `var eventToken` the event token, if the package tracked was an event.

And both event and session failed objects also contain:

- `var willRetry` indicates there will be an attempt to resend the package at a later time.

### <a id="deeplink">14. Deep linking

You can set up the adjust SDK to handle deep links that are used to open your app via a custom URL scheme. 

If you are planning to run retargeting or re-engagement campaigns with deep links, you should put the adjust campaign 
specific parameter into your deep link. For more information on how to run retargeting or re-engagement campaigns with deep 
links, check our [official docs][reattribution-deeplinks].

In the Project Navigator open the source file your Application Delegate. Find or add the `openURL` and 
`application:continueUserActivity:restorationHandler:` and add the call to the `AdjustBridge` reference which exists in your
view controller which is displaying the web view:

```objc
#import "Adjust.h"
// Or #import <AdjustSdk/Adjust.h>
// (depends on the way you have chosen to add our native iOS SDK)
// ...

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    // This is how AdjustBridge is accessed in our example app.
    // Of course, you can choose on your own how to access it.
    [self.uiWebViewExampleController.adjustBridge sendDeeplinkToWebView:url];
    
    // Your logic whether URL should be opened or not.
    BOOL shouldOpen = [self yourLogic:url];
    
    return shouldOpen;
}

// ...

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity 
 restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    if ([[userActivity activityType] isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [self.uiWebViewExampleController.adjustBridge sendDeeplinkToWebView:[userActivity webpageURL]];
    }

    // Your logic whether URL should be opened or not.
    BOOL shouldOpen = [self yourLogic:url];
    
    return shouldOpen;
}
```

By adding this call to both of these methods, you will support deeplink reattributions for both - iOS 8 and lower (which 
uses old custom URL scheme approach) and iOS 9 and higher (which uses `universal links`).

**Important**: In order to enable universal links in your app, please read the [universal links guide][ios_sdk_ulinks] from 
the native iOS SDK README.

In order to get deeplink URL info back to your web view, you should register a handle on the bridge called `deeplink`. This 
method will then get triggered by the adjust SDK once your app gets opened after clicking on tracker URL with deeplink 
information in it.

```js
setupWebViewJavascriptBridge(function(bridge) {
    bridge.registerHandler('deeplink', function(data, responseCallback) {
        // In this example, we're just displaying alert with deeplink URL content.
        alert('Deeplink:\n' + data)
    })
})
```

### <a id="deferred-deeplink-callback">15. Deferred deeplink callback

You can register a callback method to get notified before a deferred deeplink is opened and decide whether the adjust SDK 
should open it or not.

This callback is also set on `AdjustConfig` instance:

```js
adjustConfig.setDeferredDeeplinkCallback(function(deferredDeeplink) {
    // In this example, we're just displaying alert with deferred deeplink URL content.
    alert('Deferred deeplink:\n' + deferredDeeplink)
})
```

The callback function will be called after the SDK receives a deffered deeplink from ther server and before SDK tries to 
open it. 

With another setting on the `AdjustConfig` instance, you have the possibility to say to our SDK should it try to open this 
link or not. You can do that calling the `setOpenDeferredDeeplink` method:

```js
adjustConfig.setOpenDeferredDeeplink(true)
// Or if you don't want our SDK to open the link:
adjustConfig.setOpenDeferredDeeplink(false)
```

If you do not specify anything, by default, our SDK will try to open the link.

[adjust.com]: http://adjust.com
[dashboard]: http://adjust.com
[web_view_js_bridge]: https://github.com/marcuswestin/WebViewJavascriptBridge
[basic_integration]: https://github.com/adjust/ios_sdk/#basic-integration
[bridge_drag]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge/bridge_drag.png
[bridge_add]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge/bridge_add.png
[bridge_init_objc]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge/bridge_init_objc.png
[wvjsb_readme]: https://github.com/marcuswestin/WebViewJavascriptBridge#usage
[bridge_init_js]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge/bridge_init_js.png
[bridge_init_js_xcode]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge/bridge_init_js_xcode.png
[bridge_install_tracked]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge/bridge_install_tracked.png
[currency-conversion]: https://docs.adjust.com/en/event-tracking/#tracking-purchases-in-different-currencies
[event-tracking-guide]: https://docs.adjust.com/en/event-tracking/#reference-tracking-purchases-and-revenues
[special-partners]: https://docs.adjust.com/en/special-partners
[callbacks-guide]: https://docs.adjust.com/en/callbacks
[ios_sdk_ulinks]: https://github.com/adjust/ios_sdk/#universal-links
[attribution-data]: https://github.com/adjust/sdks/blob/master/doc/attribution-data.md
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

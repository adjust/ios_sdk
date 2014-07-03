## Summary

This is the guide to the iOS SDK of adjust.com™ for Web Apps. You can read more about adjust.com™ at
[adjust.com].

It provides a bridge from Javascript to native Objective-C calls using the [WebViewJavascriptBridge] plugin. 
This plugin is a thin layer that allows to make calls from and to Javascript and Objective-C in iOS simple and easy.

## Basic Installation

### 1. Install the adjust iOS SDK

To install the native iOS SDK of adjust, follow the `Basic Installation` chapter at our [GitHub page][ios_installation].

### 2. Add the Javascript bridge to your project

In Xcode's Project Navigator locate the `Supporting Files` group (or any other
group of your choice). From Finder drag the `AdjustBridge` subdirectory into
Xcode's `Supporting Files` group.

![][drag_bridge]

In the dialog `Choose options for adding these files` make sure to check the
checkbox to `Copy items into destination group's folder` and select the upper
radio button to `Create groups for any added folders`.

![][add_bridge]

### 3. Integrate AdjustBridge into your app

In the Project Navigator open the source file your View Controller. Add
the `import` statement at the top of the file. In the `viewDidLoad` or
`viewWillAppear` method of your Web View Delegate add the following
calls to `AdjustBridge`:

```objc
#import "Adjust.h"
// ...  
UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
// ...
[AdjustBridge loadBridge:self webView:webView];
// ...
```

![][delegate_bridge]

### 4. Integrate AdjustBrige into your WebView

To use the Javascript bridge of on your WebView, it must be configured like the [WebViewJavascriptBridge][js_setup] plugin in section `4)`. Include the following Javascript code to intialize the adjust iOS Javascript bridge:

```js
function connectWebViewJavascriptBridge(callback) {
	if (window.WebViewJavascriptBridge) {
		callback(WebViewJavascriptBridge)
	} else {
		document.addEventListener('WebViewJavascriptBridgeReady', function() {
			callback(WebViewJavascriptBridge)
		}, false)
	}
}

connectWebViewJavascriptBridge(function(bridge) {
	AdjustBridge.setBridge(bridge);
	
	// put calls to AdjustBridge here
})
```

![][bridge_js]

## Additional features

Once you integrated the adjust iOS Javascript bridge SDK into your project, you can take advantage
of the following features. Remember that you have only access to the bridge inside the callback that initializes it.

### 5. Add tracking of custom events.

You can tell adjust about every event you want. Suppose you want to track
every tap on a button. You would have to create a new Event Token in your
[dashboard]. Let's say that Event Token is `abc123`. In your button's
`onClick` event you could then add the following line to track the click:

```js
AdjustBridge.trackEvent('abc123');
```

You can also register a callback URL for that event in your [dashboard] and we
will send a GET request to that URL whenever the event gets tracked. In that
case you can also put some key-value-pairs in a JSON object and pass it to the
`trackEvent` function. We will then append these named parameters to your
callback URL.

For example, suppose you have registered the URL
`http://www.adjust.com/callback` for your event with Event Token `abc123` and
execute the following lines:

```js
var parameters =  {'key': 'value', 'foo': 'bar'};
AdjustBridge.trackEvent('abc123', parameters);
```

In that case we would track the event and send a request to:

    http://www.adjust.com/callback?key=value&foo=bar

It should be mentioned that we support a variety of placeholders like `{idfa}`
that can be used as parameter values. In the resulting callback this
placeholder would be replaced with the ID for Advertisers of the current
device. Also note that we don't store any of your custom parameters, but only
append them to your callbacks. If you haven't registered a callback for an
event, these parameters won't even be read.

### 6. Add tracking of revenue

If your users can generate revenue by clicking on advertisements or making
in-app purchases you can track those revenues. If, for example, a click is
worth one cent, you could make the following call to track that revenue:

```js
AdjustBridge.trackRevenue(1.0);
```

The parameter is supposed to be in cents and will get rounded to one decimal
point. If you want to differentiate between different kinds of revenue you can
get different Event Tokens for each kind. Again, you need to create those Event
Tokens in your [dashboard]. In that case you would make a call like this:

```js
AdjustBridge.trackRevenue(1.0, 'abc123');
```

Again, you can register a callback and provide a JSON object of named
parameters, just like it worked with normal events.

```js
var parameters =  {'key': 'value', 'foo': 'bar'};
AdjustBridge.trackRevenue(1.0, 'abc123', parameters);
```

If you want to track all revenues in the same currency you might want to use
[AEPriceMatrix][AEPriceMatrix] to do simple tier based currency conversion.

### 7. Handle reattributions with deep linking

You can also set up the adjust SDK to read deep links that come to your app,
also known as custom URL schemes in iOS. We will only read the data that is
injected by adjust tracker URLs. This is essential if you are planning to run
retargeting or re-engagement campaigns with deep links.

Send the captured url to the function `openUrl` of our Javascript bridge.

### 8. Receive delegate callbacks

Every time your app tries to track a session, an event or some revenue, you can
be notified about the success of that operation and receive additional
information about the current install. In Javascript is as simple as passing a 
callback function to out AdjustBridge:

```js
AdjustBridge.setResponseDelegate(function (responseData) {
    // ...
});
```

The delegate callback will get called every time any activity was tracked or
failed to track. Within the delegate callback you have access to the
`responseData` parameter. Here is a quick summary of its attributes:

- `activityKind` indicates what kind of activity was tracked. It
  has one of these values:

    ```
    'session'
    'event'
    'revenue'
    'reattribution'
    ```

- `success` indicates whether or not the tracking attempt was
  successful.
- `willRetry` is true when the request failed, but will be
  retried.
- `error` an error message when the activity failed to track or
  the response could not be parsed. Is `undefined` otherwise.
- `trackerToken` the tracker token of the current install. Is `undefined` if
  request failed or response could not be parsed.
- `trackerName` the tracker name of the current install. Is `undefined` if
  request failed or response could not be parsed.

### 9. Enable event buffering

If your app makes heavy use of event tracking, you might want to delay some
HTTP requests in order to send them in one batch every minute. You can enable
event buffering by adding the following line after your `setEnvironment:` call
in the `didFinishLaunching` method of your Application Delegate:

```objc
[Adjust setEventBufferingEnabled:YES];
```

### 10. Disable tracking

You can disable the adjust SDK from tracking by invoking the function
`setEnabled` with the enabled parameter as `false`. This setting is remembered
between sessions, but it can only be activated after the first session.

```js
AdjustBridge.setEnabled(false);
```

You can verify if the adjust SDK is currently active with the function
`isEnabled`. Pass a callback function with the parameter value as the boolean that 
indicates whether adjust SDK is active or not.

```js
AdjustBridge.isEnabled(function (isEnabledBool) {
    if (isEnabledBool) 
        // ...
}
```

It is always possible to activate the adjust SDK by invoking
`setEnabled` with the enabled parameter as `true`.

[adjust.com]: http://adjust.com
[dashboard]: http://adjust.com
[WebViewJavascriptBridge]: https://github.com/marcuswestin/WebViewJavascriptBridge
[ios_installation]: https://github.com/adjust/ios_sdk#basic-installation
[AEPriceMatrix]: https://github.com/adjust/AEPriceMatrix
[drag_bridge]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/drag_bridge.png
[add_bridge]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/add_bridge.png
[delegate_bridge]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/delegate_bridge.png
[bridge_js]: https://raw.githubusercontent.com/adjust/sdks/master/Resources/ios/bridge_js.png
[js_setup]: https://github.com/marcuswestin/WebViewJavascriptBridge#setup--examples-ios--osx

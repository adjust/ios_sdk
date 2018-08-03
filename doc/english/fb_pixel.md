## Facebook pixel integration

[The Facebook Pixel](https://www.facebook.com/business/help/952192354843755) is a web only analytics tool from Facebook.
Usually, it would not be possible to use in a web view app, but since [FB SDK](https://developers.facebook.com/docs/analytics)
was updated to v4.34, it's now possible to use the [Hybrid Mobile App Events](https://developers.facebook.com/docs/app-events/hybrid-app-events) 
to convert Facebook Pixel events into Facebook App events.

The adjust SDK now also allows you to use the Facebook pixel in your web view app, without the need of integrating the FB SDK.

### Facebook integration

#### Facebook App ID

Even though, there is no need to integrate the FB SDK, it's still required to follow some of the integration steps from FB SDK
to allow the adjust SDK to integrate the Facebook Pixel.

As is described in the [FB SDK iOS SDK guide](https://developers.facebook.com/docs/ios/getting-started/#xcode) 
you need to add your Facebook App ID to the app. You can follow the steps on that guide, but we copied it here:

1. In Xcode, right-click your project's `Info.plist` file and select Open As -> Source Code.

2. Insert the following XML snippet into the body of your file just before the final `</dict>` element.

```xml
<dict>
  ...
  <key>FacebookAppID</key>
  <string>{your-app-id}</string>
  ...
</dict>
```

3. Replace `{your-app-id}`, with your app's App's ID found on the *Facebook App Dashboard*.

#### Facebook Pixel configuration

Follow Facebook's guide how to integrate the Facebook Pixel. The Javascript code should look something like this:

```js
<!-- Facebook Pixel Code -->
<script>
  !function(f,b,e,v,n,t,s)
    ...
  fbq('init', <YOUR_PIXEL_ID>);
  fbq('track', 'PageView');
</script>
...
<!-- End Facebook Pixel Code -->
```

Now, just like described in [Hybrid Mobile App Events guide](https://developers.facebook.com/docs/app-events/hybrid-app-events)
`Update Your Pixel` section, you need to update the Facebook Pixel code like so:

```js
fbq('init', <YOUR_PIXEL_ID>);
fbq('set', 'mobileBridge', <YOUR_PIXEL_ID>, <YOUR_FB_APP_ID>);
```

### Adjust integration

#### Augment the webview

First, you still need to follow the integration guide for [iOs web view](web_views.md) apps. 
Then in the section where you load the webview bridge, like so:

```objc
- (void)viewWillAppear:(BOOL)animated {
    ...
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    // or with WKWebView:
    // WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];

    // add @property (nonatomic, strong) AdjustBridge *adjustBridge; on your interface
    self.adjustBridge = [[AdjustBridge alloc] init];
    [self.adjustBridge loadUIWebViewBridge:webView];
    // optionally you can add a web view delegate so that you can also capture its events
    // [self.adjustBridge loadUIWebViewBridge:webView webViewDelegate:(UIWebViewDelegate*)self];
    
    // or with WKWebView:
    // [self.adjustBridge loadWKWebViewBridge:webView];
    // optionally you can add a web view delegate so that you can also capture its events
    // [self.adjustBridge loadWKWebViewBridge:webView wkWebViewDelegate:(id<WKNavigationDelegate>)self];
    ...
```

however you choose to load the webview into the adjust bridge, afterwards add the following line:

```objc
[self.adjustBridge augmentHybridWebView];
```

#### Event name configuration

The adjust web bridge SDK needs to translate the Facebook Pixel events into adjust events.

For this reason it's necessary to configure either a mapping between a Facebook Pixel to a specific adjust event, or to 
configure a default adjust event token ***before*** tracking any Facebook Pixel event, 
including the copy-pasted `fbq('track', 'PageView');` from the Facebook Pixel configuration.

To add mappings between Facebook Pixel events and adjust events, you need to call `addFbPixelMapping(fbEventNameKey, adjEventTokenValue)` 
in the `adjustConfig` instance before initialise the adjust SDK. An example of mapping could be:

```js
adjustConfig.addFbPixelMapping('fb_mobile_search', adjustEventTokenForSearch);
adjustConfig.addFbPixelMapping('fb_mobile_purchase', adjustEventTokenForPurchase);
```

Take notice that this would match when tracking the Facebook pixel events `fbq('track', 'Search', ...);` and
`fbq('track', 'Purchase', ...);` respectively. Unfortunatly we do not have access to the mapping between the event name
tracked in javascript and the event name used by the FB SDK. 

To help you, we've colled the following event name mappings that we found so far:

| Pixel event name | Corresponding Facebook app event name
| ---------------- | -------------------------------------
| ViewContent      | fb_mobile_content_view
| Search           | fb_mobile_search
| AddToCart        | fb_mobile_add_to_cart
| AddToWishlist    | fb_mobile_add_to_wishlist
| InitiateCheckout | fb_mobile_initiated_checkout
| AddPaymentInfo   | fb_mobile_add_payment_info
| Purchase         | fb_mobile_purchase
| CompleteRegistration | fb_mobile_complete_registration

This might not be an exaustive list, and it's possible that Facebook adds or updates the current listing.
To make sure, during tests, check the adjust logs for warning like:

```
There is not a default event token configured or a mapping found for event named: 'fb_mobile_search'. It won't be tracked as an adjust event
```

There is also the option to have a default adjust event to be used if a mapping is not configured. 
Just call `adjustConfig.setFbPixelDefaultEventToken(defaultEventToken);` before initialise the adjust SDK.


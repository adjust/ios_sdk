## Summary

This is the iOS SDK of adjust™. You can read more about adjust™ at
[adjust.com]. If your app is a iOS Web App, consult our [iOS Web App][webApp] guide. 

## Basic Installation

These are the minimal steps required to integrate the adjust SDK into your
iOS project. We are going to assume that you use Xcode for your iOS
development.

If you're using [CocoaPods][cocoapods], you can add the following line to your
`Podfile` and continue with [step 3](#step3):

```ruby
pod 'Adjust', :git => 'git://github.com/adjust/ios_sdk.git', :tag => 'v4.0.0'
```

## Example app

There is an example app located inside the extracted folder named `example`. In it, you can open the Xcode project and see how the adjust SDK can be integrated.

### 1. Get the SDK

Download the latest version from our [releases page][releases]. Extract the
archive in a folder of your choice.

### 2. Add it to your project

In Xcode's Project Navigator locate the `Supporting Files` group (or any other
group of your choice). From Finder drag the `Adjust` subdirectory into
Xcode's `Supporting Files` group.

![][drag]

In the dialog `Choose options for adding these files` make sure to check the
checkbox to `Copy items into destination group's folder` and select the upper
radio button to `Create groups for any added folders`.

![][add]

### <a id="step3"></a>3. Add the AdSupport and iAd framework

In the Project Navigator select your project. In the left hand side of the main
view select your target. In the tab `Build Phases` expand the group `Link
Binary with Libraries`. On the bottom of that group click on the `+` button.
Select the `AdSupport.framework` and click the `Add` button. Repeat the same step to
add the `iAd.framework`. In the list of frameworks select the newly added `AdSupport.framework` 
and `iAd.framework`. Change the attribute `Required` to `Optional`.

![][framework]

### 4. Integrate Adjust into your app

Inside the example app, you can find the class `ExampleAdjustHelper` with the static method `initAdjust` that contains the minimum configuration and the optional ones commented.

The `ADJConfig` object is where all optional configurations can be set before calling `appDidLaunch` method in the `Adjust` class.

#### Minimum configuration

In the Project Navigator open the source file your Application Delegate. Add
the `import` statement at the top of the file. In the `didFinishLaunching` or
`didFinishLaunchingWithOptions` method of your App Delegate add the following
calls to `Adjust`:

```objc
#import "ADJConfig.h"
#import "Adjust.h"
// ...
NSString * yourAppToken = @"{YourAppToken}";
NSString * enviroment = AIEnvironmentSandbox;
ADJConfig * adjustConfig = [ADJConfig configWithAppToken:yourAppToken andEnvironment:enviroment];
[Adjust appDidLaunch:adjustConfig];
```
![][delegate]

Replace `{YourAppToken}` with your App Token. You can find in your [dashboard].

Depending on whether or not you build your app for testing or for production
you must set `enviroment` with one of these values:

```objc
NSString * enviroment = AIEnvironmentSandbox;
NSString * enviroment = AIEnvironmentProduction;
```

**Important:** This value should be set to `AIEnvironmentSandbox` if and only
if you or someone else is testing your app. Make sure to set the environment to
`AIEnvironmentProduction` just before you publish the app. Set it back to
`AIEnvironmentSandbox` when you start testing it again.

We use this environment to distinguish between real traffic and artificial
traffic from test devices. It is very important that you keep this value
meaningful at all times! Especially if you are tracking revenue.

#### Logging

You can increase or decrease the amount of logs you see in tests by calling
`setLogLevel:` on the `ADJConfig` object with one of the following parameters:

```objc
[adjustConfig setLogLevel:ADJLogLevelVerbose]; // enable all logging
[adjustConfig setLogLevel:AILogLevelDebug];    // enable more logging
[adjustConfig setLogLevel:AILogLevelInfo];     // the default
[adjustConfig setLogLevel:AILogLevelWarn];     // disable info logging
[adjustConfig setLogLevel:AILogLevelError];    // disable warnings as well
[adjustConfig setLogLevel:AILogLevelAssert];   // disable errors as well
```

#### Attribution callback

At install time, you can be notified of tracker attribution information. Due to the nature
of this information, it is not synchronous and can take some time before is available.
Follow these steps to implement the optional delegate protocol in your app delegate.

Please make sure to consider [applicable attribution data policies.][attribution-data]

1. Open `AppDelegate.h` and add the `ADJConfig.h` import and the `AdjustDelegate`
   declaration.

    ```objc
    #import "Adjust.h"

    @interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>
    ```

2. Open `AppDelegate.m` and add the following delegate callback function to
   your app delegate implementation.

    ```objc
    - (void)adjustAttributionCallback:(ADJAttribution *)attribution {
    }
    ```
    
3. When you are configuring the `ADJConfig` object, set the adjust delegate by calling `setDelegate` with the `AdjustDelegate` instace.

    ```objc
    [adjustConfig setDelegate:self];           // if configuration is in the `AppDelegate.m`
    [adjustConfig setDelegate:adjustDelegate]; // if configuration is set in another class, see example app
    ```

The delegate function will get called once somewhere after the install. Within the delegate function you have access to the `attribution` parameter. Here is a quick summary of its properties:

- `NSString trackerToken` the tracker token of the current install. 
- `NSString trackerName` the tracker name of the current install. 
- `NSString network` the network grouping level of the current install.  
- `NSString campaign` the campaign grouping level of the current install. 
- `NSString adgroup` the ad group grouping level of the current install.  
- `NSString creative` the creative grouping level of the current install.  

#### Enable event buffering

If your app makes heavy use of event tracking, you might want to delay some
HTTP requests in order to send them in one batch every minute. You can enable
event buffering by adding the following line to the `ADJConfig` object:

```objc
[adjustConfig setEventBufferingEnabled:YES];
```

### 5. Build your app

Build and run your app. If the build succeeds, you successfully integrated
adjust into your app. After the app launched, you should see the debug log
`Tracked session start`.

![][run]

#### Troubleshooting

- If your build failed with the error `Adjust requires ARC`, it looks like
  your project is not using [ARC][arc]. In that case we recommend
  [transitioning your project to use ARC][transition]. If you don't want to
  use ARC, you have to enable ARC for all source files of adjust in the
  target's Build Phases:

    Expand the `Compile Sources` group, select all adjust files (AjustIo,
    AI..., ...+AIAdditions, AF..., ...+AFNetworking) and change the `Compiler
    Flags` to `-fobjc-arc` (Select all and press the `Return` key to change
    all at once).

## Additional features

Once you integrated the adjust SDK into your project, you can take advantage
of the following features.

### 6. Add tracking of custom events.

You can tell adjust about every event you want. Suppose you want to track
every tap on a button. You would have to create a new Event Token in your
[dashboard]. Let's say that Event Token is `abc123`. In your button's
`buttonDown` method you could then add the following line to track the click:

```objc
ADJEvent * event = [ADJEvent eventWithEventToken:@"abc123"];
[Adjust trackEvent:event];
```

Before calling the `trackEvent` method, you can configure the `ADJEvent` object 

Inside the example app, you can find the class `ExampleAdjustHelper` with the static method `triggerEvent` that contains an example how to trigger an event.

The `ADJEvent` object is where all optional configurations can be set before calling the  `trackEvent` method in the `Adjust` class.

#### Callback URK

You can also register a callback URL for that event in your [dashboard] and we
will send a GET request to that URL whenever the event gets tracked. In that
case you can add a key-value-pair to `addCallbackParameter` method of `ADJEvent`. 
We will then append these named parameters to your callback URL.

For example, suppose you have registered the URL
`http://www.adjust.com/callback` then add following lines to the `ADJEvent` object:

```objc
[event addCallbackParameter:@"key" andValue:@"value"];
[event addCallbackParameter:@"foo" andValue:@"bar"];
```

In that case we would track the event and send a request to:

    http://www.adjust.com/callback?key=value&foo=bar

It should be mentioned that we support a variety of placeholders like `{idfa}`
that can be used as parameter values. In the resulting callback this
placeholder would be replaced with the ID for Advertisers of the current
device. Also note that we don't store any of your custom parameters, but only
append them to your callbacks. If you haven't registered a callback for an
event, these parameters won't even be read.

#### Track revenue

If your users can generate revenue by clicking on advertisements or making
in-app purchases you can track those revenues. If, for example, a click is
worth one cent of an Euro, you can add the following calll to the `ADJEvent` object to track
that revenue:

```objc
[event setRevenue:0.01 currency:@"EUR"];
```

You can also pass in an optional transaction ID to avoid tracking duplicate
revenues. The last ten transaction IDs are remembered and revenue events with
duplicate transaction IDs are skipped. This is especially useful for In-App
Purchase tracking. See an example below.

If you want to track In-App Purchases, please make sure to call `trackEvent`
after `finishTransaction` in `paymentQueue:updatedTransaction` only if the
state changed to `SKPaymentTransactionStatePurchased`:

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self finishTransaction:transaction];

                ADJEvent * event = [ADJEvent eventWithEventToken:...];
                [event setRevenue:... currency:...];
                [event setTransactionId:transaction.transactionIdentifier]; // avoid duplicates
                [Adjust trackEvent:event];

                break;
            // more cases
        }
    }
}
```

If you want to track all revenues in the same currency you might want to use
[AEPriceMatrix][AEPriceMatrix] to do simple tier based currency conversion.

### 7. Handle reattributions with deep linking

You can also set up the adjust SDK to read deep links that come to your app,
also known as custom URL schemes in iOS. We will only read the data that is
injected by adjust tracker URLs. This is essential if you are planning to run
retargeting or re-engagement campaigns with deep links.

In the Project Navigator open the source file your Application Delegate. Find
or add the method `openURL` and add the following call to adjust:

```objc
- (BOOL)  application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [Adjust appWillOpenUrl:url];
}
```

#### 8. Disable tracking

You can disable the adjust SDK from tracking by invoking the method
`setEnabled` with the enabled parameter as `NO`. This setting is remembered
between sessions, but it can only be activated after the first session.

```objc
[Adjust setEnabled:NO];
```

You can verify if the adjust SDK is currently active with the method
`isEnabled`. It is always possible to activate the adjust SDK by invoking
`setEnabled` with the enabled parameter as `YES`.

#### 9. Offline mode

You can put the adjust SDK in offline mode, preventing from tracking while in 
offline mode. When disabled, the tracking done in offline mode will be sent.
Call the method `setOfflineMode` with the enabled parameter as `YES` to put it
on offline mode, and `NO` to disable it.

```objc
[Adjust setOfflineMode:YES];
```


[adjust.com]: http://adjust.com
[cocoapods]: http://cocoapods.org
[dashboard]: http://adjust.com
[releases]: https://github.com/adjust/ios_sdk/releases
[arc]: http://en.wikipedia.org/wiki/Automatic_Reference_Counting
[transition]: http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
[drag]: https://raw.github.com/adjust/sdks/master/Resources/ios/drag3.png
[add]: https://raw.github.com/adjust/sdks/master/Resources/ios/add2.png
[framework]: https://raw.github.com/adjust/sdks/master/Resources/ios/framework3.png
[delegate]: https://raw.github.com/adjust/sdks/master/Resources/ios/delegate3.png
[run]: https://raw.github.com/adjust/sdks/master/Resources/ios/run3.png
[AEPriceMatrix]: https://github.com/adjust/AEPriceMatrix
[webApp]: https://github.com/adjust/ios_sdk/blob/master/doc/webApp.md
[attribution-data]: https://github.com/adjust/sdks/blob/master/doc/attribution-data.md

## License

The adjust-SDK is licensed under the MIT License.

Copyright (c) 2012-2014 adjust GmbH,
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

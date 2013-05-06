## Summary

This is the iOS SDK of AdjustIo. You can read more about it at [adjust.io][].

## Basic Installation

These are the minimal steps required to integrate the AdjustIo SDK into your iOS project. We are going to assume that you use Xcode for your iOS development.

### 1. Get the SDK
Download the latest version from our [tags page][tags]. Extract the archive in a folder of your liking.

### 2. Add it to your project
In Xcode's Project Navigator locate the `Supporting Files` group (or any other group of your choice). From Finder drag the `AdjustIo` subdirectory into Xcode's `Supporting Files` group.

![][drag]

In the dialog `Choose options for adding these files` make sure to check the checkbox to `Copy items into destination group's folder` and select the upper radio button to `Create groups for any added folders`.

![][add]

### 3. Add the AdSupport framework

In the Project Navigator select your project. In the left hand side of the main view select your target. In the tab `Build Phases` expand the group `Link Binary with Libraries`. On the bottom of that group click on the `+` button. Select the `AdSupport.framework` and click the `Add` button. In the list of frameworks select the newly added `AdSupport.framework` and change the attribute `Required` to `Optional`.

![][framework]

### 4. Integrate AdjustIo into your app

In the Project Navigator open the source file your Application Delegate. Add the `import` statement at the top of the file. In the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your App Delegate call the method `appDidLaunch`. Replace `<YourAppID>` with your AppId.

If you don't know your AppID, go [find](https://www.google.com/search?q=site:itunes.apple.com+%3CYourAppName%3E) your app on [itunes.apple.com][] and extract your AppID from the URL. If this was your app `https://itunes.apple.com/us/app/id315215396`, your AppID would be `315215396`.

If you want to see debug logs, call `setLoggingEnabled`.

```objc
#import "AdjustIo.h"
// ...
[AdjustIo appDidLaunch:@"<YourAppID>"];
[AdjustIo setLoggingEnabled:YES];
```

![][delegate]

### 5. Build your app

Build and run your app. If the build succeeds, you successfully integrated AdjustIo into your app. After the app launched, you should see the debug log `Tracked session start`.

![][run]

* If your build failed because of many duplicate symbols, you were probably already using AFNetwork before integrating AdjustIo. Just remove the `AdjustIo/AFNetworking` group from your Project Navigator to resolve this issue.

* If your project uses automatic reference counting, your build failed because of many ARC restriction errors. Fix this by disabling ARC on all AdjustIo files in the target's Build Phases: Expand the "Compile Sources" group, select all AdjustIo files (AjustIo, AI..., ...+AIAdditions, AF..., ...+AFNetworking) and change the "Compilec Flags" to `-fno-objc-arc` (Select all and press the `Return` key to change all at once).

## Additional features

Once you integrated the AdjustIo SDK into your project, you can take advantage of the following features wherever you see fit.

### Add tracking of custom events.
You can tell AdjustIo about every event you consider to be of your interest. Suppose you want to track every tap on a button. Currently you would have to ask us for an event token and we would give you one, like `abc123`. In your button's `buttonDown` method you could then add the following code to track the click:

```objc
[AdjustIo trackEvent:@"abc123"];
```

You can also register a callback URL for that event and we will send a request to that URL whenever the event happens. In that case you can also put some key-value-pairs in a Dictionary and pass it to the trackEvent method. We will then forward these named parameters to your callback URL. Suppose you registered the URL `http://www.adeven.com/callback` for your event and execute the following lines:

```objc
NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
[parameters setObject:@"value" forKey:@"key"];
[parameters setObject:@"bar"   forKey:@"foo"];
[AdjustIo trackEvent:@"abc123" withParameters:parameters];
```

In that case we would track the event and send a request to `http://www.adeven.com/callback?key=value&foo=bar`. If you're running Xcode 4.4 or later, you can use NSDictionary literals.

```objc
NSDictionary *parameters = @{ @"key": @"value", @"foo": @"bar" };
```

In any case you need to import AdjustIo in any source file that makes use of the SDK. Please note that we don't store your custom parameters. If you haven't registered a callback URL for an event, there is no point in sending us parameters.

### Add tracking of revenue
If your users can generate revenue by clicking on advertisements you can track those revenues. If the click is worth one Cent, you could make the following call to track that revenue:

```objc
[AdjustIo userGeneratedRevenue:1.0];
```

The parameter is supposed to be in Cents and will get rounded to one decimal point. If you want to differentiate between different kinds of revenue you can get different event tokens for each kind. Again, you need to ask us for event tokens that you can then use. In that case you would make a call like this:

```objc
[AdjustIo userGeneratedRevenue:1.0 forEvent:@"abc123"];
```

You can also register a callback URL again and provide a dictionary of named parameters, just like it worked with normal events.

```objc
NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
[parameters setObject:@"value" forKey:@"key"];
[parameters setObject:@"bar"   forKey:@"foo"];
[AdjustIo userGeneratedRevenue:1.0 forEvent:@"abc123" withParameters:parameters];
```

If you want to track In-App Purchases, please make sure to call `userGeneratedRevenue` after `finishTransaction` in `paymentQueue:updatedTransaction` only if the state changed to `SKPaymentTransactionStatePurchased`:

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                [AdjustIo userGeneratedRevenue:...];
                break;
            // more cases
        }
    }
}
```

In any case, don't forget to import AdjustIo. Again, there is no point in sending parameters if you haven't registered a callback URL for that revenue event.

[adjust.io]: http://www.adjust.io
[tags]: https://github.com/adeven/adjust_ios_sdk/tags
[drag]: https://raw.github.com/adeven/adjust_sdk/master/Resources/ios/drag.png
[add]: https://raw.github.com/adeven/adjust_sdk/master/Resources/ios/add.png
[framework]: https://raw.github.com/adeven/adjust_sdk/master/Resources/ios/framework.png
[delegate]: https://raw.github.com/adeven/adjust_sdk/master/Resources/ios/delegate.png
[run]: https://raw.github.com/adeven/adjust_sdk/master/Resources/ios/run.png
[itunes.apple.com]: https://itunes.apple.com

## License

The adjust-sdk is licensed under the MIT License.

Copyright (c) 2012 adeven GmbH,
http://www.adeven.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

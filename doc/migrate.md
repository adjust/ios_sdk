## Migrate your adjust SDK for iOS to v4.0.0 from v3.4.0

We changed the way to configure the SDK after launching. It should be done
before with a new object `ADJConfig`. See an example of how it would look
before and after the migration:

```objc
// before migration

// AppDelegate.h
#import "Adjust.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>

// AppDelegate.m

[Adjust appDidLaunch:@"{YourAppToken}"];
[Adjust setLogLevel:AILogLevelInfo];
[Adjust setEnvironment:AIEnvironmentSandbox];
[Adjust setDelegate:self];

// ...
- (void)adjustFinishedTrackingWithResponse:(AIResponseData *)responseData {
    // ...
}
// after migration

// AppDelegate.h
#import "ADJConfig.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate, AdjustDelegate>

// AppDelegate.m
#import "Adjust.h"

NSString *yourAppToken = @"{YourAppToken}";
NSString *enviroment = AIEnvironmentSandbox;
ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken andEnvironment:enviroment];
[adjustConfig setLogLevel:ADJLogLevelVerbose];
[adjustConfig setDelegate:self];
[Adjust appDidLaunch:adjustConfig];

// ...
- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    // ...
}
```

We also changed the way to track events and revenues. Now it is all configured
with the `ADJEvent` object. You can follow another example of how an
event/revenue would be tracked before and after the migration:

```objc
// before the migration
#import "Adjust.h"

NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
[parameters setObject:@"value" forKey:@"key"];
[parameters setObject:@"bar" forKey:@"foo"];

[Adjust trackEvent:@"abc123" withParameters:parameters];

//[Adjust trackRevenue:1.0]; not possible in the version. You will have to create an app token
[Adjust trackRevenue:1.0 transactionId:transaction.transactionIdentifier forEvent:@"xyz987"];

// after the migration
#import "ADJEvent.h"
#import "Adjust.h"

ADJEvent *event = [ADJEvent eventWithEventToken:@"abc123"];
[event addCallbackParameter:@"key" andValue:@"value"];
[event addCallbackParameter:@"foo" andValue:@"bar"];
[Adjust trackEvent:event];

ADJEvent *revenue = [ADJEvent eventWithEventToken:@"xyz987"];
[revenue setRevenue:0.01 currency:@"EUR"]; // You have to include the currency
[revenue setTransactionId:transaction.transactionIdentifier];
[Adjust trackEvent:revenue];

```

## Additional steps if you come from v3.0.0

We added an optional parameter `transactionId` to our `trackRevenue` methods.
If you are tracking In-App Purchases you might want to pass in the transaction
identifier provided by Apple to avoid duplicate revenue tracking. It should
look roughly like this:

```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self finishTransaction:transaction];

                [Adjust trackRevenue:...
                       transactionId:transaction.transactionIdentifier // avoid duplicates
                            forEvent:...
                      withParameters:...];

                break;
            // more cases
        }
    }
}
```

## Additional steps if you come from v2.1.x or 2.2.x

We renamed the main class `AdjustIo` to `Adjust`. Follow these steps to update
all adjust SDK calls.

1. Right click on the old `AdjustIo` source folder and select `Delete`. Confirm
   `Move to Trash`.
2. From the Xcode menu select `Find → Find and Replace in Project...` to bring
   up the project wide search and replace. Enter `AdjustIo` into the search
   field and `Adjust` into the replace field. Press enter to start the search.
   Press the preview button and deselect all matches you don't want to replace.
   Press the replace button to replace all `Adjust` imports and calls.

       ![][rename]

3. Download version v3.4.0 and drag the new folder `Adjust` into your Xcode
   Project Navigator.

       ![][drag]

4. Build your project to confirm that everything is properly connected again.

The adjust SDK v3.4.0 added delegate callbacks. Check out the [README] for
details.


## Additional steps if you come from v2.0.x

In the Project Navigator open the source file your Application Delegate. Add
the `import` statement at the top of the file. In the `didFinishLaunching` or
`didFinishLaunchingWithOptions` method of your App Delegate add the following
calls to `Adjust`:

```objc
#import "Adjust.h"
// ...
[Adjust appDidLaunch:@"{YourAppToken}"];
[Adjust setLogLevel:AILogLevelInfo];
[Adjust setEnvironment:AIEnvironmentSandbox];
```
![][delegate]

Replace `{YourAppToken}` with your App Token. You can find in your [dashboard].

You can increase or decrease the amount of logs you see by calling
`setLogLevel:` with one of the following parameters:

```objc
[Adjust setLogLevel:AILogLevelVerbose]; // enable all logging
[Adjust setLogLevel:AILogLevelDebug];   // enable more logging
[Adjust setLogLevel:AILogLevelInfo];    // the default
[Adjust setLogLevel:AILogLevelWarn];    // disable info logging
[Adjust setLogLevel:AILogLevelError];   // disable warnings as well
[Adjust setLogLevel:AILogLevelAssert];  // disable errors as well
```

Depending on whether or not you build your app for testing or for production
you must call `setEnvironment:` with one of these parameters:

```objc
[Adjust setEnvironment:AIEnvironmentSandbox];
[Adjust setEnvironment:AIEnvironmentProduction];
```

**Important:** This value should be set to `AIEnvironmentSandbox` if and only
if you or someone else is testing your app. Make sure to set the environment to
`AIEnvironmentProduction` just before you publish the app. Set it back to
`AIEnvironmentSandbox` when you start testing it again.

We use this environment to distinguish between real traffic and artificial
traffic from test devices. It is very important that you keep this value
meaningful at all times! Especially if you are tracking revenue.

## Additional steps if you come from v1.x

1. The `appDidLaunch` method now expects your App Token instead of your App ID.
   You can find your App Token in your [dashboard].

2. The adjust SDK for iOS 3.4.0 uses [ARC][arc]. If you haven't done already,
   we recommend [transitioning your project to use ARC][transition] as well. If
   you don't want to use ARC, you have to enable ARC for all files of the
   adjust SDK. Please consult the [README] for details.

3. Remove all calls to `[+Adjust setLoggingEnabled:]`. Logging is now enabled
   by default and its verbosity can be changed with the new `[Adjust
   setLogLevel:]` method. See the [README] for details.

4. Rename all calls to `[+Adjust userGeneratedRevenue:...]` to `[+Adjust
   trackRevenue:...]`. We renamed these methods to make the names more
   consistent. The amount parameter is now of type `double`, so you can drop
   the `f` suffixes in number literals (`12.3f` becomes `12.3`).

[README]: ../README.md
[rename]: https://raw.github.com/adjust/sdks/master/Resources/ios/rename.png
[drag]: https://raw.github.com/adjust/sdks/master/Resources/ios/drag3.png
[delegate]: https://raw.github.com/adjust/sdks/master/Resources/ios/delegate3.png
[arc]: http://en.wikipedia.org/wiki/Automatic_Reference_Counting
[transition]: http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
[dashboard]: http://adjust.com

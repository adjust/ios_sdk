## Migrate your AdjustIo SDK for iOS from v1.x to v2.1.2

1. Delete the old `AdjustIo` source folder from your Xcode project. Download
   version v2.1.2 and drag the new folder into your Xcode project.

    ![][drag]

2. In the Project Navigator open the source file your Application Delegate. Add
    the `import` statement at the top of the file. In the `didFinishLaunching` or
    `didFinishLaunchingWithOptions` method of your App Delegate add the following
    calls to `AdjustIo`:

    ```objc
    #import "AdjustIo.h"
    // ...
    [AdjustIo appDidLaunch:@"{YourAppToken}"];
    [AdjustIo setLogLevel:AILogLevelInfo];
    [AdjustIo setEnvironment:AIEnvironmentSandbox];
    ```
    ![][delegate]

    Replace `{YourAppToken}` with your App Token. You can find in your [dashboard].

    You can increase or decrease the amount of logs you see by calling
    `setLogLevel:` with one of the following parameters:

    ```objc
    [AdjustIo setLogLevel:AILogLevelVerbose]; // enable all logging
    [AdjustIo setLogLevel:AILogLevelDebug];   // enable more logging
    [AdjustIo setLogLevel:AILogLevelInfo];    // the default
    [AdjustIo setLogLevel:AILogLevelWarn];    // disable info logging
    [AdjustIo setLogLevel:AILogLevelError];   // disable warnings as well
    [AdjustIo setLogLevel:AILogLevelAssert];  // disable errors as well
    ```

    Depending on whether or not you build your app for testing or for production
    you must call `setEnvironment:` with one of these parameters:

    ```objc
    [AdjustIo setEnvironment:AIEnvironmentSandbox];
    [AdjustIo setEnvironment:AIEnvironmentProduction];
    ```

    **Important:** This value should be set to `AIEnvironmentSandbox` if and only
    if you or someone else is testing your app. Make sure to set the environment to
    `AIEnvironmentProduction` just before you publish the app. Set it back to
    `AIEnvironmentSandbox` when you start testing it again.

    We use this environment to distinguish between real traffic and artificial
    traffic from test devices. It is very important that you keep this value
    meaningful at all times! Especially if you are tracking revenue.

## Additional steps if you come from v1.x

2. The `appDidLaunch` method now expects your App Token instead of your App ID.
   You can find your App Token in your [dashboard].

2. The AdjustIo SDK for iOS 2.1.2 uses [ARC][arc]. If you haven't done already,
   we recommend [transitioning your project to use ARC][transition] as well. If
   you don't want to use ARC, you have to enable ARC for all files of the
   AdjustIo SDK. Please consult the [README] for details.

3. Remove all calls to `[+AdjustIo setLoggingEnabled:]`. Logging is now enabled
   by default and its verbosity can be changed with the new `[AdjustIo
   setLogLevel:]` method. See the [README] for details.

4. Rename all calls to `[+AdjustIo userGeneratedRevenue:...]` to `[+AdjustIo
   trackRevenue:...]`. We renamed these methods to make the names more
   consistent. The amount parameter is now of type `double`, so you can drop
   the `f` suffixes in number literals (`12.3f` becomes `12.3`).

[README]: ../README.md
[drag]: https://raw.github.com/adeven/adjust_sdk/master/Resources/ios/drag.png
[arc]: http://en.wikipedia.org/wiki/Automatic_Reference_Counting
[transition]: http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html
[dashboard]: http://adjust.io

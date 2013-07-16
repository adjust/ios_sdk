## Migrate to AdjustIo SDK for iOS v2.0

1. Delete the old `AdjustIo` source folder from your Xcode project. Download
   version v2.0 and drag the new folder into your Xcode project.

    ![][drag]

2. The AdjustIo SDK for iOS 2.0 uses [ARC][arc]. If you haven't done already,
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

5. If you get errors about `automated __weak references`, you need to update
   your deployment target. In your target's `Summary` tab set the `Deployment
   Target` to `5.0`.

[README]: ../README.md
[drag]: https://raw.github.com/adeven/adjust_sdk/master/Resources/ios/drag.png
[arc]: http://en.wikipedia.org/wiki/Automatic_Reference_Counting
[transition]: http://developer.apple.com/library/mac/#releasenotes/ObjectiveC/RN-TransitioningToARC/Introduction/Introduction.html

## 1. Get this SDK
by downloading or cloning this repository.

## 2. Add it to your project
by dragging the AdjustIo directory into the "Supporting Files" group in your Xcode project navigator (or any other group of your choice). A dialog box appears for you to "choose options for adding these files". Make sure the checkbox is checked and the upper radio button is selected before you finish.

## 3. Integrate AdjustIo into your app
by adding some code to your AppDelegate.m file. Import the SDK by adding the line `#import "AdjustIo.h"` at the top of the file. Start AdjustIo by adding the line `[AdjustIo appDidLaunch:@"<appId>"];` to your `application:didFinishLaunchingWithOptions:` or your `applicationDidFinishLaunching:` method's body. (replace `<appId>` with your appId). If you want to track the deviceId, add the line `[AdjustIo trackDeviceId];` as well.

## 4. Build your app
* If the build succeeds, you successfully integrated AjdustIo into your app.
* If your project was already using AFNetworking, your build failed because of many duplicate symbols. Just remove the AdjustIO/AFNetworking group to fix this issue.
* If your project uses automatic reference counting, your build failed because of many ARC restriction errors. Fix this by disabling ARC on all AdjustIo files in the target's Build Phases: Expand the "Compile Sources" group, select all AdjustIo files (AjustIo, AI..., ...+AIAdditions, AF..., ...+AFNetworking) and change the "Compilec Flags" to `-fno-objc-arc` (press the return key to change all at once).

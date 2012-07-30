## 1. Get this SDK
by downloading or cloning this repository.

## 2. Add it to your project
by dragging the AdjustIo directory into the "Supporting Files" group in your Xcode project navigator (or any other group of your choice). A dialog box appears for you to "choose options for adding these files". Make sure the checkbox is checked and the upper radio button is selected before you finish.

## 3. Add some frameworks
by selecting the project in the project navigator, select your target, switch to the "Build Phases" tab and expand the "Link Binary With Libraries" group.
To add the CFNetwork framework, click the plus button on the bottom of the group, select CFNetwork from the list and click click "Add". Repeat this step for the frameworks SystemConfiguration, MobileCoreServices, CoreGraphics and libz.dylib. Skip every framework that was already in the list or use the minus button to remove duplicates. You might want to drag the newly added frameworks in your project navigator into the "Frameworks" group.

## 4. Integrate AdjustIo into your app
by adding some code to your AppDelegate.m file. Import the SDK by adding the line `#import "AdjustIo.h"` at the top of the file. Start AdjustIo by adding the line `[AdjustIo appDidLaunch:@"<appId>"];` to your `application:didFinishLaunchingWithOptions:` or your `applicationDidFinishLaunching:` method's body. (replace `<appId>` with your appId). If you want to track the deviceId, add the line `[AdjustIo trackDeviceId];` as well.

## 5. Build your app
* If the build succeeds, you successfully integrated AjdustIo into your app.
* If your project was already using ASIHTTPRequest, your build failed because of many duplicate symbols. Just remove the AdjustIO/ASIHTTPRequest group to fix this issue.
* If your project uses automatic reference counting, your build failed because of many ARC restrictions errors. Fix this by disabling ARC on all AdjustIo files in the target's Build Phases: Expand the "Compile Sources" group, select all AdjustIo files (AjustIo, ...AIAdditions, ASI...) and change the "Compilec Flags" to `-fno-objc-arc` (press the return key to change all at once).

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
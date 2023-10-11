#import <Foundation/Foundation.h>

NSBundle* Adjust_SWIFTPM_MODULE_BUNDLE() {
    NSURL *bundleURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Adjust_Adjust.bundle"];

    NSBundle *preferredBundle = [NSBundle bundleWithURL:bundleURL];
    if (preferredBundle == nil) {
      return [NSBundle bundleWithPath:@"/Users/nonelse/Development/Github/adjust/ios_sdk_dev/.build/arm64-apple-macosx/debug/Adjust_Adjust.bundle"];
    }

    return preferredBundle;
}
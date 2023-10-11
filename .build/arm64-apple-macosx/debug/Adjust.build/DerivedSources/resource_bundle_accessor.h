#import <Foundation/Foundation.h>

#if __cplusplus
extern "C" {
#endif

NSBundle* Adjust_SWIFTPM_MODULE_BUNDLE(void);

#define SWIFTPM_MODULE_BUNDLE Adjust_SWIFTPM_MODULE_BUNDLE()

#if __cplusplus
}
#endif
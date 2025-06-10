//
//  Adjust
//
//  Created by Abdullah Joseph on 17.04.19
//  Copyright © 2019 adjust GmbH. All rights reserved.
//

#ifndef ADJSigner_h
#define ADJSigner_h

#import <Foundation/Foundation.h>

__attribute__((visibility("default")))
@interface ADJSigner : NSObject

+ (nonnull NSString*)getVersion;

+ (void)sign:(nonnull NSMutableDictionary*)packageDict
  withActivityKind:(nonnull const char*)activityKind
    withSdkVersion:(nonnull const char*)sdkVersion;

+ (void)sign:(nonnull NSDictionary*)packageParamsDict
   withExtraParams:(nonnull NSDictionary*)extraParamsDict
  withOutputParams:(nonnull NSMutableDictionary*)outputParamsDict;

@end

// Trampoline from C to ObjC
void
_ADJSigner_sign(size_t argc, void** args);

#endif /* ADJSigner_h */

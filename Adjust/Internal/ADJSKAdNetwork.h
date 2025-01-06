//
//  ADJSKAdNetwork.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on 27th October 2022.
//  Copyright © 2022-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJSKAdNetwork : NSObject

extern NSString * _Nonnull const ADJSKAdNetworkCallSourceSdk;
extern NSString * _Nonnull const ADJSKAdNetworkCallSourceBackend;
extern NSString * _Nonnull const ADJSKAdNetworkCallSourceClient;
extern NSString * _Nonnull const ADJSKAdNetworkCallActualConversionParamsKey;
extern NSString * _Nonnull const ADJSKAdNetworkCallErrorKey;

+ (nullable instancetype)getInstance;

- (void)registerWithConversionValue:(nonnull NSNumber *)conversionValue
                        coarseValue:(nonnull NSString *)coarseValue
                         lockWindow:(nonnull NSNumber *)lockWindow
              withCompletionHandler:(void (^_Nonnull)(NSDictionary *_Nonnull result))completion;

- (void)updateConversionValue:(nonnull NSNumber *)conversionValue
                  coarseValue:(nullable NSString *)coarseValue
                   lockWindow:(nullable NSNumber *)lockWindow
                       source:(nonnull NSString *)source
        withCompletionHandler:(void (^_Nonnull)(NSDictionary *_Nonnull result))completion;

- (NSDictionary * _Nullable)lastSKAdNetworkUpdateData;
@end

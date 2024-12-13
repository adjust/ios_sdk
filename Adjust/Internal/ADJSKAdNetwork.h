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

+ (nullable instancetype)getInstance;

- (void)registerWithConversionValue:(NSInteger)conversionValue
                        coarseValue:(nonnull NSString *)coarseValue
                         lockWindow:(nonnull NSNumber *)lockWindow
              withCompletionHandler:(void (^_Nonnull)(NSError *_Nullable error))completion;

- (void)updateConversionValue:(NSInteger)conversionValue
                  coarseValue:(nullable NSString *)coarseValue
                   lockWindow:(nullable NSNumber *)lockWindow
                       source:(nonnull NSString *)source
        withCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion;

- (NSDictionary * _Nullable)lastSKAdNetworkUpdateData;
@end

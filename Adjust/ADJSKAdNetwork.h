//
//  ADJSKAdNetwork.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on 27th October 2022.
//  Copyright © 2022-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJSKAdNetwork : NSObject

+ (nullable instancetype)getInstance;

- (void)adjRegisterWithConversionValue:(NSInteger)conversionValue
                           coarseValue:(nonnull NSString *)coarseValue
                            lockWindow:(nonnull NSNumber *)lockWindow
                     completionHandler:(void (^_Nonnull)(NSError *_Nullable error))completion;

- (void)adjUpdateConversionValue:(NSInteger)conversionValue
                     coarseValue:(nullable NSString *)coarseValue
                      lockWindow:(nullable NSNumber *)lockWindow
               completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion;

@end

//
//  AdjustBridgeRegister.h
//  Adjust
//
//  Created by Aditi Agrawal on 22/07/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustBridgeRegister : NSObject

+ (NSString *)AdjustBridge_js;

+ (void)augmentHybridWebView:(NSString *)fbAppId;


@end

NS_ASSUME_NONNULL_END

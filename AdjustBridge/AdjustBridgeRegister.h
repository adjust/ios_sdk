//
//  AdjustBridgeRegister.h
//  Adjust
//
//  Created by Pedro Filipe (@nonelse) on 27th April 2016.
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustBridgeRegister : NSObject

+ (NSString *)AdjustBridge_js;
+ (void)augmentHybridWebView:(NSString *)fbAppId;

@end

NS_ASSUME_NONNULL_END

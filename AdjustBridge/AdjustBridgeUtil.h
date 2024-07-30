//
//  AdjustBridgeUtil.h
//  Adjust
//
//  Created by Aditi Agrawal on 29/07/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustBridgeUtil : NSObject

#pragma mark - Private & helper methods

+ (BOOL)isFieldValid:(NSObject *)field;
+ (void)launchInMainThread:(dispatch_block_t)block;
+ (NSDictionary *)getTestOptions:(id)data;
+ (NSString *)convertJsonDictionaryToNSString:(NSDictionary *)jsonDictionary;
+ (NSString *)serializeData:(id)data pretty:(BOOL)pretty;

@end

NS_ASSUME_NONNULL_END

//
//  AdjustBridgeHelper.h
//  Adjust
//
//  Created by Aditi Agrawal on 29/07/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdjustBridgeHelper : NSObject

#pragma mark - Private & helper methods

+ (BOOL)isFieldValid:(NSObject *)field;

+ (NSString *)convertJsonDictionaryToNSString:(NSDictionary *)jsonDictionary;

+ (NSString *)serializeData:(id)data pretty:(BOOL)pretty;

+ (NSString *)serializeMutuableDictionary:(NSMutableDictionary *)data pretty:(BOOL)pretty;

+ (NSDictionary *)getTestOptions:(id)data;

+ (NSString *)getFbAppId;

@end

NS_ASSUME_NONNULL_END

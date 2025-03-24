//
//  ADJAttribution.h
//  adjust
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Adjust attribution object.
 */
@interface ADJAttribution : NSObject <NSSecureCoding, NSCopying>

/**
 * @brief Tracker token.
 */
@property (nonatomic, copy, nullable) NSString *trackerToken;

/**
 * @brief Tracker name.
 */
@property (nonatomic, copy, nullable) NSString *trackerName;

/**
 * @brief Network name.
 */
@property (nonatomic, copy, nullable) NSString *network;

/**
 * @brief Campaign name.
 */
@property (nonatomic, copy, nullable) NSString *campaign;

/**
 * @brief Adgroup name.
 */
@property (nonatomic, copy, nullable) NSString *adgroup;

/**
 * @brief Creative name.
 */
@property (nonatomic, copy, nullable) NSString *creative;

/**
 * @brief Click label content.
 */
@property (nonatomic, copy, nullable) NSString *clickLabel;

/**
 * @brief Cost type.
 */
@property (nonatomic, copy, nullable) NSString *costType;

/**
 * @brief Cost amount.
 */
@property (nonatomic, copy, nullable) NSNumber *costAmount;

/**
 * @brief Cost currency.
 */
@property (nonatomic, copy, nullable) NSString *costCurrency;

/**
 * @brief All attribution fields from backend's attribution JSON response.
 */
@property (nonatomic, strong, nullable) NSDictionary *jsonResponse;

/**
 * @brief Make attribution object.
 * 
 * @param jsonDict Dictionary holding attribution key value pairs.
 * 
 * @return Adjust attribution object.
 */
- (nullable id)initWithJsonDict:(nonnull NSDictionary *)jsonDict;

/**
 * @brief Check if given attribution equals current one.
 * 
 * @param attribution Attribution object to be compared with current one.
 * 
 * @return Boolean indicating whether two attribution objects are the equal.
 */
- (BOOL)isEqualToAttribution:(nonnull ADJAttribution *)attribution;

/**
 * @brief Get attribution value as dictionary.
 * 
 * @return Dictionary containing attribution as key-value pairs.
 */
- (nullable NSDictionary *)dictionary;

@end

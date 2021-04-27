//
//  ADJAdRevenue.h
//  Adjust SDK
//
//  Created by Uglješa Erceg (@uerceg) on 13th April 2021
//  Copyright (c) 2021 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Adjust ad revenue class.
 */
@interface ADJAdRevenue : NSObject<NSCopying>

/**
 * @brief Ad revenue source value.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *source;

/**
 * @brief Revenue value.
 */
@property (nonatomic, copy, readonly, nonnull) NSNumber *revenue;

/**
 * @brief Currency value.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *currency;

/**
 * @brief Ad impressions count.
 */
@property (nonatomic, copy, readonly, nonnull) NSNumber *adImpressionsCount;

/**
 * @brief Ad revenue network.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *adRevenueNetwork;

/**
 * @brief Ad revenue unit.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *adRevenueUnit;

/**
 * @brief Ad revenue placement.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *adRevenuePlacement;

/**
 * @brief List of partner parameters.
 */
@property (nonatomic, copy, readonly, nonnull) NSDictionary *partnerParameters;

/**
 * @brief List of callback parameters.
 */
@property (nonatomic, copy, readonly, nonnull) NSDictionary *callbackParameters;


- (nullable id)initWithSource:(nonnull NSString *)source;

- (void)setRevenue:(double)amount currency:(nonnull NSString *)currency;

- (void)setAdImpressionsCount:(int)adImpressionsCount;

- (void)setAdRevenueNetwork:(nonnull NSString *)adRevenueNetwork;

- (void)setAdRevenueUnit:(nonnull NSString *)adRevenueUnit;

- (void)setAdRevenuePlacement:(nonnull NSString *)adRevenuePlacement;

- (void)addCallbackParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

- (void)addPartnerParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

- (BOOL)isValid;

@end

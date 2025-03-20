//
//  ADJStoreInfo.h
//  Adjust
//
//  Created by Aditi Agrawal on 12/03/25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJStoreInfo : NSObject <NSCopying>

/**
 * @brief StoreType.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *storeType;

/**
 * @brief StoreAppId.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *appId;

/**
 * @brief Initializes a new instance of ADJStoreInfo with the given store type and app Id.
 *
 * @param storeType The type of the store.
 * @param appId The application identifier.
 *
 * @return A newly-initialized ADJStoreInfo instance, or nil if initialization fails.
 */
- (nullable id)initWithStoreInfoType:(nonnull NSString *)storeType
                  storeInfoAppId:(nonnull NSString *)appId;

/**
 * @brief Unavailable. Use initWithStoreInfoType:storeInfoAppId: instead.
 */
- (nullable id)init NS_UNAVAILABLE;

@end

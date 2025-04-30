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
 * @brief StoreName.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *storeName;

/**
 * @brief StoreAppId.
 */
@property (nonatomic, copy, nonnull) NSString *storeAppId;

/**
 * @brief Initializes a new instance of ADJStoreInfo with the given store name.
 *
 * @param storeName The name of the store.
 *
 * @return A newly-initialized ADJStoreInfo instance, or nil if initialization fails.
 */
- (nullable id)initWithStoreName:(nonnull NSString *)storeName;

/**
 * @brief Unavailable. Use initWithStoreName: instead.
 */
- (nonnull id)init NS_UNAVAILABLE;

@end

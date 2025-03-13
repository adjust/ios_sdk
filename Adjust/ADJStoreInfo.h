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
 * @brief StoreInfoType.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *storeType;

/**
 * @brief StoreInfoAppId.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *appId;

- (nullable id)initWithStoreInfoType:(nonnull NSString *)storeType
                  storeInfoAppId:(nonnull NSString *)appId;

- (nullable id)init NS_UNAVAILABLE;

@end

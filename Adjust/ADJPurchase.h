//
//  ADJPurchase.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on May 25th 2023.
//  Copyright © 2023 Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADJPurchase : NSObject<NSCopying>

@property (nonatomic, copy, readonly, nonnull) NSString *transactionId;

@property (nonatomic, copy, readonly, nonnull) NSData *receipt;

@property (nonatomic, copy, readonly, nonnull) NSString *productId;

- (nullable id)initWithTransactionId:(nonnull NSString *)transactionId
                           productId:(nonnull NSString *)productId
                          andReceipt:(nonnull NSData *)receipt;

@end

NS_ASSUME_NONNULL_END

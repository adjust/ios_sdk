//
//  ADJSubscription.h
//  Adjust
//
//  Created by Uglješa Erceg on 16.04.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJSubscription : NSObject<NSCopying>

@property (nonatomic, copy, readonly, nonnull) NSDecimalNumber *price;

@property (nonatomic, copy, readonly, nonnull) NSString *currency;

@property (nonatomic, copy, readonly, nonnull) NSDate *transactionDate;

@property (nonatomic, copy, readonly, nonnull) NSString *transactionId;

@property (nonatomic, copy, readonly, nonnull) NSData *receipt;

@property (nonatomic, copy, readonly, nonnull) NSString *billingStore;

@property (nonatomic, copy, readonly, nonnull) NSDictionary *partnerParameters;

@property (nonatomic, copy, readonly, nonnull) NSDictionary *callbackParameters;

- (nullable id)initWithPrice:(nonnull NSDecimalNumber *)price
                    currency:(nonnull NSString *)currency
             transactionDate:(nonnull NSDate *)transactionDate
               transactionId:(nonnull NSString *)transactionId
                  andReceipt:(nonnull NSData *)receipt;

- (void)addCallbackParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

- (void)addPartnerParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

@end

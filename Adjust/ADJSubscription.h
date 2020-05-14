//
//  ADJSubscription.h
//  Adjust
//
//  Created by Uglješa Erceg on 16.04.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJSubscription : NSObject<NSCopying>

@property (nonatomic, copy, readonly, nonnull) NSDecimalNumber *price;  // [M] revenue

@property (nonatomic, copy, readonly, nonnull) NSString *currency;      // [M] currency

@property (nonatomic, copy, readonly, nonnull) NSString *transactionId; // [M] transaction_id

@property (nonatomic, copy, readonly, nonnull) NSData *receipt;         // [M] receipt

@property (nonatomic, copy, readonly, nonnull) NSString *billingStore;  // [M] billing_store

@property (nonatomic, copy, readonly, nonnull) NSDate *transactionDate; // [O] transaction_date

@property (nonatomic, copy, readonly, nonnull) NSString *salesRegion;   // [O] sales_region

@property (nonatomic, copy, readonly, nonnull) NSDictionary *callbackParameters;    // [O] callback_params

@property (nonatomic, copy, readonly, nonnull) NSDictionary *partnerParameters;     // [O] partner_params

- (nullable id)initWithPrice:(nonnull NSDecimalNumber *)price
                    currency:(nonnull NSString *)currency
               transactionId:(nonnull NSString *)transactionId
                  andReceipt:(nonnull NSData *)receipt;

- (void)setTransactionDate:(nonnull NSDate *)transactionDate;

- (void)setSalesRegion:(nonnull NSString *)salesRegion;

- (void)addCallbackParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

- (void)addPartnerParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

@end

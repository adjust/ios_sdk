//
//  ADJSubscription.m
//  Adjust
//
//  Created by Uglješa Erceg on 16.04.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJSubscription.h"
#import "ADJAdjustFactory.h"

@interface ADJSubscription()

@property (nonatomic, weak) id<ADJLogger> logger;

@property (nonatomic, strong) NSMutableDictionary *mutableCallbackParameters;

@property (nonatomic, strong) NSMutableDictionary *mutablePartnerParameters;

@end

@implementation ADJSubscription

- (nullable id)initWithPrice:(nonnull NSDecimalNumber *)price
                    currency:(nonnull NSString *)currency
               transactionId:(nonnull NSString *)transactionId
                  andReceipt:(nonnull NSData *)receipt {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _price = [price copy];
    _currency = [currency copy];
    _transactionId = [transactionId copy];
    _receipt = [receipt copy];
    _billingStore = @"iOS";

    _logger = ADJAdjustFactory.logger;
    
    return self;
}

- (void)setTransactionDate:(NSDate *)transactionDate {
    @synchronized (self) {
        _transactionDate = [transactionDate copy];
    }
}

- (void)setSalesRegion:(NSString *)salesRegion {
    @synchronized (self) {
        _salesRegion = [salesRegion copy];
    }
}

- (void)addCallbackParameter:(nonnull NSString *)key
                       value:(nonnull NSString *)value
{
    @synchronized (self) {
        NSString *immutableKey = [key copy];
        NSString *immutableValue = [value copy];

        if (![ADJUtil isValidParameter:immutableKey
                         attributeType:@"key"
                         parameterName:@"Callback"]) {
            return;
        }
        if (![ADJUtil isValidParameter:immutableValue
                         attributeType:@"value"
                         parameterName:@"Callback"]) {
            return;
        }

        if (self.mutableCallbackParameters == nil) {
            self.mutableCallbackParameters = [[NSMutableDictionary alloc] init];
        }

        if ([self.mutableCallbackParameters objectForKey:immutableKey]) {
            [self.logger warn:@"key %@ was overwritten", immutableKey];
        }

        [self.mutableCallbackParameters setObject:immutableValue forKey:immutableKey];
    }
}

- (void)addPartnerParameter:(nonnull NSString *)key
                      value:(nonnull NSString *)value
{
    @synchronized (self) {
        NSString *immutableKey = [key copy];
        NSString *immutableValue = [value copy];

        if (![ADJUtil isValidParameter:immutableKey
                         attributeType:@"key"
                         parameterName:@"Partner"]) {
            return;
        }
        if (![ADJUtil isValidParameter:immutableValue
                         attributeType:@"value"
                         parameterName:@"Partner"]) {
            return;
        }

        if (self.mutablePartnerParameters == nil) {
            self.mutablePartnerParameters = [[NSMutableDictionary alloc] init];
        }

        if ([self.mutablePartnerParameters objectForKey:immutableKey]) {
            [self.logger warn:@"key %@ was overwritten", immutableKey];
        }

        [self.mutablePartnerParameters setObject:immutableValue forKey:immutableKey];
    }
}

- (nonnull NSDictionary *)callbackParameters {
    return [self.mutableCallbackParameters copy];
}

- (nonnull NSDictionary *)partnerParameters {
    return [self.mutablePartnerParameters copy];
}

- (id)copyWithZone:(NSZone *)zone {
    ADJSubscription *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_price = [self.price copyWithZone:zone];
        copy->_currency = [self.currency copyWithZone:zone];
        copy->_transactionId = [self.transactionId copyWithZone:zone];
        copy->_receipt = [self.receipt copyWithZone:zone];
        copy->_billingStore = [self.billingStore copyWithZone:zone];
        copy->_transactionDate = [self.transactionDate copyWithZone:zone];
        copy->_salesRegion = [self.salesRegion copyWithZone:zone];
        copy.mutableCallbackParameters = [self.mutableCallbackParameters copyWithZone:zone];
        copy.mutablePartnerParameters = [self.mutablePartnerParameters copyWithZone:zone];
    }

    return copy;
}

@end

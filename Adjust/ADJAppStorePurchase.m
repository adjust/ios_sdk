//
//  ADJPurchase.m
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on May 25th 2023.
//  Copyright © 2023 Adjust. All rights reserved.
//

#import "ADJAppStorePurchase.h"

@implementation ADJAppStorePurchase

- (nullable id)initWithTransactionId:(NSString *)transactionId
                           productId:(NSString *)productId {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _transactionId = [transactionId copy];
    _productId = [productId copy];

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJAppStorePurchase *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_transactionId = [self.transactionId copyWithZone:zone];
        copy->_productId = [self.productId copyWithZone:zone];
    }

    return copy;
}

@end

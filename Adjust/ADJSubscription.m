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

- (nullable id)initWithRevenue:(double)revenue
                      currency:(nonnull NSString *)currency
               transactionDate:(double)transactionDate
                 transactionId:(nonnull NSString *)transactionId
                    andReceipt:(nonnull NSData *)receipt {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _revenue = [NSNumber numberWithDouble:revenue];
    _currency = currency;
    _transactionDate = [NSNumber numberWithDouble:transactionDate];
    _transactionId = transactionId;
    _receipt = receipt;
    _billingStore = @"iOS";

    self.logger = ADJAdjustFactory.logger;
    
    if (![self isValid]) {
        return nil;
    }
    
    return self;
}

- (void)addCallbackParameter:(NSString *)key value:(NSString *)value {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Callback"]) {
        return;
    }
    if (![ADJUtil isValidParameter:value
                     attributeType:@"value"
                     parameterName:@"Callback"]) {
        return;
    }

    if (self.mutableCallbackParameters == nil) {
        self.mutableCallbackParameters = [[NSMutableDictionary alloc] init];
    }

    if ([self.mutableCallbackParameters objectForKey:key]) {
        [self.logger warn:@"key %@ was overwritten", key];
    }

    [self.mutableCallbackParameters setObject:value forKey:key];
}

- (void)addPartnerParameter:(NSString *)key value:(NSString *)value {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Partner"]) {
        return;
    }
    if (![ADJUtil isValidParameter:value
                     attributeType:@"value"
                     parameterName:@"Partner"]) {
        return;
    }

    if (self.mutablePartnerParameters == nil) {
        self.mutablePartnerParameters = [[NSMutableDictionary alloc] init];
    }

    if ([self.mutablePartnerParameters objectForKey:key]) {
        [self.logger warn:@"key %@ was overwritten", key];
    }

    [self.mutablePartnerParameters setObject:value forKey:key];
}

- (BOOL)isValid {
    if (_revenue == nil) {
        return NO;
    }
    if (_currency == nil) {
        return NO;
    }
    if (_transactionDate == nil) {
        return NO;
    }
    if (_transactionId == nil) {
        return NO;
    }
    if (_receipt == nil) {
        return NO;
    }
    if (_billingStore == nil) {
        return NO;
    }

    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJSubscription *copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy->_revenue = [self.revenue copyWithZone:zone];
        copy->_currency = [self.currency copyWithZone:zone];
        copy->_transactionDate = [self.receipt copyWithZone:zone];
        copy->_transactionId = [self.transactionId copyWithZone:zone];
        copy->_receipt = [self.receipt copyWithZone:zone];
        copy->_billingStore = [self.receipt copyWithZone:zone];
        copy.mutableCallbackParameters = [self.mutableCallbackParameters copyWithZone:zone];
        copy.mutablePartnerParameters = [self.mutablePartnerParameters copyWithZone:zone];
    }
    return copy;
}

@end

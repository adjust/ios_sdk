//
//  ADJEvent.m
//  adjust
//
//  Created by Pedro Filipe on 15/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJEvent.h"
#import "ADJAdjustFactory.h"
#import "ADJUtil.h"

@interface ADJEvent()

@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) NSMutableDictionary *callbackMutableParameters;
@property (nonatomic, strong) NSMutableDictionary *partnerMutableParameters;

@end

@implementation ADJEvent

+ (ADJEvent *)eventWithEventToken:(NSString *)eventToken {
    return [[ADJEvent alloc] initWithEventToken:eventToken];
}

- (id)initWithEventToken:(NSString *)eventToken {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.logger = ADJAdjustFactory.logger;

    if (![self checkEventToken:eventToken]) {
        return self;
    }

    _eventToken = [eventToken copy];

    return self;
}

- (void)addCallbackParameter:(NSString *)key value:(NSString *)value {
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

        if (self.callbackMutableParameters == nil) {
            self.callbackMutableParameters = [[NSMutableDictionary alloc] init];
        }
        if ([self.callbackMutableParameters objectForKey:immutableKey]) {
            [self.logger warn:@"Callback parameter key %@ was overwritten", immutableKey];
        }
        [self.callbackMutableParameters setObject:immutableValue forKey:immutableKey];
    }
}

- (void)addPartnerParameter:(NSString *)key value:(NSString *)value {
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

        if (self.partnerMutableParameters == nil) {
            self.partnerMutableParameters = [[NSMutableDictionary alloc] init];
        }
        if ([self.partnerMutableParameters objectForKey:immutableKey]) {
            [self.logger warn:@"Partner parameter key %@ was overwritten", immutableKey];
        }
        [self.partnerMutableParameters setObject:immutableValue forKey:immutableKey];
    }
}

- (void)setRevenue:(double)amount currency:(NSString *)currency {
    NSNumber *revenue = [NSNumber numberWithDouble:amount];
    if (![self checkRevenue:revenue currency:currency]) {
        return;
    }

    _revenue = revenue;
    @synchronized (self) {
        _currency = [currency copy];
    }
}

- (void)setTransactionId:(NSString *)transactionId {
    @synchronized (self) {
        _transactionId = [transactionId copy];
    }
}

- (void)setCallbackId:(NSString *)callbackId {
    @synchronized (self) {
        _callbackId = [callbackId copy];
    }
}

- (NSDictionary *)callbackParameters {
    @synchronized (self) {
        return (NSDictionary *)self.callbackMutableParameters;
    }
}

- (NSDictionary *)partnerParameters {
    @synchronized (self) {
        return (NSDictionary *)self.partnerMutableParameters;
    }
}

- (void)setProductId:(NSString *)productId {
    @synchronized (self) {
        _productId = [productId copy];
    }
}

- (void)setReceipt:(NSData *)receipt {
    @synchronized (self) {
        _receipt = [receipt copy];
    }
}

- (BOOL)checkEventToken:(NSString *)eventToken {
    if ([ADJUtil isNull:eventToken]) {
        [self.logger error:@"Missing Event Token"];
        return NO;
    }
    if ([eventToken length] <= 0) {
        [self.logger error:@"Event Token can't be empty"];
        return NO;
    }
    return YES;
}

- (BOOL)checkRevenue:(NSNumber *)revenue currency:(NSString *)currency {
    if (![ADJUtil isNull:revenue]) {
        double amount =  [revenue doubleValue];
        if (amount < 0.0) {
            [self.logger error:@"Invalid amount %.5f", amount];
            return NO;
        }
        if ([ADJUtil isNull:currency]) {
            [self.logger error:@"Currency must be set with revenue"];
            return NO;
        }
        if ([currency isEqualToString:@""]) {
            [self.logger error:@"Currency is empty"];
            return NO;
        }
    } else {
        if ([ADJUtil isNotNull:currency]) {
            [self.logger error:@"Revenue must be set with currency"];
            return NO;
        }
    }

    return YES;
}

- (BOOL)isValid {
    return self.eventToken != nil;
}

- (void)setReceipt:(NSData *)receipt transactionId:(NSString *)transactionId {
    if (![self checkReceipt:receipt transactionId:transactionId]) {
        return;
    }

    if ([ADJUtil isNull:receipt] || [receipt length] == 0) {
        _emptyReceipt = YES;
    }
    _receipt = receipt;
    _transactionId = transactionId;
}

- (BOOL)checkReceipt:(NSData *)receipt transactionId:(NSString *)transactionId {
    if ([ADJUtil isNotNull:receipt] && [ADJUtil isNull:transactionId]) {
        [self.logger error:@"Missing transactionId"];
        return NO;
    }
    return YES;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJEvent *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_eventToken = [self.eventToken copyWithZone:zone];
        copy->_revenue = [self.revenue copyWithZone:zone];
        copy->_currency = [self.currency copyWithZone:zone];
        copy.callbackMutableParameters = [self.callbackMutableParameters copyWithZone:zone];
        copy.partnerMutableParameters = [self.partnerMutableParameters copyWithZone:zone];
        copy->_transactionId = [self.transactionId copyWithZone:zone];
        copy->_receipt = [self.receipt copyWithZone:zone];
        copy->_emptyReceipt = self.emptyReceipt;
        copy->_productId = [self.productId copyWithZone:zone];
    }

    return copy;
}

@end

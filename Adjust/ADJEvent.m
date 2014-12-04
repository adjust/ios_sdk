//
//  ADJEvent.m
//  adjust
//
//  Created by Pedro Filipe on 15/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJEvent.h"
#import "ADJAdjustFactory.h"

#pragma mark -

@implementation ADJEvent

+ (ADJEvent *)eventWithEventToken:(NSString *)eventToken {
    return [[ADJEvent alloc] initWithEventToken:eventToken];
}

- (id) initWithEventToken:(NSString *)eventToken {
    self = [super init];
    if (self == nil) return nil;

    self.eventToken = eventToken;

    return self;
}

- (void) addCallbackParameter:(NSString *)key
                     andValue:(NSString *)value {
    if (_callbackParameters == nil) {
        _callbackParameters = [[NSMutableDictionary alloc] init];
    }

    [_callbackParameters setObject:value forKey:key];
}

- (void) addPartnerParameter:(NSString *)key
                    andValue:(NSString *)value {
    if (_partnerParameters == nil) {
        _partnerParameters = [[NSMutableDictionary alloc] init];
    }

    [_partnerParameters setObject:value forKey:key];
}

- (void) setRevenue:(double) amount currency:(NSString *)currency{
    _revenue = [NSNumber numberWithDouble:amount];
    _currency = currency;
}

- (void) setTransactionId:(NSString *)transactionId {
    _transactionId = transactionId;
}

- (BOOL) isValid {

    id<ADJLogger> logger = ADJAdjustFactory.logger;

    if (self.eventToken == nil) {
        [logger error:@"Missing Event Token"];
        return NO;
    }

    if (self.eventToken.length != 6) {
        [logger error:@"Malformed Event Token '%@'", self.eventToken];
        return NO;
    }

    if (self.revenue != nil) {
        double amount =  [self.revenue doubleValue];
        if (amount < 0.0) {
            [logger error:@"Invalid amount %.1f", amount];
            return NO;
        }

        if (self.currency == nil) {
            [logger error:@"Currency must be set with revenue"];
            return NO;
        }
    }

    return YES;
}

-(id)copyWithZone:(NSZone *)zone
{
    ADJEvent* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.eventToken = [self.eventToken copyWithZone:zone];
        copy.revenue = [self.revenue copyWithZone:zone];
        copy.callbackParameters = [self.callbackParameters copyWithZone:zone];
        copy.partnerParameters = [self.partnerParameters copyWithZone:zone];
        copy.transactionId = [self.transactionId copyWithZone:zone];
        copy.currency = [self.currency copyWithZone:zone];
    }
    return copy;

}

@end

//
//  ADJEvent.h
//  adjust
//
//  Created by Pedro Filipe on 15/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJEvent : NSObject<NSCopying>

@property (nonatomic, copy) NSString* eventToken;
@property (nonatomic, copy) NSNumber* revenue;
@property (nonatomic, copy) NSMutableDictionary* callbackParameters;
@property (nonatomic, copy) NSMutableDictionary* partnerParameters;
@property (nonatomic, copy) NSString* transactionId;
@property (nonatomic, copy) NSString* currency;

- (id) initWithEventToken:(NSString *)eventToken;
+ (ADJEvent *)eventWithEventToken:(NSString *)eventToken;

- (void) addCallbackParameter:(NSString *)key
                     value:(NSString *)value;

- (void) addPartnerParameter:(NSString *)key
                     value:(NSString *)value;

- (void) setRevenue:(double)amount currency:(NSString *)currency;
// check currency correctness, warn if weird
- (void) setTransactionId:(NSString *)transactionId;

- (BOOL) isValid;

@end

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

/**
 * Create Event object with Event Token.
 *
 * In your dashboard at http://adjust.com you can assign a callback URL to each
 * event type. That URL will get called every time the event is triggered. On
 * top of that you can pass a set of parameters to the following method that
 * will be forwarded to these callbacks.
 *
 * TODO: Parameter parameter
 *
 * The event can contain some revenue. The amount is measured in units and
 * rounded to the decimal cent point. It must include a currency in the
 * ISO 4217 format
 *
 * A transaction ID can be used to avoid duplicate revenue events. The last ten
 * transaction identifiers are remembered.
 *
 * @param event Event token that is  created in the dashboard 
 * at http://adjust.com and should be six characters long.
 */
+ (ADJEvent *)eventWithEventToken:(NSString *)eventToken;
- (id) initWithEventToken:(NSString *)eventToken;

/**
 * Add a key-pair to a callback URL. You must add as many as you want before
 * using tracking the ADJEvent object
 *
 * In your dashboard at http://adjust.com you can assign a callback URL to each
 * event type. That URL will get called every time the event is triggered. On
 * top of that you can pass a set of parameters to the following method that
 * will be forwarded to these callbacks.
 *
 * @param key String key in the callback URL.
 * @param value String value of the key in the Callback URL.
 *
 */
- (void) addCallbackParameter:(NSString *)key
                     value:(NSString *)value;

/**
 * Add a key-pair to ...
 *
 * ...
 *
 * @param key ...
 * @param value ...
 *
 */
- (void) addPartnerParameter:(NSString *)key
                     value:(NSString *)value;

/**
 * Set the revenue and associated currency of the event.
 *
 * The event can contain some revenue. The amount revenue is measured in units.
 * It must include a currency in the ISO 4217 format.
 *
 * @param amount The amount in units (example: 1€50 is 1.5)
 * @param currency String of the currency with ISO 4217 format.
 * It should be 3 characters long (example: 1€50 is @"EUR")
 */
- (void) setRevenue:(double)amount currency:(NSString *)currency;

/**
 * Set the transaction ID of a In-App Purchases to avoid revenue duplications.
 *
 * A transaction ID can be used to avoid duplicate revenue events. The last ten
 * transaction identifiers are remembered.
 *
 * @param The identifier used to avoid duplicate revenue events
 */
- (void) setTransactionId:(NSString *)transactionId;

- (BOOL) isValid;

@end

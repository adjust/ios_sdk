//
//  ADJEvent.h
//  adjust
//
//  Created by Pedro Filipe on 15/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Adjust event class.
 */
@interface ADJEvent : NSObject<NSCopying>

/**
 * @brief Event token.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *eventToken;

/**
 * @brief Revenue attached to the event.
 */
@property (nonatomic, copy, readonly, nonnull) NSNumber *revenue;

/**
 * @brief Currency value.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *currency;

/**
 * @brief Deduplication ID.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *deduplicationId;

/**
 * @brief Custom user defined event ID.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *callbackId;

/**
 * @brief IAP transaction ID.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *transactionId;

/**
 * @brief IAP product ID.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *productId;

/**
 * @brief List of partner parameters.
 */
@property (nonatomic, readonly, nonnull) NSDictionary *partnerParameters;

/**
 * @brief List of callback parameters.
 */
@property (nonatomic, readonly, nonnull) NSDictionary *callbackParameters;

/**
 * @brief Create Event object with event token.
 *
 * @param eventToken Event token that is created in the dashboard
 *                   at http://adjust.com and should be six characters long.
 */
- (nullable id)initWithEventToken:(nonnull NSString *)eventToken;

/**
 * @brief Check if created adjust event object is valid.
 *
 * @return Boolean indicating whether the adjust event object is valid or not.
 */
- (BOOL)isValid;

/**
 * @brief Set the revenue and associated currency of the event.
 *
 * @param amount The amount in units (example: for 1.50 EUR is 1.5).
 * @param currency String of the currency with ISO 4217 format.
 *                 It should be 3 characters long (example: for 1.50 EUR is @"EUR").
 *
 * @note The event can contain some revenue. The amount revenue is measured in units.
 *       It must include a currency in the ISO 4217 format.
 */
- (void)setRevenue:(double)amount currency:(nonnull NSString *)currency;

/**
 * @brief Add a key-pair to a callback URL.
 *
 * @param key String key in the callback URL.
 * @param value String value of the key in the Callback URL.
 *
 * @note In your dashboard at http://adjust.com you can assign a callback URL to each
 *       event type. That URL will get called every time the event is triggered. On
 *       top of that you can add callback parameters to the following method that
 *       will be forwarded to these callbacks.
 */
- (void)addCallbackParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

/**
 * @brief Add a key-pair to be forwarded to a partner.
 *
 * @param key String key to be forwarded to the partner.
 * @param value String value of the key to be forwarded to the partner.
 */
- (void)addPartnerParameter:(nonnull NSString *)key value:(nonnull NSString *)value;

/**
 * @brief Set the deduplication ID to avoid events duplications.
 *
 * @note A deduplication ID can be used to avoid duplicate events.
 *       The number of last remembered deduplication identifiers can be set in deduplicationIdsMaxSize of ADJConfig.
 *
 * @param deduplicationId The identifier used to avoid duplicate events.
 */
- (void)setDeduplicationId:(nonnull NSString *)deduplicationId;

/**
 * @brief Set the custom user defined ID for the event which will be reported in
 *        success/failure callbacks.
 *
 * @param callbackId Custom user defined identifier for the event
 */
- (void)setCallbackId:(nonnull NSString *)callbackId;

/**
 * @brief Set the transaction ID of an In-App Purchases to avoid revenue duplications.
 *
 * @param transactionId The identifier used to avoid duplicate revenue events.
 */
- (void)setTransactionId:(nonnull NSString *)transactionId;

/**
 * @brief Set the product ID of an In-App Purchases to perform IAP verification.
 *
 * @param productId The product ID of the purchased item.
 */
- (void)setProductId:(NSString * _Nonnull)productId;

@end

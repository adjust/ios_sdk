//
//  ADJCriteoEvents.h
//
//
//  Created by Pedro Filipe on 06/02/15.
//
//

#import <Foundation/Foundation.h>

#import "ADJEvent.h"

@interface ADJCriteoProduct : NSObject

@property (nonatomic, assign) float criteoPrice;

@property (nonatomic, assign) NSUInteger criteoQuantity;

@property (nonatomic, copy, nonnull) NSString *criteoProductID;

- (nullable id)initWithId:(nonnull NSString *)productId price:(float)price quantity:(NSUInteger)quantity;

+ (nullable ADJCriteoProduct *)productWithId:(nonnull NSString *)productId price:(float)price quantity:(NSUInteger)quantity;

@end

@interface ADJCriteo : NSObject

+ (void)injectPartnerIdIntoCriteoEvents:(nonnull NSString *)partnerId;

+ (void)injectCustomerIdIntoCriteoEvents:(nonnull NSString *)customerId;

+ (void)injectHashedEmailIntoCriteoEvents:(nonnull NSString *)hashEmail;

+ (void)injectUserSegmentIntoCriteoEvents:(nonnull NSString *)userSegment;

+ (void)injectDeeplinkIntoEvent:(nonnull ADJEvent *)event url:(nonnull NSURL *)url;

+ (void)injectCartIntoEvent:(nonnull ADJEvent *)event products:(nonnull NSArray *)products;

+ (void)injectUserLevelIntoEvent:(nonnull ADJEvent *)event uiLevel:(NSUInteger)uiLevel;

+ (void)injectCustomEventIntoEvent:(nonnull ADJEvent *)event uiData:(nonnull NSString *)uiData;

+ (void)injectUserStatusIntoEvent:(nonnull ADJEvent *)event uiStatus:(nonnull NSString *)uiStatus;

+ (void)injectViewProductIntoEvent:(nonnull ADJEvent *)event productId:(nonnull NSString *)productId;

+ (void)injectViewListingIntoEvent:(nonnull ADJEvent *)event productIds:(nonnull NSArray *)productIds;

+ (void)injectAchievementUnlockedIntoEvent:(nonnull ADJEvent *)event uiAchievement:(nonnull NSString *)uiAchievement;

+ (void)injectViewSearchDatesIntoCriteoEvents:(nonnull NSString *)checkInDate checkOutDate:(nonnull NSString *)checkOutDate;

+ (void)injectCustomEvent2IntoEvent:(nonnull ADJEvent *)event uiData2:(nonnull NSString *)uiData2 uiData3:(NSUInteger)uiData3;

+ (void)injectTransactionConfirmedIntoEvent:(nonnull ADJEvent *)event
                                   products:(nonnull NSArray *)products
                              transactionId:(nonnull NSString *)transactionId
                                newCustomer:(nonnull NSString *)newCustomer;

@end

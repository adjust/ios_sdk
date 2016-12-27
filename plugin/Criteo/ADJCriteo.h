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
@property (nonatomic, copy) NSString *criteoProductID;

- (id) initWithId:(NSString*)productId
            price:(float)price
         quantity:(NSUInteger)quantity;

+ (ADJCriteoProduct *)productWithId:(NSString*)productId
                           price:(float)price
                        quantity:(NSUInteger)quantity;

@end

@interface ADJCriteo : NSObject

+ (void)injectViewListingIntoEvent:(ADJEvent *)event
                        productIds:(NSArray *)productIds;

+ (void)injectViewProductIntoEvent:(ADJEvent *)event
                         productId:(NSString *)productId;

+ (void)injectCartIntoEvent:(ADJEvent *)event
                   products:(NSArray *)products;

+ (void)injectTransactionConfirmedIntoEvent:(ADJEvent *)event
                                   products:(NSArray *)products
                              transactionId:(NSString *)transactionId
                                newCustomer:(NSString *)newCustomer;

+ (void)injectUserLevelIntoEvent:(ADJEvent *)event
                         uiLevel:(NSUInteger)uiLevel;

+ (void)injectUserStatusIntoEvent:(ADJEvent *)event
                         uiStatus:(NSString *)uiStatus;

+ (void)injectAchievementUnlockedIntoEvent:(ADJEvent *)event
                             uiAchievement:(NSString *)uiAchievement;

+ (void)injectCustomEventIntoEvent:(ADJEvent *)event
                            uiData:(NSString *)uiData;

+ (void)injectCustomEvent2IntoEvent:(ADJEvent *)event
                            uiData2:(NSString *)uiData2
                            uiData3:(NSUInteger)uiData3;

+ (void)injectDeeplinkIntoEvent:(ADJEvent *)event
                            url:(NSURL *)url;

+ (void)injectHashedEmailIntoCriteoEvents:(NSString *)hashEmail;

+ (void)injectViewSearchDatesIntoCriteoEvents:(NSString *)checkInDate
                                checkOutDate:(NSString *)checkOutDate;

+ (void)injectPartnerIdIntoCriteoEvents:(NSString *)partnerId;

+ (void)injectUserSegmentIntoCriteoEvents:(NSString *)userSegment;

+ (void)injectCustomerIdIntoCriteoEvents:(NSString *)customerId;

@end

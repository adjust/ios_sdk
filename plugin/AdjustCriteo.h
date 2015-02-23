//
//  AdjustCriteoEvents.h
//  
//
//  Created by Pedro Filipe on 06/02/15.
//
//

#import <Foundation/Foundation.h>
#import "ADJEvent.h"

@interface CriteoProduct : NSObject

@property (nonatomic, assign) float criteoPrice;
@property (nonatomic, assign) NSUInteger criteoQuantity;
@property (nonatomic, copy) NSString *criteoProductID;

- (id) initWithPrice:(float)price
         andQuantity:(NSUInteger)quantity
        andProductId:(NSString*)productId;

+ (CriteoProduct *)productWithPrice:(float)price
                               andQuantity:(NSUInteger)quantity
                              andProductId:(NSString*)productId;

@end

@interface AdjustCriteo : NSObject

+ (void)injectViewSearchIntoEvent:(ADJEvent *)event
                      checkInDate:(NSString *)din
                     checkOutDate:(NSString *)dout;

+ (void)injectViewListingIntoEvent:(ADJEvent *)event
                          products:(NSArray *)products
                        customerId:(NSString *)customerId;

+ (void)injectViewProductIntoEvent:(ADJEvent *)event
                         productId:(NSString *)productId
                        customerId:(NSString *)customerId;

+ (void)injectCartIntoEvent:(ADJEvent *)event
                   products:(NSArray *)products
                 customerId:(NSString *)customerId;

+ (void)injectTransactionConfirmedIntoEvent:(ADJEvent *)event
                                   products:(NSArray *)products
                                 customerId:(NSString *)customerId;

@end

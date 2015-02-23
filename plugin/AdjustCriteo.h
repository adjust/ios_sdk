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

+ (void)injectDates:(ADJEvent *)event checkInDate:(NSString *)din checkOutDate:(NSString *)dout;
+ (void)injectProductListing:(ADJEvent *)event customerId:(NSString *)customerId products:(NSArray *) products;
+ (void)injectProduct:(ADJEvent *)event customerId:(NSString *)customerId productId:(NSString *) productId;
+ (void)injectProductCart:(ADJEvent *)event customerId:(NSString *)customerId products:(NSArray *) products;

@end

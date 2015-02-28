//
//  AdjustCriteoEvents.m
//
//
//  Created by Pedro Filipe on 06/02/15.
//
//

#import "AdjustCriteo.h"
#import "Adjust.h"

@implementation CriteoProduct

- (id) initWithId:(NSString *)productId
            price:(float)price
         quantity:(NSUInteger)quantity
{
    self = [super init];
    if (self == nil) return nil;

    self.criteoProductID = productId;
    self.criteoPrice = price;
    self.criteoQuantity = quantity;

    return self;
}

+ (CriteoProduct *) productWithId:(NSString *)productId
                            price:(float)price
                         quantity:(NSUInteger)quantity
{
    return [[CriteoProduct alloc] initWithId:productId price:price quantity:quantity];
}

@end

@implementation AdjustCriteo


+ (void)injectViewSearchIntoEvent:(ADJEvent *)event
                      checkInDate:(NSString *)din
                     checkOutDate:(NSString *)dout
{
    [event addPartnerParameter:@"din" value:din];
    [event addPartnerParameter:@"dout" value:dout];
}

+ (void)injectViewListingIntoEvent:(ADJEvent *)event
                          products:(NSArray *)products
                        customerId:(NSString *)customerId
{
    [event addPartnerParameter:@"customer_id" value:customerId];

    NSString * jsonProducts = [AdjustCriteo createCriteoVLFromProducts:products];
    [event addPartnerParameter:@"criteo_p" value:jsonProducts];
}

+ (void)injectViewProductIntoEvent:(ADJEvent *)event
                         productId:(NSString *)productId
                        customerId:(NSString *)customerId
{
    [event addPartnerParameter:@"customer_id" value:customerId];
    [event addPartnerParameter:@"criteo_p" value:productId];
}

+ (void)injectCartIntoEvent:(ADJEvent *)event
                   products:(NSArray *)products
                 customerId:(NSString *)customerId
{
    [event addPartnerParameter:@"customer_id" value:customerId];

    NSString * jsonProducts = [AdjustCriteo createCriteoVBFromProducts:products];
    [event addPartnerParameter:@"criteo_p" value:jsonProducts];
}

+ (void)injectTransactionConfirmedIntoEvent:(ADJEvent *)event
                                   products:(NSArray *)products
                                 customerId:(NSString *)customerId
{
    [event addPartnerParameter:@"customer_id" value:customerId];

    NSString * jsonProducts = [AdjustCriteo createCriteoVBFromProducts:products];
    [event addPartnerParameter:@"criteo_p" value:jsonProducts];
}

+ (NSString*) createCriteoVBFromProducts:(NSArray*) products
{
    NSMutableString* criteoVBValue = [NSMutableString stringWithString:@"["];
    for (CriteoProduct *product in products)
    {
        NSString* productString = [NSString stringWithFormat:@"{\"i\":\"%@\",\"pr\":%f,\"q\":%lu}",
                                   [product criteoProductID],
                                   [product criteoPrice],
                                   (unsigned long)[product criteoQuantity]];

        [criteoVBValue appendString:productString];
        if (product != [products lastObject])
        {
            [criteoVBValue appendString:@","];
        }
    }
    [criteoVBValue appendString:@"]"];
    return [criteoVBValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*) createCriteoVLFromProducts:(NSArray*) products
{
#ifdef DEBUG
    if ([products count] > 3)
        NSLog(@"Warning : VL Events should only have at most 3 objects, discarding the rest");
#endif
    NSUInteger numberOfProducts = 0;
    NSMutableString* criteoVBValue = [NSMutableString stringWithString:@"["];

    for (CriteoProduct *product in products)
    {
        NSString* productString = [NSString stringWithFormat:@"\"%@\"", [product criteoProductID]];

        [criteoVBValue appendString:productString];
        ++numberOfProducts;

        if (product != [products lastObject] && numberOfProducts < 3)
        {
            [criteoVBValue appendString:@","];
        }
        if (numberOfProducts >= 3)
            break;
    }
    [criteoVBValue appendString:@"]"];
    return [criteoVBValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*) createCriteoVBFromProductsDictionary:(NSArray*) products
{
    NSMutableString* criteoVBValue = [NSMutableString stringWithString:@"["];
    for (NSDictionary* product in products)
    {
        NSString* productString = [NSString stringWithFormat:@"{\"i\":\"%@\",\"pr\":%f,\"q\":%lu}",
                                   [product objectForKey:@"productID"],
                                   [[product objectForKey:@"price"] floatValue],
                                   [[product objectForKey:@"quantity"] integerValue]];

        [criteoVBValue appendString:productString];
        if (product != [products lastObject])
        {
            [criteoVBValue appendString:@","];
        }
    }
    [criteoVBValue appendString:@"]"];
    return [criteoVBValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString*) createCriteoVLFromProductsArray:(NSArray*) products
{
#ifdef DEBUG
    if ([products count] > 3)
        NSLog(@"Warning : VL Events should only have at most 3 objects, discarding the rest");
#endif
    NSUInteger numberOfProducts = 0;

    NSMutableString* criteoVBValue = [NSMutableString stringWithString:@"["];
    for (NSString* product in products)
    {
        NSString* productString = [NSString stringWithFormat:@"\"%@\"", product];

        [criteoVBValue appendString:productString];
        ++numberOfProducts;

        if (product != [products lastObject] && numberOfProducts < 3)
        {
            [criteoVBValue appendString:@","];
        }
        if (numberOfProducts >= 3)
            break;

    }
    [criteoVBValue appendString:@"]"];
    return [criteoVBValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end

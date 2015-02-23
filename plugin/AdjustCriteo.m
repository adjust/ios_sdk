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

- (id) initWithPrice:(float)price
         andQuantity:(NSUInteger)quantity
        andProductId:(NSString *)productId
{
    self = [super init];
    if (self == nil) return nil;

    self.criteoPrice = price;
    self.criteoQuantity = quantity;
    self.criteoProductID = productId;

    return self;
}

+ (CriteoProduct *) productWithPrice:(float)price
                         andQuantity:(NSUInteger)quantity
                        andProductId:(NSString *)productId
{
    return [[CriteoProduct alloc] initWithPrice:price andQuantity:quantity andProductId:productId];
}

@end

@implementation AdjustCriteo


+ (void)injectDates:(ADJEvent *)event checkInDate:(NSString *)din checkOutDate:(NSString *)dout
{
    [event addPartnerParameter:@"din" value:din];
    [event addPartnerParameter:@"dout" value:dout];
}


+ (void)injectProductListing:(ADJEvent *)event customerId:(NSString *)customerId products:(NSArray *) products
{
    [event addPartnerParameter:@"customer_id" value:customerId];

    NSString * jsonProducts = [AdjustCriteo createCriteoVLFromProducts:products];
    [event addPartnerParameter:@"criteo_p" value:jsonProducts];
}

+ (void)injectProduct:(ADJEvent *)event customerId:(NSString *)customerId productId:(NSString *) productId
{
    [event addPartnerParameter:@"customer_id" value:customerId];
    [event addPartnerParameter:@"criteo_p" value:productId];
}

+ (void)injectProductCart:(ADJEvent *)event customerId:(NSString *)customerId products:(NSArray *) products
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

 //
//  ADJTrademob.h
//  Adjust
//
//  Created by Davit Ohanyan on 9/14/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJEvent.h"

@interface ADJTrademobItem : NSObject

@property (nonatomic, assign) float price;

@property (nonatomic, assign) NSUInteger quantity;

@property (nonatomic, copy, nonnull) NSString *itemId;

- (nullable instancetype)initWithId:(nonnull NSString *)itemId price:(float)price quantity:(NSUInteger)quantity;

@end

@interface ADJTrademob : NSObject

+ (void)injectViewListingIntoEvent:(nonnull ADJEvent *)event
                           itemIds:(nonnull NSArray *)itemIds
                          metadata:(nonnull NSDictionary *)metadata;

+ (void)injectViewItemIntoEvent:(nonnull ADJEvent *)event
                         itemId:(nonnull NSString *)itemId
                       metadata:(nonnull NSDictionary *)metadata;


+ (void)injectAddToBasketIntoEvent:(nonnull ADJEvent *)event
                             items:(nonnull NSArray *)items
                          metadata:(nonnull NSDictionary *)metadata;

+ (void)injectCheckoutIntoEvent:(nonnull ADJEvent *)event
                          items:(nonnull NSArray *)items
                       metadata:(nonnull NSDictionary *)metadata;

@end

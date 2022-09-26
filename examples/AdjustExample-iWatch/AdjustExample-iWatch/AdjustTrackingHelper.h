//
//  AdjustTrackingHelper.h
//  AdjustExample-iWatch
//
//  Created by Uglješa Erceg (@uerceg) on 6th April 2016
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdjustDelegate;

@interface AdjustTrackingHelper : NSObject

+ (id)sharedInstance;

- (void)initialize:(NSObject<AdjustDelegate> *)delegate;
- (void)trackSimpleEvent;
- (void)trackRevenueEvent;
- (void)trackCallbackEvent;
- (void)trackPartnerEvent;

@end

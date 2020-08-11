//
//  UIDevice+ADJAdditions.h
//  Adjust
//
//  Created by Christian Wellenbrock (@wellle) on 23rd July 2012.
//  Copyright © 2012-2018 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ADJActivityHandler.h"
#import "ADJTimerOnce.h"

@interface UIDevice(ADJAdditions)

- (int)adjATTStatus;
- (BOOL)adjTrackingEnabled;
- (NSString *)adjIdForAdvertisers;
- (NSString *)adjFbAnonymousId;
- (NSString *)adjDeviceType;
- (NSString *)adjDeviceName;
- (NSString *)adjCreateUuid;
- (NSString *)adjVendorId;
- (void)adjCheckForiAd:(ADJActivityHandler *)activityHandler queue:(dispatch_queue_t)queue;
- (void)adjRegisterForSKANAttribution;

@end

//
//  UIDevice+ADJAdditions.h
//  Adjust
//
//  Created by Christian Wellenbrock (@wellle) on 23rd July 2012.
//  Copyright © 2012-2018 Adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ADJDeviceInfo.h"
#import "ADJActivityHandler.h"

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
- (NSString *)adjFetchAdServicesAttribution:(NSError **)errorPtr;

- (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(NSUInteger status))completion;

@end

//
//  ADJPackageBuilder.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJDeviceInfo.h"
#import "ADJActivityState.h"
#import "ADJActivityPackage.h"

#import <Foundation/Foundation.h>

@interface ADJPackageBuilder : NSObject

@property (nonatomic, copy) NSDate *clickTime;
@property (nonatomic, copy) NSDate *purchaseTime;

@property (nonatomic, copy) NSString *deeplink;
@property (nonatomic, copy) NSString *deviceToken;

@property (nonatomic, retain) NSDictionary *iadDetails;
@property (nonatomic, retain) NSDictionary* deeplinkParameters;

@property (nonatomic, copy) ADJAttribution *attribution;

- (id)initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
           activityState:(ADJActivityState *)activityState
                  config:(ADJConfig *)adjustConfig
               createdAt:(double)createdAt;

- (ADJActivityPackage *)buildSessionPackage;
- (ADJActivityPackage *)buildAttributionPackage;
- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event;
- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource;

@end

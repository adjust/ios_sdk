//
//  ADJPackageBuilder.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ADJEvent.h"
#import "ADJDeviceInfo.h"
#import "ADJActivityState.h"
#import "ADJActivityPackage.h"
#import "ADJConfig.h"

@interface ADJPackageBuilder : NSObject

@property (nonatomic, copy) ADJDeviceInfo* deviceInfo;
@property (nonatomic, copy) ADJActivityState *activityState;
@property (nonatomic, copy) ADJConfig *adjustConfig;
@property (nonatomic, copy) ADJAttribution *attribution;
@property (nonatomic, copy) NSDate *clickTime;
@property (nonatomic, copy) NSDate *purchaseTime;
@property (nonatomic, retain) NSDictionary* deeplinkParameters;

- (id) initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
            activityState:(ADJActivityState *)activityState
                   config:(ADJConfig *)adjustConfig;

- (ADJActivityPackage *)buildSessionPackage;
- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event;
- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource;
- (ADJActivityPackage *)buildAttributionPackage;

@end

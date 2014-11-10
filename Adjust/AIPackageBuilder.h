//
//  AIPackageBuilder.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AIEvent.h"
#import "AIDeviceInfo.h"
#import "AIActivityState.h"
#import "AIActivityPackage.h"
#import "AdjustConfig.h"

@interface AIPackageBuilder : NSObject

@property (nonatomic, copy) AIDeviceInfo* deviceInfo;
@property (nonatomic, copy) AIEvent* event;
@property (nonatomic, copy) AIActivityState *activityState;
@property (nonatomic, copy) AdjustConfig *adjustConfig;
@property (nonatomic, assign) BOOL hasDelegate;

// reattributions
@property (nonatomic, copy) NSDictionary* deeplinkParameters;

- (id) initWithDeviceInfo:(AIDeviceInfo *)deviceInfo
         andActivityState:(AIActivityState *)activityState
                andConfig:(AdjustConfig *)adjustConfig;

- (AIActivityPackage *)buildSessionPackage;
- (AIActivityPackage *)buildEventPackage;
- (AIActivityPackage *)buildClickPackage;

@end

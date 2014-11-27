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
@property (nonatomic, assign) BOOL hasDelegate;
@property (nonatomic, copy) ADJAttribution * attribution;
@property (nonatomic, copy) NSDate * iAdImpressionDate;
@property (nonatomic, copy) NSDate * appPurchaseDate;
@property (nonatomic, copy) NSDictionary* deeplinkParameters;

- (id) initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
         andActivityState:(ADJActivityState *)activityState
                andConfig:(ADJConfig *)adjustConfig;

- (ADJActivityPackage *)buildSessionPackage;
- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event;
- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource;
@end

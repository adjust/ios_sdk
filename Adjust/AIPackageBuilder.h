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

@class AIActivityPackage;

@interface AIPackageBuilder : NSObject

// general
@property (nonatomic, copy) AIDeviceInfo* deviceInfo;
@property (nonatomic, assign) BOOL trackMd5;

// sessions
@property (nonatomic, assign) int sessionCount;
@property (nonatomic, assign) int subsessionCount;
@property (nonatomic, assign) double createdAt;
@property (nonatomic, assign) double sessionLength;
@property (nonatomic, assign) double timeSpent;
@property (nonatomic, assign) double lastInterval;

// events
@property (nonatomic, assign) int eventCount;
@property (nonatomic, copy) AIEvent* event;

// reattributions
@property (nonatomic, copy) NSDictionary* deeplinkParameters;


//- (id) initWithDeviceInfo:(AIDeviceInfo *)deviceInfo;

- (AIActivityPackage *)buildSessionPackage;
- (AIActivityPackage *)buildEventPackage;
- (AIActivityPackage *)buildReattributionPackage;

@end

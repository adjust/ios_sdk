//
//  AIPackageBuilder.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@class AIActivityPackage;

@interface AIPackageBuilder : NSObject

// general
@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, copy) NSString *macSha1;
@property (nonatomic, copy) NSString *macShortMd5;
@property (nonatomic, copy) NSString *idForAdvertisers;
@property (nonatomic, copy) NSString *fbAttributionId;
@property (nonatomic, copy) NSString *environment;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *clientSdk;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) BOOL trackingEnabled;
@property (nonatomic, assign) BOOL isIad;
@property (nonatomic, copy) NSString *vendorId;

// sessions
@property (nonatomic, assign) int sessionCount;
@property (nonatomic, assign) int subsessionCount;
@property (nonatomic, assign) double createdAt;
@property (nonatomic, assign) double sessionLength;
@property (nonatomic, assign) double timeSpent;
@property (nonatomic, assign) double lastInterval;

// events
@property (nonatomic, assign) int eventCount;
@property (nonatomic, copy)   NSString *eventToken;
@property (nonatomic, copy)   NSDictionary *callbackParameters;
@property (nonatomic, assign) double amountInCents;

// reattributions
@property (nonatomic, copy) NSDictionary* deeplinkParameters;


- (AIActivityPackage *)buildSessionPackage;
- (AIActivityPackage *)buildEventPackage;
- (AIActivityPackage *)buildRevenuePackage;
- (AIActivityPackage *)buildReattributionPackage;

@end

//
//  AIPackageBuilder.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 03.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

@class AIActivityPackage;

@interface AIPackageBuilder : NSObject

// general
@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, copy) NSString *macSha1;
@property (nonatomic, copy) NSString *macShortMd5;
@property (nonatomic, copy) NSString *idForAdvertisers;
@property (nonatomic, copy) NSString *attributionId;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *clientSdk;

// sessions
@property (nonatomic, assign) int sessionCount;
@property (nonatomic, assign) int subsessionCount;
@property (nonatomic, assign) long createdAt;
@property (nonatomic, assign) long sessionLength;
@property (nonatomic, assign) long timeSpent;
@property (nonatomic, assign) long lastInterval;

// events
@property (nonatomic, assign) int eventCount;
@property (nonatomic, copy) NSString *eventToken;
@property (nonatomic, copy) NSDictionary *callbackParameters;
@property (nonatomic, assign) float amountInCents;

- (AIActivityPackage *)buildSessionPackage;
- (AIActivityPackage *)buildEventPackage;
- (AIActivityPackage *)buildRevenuePackage;

@end

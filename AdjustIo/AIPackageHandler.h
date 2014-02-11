//
//  AIPackageHandler.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adeven. All rights reserved.
//

@class AIActivityHandler;
@class AIActivityPackage;
@class AIResponseData;

@protocol AIPackageHandler

+ (id<AIPackageHandler>)handlerWithActivityHandler:(AIActivityHandler *)activityHandler;
- (id)initWithActivityHandler:(AIActivityHandler *)activityHandler;

- (void)addPackage:(AIActivityPackage *)package;
- (void)sendFirstPackage;
- (void)sendNextPackage;
- (void)closeFirstPackage;
- (void)pauseSending;
- (void)resumeSending;

- (void)finishedTrackingActivity:(AIActivityPackage *)activityPackage withResponse:(AIResponseData *)response;

@end

@interface AIPackageHandler : NSObject <AIPackageHandler>
@end

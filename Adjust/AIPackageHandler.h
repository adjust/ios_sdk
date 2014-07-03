//
//  AIPackageHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@class AIActivityPackage;
@class AIResponseData;
@protocol AIActivityHandler;

@protocol AIPackageHandler

- (id)initWithActivityHandler:(id<AIActivityHandler>)activityHandler;

- (void)addPackage:(AIActivityPackage *)package;
- (void)sendFirstPackage;
- (void)sendNextPackage;
- (void)closeFirstPackage;
- (void)pauseSending;
- (void)resumeSending;

- (void)finishedTrackingActivity:(AIActivityPackage *)activityPackage withResponse:(AIResponseData *)response;

@end

@interface AIPackageHandler : NSObject <AIPackageHandler>

+ (id<AIPackageHandler>)handlerWithActivityHandler:(id<AIActivityHandler>)activityHandler;

@end

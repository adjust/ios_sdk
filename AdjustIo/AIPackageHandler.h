//
//  AIPackageHandler.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adeven. All rights reserved.
//
#import <Foundation/Foundation.h>

@class AIActivityHandler;
@class AIActivityPackage;

@protocol AIPackageHandler

+ (id<AIPackageHandler>)handlerWithActivityHandler:(AIActivityHandler *)activityHandler;
- (id)initWithActivityHandler:(AIActivityHandler *)activityHandler;

- (void)addPackage:(AIActivityPackage *)package;
- (void)sendFirstPackage;
- (void)sendNextPackage;
- (void)closeFirstPackage;
- (void)pauseSending;
- (void)resumeSending;

@end

@interface AIPackageHandler : NSObject <AIPackageHandler>
@end

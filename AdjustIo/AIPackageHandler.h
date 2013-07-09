//
//  AIPackageHandler.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adeven. All rights reserved.
//

@class AIActivityPackage;

@interface AIPackageHandler : NSObject

- (void)addPackage:(AIActivityPackage *)package;
- (void)sendFirstPackage;
- (void)sendNextPackage;
- (void)closeFirstPackage;
- (void)pauseSending;
- (void)resumeSending;

@end

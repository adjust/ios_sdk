//
//  AIRequestHandler.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 04.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AIPackageHandler;
@class AIActivityPackage;

@interface AIRequestHandler : NSObject

+ (AIRequestHandler *)handlerWithPackageHandler:(AIPackageHandler *)packageHandler;
- (id)initWithPackageHandler:(AIPackageHandler *)packageHandler;

- (void)sendPackage:(AIActivityPackage *)activityPackage;

@end

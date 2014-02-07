//
//  AIRequestHandler.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#include "AIPackageHandler.h"
@class AIPackageHandler, AIActivityPackage;

@protocol AIRequestHandler

+ (id<AIRequestHandler>) handlerWithPackageHandler:(id<AIPackageHandler>)packageHandler;
- (id)initWithPackageHandler:(id<AIPackageHandler>) packageHandler;

- (void)sendPackage:(AIActivityPackage *)activityPackage;

@end


@interface AIRequestHandler : NSObject <AIRequestHandler>
@end
//
//  AIAdjustIoFactory.h
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//


#import "AdjustIo.h"
#import "AIPackageHandler.h"
#import "AIRequestHandler.h"
#import "AILogger.h"

@interface AIAdjustIoFactory : NSObject

+ (id<AIPackageHandler>)packageHandler;
+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (id<AILogger>)logger;

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler;
+ (void)setLogger:(id<AILogger>)logger;

@end

//
//  AIAdjustIoFactory.h
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//
#import <Foundation/Foundation.h>
@class AdjustIo;
@class AIActivityHandler;

@protocol AIPackageHandler;
@protocol AIRequestHandler;
@protocol AILogger;

@interface AIAdjustIoFactory : NSObject

+ (id<AIPackageHandler>)packageHandlerForActivityHandler:(AIActivityHandler *)activityHandler;
+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (id<AILogger>)logger;

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler;
+ (void)setLogger:(id<AILogger>)logger;

@end

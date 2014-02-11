//
//  AIAdjustIoFactory.h
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//
#import <Foundation/Foundation.h>

@class AdjustIo;

@protocol AIPackageHandler;
@protocol AIRequestHandler;
@protocol AIActivityHandler;
@protocol AILogger;

@interface AIAdjustIoFactory : NSObject

+ (id<AIPackageHandler>)packageHandlerForActivityHandler:(id<AIActivityHandler>)activityHandler;
+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (id<AILogger>)logger;
+ (id<AIActivityHandler>)activityHandlerWithAppToken:(NSString *)appToken;

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler;
+ (void)setLogger:(id<AILogger>)logger;

@end

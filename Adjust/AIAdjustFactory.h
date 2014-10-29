//
//  AIAdjustFactory.h
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "AIActivityHandler.h"
#import "AIPackageHandler.h"
#import "AIRequestHandler.h"
#import "AILogger.h"
#import "AIAttributionHandler.h"

@interface AIAdjustFactory : NSObject

+ (id<AIPackageHandler>)packageHandlerForActivityHandler:(id<AIActivityHandler>)activityHandler;
+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (id<AIActivityHandler>)activityHandlerWithAppToken:(NSString *)appToken;
+ (id<AILogger>)logger;
+ (double)sessionInterval;
+ (double)subsessionInterval;
+ (id<AIAttributionHandler>)attributionHandlerForActivityHandler:(id<AIActivityHandler>)activityHandler;

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler;
+ (void)setActivityHandler:(id<AIActivityHandler>)activityHandler;
+ (void)setLogger:(id<AILogger>)logger;
+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;
+ (void)setAttributionHandler:(id<AIAttributionHandler>)attributionHandler;

@end

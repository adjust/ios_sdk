//
//  AIAdjustFactory.h
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@class Adjust;

@protocol AIPackageHandler;
@protocol AIRequestHandler;
@protocol AIActivityHandler;
@protocol AILogger;

@interface AIAdjustFactory : NSObject

+ (id<AIPackageHandler>)packageHandlerForActivityHandler:(id<AIActivityHandler>)activityHandler;
+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (id<AIActivityHandler>)activityHandlerWithAppToken:(NSString *)appToken;
+ (id<AILogger>)logger;
+ (double)sessionInterval;
+ (double)subsessionInterval;

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler;
+ (void)setActivityHandler:(id<AIActivityHandler>)activityHandler;
+ (void)setLogger:(id<AILogger>)logger;
+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;

@end

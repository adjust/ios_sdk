//
//  ADJAdjustFactory.h
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ADJActivityHandler.h"
#import "ADJPackageHandler.h"
#import "ADJRequestHandler.h"
#import "ADJLogger.h"
#import "ADJAttributionHandler.h"
#import "ADJActivityPackage.h"

@interface ADJAdjustFactory : NSObject

+ (id<ADJPackageHandler>)packageHandlerForActivityHandler:(id<ADJActivityHandler>)activityHandler;
+ (id<ADJRequestHandler>)requestHandlerForPackageHandler:(id<ADJPackageHandler>)packageHandler;
+ (id<ADJActivityHandler>)activityHandlerWithConfig:(ADJConfig *)adjustConfig;
+ (id<ADJLogger>)logger;
+ (double)sessionInterval;
+ (double)subsessionInterval;
+ (id<ADJAttributionHandler>)attributionHandlerForActivityHandler:(id<ADJActivityHandler>)activityHandler
                                                     withMaxDelay:(NSNumber *)milliseconds
                                           withAttributionPackage:(ADJActivityPackage *) attributionPackage;

+ (void)setPackageHandler:(id<ADJPackageHandler>)packageHandler;
+ (void)setRequestHandler:(id<ADJRequestHandler>)requestHandler;
+ (void)setActivityHandler:(id<ADJActivityHandler>)activityHandler;
+ (void)setLogger:(id<ADJLogger>)logger;
+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;
+ (void)setAttributionHandler:(id<ADJAttributionHandler>)attributionHandler;

@end

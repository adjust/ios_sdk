//
//  ADJPackageHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ADJActivityPackage.h"
#import "ADJPackageHandler.h"
#import "ADJActivityHandler.h"
#import "ADJResponseDataTasks.h"

@protocol ADJPackageHandler

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                  startPaused:(BOOL)startPaused;

- (void)addPackage:(ADJActivityPackage *)package;
- (void)sendFirstPackage;
- (void)sendNextPackage:(ADJResponseDataTasks *)responseDataTasks;
- (void)closeFirstPackage;
- (void)pauseSending;
- (void)resumeSending;

@end

@interface ADJPackageHandler : NSObject <ADJPackageHandler>

+ (id<ADJPackageHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                        startPaused:(BOOL)startPaused;

@end

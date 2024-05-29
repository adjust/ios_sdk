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
#import "ADJResponseData.h"
#import "ADJGlobalParameters.h"
#import "ADJRequestHandler.h"
#import "ADJUrlStrategy.h"

@interface ADJPackageHandler : NSObject <ADJResponseCallback>

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                  urlStrategy:(ADJUrlStrategy *)urlStrategy;
                    //extraPath:(NSString *)extraPath;

- (void)addPackage:(ADJActivityPackage *)package;
- (void)sendFirstPackage;
- (void)pauseSending;
- (void)resumeSending;
- (void)updatePackagesWithAttStatus:(int)attStatus;
- (void)flush;

- (void)teardown;
+ (void)deleteState;

@end

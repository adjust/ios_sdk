//
//  ADJPackageBuilder.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJDeviceInfo.h"
#import "ADJActivityState.h"
#import "ADJActivityPackage.h"
#import "ADJSessionParameters.h"

#import <Foundation/Foundation.h>

@interface ADJPackageBuilder : NSObject

@property (nonatomic, copy) NSDate *clickTime;
@property (nonatomic, copy) NSDate *purchaseTime;

@property (nonatomic, copy) NSString *deeplink;

@property (nonatomic, strong) NSDictionary *attributionDetails;
@property (nonatomic, strong) NSDictionary *deeplinkParameters;

@property (nonatomic, copy) ADJAttribution *attribution;

- (id)initWithDeviceInfo:(ADJDeviceInfo *)deviceInfo
           activityState:(ADJActivityState *)activityState
                  config:(ADJConfig *)adjustConfig
       sessionParameters:(ADJSessionParameters *)sessionParameters
               createdAt:(double)createdAt;

- (ADJActivityPackage *)buildSessionPackage:(BOOL)isInDelay;

- (ADJActivityPackage *)buildAttributionPackage;

- (ADJActivityPackage *)buildGdprPackage;

- (ADJActivityPackage *)buildEventPackage:(ADJEvent *)event
                                isInDelay:(BOOL)isInDelay;

- (ADJActivityPackage *)buildClickPackage:(NSString *)clickSource;

- (ADJActivityPackage *)buildInfoPackage:(NSString *)infoSource;

+ (void)parameters:(NSMutableDictionary *)parameters setDictionary:(NSDictionary *)dictionary forKey:(NSString *)key;

+ (void)parameters:(NSMutableDictionary *)parameters setString:(NSString *)value forKey:(NSString *)key;

@end

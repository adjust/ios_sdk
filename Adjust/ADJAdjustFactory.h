//
//  ADJAdjustFactory.h
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ADJLogger.h"
#import "ADJActivityPackage.h"
#import "ADJBackoffStrategy.h"
#import "ADJSdkClickHandler.h"

@interface ADJAdjustFactory : NSObject

+ (id<ADJLogger>)logger;
+ (double)sessionInterval;
+ (double)subsessionInterval;
+ (double)requestTimeout;
+ (NSNumber *)attStatus;
+ (NSString *)idfa;
+ (NSTimeInterval)timerInterval;
+ (NSTimeInterval)timerStart;
+ (ADJBackoffStrategy *)packageHandlerBackoffStrategy;
+ (ADJBackoffStrategy *)sdkClickHandlerBackoffStrategy;
+ (ADJBackoffStrategy *)installSessionBackoffStrategy;

+ (BOOL)testing;
+ (NSTimeInterval)maxDelayStart;
+ (NSString *)urlOverwrite;
+ (BOOL)adServicesFrameworkEnabled;

+ (void)setLogger:(id<ADJLogger>)logger;
+ (void)setSessionInterval:(double)sessionInterval;
+ (void)setSubsessionInterval:(double)subsessionInterval;
+ (void)setAttStatus:(NSNumber *)attStatus;
+ (void)setIdfa:(NSString *)idfa;
+ (void)setRequestTimeout:(double)requestTimeout;
+ (void)setTimerInterval:(NSTimeInterval)timerInterval;
+ (void)setTimerStart:(NSTimeInterval)timerStart;
+ (void)setPackageHandlerBackoffStrategy:(ADJBackoffStrategy *)backoffStrategy;
+ (void)setSdkClickHandlerBackoffStrategy:(ADJBackoffStrategy *)backoffStrategy;
+ (void)setTesting:(BOOL)testing;
+ (void)setAdServicesFrameworkEnabled:(BOOL)adServicesFrameworkEnabled;
+ (void)setMaxDelayStart:(NSTimeInterval)maxDelayStart;
+ (void)setUrlOverwrite:(NSString *)urlOverwrite;

+ (void)enableSigning;
+ (void)disableSigning;

+ (void)teardown:(BOOL)deleteState;
@end

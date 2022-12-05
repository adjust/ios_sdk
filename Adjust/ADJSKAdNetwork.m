//
//  ADJSKAdNetwork.m
//  Adjust
//
//  Created by Uglješa Erceg on 27.10.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#include <dlfcn.h>

#import "ADJSKAdNetwork.h"
#import "ADJUserDefaults.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"

@interface ADJSKAdNetwork()

@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) Class clsSkAdNetwork;
@property (nonatomic, assign) SEL selRegisterAppForAdNetworkAttribution;
@property (nonatomic, assign) SEL selUpdateConversionValue;
@property (nonatomic, assign) SEL selUpdatePostbackConversionValueCompletionHandler;
@property (nonatomic, assign) SEL selUpdatePostbackConversionValueCoarseValueCompletionHandler;
@property (nonatomic, assign) SEL selUpdatePostbackConversionValueCoarseValueLockWindowCompletionHandler;

@end

@implementation ADJSKAdNetwork

#pragma mark - Lifecycle

+ (instancetype)getInstance {
    static ADJSKAdNetwork *defaultInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });
    return defaultInstance;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.logger = [ADJAdjustFactory logger];
    self.clsSkAdNetwork = NSClassFromString(@"SKAdNetwork");
    self.selRegisterAppForAdNetworkAttribution = NSSelectorFromString(@"registerAppForAdNetworkAttribution");
    self.selUpdateConversionValue = NSSelectorFromString(@"updateConversionValue:");
    self.selUpdatePostbackConversionValueCompletionHandler = NSSelectorFromString(@"updatePostbackConversionValue:completionHandler:");
    self.selUpdatePostbackConversionValueCoarseValueCompletionHandler = NSSelectorFromString(@"updatePostbackConversionValue:coarseValue:completionHandler:");
    self.selUpdatePostbackConversionValueCoarseValueLockWindowCompletionHandler = NSSelectorFromString(@"updatePostbackConversionValue:coarseValue:lockWindow:completionHandler:");

    return self;
}

#pragma mark - SKAdNetwork API

- (void)registerAppForAdNetworkAttribution {
    if (@available(iOS 14.0, *)) {
        if ([self isApiAvailable:self.selRegisterAppForAdNetworkAttribution]) {
            NSMethodSignature *methodSignature = [self.clsSkAdNetwork methodSignatureForSelector:self.selRegisterAppForAdNetworkAttribution];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:self.selRegisterAppForAdNetworkAttribution];
            [invocation setTarget:self.clsSkAdNetwork];
            [invocation invoke];
            [self.logger verbose:@"Call to SKAdNetwork's registerAppForAdNetworkAttribution method made"];
        }
    } else {
        [self.logger warn:@"SKAdNetwork's registerAppForAdNetworkAttribution method not available for this operating system version"];
    }
}

- (void)updateConversionValue:(NSInteger)conversionValue {
    if (@available(iOS 14.0, *)) {
        if ([self isApiAvailable:self.selUpdateConversionValue]) {
            NSMethodSignature *methodSignature = [self.clsSkAdNetwork methodSignatureForSelector:self.selUpdateConversionValue];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:self.selUpdateConversionValue];
            [invocation setTarget:self.clsSkAdNetwork];
            [invocation setArgument:&conversionValue atIndex:2];
            [invocation invoke];
            [self.logger verbose:@"Call to SKAdNetwork's updateConversionValue: method made with value %d", conversionValue];
        }
    } else {
        [self.logger warn:@"SKAdNetwork's updateConversionValue: method not available for this operating system version"];
    }
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                    completionHandler:(void (^)(NSError *error))completion {
    if (@available(iOS 15.4, *)) {
        if ([self isApiAvailable:self.selUpdatePostbackConversionValueCompletionHandler]) {
            NSMethodSignature *methodSignature = [self.clsSkAdNetwork methodSignatureForSelector:self.selUpdatePostbackConversionValueCompletionHandler];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:self.selUpdatePostbackConversionValueCompletionHandler];
            [invocation setTarget:self.clsSkAdNetwork];
            [invocation setArgument:&conversionValue atIndex:2];
            [invocation setArgument:&completion atIndex:3];
            [invocation invoke];
        }
    } else {
        [self.logger warn:@"SKAdNetwork's updatePostbackConversionValue:completionHandler: method not available for this operating system version"];
    }
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(NSString *)coarseValue
                    completionHandler:(void (^)(NSError *error))completion {
    if (@available(iOS 16.1, *)) {
        if ([self isApiAvailable:self.selUpdatePostbackConversionValueCoarseValueCompletionHandler]) {
            NSMethodSignature *methodSignature = [self.clsSkAdNetwork methodSignatureForSelector:self.selUpdatePostbackConversionValueCoarseValueCompletionHandler];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:self.selUpdatePostbackConversionValueCoarseValueCompletionHandler];
            [invocation setTarget:self.clsSkAdNetwork];
            [invocation setArgument:&fineValue atIndex:2];
            [invocation setArgument:&coarseValue atIndex:3];
            [invocation setArgument:&completion atIndex:4];
            [invocation invoke];
        }
    } else {
        [self.logger warn:@"SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method not available for this operating system version"];
    }
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(NSString *)coarseValue
                           lockWindow:(BOOL)lockWindow
                    completionHandler:(void (^)(NSError *error))completion {
    if (@available(iOS 16.1, *)) {
        if ([self isApiAvailable:self.selUpdatePostbackConversionValueCoarseValueLockWindowCompletionHandler]) {
            NSMethodSignature *methodSignature = [self.clsSkAdNetwork methodSignatureForSelector:self.selUpdatePostbackConversionValueCoarseValueLockWindowCompletionHandler];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:self.selUpdatePostbackConversionValueCoarseValueLockWindowCompletionHandler];
            [invocation setTarget:self.clsSkAdNetwork];
            [invocation setArgument:&fineValue atIndex:2];
            [invocation setArgument:&coarseValue atIndex:3];
            [invocation setArgument:&lockWindow atIndex:4];
            [invocation setArgument:&completion atIndex:5];
            [invocation invoke];
        }
    } else {
        [self.logger warn:@"SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method not available for this operating system version"];
    }
}

#pragma mark - Adjust helper methods

- (void)adjRegisterWithCompletionHandler:(void (^)(NSError *error))callback {
    if ([ADJUserDefaults getSkadRegisterCallTimestamp] != nil) {
        [self.logger debug:@"Call to register app with SKAdNetwork already made for this install"];
        callback(nil);
        return;
    }
    [self registerAppForAdNetworkAttribution];
    callback(nil);
    [self writeSkAdNetworkRegisterCallTimestamp];
}

- (void)adjUpdateConversionValue:(NSInteger)conversionValue
                     coarseValue:(NSString *)coarseValue
                      lockWindow:(NSNumber *)lockWindow
               completionHandler:(void (^)(NSError *error))callback {
    if (coarseValue != nil && lockWindow != nil) {
        // 4.0 world
        [self updatePostbackConversionValue:conversionValue
                                coarseValue:[self getSkAdNetworkCoarseConversionValue:coarseValue]
                                 lockWindow:[lockWindow boolValue]
                          completionHandler:^(NSError * _Nonnull error) {
            if (error) {
                [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %d, coarse value: %@, lock window: %d failed\nDescription: %@", conversionValue, coarseValue, [lockWindow boolValue], error.localizedDescription];
            } else {
                [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %d, coarse value: %@, lock window: %d", conversionValue, coarseValue, [lockWindow boolValue]];
            }
            callback(error);
        }];
    } else {
        // pre 4.0 world
        if (@available(iOS 15.4, *)) {
            [self updatePostbackConversionValue:conversionValue
                              completionHandler:^(NSError * _Nonnull error) {
                if (error) {
                    [self.logger error:@"Call to updatePostbackConversionValue:completionHandler: method with conversion value: %d failed\nDescription: %@", conversionValue, error.localizedDescription];
                } else {
                    [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d", conversionValue];
                }
                callback(error);
            }];
        } else if (@available(iOS 14.0, *)) {
            [self updateConversionValue:conversionValue];
            callback(nil);
        } else {
            [self.logger error:@"SKAdNetwork API not available on this iOS version"];
            callback(nil);
        }
    }
}

#pragma mark - Private

- (BOOL)isApiAvailable:(SEL)selector {
    if (self.clsSkAdNetwork == nil) {
        [self.logger warn:@"StoreKit.framework not found in the app (SKAdNetwork class not found)"];
        return NO;
    }
    if ([self.clsSkAdNetwork respondsToSelector:selector] == NO) {
        [self.logger warn:@"%@ method implementation not found", selector];
        return NO;
    }
    return YES;
}

- (void)writeSkAdNetworkRegisterCallTimestamp {
    NSDate *callTime = [NSDate date];
    [ADJUserDefaults saveSkadRegisterCallTimestamp:callTime];
}

- (NSString *)getSkAdNetworkCoarseConversionValue:(NSString *)adjustCoarseValue {
    if (@available(iOS 16.1, *)) {
        if ([adjustCoarseValue isEqualToString:@"low"]) {
            NSString * __autoreleasing *lowValue = (NSString * __autoreleasing *)dlsym(RTLD_DEFAULT, "SKAdNetworkCoarseConversionValueLow");
            return *lowValue;
        } else if ([adjustCoarseValue isEqualToString:@"medium"]) {
            NSString * __autoreleasing *mediumValue = (NSString * __autoreleasing *)dlsym(RTLD_DEFAULT, "SKAdNetworkCoarseConversionValueMedium");
            return *mediumValue;
        } else if ([adjustCoarseValue isEqualToString:@"high"]) {
            NSString * __autoreleasing *highValue = (NSString * __autoreleasing *)dlsym(RTLD_DEFAULT, "SKAdNetworkCoarseConversionValueHigh");
            return *highValue;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end

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

    return self;
}

#pragma mark - SKAdNetwork API

- (void)registerAppForAdNetworkAttribution {
    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"registerAppForAdNetworkAttribution");
    if (@available(iOS 14.0, *)) {
        if ([self isApiAvailableForClass:class andSelector:selector]) {
            NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:selector];
            [invocation setTarget:class];
            [invocation invoke];
            [self.logger verbose:@"Call to SKAdNetwork's registerAppForAdNetworkAttribution method made"];
        }
    } else {
        [self.logger warn:@"SKAdNetwork's registerAppForAdNetworkAttribution method not available for this operating system version"];
    }
}

- (void)updateConversionValue:(NSInteger)conversionValue {
    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updateConversionValue:");
    if (@available(iOS 14.0, *)) {
        if ([self isApiAvailableForClass:class andSelector:selector]) {
            NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:selector];
            [invocation setTarget:class];
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
    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updatePostbackConversionValue:completionHandler:");
    if (@available(iOS 15.4, *)) {
        if ([self isApiAvailableForClass:class andSelector:selector]) {
            NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:selector];
            [invocation setTarget:class];
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
    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updatePostbackConversionValue:coarseValue:completionHandler:");
    if (@available(iOS 16.1, *)) {
        if ([self isApiAvailableForClass:class andSelector:selector]) {
            NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:selector];
            [invocation setTarget:class];
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
    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updatePostbackConversionValue:coarseValue:lockWindow:completionHandler:");
    if (@available(iOS 16.1, *)) {
        if ([self isApiAvailableForClass:class andSelector:selector]) {
            NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [invocation setSelector:selector];
            [invocation setTarget:class];
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
    if (NSClassFromString(@"SKAdNetwork") == nil) {
        [self.logger debug:@"StoreKit.framework not found in the app (SKAdNetwork class not found)"];
        return;
    }
    if ([ADJUserDefaults getSkadRegisterCallTimestamp] != nil) {
        [self.logger debug:@"Call to register app with SKAdNetwork already made for this install"];
        callback(nil);
        return;
    }

    if (@available(iOS 16.1, *)) {
        [self updatePostbackConversionValue:0
                                coarseValue:[self getSkAdNetworkCoarseConversionValue:@"low"]
                                 lockWindow:NO
                          completionHandler:^(NSError * _Nonnull error) {
            callback(error);
        }];
    } else if (@available(iOS 15.4, *)) {
        [self updatePostbackConversionValue:0
                          completionHandler:^(NSError * _Nonnull error) {
            callback(error);
        }];
    } else if (@available(iOS 14.0, *)) {
        [self registerAppForAdNetworkAttribution];
        callback(nil);
    } else {
        [self.logger error:@"SKAdNetwork API not available on this iOS version"];
        callback(nil);
        return;
    }

    [self writeSkAdNetworkRegisterCallTimestamp];
}

- (void)adjUpdateConversionValue:(NSInteger)conversionValue
                     coarseValue:(NSString *)coarseValue
                      lockWindow:(NSNumber *)lockWindow
               completionHandler:(void (^)(NSError *error))callback {
    if (NSClassFromString(@"SKAdNetwork") == nil) {
        [self.logger debug:@"StoreKit.framework not found in the app (SKAdNetwork class not found)"];
        return;
    }
    // let's make sure that the conversionValue makes sense
    if (conversionValue < 0) {
        callback(nil);
        return;
    }

    if (@available(iOS 16.1, *)) {
        // let's check if coarseValue and lockWindow make sense
        if (coarseValue != nil) {
            if (lockWindow != nil) {
                // they do both
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
                // Only coarse value is received
                [self updatePostbackConversionValue:conversionValue
                                        coarseValue:[self getSkAdNetworkCoarseConversionValue:coarseValue]
                                  completionHandler:^(NSError * _Nonnull error) {
                    if (error) {
                        [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with conversion value: %d, coarse value: %@ failed\nDescription: %@", conversionValue, coarseValue, error.localizedDescription];
                    } else {
                        [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with conversion value: %d, coarse value: %@", conversionValue, coarseValue];
                    }
                    callback(error);
                }];
            }
        } else {
            // they don't, let's make sure to update conversion value with a
            // call to updatePostbackConversionValue:completionHandler: method
            [self updatePostbackConversionValue:conversionValue
                              completionHandler:^(NSError * _Nonnull error) {
                if (error) {
                    [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d failed\nDescription: %@", conversionValue, error.localizedDescription];
                } else {
                    [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d", conversionValue];
                }
                callback(error);
            }];
        }
    } else if (@available(iOS 15.4, *)) {
        [self updatePostbackConversionValue:conversionValue
                          completionHandler:^(NSError * _Nonnull error) {
            if (error) {
                [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d failed\nDescription: %@", conversionValue, error.localizedDescription];
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

#pragma mark - Private

- (BOOL)isApiAvailableForClass:(Class)class andSelector:(SEL)selector {
#if !(TARGET_OS_TV)
    if (class == nil) {
        [self.logger warn:@"StoreKit.framework not found in the app (SKAdNetwork class not found)"];
        return NO;
    }
    if (!selector) {
        [self.logger warn:@"Selector for given method was not found"];
        return NO;
    }
    if ([class respondsToSelector:selector] == NO) {
        [self.logger warn:@"%@ method implementation not found", NSStringFromSelector(selector)];
        return NO;
    }
    return YES;
#else
    [self.logger debug:@"%@ method implementation not available for tvOS platform", NSStringFromSelector(selector)];
    return NO;
#endif
}

- (void)writeSkAdNetworkRegisterCallTimestamp {
    NSDate *callTime = [NSDate date];
    [ADJUserDefaults saveSkadRegisterCallTimestamp:callTime];
}

- (NSString *)getSkAdNetworkCoarseConversionValue:(NSString *)adjustCoarseValue {
#if !(TARGET_OS_TV)
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
#else
    return nil;
#endif
}

@end

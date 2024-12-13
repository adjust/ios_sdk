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

static const char * const kInternalQueueName = "io.adjust.SKAdNetworkQueue";

@interface ADJSKAdNetwork()
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@end

static NSString * const ADJSKAdNetworkDomain = @"com.adjust.sdk.skadnetwork";
typedef NS_ENUM(NSInteger, ADJSKAdNetworkError) {
    ADJSKAdNetworkErrorOsNotSupported       = -100,
    ADJSKAdNetworkErrorFrameworkNotFound    = -101,
    ADJSKAdNetworkErrorApiNotAvailable      = -102
};

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
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    return self;
}

#pragma mark - SKAdNetwork API

- (void)registerAppForAdNetworkAttributionWithCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"registerAppForAdNetworkAttribution"];
    if (error != nil) {
        [self asyncSendResultError:error toCompletionHandler:completion];
        return;
    }

    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"registerAppForAdNetworkAttribution");
    NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    [invocation setTarget:class];
    [invocation invoke];
    [self.logger verbose:@"Call to SKAdNetwork's registerAppForAdNetworkAttribution method made"];
    [self asyncSendResultError:error toCompletionHandler:completion];
}

- (void)updateConversionValue:(NSInteger)conversionValue
        withCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"updateConversionValue:"];
    if (error != nil) {
        [self asyncSendResultError:error toCompletionHandler:completion];
        return;
    }

    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updateConversionValue:");
    NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    [invocation setTarget:class];
    [invocation setArgument:&conversionValue atIndex:2];
    [invocation invoke];
    [self.logger verbose:@"Call to SKAdNetwork's updateConversionValue: method made with value %d", conversionValue];
    [self asyncSendResultError:error toCompletionHandler:completion];
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                withCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"updatePostbackConversionValue:completionHandler:"];
    if (error != nil) {
        [self asyncSendResultError:error toCompletionHandler:completion];
        return;
    }

    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updatePostbackConversionValue:completionHandler:");
    NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    [invocation setTarget:class];
    [invocation setArgument:&conversionValue atIndex:2];
    [invocation setArgument:&completion atIndex:3];
    [invocation invoke];
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(NSString *)coarseValue
                withCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"updatePostbackConversionValue:coarseValue:completionHandler:"];
    if (error != nil) {
        [self asyncSendResultError:error toCompletionHandler:completion];
        return;
    }

    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updatePostbackConversionValue:coarseValue:completionHandler:");
    NSMethodSignature *methodSignature = [class methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    [invocation setTarget:class];
    [invocation setArgument:&fineValue atIndex:2];
    [invocation setArgument:&coarseValue atIndex:3];
    [invocation setArgument:&completion atIndex:4];
    [invocation invoke];
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(NSString *)coarseValue
                           lockWindow:(BOOL)lockWindow
                withCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"updatePostbackConversionValue:coarseValue:lockWindow:completionHandler:"];
    if (error != nil) {
        [self asyncSendResultError:error toCompletionHandler:completion];
        return;
    }

    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(@"updatePostbackConversionValue:coarseValue:lockWindow:completionHandler:");
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

#pragma mark - Adjust helper methods

- (void)registerWithConversionValue:(NSInteger)conversionValue
                        coarseValue:(nonnull NSString *)coarseValue
                         lockWindow:(nonnull NSNumber *)lockWindow
              withCompletionHandler:(void (^_Nonnull)(NSError *_Nullable error))completion {

    NSError *error = nil;
    // Check iOS 14.0+ / NON-tvOS / SKAdNetwork framework available
    if (![self checkSKAdNetworkFrameworkAvailability:&error]) {
        [self.logger debug:error.localizedDescription];
        [self asyncSendResultError:error toCompletionHandler:completion];
        return;
    }

    if (@available(iOS 16.1, *)) {
        [self updatePostbackConversionValue:conversionValue
                                coarseValue:[self getSkAdNetworkCoarseConversionValue:coarseValue]
                                 lockWindow:lockWindow
                      withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self.logger error:@"Registration: call to SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %d, coarse value: %@, lock window: %d failed\nDescription: %@", conversionValue, coarseValue, [lockWindow boolValue], error.localizedDescription];
            } else {
                [self.logger debug:@"Registration: called SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %d, coarse value: %@, lock window: %d", conversionValue, coarseValue, [lockWindow boolValue]];
            }

            if (error == nil) {
                [self writeSkAdNetworkRegisterCallTimestamp];
            }
            if (completion != nil) {
                completion(error);
            }
        }];
    } else if (@available(iOS 15.4, *)) {
        [self updatePostbackConversionValue:conversionValue
                      withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self.logger error:@"Registration: call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d failed\nDescription: %@", conversionValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Registration: called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d", conversionValue];
            }
            if (error == nil) {
                [self writeSkAdNetworkRegisterCallTimestamp];
            }
            if (completion != nil) {
                completion(error);
            }
        }];
    } else { // if (@available(iOS 14.0, *)) { already checked in 'checkSKAdNetworkFrameworkAvailability'
        [self registerAppForAdNetworkAttributionWithCompletionHandler:^(NSError *error) {
            if (error) {
                [self.logger error:@"Registration: call to SKAdNetwork's registerAppForAdNetworkAttribution method failed\nDescription: %@", error.localizedDescription];
            } else {
                [self.logger debug:@"Registration: called SKAdNetwork's registerAppForAdNetworkAttribution method"];
            }
            if (error == nil) {
                [self writeSkAdNetworkRegisterCallTimestamp];
            }
            if (completion != nil) {
                completion(error);
            }
        }];
    }
}

- (void)updateConversionValue:(NSInteger)conversionValue
                  coarseValue:(nullable NSString *)coarseValue
                   lockWindow:(nullable NSNumber *)lockWindow
        withCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {

    NSError *error = nil;
    // Check iOS 14.0+ / NON-tvOS / SKAdNetwork available
    if (![self checkSKAdNetworkFrameworkAvailability:&error]) {
        [self.logger debug:error.localizedDescription];
        [self asyncSendResultError:error toCompletionHandler:completion];
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
                              withCompletionHandler:^(NSError * _Nullable error) {
                    if (error) {
                        [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %d, coarse value: %@, lock window: %d failed\nDescription: %@", conversionValue, coarseValue, [lockWindow boolValue], error.localizedDescription];
                    } else {
                        [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %d, coarse value: %@, lock window: %d", conversionValue, coarseValue, [lockWindow boolValue]];
                    }
                    if (completion != nil) {
                        completion(error);
                    }
                }];
            } else {
                // Only coarse value is received
                [self updatePostbackConversionValue:conversionValue
                                        coarseValue:[self getSkAdNetworkCoarseConversionValue:coarseValue]
                              withCompletionHandler:^(NSError * _Nullable error) {
                    if (error) {
                        [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with conversion value: %d, coarse value: %@ failed\nDescription: %@", conversionValue, coarseValue, error.localizedDescription];
                    } else {
                        [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with conversion value: %d, coarse value: %@", conversionValue, coarseValue];
                    }
                    if (completion != nil) {
                        completion(error);
                    }
                }];
            }
        } else {
            // they don't, let's make sure to update conversion value with a
            // call to updatePostbackConversionValue:completionHandler: method
            [self updatePostbackConversionValue:conversionValue
                          withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d failed\nDescription: %@", conversionValue, error.localizedDescription];
                } else {
                    [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d", conversionValue];
                }
                if (completion != nil) {
                    completion(error);
                }
            }];
        }
    } else if (@available(iOS 15.4, *)) {
        [self updatePostbackConversionValue:conversionValue
                      withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d failed\nDescription: %@", conversionValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %d", conversionValue];
            }
            if (completion != nil) {
                completion(error);
            }
        }];
    } else { //if (@available(iOS 14.0, *)) { already checked in 'checkSKAdNetworkFrameworkAvailability'
        [self updateConversionValue:conversionValue withCompletionHandler:^(NSError *error) {
            if (error) {
                [self.logger error:@"Update CV: call to SKAdNetwork's updateConversionValue: method with conversion value: %d failed\nDescription: %@", conversionValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Update CV: called SKAdNetwork's updateConversionValue: method with conversion value: %d", conversionValue];
            }
            if (completion != nil) {
                completion(error);
            }
        }];
    }
}

#pragma mark - Private

- (BOOL)checkSKAdNetworkFrameworkAvailability:(NSError **)error {
#if !(TARGET_OS_TV)
    if (@available(iOS 14.0, *)) {
        if (NSClassFromString(@"SKAdNetwork") == nil) {
            NSString *strError = @"SKAdNetwork class not found. Check StoreKit.framework availability.";
            *error = [NSError errorWithDomain:ADJSKAdNetworkDomain
                                         code:ADJSKAdNetworkErrorFrameworkNotFound
                                     userInfo:@{ NSLocalizedDescriptionKey: strError }];
            return NO;
        }
        return YES;
    } else {
        NSString *strError = @"SKAdNetwork API not available on this iOS version";
        *error = [NSError errorWithDomain:ADJSKAdNetworkDomain
                                     code:ADJSKAdNetworkErrorOsNotSupported
                                 userInfo:@{ NSLocalizedDescriptionKey: strError }];
        return NO;
    }
#else
    NSString *strError = @"SKAdNetwork is not supported on tvOS";
    *error = [NSError errorWithDomain:ADJSKAdNetworkDomain
                                 code:ADJSKAdNetworkErrorOsNotSupported
                             userInfo:@{ NSLocalizedDescriptionKey: strError }];
    return NO;
#endif
}

- (NSError *)checkSKAdNetworkMethodAvailability:(NSString *)methodName {
    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(methodName);

    if ([class respondsToSelector:selector] == NO) {
        NSString *strError = [NSString stringWithFormat:@"Implementation of %@ not found in SKAdNetwork", methodName];
        NSError *error = [NSError errorWithDomain:ADJSKAdNetworkDomain
                                             code:ADJSKAdNetworkErrorApiNotAvailable
                                         userInfo:@{ NSLocalizedDescriptionKey: strError }];
        return error;
    }
    return nil;
}

- (void)asyncSendResultError:(NSError *_Nullable)error
         toCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    dispatch_async(self.internalQueue, ^{
        if (completion != nil) {
            completion(error);
        }
    });
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

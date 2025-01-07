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
#import "ADJUtil.h"

static const char * const kInternalQueueName = "io.adjust.SKAdNetworkQueue";
static NSString * const ADJSKAdNetworkDomain = @"com.adjust.sdk.skadnetwork";
typedef NS_ENUM(NSInteger, ADJSKAdNetworkError) {
    ADJSKAdNetworkErrorOsNotSupported       = -100,
    ADJSKAdNetworkErrorFrameworkNotFound    = -101,
    ADJSKAdNetworkErrorApiNotAvailable      = -102,
    ADJSKAdNetworkErrorInvalidCoarseValue   = -103
};

// Externally Available constants
NSString * const ADJSKAdNetworkCallSourceSdk = @"sdk";
NSString * const ADJSKAdNetworkCallSourceBackend = @"backend";
NSString * const ADJSKAdNetworkCallSourceClient = @"client";
NSString * const ADJSKAdNetworkCallActualConversionParamsKey = @"skan_call_actual_conversion_params";
NSString * const ADJSKAdNetworkCallErrorKey = @"skan_call_error";

static NSString   * const kSkanConversionValueCallbackKey = @"conversion_value";
static NSString   * const kSkanCoarseValueCallbackKey = @"coarse_value";
static NSString   * const kSkanLockWindowCallbackKey = @"lock_window";
static NSString   * const kSkanErrorCallbackKey = @"error";

@interface ADJSKAdNetwork()
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
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
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    return self;
}

#pragma mark - SKAdNetwork API

- (void)registerAppForAdNetworkAttributionWithCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"registerAppForAdNetworkAttribution"];
    if (error != nil) {
        [self sendSkanCallError:error toCompletionHandler:completion];
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
    [self sendSkanCallError:error toCompletionHandler:completion];
}

- (void)updateConversionValue:(NSInteger)conversionValue
        withCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"updateConversionValue:"];
    if (error != nil) {
        [self sendSkanCallError:error toCompletionHandler:completion];
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
    [self sendSkanCallError:error toCompletionHandler:completion];
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                withCompletionHandler:(void (^)(NSError *error))completion {

    NSError *error = [self checkSKAdNetworkMethodAvailability:@"updatePostbackConversionValue:completionHandler:"];
    if (error != nil) {
        [self sendSkanCallError:error toCompletionHandler:completion];
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
        [self sendSkanCallError:error toCompletionHandler:completion];
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
        [self sendSkanCallError:error toCompletionHandler:completion];
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

- (void)registerWithConversionValue:(nonnull NSNumber *)conversionValue
                        coarseValue:(nonnull NSString *)coarseValue
                         lockWindow:(nonnull NSNumber *)lockWindow
              withCompletionHandler:(void (^_Nonnull)(NSDictionary *_Nonnull result))completion {

    NSDate *skanRegisterDate = [self skadNetworkRegisterCallTimestamp];
    if (skanRegisterDate != nil) {
        [self.logger debug:@"Call to register app with SKAdNetwork already made for this install"];
        return;
    }

    NSError *error = nil;
    // Check iOS 14.0+ / NON-tvOS / SKAdNetwork framework available
    if (![self checkSKAdNetworkFrameworkAvailability:&error]) {
        [self.logger debug:error.localizedDescription];
        [self sendSkanCallResultWithConversionValue:conversionValue
                                        coarseValue:coarseValue
                                         lockWindow:lockWindow
                                 apiInvocationError:error
                                toCompletionHandler:completion];
        return;
    }

    if (@available(iOS 16.1, *)) {
        NSError *error = nil;
        NSString *skanCoarseValue = [self getSKAdNetworkCoarseConversionValue:coarseValue
                                                                    withError:&error];
        if (skanCoarseValue == nil) {
            [self.logger debug:error.localizedDescription];
            [self sendSkanCallResultWithConversionValue:conversionValue
                                            coarseValue:coarseValue
                                             lockWindow:lockWindow
                                     apiInvocationError:error
                                    toCompletionHandler:completion];
            return;
        }

        [self updatePostbackConversionValue:conversionValue.integerValue
                                coarseValue:skanCoarseValue
                                 lockWindow:lockWindow.boolValue
                      withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self.logger error:@"Registration: call to SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %ld, coarse value: %@, lock window: %d failed\nDescription: %@",
                 conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Registration: called SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %ld, coarse value: %@, lock window: %d",
                 conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue];
            }

            if (error == nil) {
                [self writeSKAdNetworkRegisterCallTimestamp];
                [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                    coarseValue:skanCoarseValue
                                                     lockWindow:lockWindow
                                                      timestamp:[NSDate date]
                                                         source:ADJSKAdNetworkCallSourceSdk];
            }
            [self sendSkanCallResultWithConversionValue:conversionValue
                                            coarseValue:skanCoarseValue
                                             lockWindow:lockWindow
                                     apiInvocationError:error
                                    toCompletionHandler:completion];
        }];
    } else if (@available(iOS 15.4, *)) {
        [self updatePostbackConversionValue:conversionValue.integerValue
                      withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self.logger error:@"Registration: call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %ld failed\nDescription: %@",
                 conversionValue.integerValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Registration: called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %ld",
                 conversionValue.integerValue];
            }
            if (error == nil) {
                [self writeSKAdNetworkRegisterCallTimestamp];
                [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                    coarseValue:nil
                                                     lockWindow:nil
                                                      timestamp:[NSDate date]
                                                         source:ADJSKAdNetworkCallSourceSdk];
            }
            [self sendSkanCallResultWithConversionValue:conversionValue
                                            coarseValue:nil
                                             lockWindow:nil
                                     apiInvocationError:error
                                    toCompletionHandler:completion];
        }];
    } else { // if (@available(iOS 14.0, *)) { already checked in 'checkSKAdNetworkFrameworkAvailability'
        [self registerAppForAdNetworkAttributionWithCompletionHandler:^(NSError *error) {
            if (error) {
                [self.logger error:@"Registration: call to SKAdNetwork's registerAppForAdNetworkAttribution method failed\nDescription: %@", error.localizedDescription];
            } else {
                [self.logger debug:@"Registration: called SKAdNetwork's registerAppForAdNetworkAttribution method"];
            }
            if (error == nil) {
                [self writeSKAdNetworkRegisterCallTimestamp];
                [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                    coarseValue:nil
                                                     lockWindow:nil
                                                      timestamp:[NSDate date]
                                                         source:ADJSKAdNetworkCallSourceSdk];
            }
            [self sendSkanCallResultWithConversionValue:conversionValue
                                            coarseValue:nil
                                             lockWindow:nil
                                     apiInvocationError:error
                                    toCompletionHandler:completion];
        }];
    }
}

- (void)updateConversionValue:(nonnull NSNumber *)conversionValue
                  coarseValue:(nullable NSString *)coarseValue
                   lockWindow:(nullable NSNumber *)lockWindow
                       source:(nonnull NSString *)source
        withCompletionHandler:(void (^_Nonnull)(NSDictionary *_Nonnull result))completion {

    NSError *error = nil;
    // Check iOS 14.0+ / NON-tvOS / SKAdNetwork framework available
    if (![self checkSKAdNetworkFrameworkAvailability:&error]) {
        [self.logger debug:error.localizedDescription];
        [self sendSkanCallResultWithConversionValue:conversionValue
                                        coarseValue:coarseValue
                                         lockWindow:lockWindow
                                 apiInvocationError:error
                                toCompletionHandler:completion];
        return;
    }


    if (@available(iOS 16.1, *)) {
        // let's check if coarseValue and lockWindow make sense
        if (coarseValue != nil) {
            NSError *error = nil;
            NSString *skanCoarseValue = [self getSKAdNetworkCoarseConversionValue:coarseValue
                                                                        withError:&error];
            if (skanCoarseValue == nil) {
                [self.logger debug:error.localizedDescription];
                [self sendSkanCallResultWithConversionValue:conversionValue
                                                coarseValue:coarseValue
                                                 lockWindow:lockWindow
                                         apiInvocationError:error
                                        toCompletionHandler:completion];
                return;
            }

            if (lockWindow != nil) {
                // they do both
                [self updatePostbackConversionValue:conversionValue.integerValue
                                        coarseValue:skanCoarseValue
                                         lockWindow:lockWindow.boolValue
                              withCompletionHandler:^(NSError * _Nullable error) {
                    if (error) {
                        [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %ld, coarse value: %@, lock window: %d failed\nDescription: %@", conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue, error.localizedDescription];
                    } else {
                        [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with conversion value: %d, coarse value: %@, lock window: %d",
                         conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue];
                        [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                            coarseValue:skanCoarseValue
                                                             lockWindow:lockWindow
                                                              timestamp:[NSDate date]
                                                                 source:source];
                    }
                    [self sendSkanCallResultWithConversionValue:conversionValue
                                                    coarseValue:skanCoarseValue
                                                     lockWindow:lockWindow
                                             apiInvocationError:error
                                            toCompletionHandler:completion];
                }];
            } else {
                // Only coarse value is received
                [self updatePostbackConversionValue:conversionValue.integerValue
                                        coarseValue:skanCoarseValue
                              withCompletionHandler:^(NSError * _Nullable error) {
                    if (error) {
                        [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with conversion value: %ld, coarse value: %@ failed\nDescription: %@",
                         conversionValue.integerValue, skanCoarseValue, error.localizedDescription];
                    } else {
                        [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with conversion value: %ld, coarse value: %@",
                         conversionValue.integerValue, skanCoarseValue];
                        [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                            coarseValue:skanCoarseValue
                                                             lockWindow:nil
                                                              timestamp:[NSDate date]
                                                                 source:source];
                    }
                    [self sendSkanCallResultWithConversionValue:conversionValue
                                                    coarseValue:skanCoarseValue
                                                     lockWindow:nil
                                             apiInvocationError:error
                                            toCompletionHandler:completion];
                }];
            }
        } else {
            // they don't, let's make sure to update conversion value with a
            // call to updatePostbackConversionValue:completionHandler: method
            [self updatePostbackConversionValue:conversionValue.integerValue
                          withCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %ld failed\nDescription: %@",
                     conversionValue.integerValue, error.localizedDescription];
                } else {
                    [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %ld",
                     conversionValue.integerValue];
                    [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                        coarseValue:nil
                                                         lockWindow:nil
                                                          timestamp:[NSDate date]
                                                             source:source];
                }
                [self sendSkanCallResultWithConversionValue:conversionValue
                                                coarseValue:nil
                                                 lockWindow:nil
                                         apiInvocationError:error
                                        toCompletionHandler:completion];
            }];
        }
    } else if (@available(iOS 15.4, *)) {
        [self updatePostbackConversionValue:conversionValue.integerValue
                      withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                [self.logger error:@"Update CV: call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %ld failed\nDescription: %@",
                 conversionValue.integerValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Update CV: called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with conversion value: %ld",
                 conversionValue.integerValue];
                [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                    coarseValue:nil
                                                     lockWindow:nil
                                                      timestamp:[NSDate date]
                                                         source:source];
            }
            [self sendSkanCallResultWithConversionValue:conversionValue
                                            coarseValue:nil
                                             lockWindow:nil
                                     apiInvocationError:error
                                    toCompletionHandler:completion];
        }];
    } else { //if (@available(iOS 14.0, *)) { already checked in 'checkSKAdNetworkFrameworkAvailability'
        [self updateConversionValue:conversionValue.integerValue withCompletionHandler:^(NSError *error) {
            if (error) {
                [self.logger error:@"Update CV: call to SKAdNetwork's updateConversionValue: method with conversion value: %ld failed\nDescription: %@",
                 conversionValue.integerValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Update CV: called SKAdNetwork's updateConversionValue: method with conversion value: %ld",
                 conversionValue.integerValue];
                [self writeLastSKAdNetworkUpdateConversionValue:conversionValue
                                                    coarseValue:nil
                                                     lockWindow:nil
                                                      timestamp:[NSDate date]
                                                         source:source];
            }
            [self sendSkanCallResultWithConversionValue:conversionValue
                                            coarseValue:nil
                                             lockWindow:nil
                                     apiInvocationError:error
                                    toCompletionHandler:completion];
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

- (void)sendSkanCallError:(NSError *_Nullable)error
      toCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    dispatch_async(self.internalQueue, ^{
        if (completion != nil) {
            completion(error);
        }
    });
}

- (void)sendSkanCallResultWithConversionValue:(nonnull NSNumber *)conversionValue
                                  coarseValue:(nullable NSString *)coarseValue
                                   lockWindow:(nullable NSNumber *)lockWindow
                           apiInvocationError:(nullable NSError *)error
                          toCompletionHandler:(void (^_Nonnull)(NSDictionary *_Nonnull result))completion {
    dispatch_async(self.internalQueue, ^{

        // Create output result diictionary
        NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

        // Create updated conversion data dictionary
        NSMutableDictionary<NSString *, NSString *> *conversionParams = [[NSMutableDictionary alloc] init];
        [conversionParams setObject:conversionValue.stringValue forKey:kSkanConversionValueCallbackKey];

        if (coarseValue != nil) {
            [conversionParams setObject:coarseValue forKey:kSkanCoarseValueCallbackKey];
        }
        if (lockWindow != nil) {
            NSString *val = (lockWindow.boolValue) ? @"true" : @"false";
            [conversionParams setObject:val forKey:kSkanLockWindowCallbackKey];
        }
        if (error != nil) {
            [conversionParams setObject:error.localizedDescription forKey:kSkanErrorCallbackKey];
        }

        // Add actual conversion params dictionary and error objects if present
        [result setObject:conversionParams forKey:ADJSKAdNetworkCallActualConversionParamsKey];
        if (error != nil) {
            [result setObject:error forKey:ADJSKAdNetworkCallErrorKey];
        }

        completion(result);
    });
}

- (void)writeSKAdNetworkRegisterCallTimestamp {
    NSDate *callTime = [NSDate date];
    [ADJUserDefaults saveSkadRegisterCallTimestamp:callTime];
}

- (NSDate *)skadNetworkRegisterCallTimestamp {
    return [ADJUserDefaults getSkadRegisterCallTimestamp];
}

- (void)writeLastSKAdNetworkUpdateConversionValue:(NSNumber * _Nullable)conversionValue
                                      coarseValue:(NSString * _Nullable)coarseValue
                                       lockWindow:(NSNumber * _Nullable)lockWindow
                                        timestamp:(NSDate * _Nonnull)timestamp
                                           source:(NSString * _Nonnull)source {

    NSMutableDictionary *skanUpdateData = [NSMutableDictionary dictionary];
    if (conversionValue != nil) {
        [skanUpdateData setObject:conversionValue forKey:kSkanConversionValueCallbackKey];
    }
    if (coarseValue != nil) {
        [skanUpdateData setObject:coarseValue forKey:kSkanCoarseValueCallbackKey];
    }
    if (lockWindow != nil) {
        [skanUpdateData setObject:lockWindow forKey:kSkanLockWindowCallbackKey];
    }
    [skanUpdateData setObject:[ADJUtil formatDate:timestamp] forKey:@"timestamp"];
    [skanUpdateData setObject:source forKey:@"source"];

    [ADJUserDefaults saveLastSkanUpdateData:skanUpdateData];
}

- (NSDictionary *)lastSKAdNetworkUpdateData {
    return [ADJUserDefaults getLastSkanUpdateData];
}

- (NSString *)getSKAdNetworkCoarseConversionValue:(NSString *)adjustCoarseValue
                                        withError:(NSError **)error {
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
            NSString *strError = [NSString stringWithFormat:@"Coarse value \"%@\" is invalid", adjustCoarseValue];
            *error = [NSError errorWithDomain:ADJSKAdNetworkDomain
                                         code:ADJSKAdNetworkErrorInvalidCoarseValue
                                     userInfo:@{ NSLocalizedDescriptionKey: strError }];
            return nil;
        }
    } else {
        NSString *strError = [NSString stringWithFormat:@"SKAdNetwork Coarse value is not available on this iOS version"];
        *error = [NSError errorWithDomain:ADJSKAdNetworkDomain
                                     code:ADJSKAdNetworkErrorApiNotAvailable
                                 userInfo:@{ NSLocalizedDescriptionKey: strError }];
        return nil;
    }
}

@end

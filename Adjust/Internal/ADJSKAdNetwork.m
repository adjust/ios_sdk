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

static const char * const kInternalQueueName = "io.adjust.SkanQueue";
static NSString * const ADJSkanDomain = @"com.adjust.sdk.skadnetwork";

typedef NS_ENUM(NSInteger, ADJSkanError) {
    ADJSkanErrorOsNotSupported          = -100,
    ADJSkanErrorOsVersionNotSupported   = -101,
    ADJSkanErrorFrameworkNotFound       = -102,
    ADJSkanErrorApiNotAvailable         = -103,
    ADJSkanErrorInvalidCoarseValue      = -104
};

// Externally Available constants
NSString * const ADJSkanSourceSdk = @"sdk";
NSString * const ADJSkanSourceBackend = @"backend";
NSString * const ADJSkanSourceClient = @"client";
NSString * const ADJSkanClientCallbackParamsKey = @"skan_client_callback_params";
NSString * const ADJSkanClientCompletionErrorKey = @"skan_client_completion_error";

static NSString * const kSkanCallbackConversionValueKey = @"conversion_value";
static NSString * const kSkanCallbackCoarseValueKey = @"coarse_value";
static NSString * const kSkanCallbackLockWindowKey = @"lock_window";
static NSString * const kSkanCallbackErrorKey = @"error";

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

#pragma mark - Public API

- (void)registerWithConversionValue:(nonnull NSNumber *)conversionValue
                        coarseValue:(nonnull NSString *)coarseValue
                         lockWindow:(nonnull NSNumber *)lockWindow
              withCompletionHandler:(void (^_Nonnull)(NSDictionary *_Nonnull result))completion {
    NSDate *skanRegisterDate = [self skanRegisterCallTimestamp];
    if (skanRegisterDate != nil) {
        [self.logger debug:@"Call to register app with SKAdNetwork already made for this install"];
        return;
    }

    NSError *error = nil;
    // Check iOS 14.0+ / NON-tvOS / SKAdNetwork framework available
    if (![self checkSkanFrameworkAvailability:&error]) {
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
        NSString *skanCoarseValue = [self getSkanCoarseConversionValue:coarseValue
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
                [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: (registration) method with { conversion value: %ld, coarse value: %@, lock window: %d } failed. Error: %@",
                 conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: (registration) method with { conversion value: %ld, coarse value: %@, lock window: %d }",
                 conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue];
            }

            if (error == nil) {
                [self writeskanRegisterCallTimestamp];
                [self writeLastSkanUpdateConversionValue:conversionValue
                                             coarseValue:skanCoarseValue
                                              lockWindow:lockWindow
                                               timestamp:[NSDate date]
                                                  source:ADJSkanSourceSdk];
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
                [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:completionHandler: (registration) method with { conversion value: %ld } failed. Error: %@",
                 conversionValue.integerValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:completionHandler: (registration) method with { conversion value: %ld }",
                 conversionValue.integerValue];
            }
            if (error == nil) {
                [self writeskanRegisterCallTimestamp];
                [self writeLastSkanUpdateConversionValue:conversionValue
                                             coarseValue:nil
                                              lockWindow:nil
                                               timestamp:[NSDate date]
                                                  source:ADJSkanSourceSdk];
            }
            [self sendSkanCallResultWithConversionValue:conversionValue
                                            coarseValue:nil
                                             lockWindow:nil
                                     apiInvocationError:error
                                    toCompletionHandler:completion];
        }];
    } else { // if (@available(iOS 14.0, *)) { already checked in 'checkSkanFrameworkAvailability'
        [self registerAppForAdNetworkAttributionWithCompletionHandler:^(NSError *error) {
            if (error) {
                [self.logger error:@"Call to SKAdNetwork's registerAppForAdNetworkAttribution method failed. Error: %@", error.localizedDescription];
            } else {
                [self.logger debug:@"Called SKAdNetwork's registerAppForAdNetworkAttribution method"];
            }
            if (error == nil) {
                [self writeskanRegisterCallTimestamp];
                [self writeLastSkanUpdateConversionValue:conversionValue
                                             coarseValue:nil
                                              lockWindow:nil
                                               timestamp:[NSDate date]
                                                  source:ADJSkanSourceSdk];
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
    if (![self checkSkanFrameworkAvailability:&error]) {
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
            NSString *skanCoarseValue = [self getSkanCoarseConversionValue:coarseValue
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
                        [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with { conversion value: %ld, coarse value: %@, lock window: %d } failed. Error: %@", conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue, error.localizedDescription];
                    } else {
                        [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:coarseValue:lockWindow:completionHandler: method with { conversion value: %d, coarse value: %@, lock window: %d }",
                         conversionValue.integerValue, skanCoarseValue, lockWindow.boolValue];
                        [self writeLastSkanUpdateConversionValue:conversionValue
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
                        [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with { conversion value: %ld, coarse value: %@ } failed. Error: %@",
                         conversionValue.integerValue, skanCoarseValue, error.localizedDescription];
                    } else {
                        [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:coarseValue:completionHandler: method with { conversion value: %ld, coarse value: %@ }",
                         conversionValue.integerValue, skanCoarseValue];
                        [self writeLastSkanUpdateConversionValue:conversionValue
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
                    [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with { conversion value: %ld } failed. Error: %@",
                     conversionValue.integerValue, error.localizedDescription];
                } else {
                    [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with { conversion value: %ld }",
                     conversionValue.integerValue];
                    [self writeLastSkanUpdateConversionValue:conversionValue
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
                [self.logger error:@"Call to SKAdNetwork's updatePostbackConversionValue:completionHandler: method with { conversion value: %ld } failed. Error: %@",
                 conversionValue.integerValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Called SKAdNetwork's updatePostbackConversionValue:completionHandler: method with { conversion value: %ld }",
                 conversionValue.integerValue];
                [self writeLastSkanUpdateConversionValue:conversionValue
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
    } else { //if (@available(iOS 14.0, *)) { already checked in 'checkSkanFrameworkAvailability'
        [self updateConversionValue:conversionValue.integerValue withCompletionHandler:^(NSError *error) {
            if (error) {
                [self.logger error:@"Call to SKAdNetwork's updateConversionValue: method with { conversion value: %ld } failed. Error: %@",
                 conversionValue.integerValue, error.localizedDescription];
            } else {
                [self.logger debug:@"Called SKAdNetwork's updateConversionValue: method with { conversion value: %ld }",
                 conversionValue.integerValue];
                [self writeLastSkanUpdateConversionValue:conversionValue
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

- (NSDictionary *)lastSkanUpdateData {
    return [ADJUserDefaults getLastSkanUpdateData];
}

#pragma mark - SKAdNetwork API

- (void)registerAppForAdNetworkAttributionWithCompletionHandler:(void (^)(NSError *error))completion {
    NSError *error = [self checkSkanMethodAvailability:@"registerAppForAdNetworkAttribution"];
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
    NSError *error = [self checkSkanMethodAvailability:@"updateConversionValue:"];
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
    NSError *error = [self checkSkanMethodAvailability:@"updatePostbackConversionValue:completionHandler:"];
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
    NSError *error = [self checkSkanMethodAvailability:@"updatePostbackConversionValue:coarseValue:completionHandler:"];
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
    NSError *error = [self checkSkanMethodAvailability:@"updatePostbackConversionValue:coarseValue:lockWindow:completionHandler:"];
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

#pragma mark - Private

- (BOOL)checkSkanFrameworkAvailability:(NSError **)error {
#if !(TARGET_OS_TV)
    if (@available(iOS 14.0, *)) {
        if (NSClassFromString(@"SKAdNetwork") == nil) {
            NSString *strError = @"SKAdNetwork class not found. Check StoreKit.framework availability.";
            *error = [NSError errorWithDomain:ADJSkanDomain
                                         code:ADJSkanErrorFrameworkNotFound
                                     userInfo:@{ NSLocalizedDescriptionKey: strError }];
            return NO;
        }
        return YES;
    } else {
        NSString *strError = @"SKAdNetwork API not available on this iOS version";
        *error = [NSError errorWithDomain:ADJSkanDomain
                                     code:ADJSkanErrorOsVersionNotSupported
                                 userInfo:@{ NSLocalizedDescriptionKey: strError }];
        return NO;
    }
#else
    NSString *strError = @"SKAdNetwork is not supported on tvOS";
    *error = [NSError errorWithDomain:ADJSkanDomain
                                 code:ADJSkanErrorOsNotSupported
                             userInfo:@{ NSLocalizedDescriptionKey: strError }];
    return NO;
#endif
}

- (NSError *)checkSkanMethodAvailability:(NSString *)methodName {
    Class class = NSClassFromString(@"SKAdNetwork");
    SEL selector = NSSelectorFromString(methodName);

    if ([class respondsToSelector:selector] == NO) {
        NSString *strError = [NSString stringWithFormat:@"Implementation of %@ not found in SKAdNetwork", methodName];
        NSError *error = [NSError errorWithDomain:ADJSkanDomain
                                             code:ADJSkanErrorApiNotAvailable
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
        [conversionParams setObject:conversionValue.stringValue forKey:kSkanCallbackConversionValueKey];

        if (coarseValue != nil) {
            [conversionParams setObject:coarseValue forKey:kSkanCallbackCoarseValueKey];
        }
        if (lockWindow != nil) {
            NSString *val = (lockWindow.boolValue) ? @"true" : @"false";
            [conversionParams setObject:val forKey:kSkanCallbackLockWindowKey];
        }
        if (error != nil) {
            [conversionParams setObject:error.localizedDescription forKey:kSkanCallbackErrorKey];
        }

        // add client callback params dictionary and error objects if present
        [result setObject:conversionParams forKey:ADJSkanClientCallbackParamsKey];
        if (error != nil) {
            [result setObject:error forKey:ADJSkanClientCompletionErrorKey];
        }

        completion(result);
    });
}

- (void)writeskanRegisterCallTimestamp {
    NSDate *callTime = [NSDate date];
    [ADJUserDefaults saveSkadRegisterCallTimestamp:callTime];
}

- (NSDate *)skanRegisterCallTimestamp {
    return [ADJUserDefaults getSkadRegisterCallTimestamp];
}

- (void)writeLastSkanUpdateConversionValue:(NSNumber * _Nullable)conversionValue
                               coarseValue:(NSString * _Nullable)coarseValue
                                lockWindow:(NSNumber * _Nullable)lockWindow
                                 timestamp:(NSDate * _Nonnull)timestamp
                                    source:(NSString * _Nonnull)source {
    NSMutableDictionary *skanUpdateData = [NSMutableDictionary dictionary];
    if (conversionValue != nil) {
        [skanUpdateData setObject:conversionValue forKey:kSkanCallbackConversionValueKey];
    }
    if (coarseValue != nil) {
        [skanUpdateData setObject:coarseValue forKey:kSkanCallbackCoarseValueKey];
    }
    if (lockWindow != nil) {
        [skanUpdateData setObject:lockWindow forKey:kSkanCallbackLockWindowKey];
    }
    [skanUpdateData setObject:[ADJUtil formatDate:timestamp] forKey:@"timestamp"];
    [skanUpdateData setObject:source forKey:@"source"];

    [ADJUserDefaults saveLastSkanUpdateData:skanUpdateData];
}

- (NSString *)getSkanCoarseConversionValue:(NSString *)adjustCoarseValue
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
            *error = [NSError errorWithDomain:ADJSkanDomain
                                         code:ADJSkanErrorInvalidCoarseValue
                                     userInfo:@{ NSLocalizedDescriptionKey: strError }];
            return nil;
        }
    } else {
        NSString *strError = [NSString stringWithFormat:@"SKAdNetwork цoarse value is not available on this iOS version"];
        *error = [NSError errorWithDomain:ADJSkanDomain
                                     code:ADJSkanErrorApiNotAvailable
                                 userInfo:@{ NSLocalizedDescriptionKey: strError }];
        return nil;
    }
}

@end

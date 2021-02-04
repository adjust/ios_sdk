//
//  ADJAdjustFactory.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"
#import "ADJPackageHandler.h"

static id<ADJLogger> internalLogger = nil;

static double internalSessionInterval    = -1;
static double intervalSubsessionInterval = -1;
static double internalRequestTimeout = -1;
static NSTimeInterval internalTimerInterval = -1;
static NSTimeInterval intervalTimerStart = -1;
static ADJBackoffStrategy * packageHandlerBackoffStrategy = nil;
static ADJBackoffStrategy * sdkClickHandlerBackoffStrategy = nil;
static ADJBackoffStrategy * installSessionBackoffStrategy = nil;
static BOOL internalTesting = NO;
static NSTimeInterval internalMaxDelayStart = -1;
static BOOL internaliAdFrameworkEnabled = YES;
static BOOL internalAdServicesFrameworkEnabled = YES;

static NSString * internalBaseUrl = nil;
static NSString * internalGdprUrl = nil;
static NSString * internalSubscriptionUrl = nil;

@implementation ADJAdjustFactory

+ (id<ADJLogger>)logger {
    if (internalLogger == nil) {
        //  same instance of logger
        internalLogger = [[ADJLogger alloc] init];
    }
    return internalLogger;
}

+ (double)sessionInterval {
    if (internalSessionInterval < 0) {
        return 30 * 60;           // 30 minutes
    }
    return internalSessionInterval;
}

+ (double)subsessionInterval {
    if (intervalSubsessionInterval == -1) {
        return 1;                 // 1 second
    }
    return intervalSubsessionInterval;
}

+ (double)requestTimeout {
    if (internalRequestTimeout == -1) {
        return 60;                 // 60 second
    }
    return internalRequestTimeout;
}

+ (NSTimeInterval)timerInterval {
    if (internalTimerInterval < 0) {
        return 60;                // 1 minute
    }
    return internalTimerInterval;
}

+ (NSTimeInterval)timerStart {
    if (intervalTimerStart < 0) {
        return 60;                 // 1 minute
    }
    return intervalTimerStart;
}

+ (ADJBackoffStrategy *)packageHandlerBackoffStrategy {
    if (packageHandlerBackoffStrategy == nil) {
        return [ADJBackoffStrategy backoffStrategyWithType:ADJLongWait];
    }
    return packageHandlerBackoffStrategy;
}

+ (ADJBackoffStrategy *)sdkClickHandlerBackoffStrategy {
    if (sdkClickHandlerBackoffStrategy == nil) {
        return [ADJBackoffStrategy backoffStrategyWithType:ADJShortWait];
    }
    return sdkClickHandlerBackoffStrategy;
}

+ (ADJBackoffStrategy *)installSessionBackoffStrategy {
    if (installSessionBackoffStrategy == nil) {
        return [ADJBackoffStrategy backoffStrategyWithType:ADJShortWait];
    }
    return installSessionBackoffStrategy;
}

+ (BOOL)testing {
    return internalTesting;
}

+ (BOOL)iAdFrameworkEnabled {
    return internaliAdFrameworkEnabled;
}

+ (BOOL)adServicesFrameworkEnabled {
    return internalAdServicesFrameworkEnabled;
}

+ (NSTimeInterval)maxDelayStart {
    if (internalMaxDelayStart < 0) {
        return 10.0;               // 10 seconds
    }
    return internalMaxDelayStart;
}

+ (NSString *)baseUrl {
    return internalBaseUrl;
}

+ (NSString *)gdprUrl {
    return internalGdprUrl;
}

+ (NSString *)subscriptionUrl {
    return internalSubscriptionUrl;
}

+ (void)setLogger:(id<ADJLogger>)logger {
    internalLogger = logger;
}

+ (void)setSessionInterval:(double)sessionInterval {
    internalSessionInterval = sessionInterval;
}

+ (void)setSubsessionInterval:(double)subsessionInterval {
    intervalSubsessionInterval = subsessionInterval;
}

+ (void)setRequestTimeout:(double)requestTimeout {
    internalRequestTimeout = requestTimeout;
}

+ (void)setTimerInterval:(NSTimeInterval)timerInterval {
    internalTimerInterval = timerInterval;
}

+ (void)setTimerStart:(NSTimeInterval)timerStart {
    intervalTimerStart = timerStart;
}

+ (void)setPackageHandlerBackoffStrategy:(ADJBackoffStrategy *)backoffStrategy {
    packageHandlerBackoffStrategy = backoffStrategy;
}

+ (void)setSdkClickHandlerBackoffStrategy:(ADJBackoffStrategy *)backoffStrategy {
    sdkClickHandlerBackoffStrategy = backoffStrategy;
}

+ (void)setTesting:(BOOL)testing {
    internalTesting = testing;
}

+ (void)setiAdFrameworkEnabled:(BOOL)iAdFrameworkEnabled {
    internaliAdFrameworkEnabled = iAdFrameworkEnabled;
}

+ (void)setAdServicesFrameworkEnabled:(BOOL)adServicesFrameworkEnabled {
    internalAdServicesFrameworkEnabled = adServicesFrameworkEnabled;
}

+ (void)setMaxDelayStart:(NSTimeInterval)maxDelayStart {
    internalMaxDelayStart = maxDelayStart;
}

+ (void)setBaseUrl:(NSString *)baseUrl {
    internalBaseUrl = baseUrl;
}

+ (void)setGdprUrl:(NSString *)gdprUrl {
    internalGdprUrl = gdprUrl;
}

+ (void)setSubscriptionUrl:(NSString *)subscriptionUrl {
    internalSubscriptionUrl = subscriptionUrl;
}

+ (void)enableSigning {
    Class signerClass = NSClassFromString(@"ADJSigner");
    if (signerClass == nil) {
        return;
    }

    SEL enabledSEL = NSSelectorFromString(@"enableSigning");
    if (![signerClass respondsToSelector:enabledSEL]) {
        return;
    }

    IMP enableIMP = [signerClass methodForSelector:enabledSEL];
    if (!enableIMP) {
        return;
    }

    void (*enableFunc)(id, SEL) = (void *)enableIMP;

    enableFunc(signerClass, enabledSEL);
}

+ (void)disableSigning {
    Class signerClass = NSClassFromString(@"ADJSigner");
    if (signerClass == nil) {
        return;
    }

    SEL disableSEL = NSSelectorFromString(@"disableSigning");
    if (![signerClass respondsToSelector:disableSEL]) {
        return;
    }

    IMP disableIMP = [signerClass methodForSelector:disableSEL];
    if (!disableIMP) {
        return;
    }

    void (*disableFunc)(id, SEL) = (void *)disableIMP;

    disableFunc(signerClass, disableSEL);
}

+ (void)teardown:(BOOL)deleteState {
    if (deleteState) {
        [ADJActivityHandler deleteState];
        [ADJPackageHandler deleteState];
    }
    internalLogger = nil;

    internalSessionInterval = -1;
    intervalSubsessionInterval = -1;
    internalTimerInterval = -1;
    intervalTimerStart = -1;
    internalRequestTimeout = -1;
    packageHandlerBackoffStrategy = nil;
    sdkClickHandlerBackoffStrategy = nil;
    installSessionBackoffStrategy = nil;
    internalTesting = NO;
    internalMaxDelayStart = -1;
    internalBaseUrl = nil;
    internalGdprUrl = nil;
    internalSubscriptionUrl = nil;
    internaliAdFrameworkEnabled = YES;
    internalAdServicesFrameworkEnabled = YES;
}
@end

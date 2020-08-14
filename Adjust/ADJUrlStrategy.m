//
//  ADJUrlStrategy.m
//  Adjust
//
//  Created by Pedro S. on 11.08.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import "ADJUrlStrategy.h"
#import "Adjust.h"
#import "ADJAdjustFactory.h"

static NSString * const baseUrl = @"https://app.adjust.com";
static NSString * const gdprUrl = @"https://gdpr.adjust.com";
static NSString * const subscriptionUrl = @"https://subscription.adjust.com";

static NSString * const baseIndiaUrl = @"https://app.adjust.net.in";
static NSString * const gdprIndiaUrl = @"https://gdpr.adjust.net.in";
static NSString * const subscriptionIndiaUrl = @"https://subscription.adjust.net.in";

static NSString * const baseChinaUrl = @"https://app.adjust.world";
static NSString * const gdprChinaUrl = @"https://gdpr.adjust.world";
static NSString * const subscriptionChinaUrl = @"https://subscription.adjust.world";

static NSString * const randomIndiaIpAddressChoice = @"RandomIndiaIpAddress";
static NSString * const randomChinaIpAddressChoice = @"RandomChinaIpAddress";

static NSString * const baseIpToFormat = @"https://185.151.204.%u";

static int const numberIndiaIps = 10;
static int const shiftIndiaIp = 6;

static int const numberChinaIps = 4;
static int const shiftChinaIp = 40;

@interface ADJUrlStrategy ()

@property (nonatomic, copy) NSArray<NSString *> *baseUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *gdprUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *subscriptionUrlChoicesArray;

@property (nonatomic, copy) NSString *overridenBaseUrl;
@property (nonatomic, copy) NSString *overridenGdprUrl;
@property (nonatomic, copy) NSString *overridenSubscriptionUrl;

@property (nonatomic, copy) NSString *cachedIp;
@property (nonatomic, assign) BOOL wasLastAttemptSuccess;

@property (nonatomic, assign) NSUInteger choiceIndex;
@property (nonatomic, assign) NSUInteger startingChoiceIndex;

@end

@implementation ADJUrlStrategy

- (instancetype)initWithUrlStrategyInfo:(NSString *)urlStrategyInfo
                              extraPath:(NSString *)extraPath
{
    self = [super init];

    _extraPath = extraPath ?: @"";

    _baseUrlChoicesArray = [ADJUrlStrategy baseUrlChoicesWithWithUrlStrategyInfo:urlStrategyInfo];
    _gdprUrlChoicesArray = [ADJUrlStrategy gdprUrlChoicesWithWithUrlStrategyInfo:urlStrategyInfo];
    _subscriptionUrlChoicesArray = [ADJUrlStrategy
                                    subscriptionUrlChoicesWithWithUrlStrategyInfo:urlStrategyInfo];

    _overridenBaseUrl = [ADJAdjustFactory baseUrl];
    _overridenGdprUrl = [ADJAdjustFactory gdprUrl];
    _overridenSubscriptionUrl = [ADJAdjustFactory subscriptionUrl];

    _cachedIp = nil;
    _wasLastAttemptSuccess = NO;

    _choiceIndex = 0;
    _startingChoiceIndex = 0;

    return self;
}

+ (NSArray<NSString *> *)baseUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo
{
    if ([urlStrategyInfo isEqualToString:ADJIndiaUrlStrategy]) {
        return @[baseIndiaUrl, baseUrl, randomIndiaIpAddressChoice];
    } else if ([urlStrategyInfo isEqualToString:ADJChinaUrlStrategy]) {
        return @[baseChinaUrl, baseUrl, randomChinaIpAddressChoice];
    } else {
        return @[baseUrl, baseIndiaUrl, baseChinaUrl];
    }
}

+ (NSArray<NSString *> *)gdprUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo
{
    if ([urlStrategyInfo isEqualToString:ADJIndiaUrlStrategy]) {
        return @[gdprIndiaUrl, gdprUrl, randomIndiaIpAddressChoice];
    } else if ([urlStrategyInfo isEqualToString:ADJChinaUrlStrategy]) {
        return @[gdprChinaUrl, gdprUrl, randomChinaIpAddressChoice];
    } else {
        return @[gdprUrl, gdprIndiaUrl, gdprChinaUrl];
    }
}

+ (NSArray<NSString *> *)subscriptionUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo
{
    if ([urlStrategyInfo isEqualToString:ADJIndiaUrlStrategy]) {
        return @[subscriptionIndiaUrl, subscriptionUrl, randomIndiaIpAddressChoice];
    } else if ([urlStrategyInfo isEqualToString:ADJChinaUrlStrategy]) {
        return @[subscriptionChinaUrl, subscriptionUrl, randomChinaIpAddressChoice];
    } else {
        return @[subscriptionUrl, subscriptionIndiaUrl, subscriptionChinaUrl];
    }
}

- (NSString *)getUrlHostStringByPackageKind:(ADJActivityKind)activityKind {
    if (activityKind == ADJActivityKindGdpr) {
        if (self.overridenGdprUrl != nil) {
            self.cachedIp = nil;
            return self.overridenGdprUrl;
        } else {
            return [self getChoosenUrlByArray:self.gdprUrlChoicesArray];
        }
    } else if (activityKind == ADJActivityKindSubscription) {
        if (self.overridenSubscriptionUrl != nil) {
            self.cachedIp = nil;
            return self.overridenSubscriptionUrl;
        } else {
            return [self getChoosenUrlByArray:self.subscriptionUrlChoicesArray];
        }
    } else {
        if (self.overridenBaseUrl != nil) {
            self.cachedIp = nil;
            return self.overridenBaseUrl;
        } else {
            return [self getChoosenUrlByArray:self.baseUrlChoicesArray];
        }
    }
}

- (NSString *)getChoosenUrlByArray:(NSArray<NSString *>*)urlChoiceArray {
    NSString *choosenUrl = [urlChoiceArray objectAtIndex:self.choiceIndex];
    if (choosenUrl == randomIndiaIpAddressChoice) {
        if (!self.wasLastAttemptSuccess || self.cachedIp == nil) {
            self.cachedIp = [ADJUrlStrategy randomIpAddressWithBaseValue:numberIndiaIps
                                                              shiftValue:shiftIndiaIp];
        }
        return self.cachedIp;
    } else if (choosenUrl == randomChinaIpAddressChoice) {
        if (!self.wasLastAttemptSuccess || self.cachedIp == nil) {
            self.cachedIp = [ADJUrlStrategy randomIpAddressWithBaseValue:numberChinaIps
                                                              shiftValue:shiftChinaIp];
        }
        return self.cachedIp;
    } else {
        self.cachedIp = nil;
        return choosenUrl;
    }
}

+ (NSString *)randomIpAddressWithBaseValue:(int)range
                                shiftValue:(int)shiftValue
{
    uint32_t zeroToRange = arc4random_uniform(range);
    return [NSString stringWithFormat:baseIpToFormat, zeroToRange + shiftValue];
}

- (void)resetAfterSuccess {
    self.startingChoiceIndex = self.choiceIndex;
    self.wasLastAttemptSuccess = YES;
}

- (BOOL)shouldRetryAfterFailure {
    NSUInteger nextChoiceIndex = (self.choiceIndex + 1) % self.baseUrlChoicesArray.count;
    self.choiceIndex = nextChoiceIndex;

    self.wasLastAttemptSuccess = NO;

    BOOL nextChoiceHasNotReturnedToStartingChoice = self.choiceIndex != self.startingChoiceIndex;
    return nextChoiceHasNotReturnedToStartingChoice;
}

- (BOOL)usingIpAddress {
    return self.cachedIp != nil;
}

@end

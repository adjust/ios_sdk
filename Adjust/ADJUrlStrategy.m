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

static NSString * const baseUrlIndia = @"https://app.adjust.net.in";
static NSString * const gdprUrlIndia = @"https://gdpr.adjust.net.in";
static NSString * const subscritionUrlIndia = @"https://subscription.adjust.net.in";

static NSString * const baseUrlChina = @"https://app.adjust.world";
static NSString * const gdprUrlChina = @"https://gdpr.adjust.world";
static NSString * const subscritionUrlChina = @"https://subscription.adjust.world";

@interface ADJUrlStrategy ()

@property (nonatomic, copy) NSArray<NSString *> *baseUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *gdprUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *subscriptionUrlChoicesArray;

@property (nonatomic, copy) NSString *overridenBaseUrl;
@property (nonatomic, copy) NSString *overridenGdprUrl;
@property (nonatomic, copy) NSString *overridenSubscriptionUrl;

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

    _wasLastAttemptSuccess = NO;

    _choiceIndex = 0;
    _startingChoiceIndex = 0;

    return self;
}

+ (NSArray<NSString *> *)baseUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo
{
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[baseUrlIndia, baseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[baseUrlChina, baseUrl];
    } else {
        return @[baseUrl, baseUrlIndia, baseUrlChina];
    }
}

+ (NSArray<NSString *> *)gdprUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo
{
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[gdprUrlIndia, gdprUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[gdprUrlChina, gdprUrl];
    } else {
        return @[gdprUrl, gdprUrlIndia, gdprUrlChina];
    }
}

+ (NSArray<NSString *> *)subscriptionUrlChoicesWithWithUrlStrategyInfo:(NSString *)urlStrategyInfo
{
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[subscritionUrlIndia, subscriptionUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[subscritionUrlChina, subscriptionUrl];
    } else {
        return @[subscriptionUrl, subscritionUrlIndia, subscritionUrlChina];
    }
}

- (NSString *)getUrlHostStringByPackageKind:(ADJActivityKind)activityKind {
    if (activityKind == ADJActivityKindGdpr) {
        if (self.overridenGdprUrl != nil) {
            return self.overridenGdprUrl;
        } else {
            return [self.gdprUrlChoicesArray objectAtIndex:self.choiceIndex];
        }
    } else if (activityKind == ADJActivityKindSubscription) {
        if (self.overridenSubscriptionUrl != nil) {
            return self.overridenSubscriptionUrl;
        } else {
            return [self.subscriptionUrlChoicesArray objectAtIndex:self.choiceIndex];
        }
    } else {
        if (self.overridenBaseUrl != nil) {
            return self.overridenBaseUrl;
        } else {
            return [self.baseUrlChoicesArray objectAtIndex:self.choiceIndex];
        }
    }
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

@end

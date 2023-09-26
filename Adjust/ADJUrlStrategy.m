//
//  ADJUrlStrategy.m
//  Adjust
//
//  Created by Pedro S. on 11.08.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//analytics.adjust.com


#import "ADJUrlStrategy.h"
#import "Adjust.h"
#import "ADJAdjustFactory.h"

static NSString * const aBaseUrl = @"https://analytics.adjust.com";
static NSString * const cBaseUrl = @"https://consent.adjust.com";
static NSString * const gdprUrl = @"https://gdpr.adjust.com";
static NSString * const subscriptionUrl = @"https://subscription.adjust.com";
static NSString * const purchaseVerificationUrl = @"https://ssrv.adjust.com";

static NSString * const aBaseUrlIndia = @"https://analytics.adjust.net.in";
static NSString * const cBaseUrlIndia = @"https://consent.adjust.net.in";
static NSString * const gdprUrlIndia = @"https://gdpr.adjust.net.in";
static NSString * const subscriptionUrlIndia = @"https://subscription.adjust.net.in";
static NSString * const purchaseVerificationUrlIndia = @"https://ssrv.adjust.net.in";

static NSString * const aBaseUrlChina = @"https://analytics.adjust.world";
static NSString * const cBaseUrlChina = @"https://consent.adjust.world";
static NSString * const gdprUrlChina = @"https://gdpr.adjust.world";
static NSString * const subscriptionUrlChina = @"https://subscription.adjust.world";
static NSString * const purchaseVerificationUrlChina = @"https://ssrv.adjust.world";

static NSString * const aBaseUrlCn = @"https://analytics.adjust.cn";
static NSString * const cBaseUrlCn = @"https://consent.adjust.cn";
static NSString * const gdprUrlCn = @"https://gdpr.adjust.com"; // TODO: switch to .cn
static NSString * const subscriptionUrlCn = @"https://subscription.adjust.com"; // TODO: switch to .cn
static NSString * const purchaseVerificationUrlCn = @"https://ssrv.adjust.cn";

static NSString * const aBaseUrlEU = @"https://analytics.eu.adjust.com";
static NSString * const cBaseUrlEU = @"https://consent.eu.adjust.com";
static NSString * const gdprUrlEU = @"https://gdpr.eu.adjust.com";
static NSString * const subscriptionUrlEU = @"https://subscription.eu.adjust.com";
static NSString * const purchaseVerificationUrlEU = @"https://ssrv.eu.adjust.com";

static NSString * const aBaseUrlTR = @"https://analytics.tr.adjust.com";
static NSString * const cBaseUrlTR = @"https://consent.tr.adjust.com";
static NSString * const gdprUrlTR = @"https://gdpr.tr.adjust.com";
static NSString * const subscriptionUrlTR = @"https://subscription.tr.adjust.com";
static NSString * const purchaseVerificationUrlTR = @"https://ssrv.tr.adjust.com";

static NSString * const aBaseUrlUS = @"https://analytics.us.adjust.com";
static NSString * const cBaseUrlUS = @"https://consent.us.adjust.com";
static NSString * const gdprUrlUS = @"https://gdpr.us.adjust.com";
static NSString * const subscriptionUrlUS = @"https://subscription.us.adjust.com";
static NSString * const purchaseVerificationUrlUS = @"https://ssrv.us.adjust.com";

static NSString *const testServerCustomEndPointKey = @"test_server_custom_end_point";
static NSString *const testServerAdjustEndPointKey = @"test_server_adjust_end_point";


@interface ADJUrlStrategy ()

@property (nonatomic, copy) NSArray<NSString *> *aBaseUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *cBaseUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *gdprUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *subscriptionUrlChoicesArray;
@property (nonatomic, copy) NSArray<NSString *> *purchaseVerificationUrlChoicesArray;

@property (nonatomic, copy) NSString *urlOverwrite;

@property (nonatomic, assign) BOOL wasLastAttemptSuccess;

@property (nonatomic, assign) NSUInteger choiceIndex;
@property (nonatomic, assign) NSUInteger startingChoiceIndex;

@end

@implementation ADJUrlStrategy

- (instancetype)initWithUrlStrategyInfo:(NSString *)urlStrategyInfo
                              extraPath:(NSString *)extraPath {
    self = [super init];

    _extraPath = extraPath ?: @"";

    _aBaseUrlChoicesArray = [ADJUrlStrategy aBaseUrlChoicesWithUrlStrategyInfo:urlStrategyInfo];
    _cBaseUrlChoicesArray = [ADJUrlStrategy cBaseUrlChoicesWithUrlStrategyInfo:urlStrategyInfo];
    _gdprUrlChoicesArray = [ADJUrlStrategy gdprUrlChoicesWithUrlStrategyInfo:urlStrategyInfo];
    _subscriptionUrlChoicesArray = [ADJUrlStrategy
                                    subscriptionUrlChoicesWithUrlStrategyInfo:urlStrategyInfo];
    _purchaseVerificationUrlChoicesArray = [ADJUrlStrategy
                                            purchaseVerificationUrlChoicesWithUrlStrategyInfo:urlStrategyInfo];

    _urlOverwrite = [ADJAdjustFactory urlOverwrite];

    _wasLastAttemptSuccess = NO;
    _choiceIndex = 0;
    _startingChoiceIndex = 0;

    return self;
}

+ (NSArray<NSString *> *)aBaseUrlChoicesWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[aBaseUrlIndia, aBaseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[aBaseUrlChina, aBaseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCn]) {
        return @[aBaseUrlCn, aBaseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCnOnly]) {
        return @[aBaseUrlCn];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyEU]) {
        return @[aBaseUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyTR]) {
        return @[aBaseUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyUS]) {
        return @[aBaseUrlUS];
    } else {
        return @[aBaseUrl, aBaseUrlIndia, aBaseUrlChina];
    }
}

+ (NSArray<NSString *> *)cBaseUrlChoicesWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[cBaseUrlIndia, cBaseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[cBaseUrlChina, cBaseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCn]) {
        return @[cBaseUrlCn, cBaseUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyEU]) {
        return @[cBaseUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyTR]) {
        return @[cBaseUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyUS]) {
        return @[cBaseUrlUS];
    } else {
        return @[cBaseUrl, cBaseUrlIndia, cBaseUrlChina];
    }
}

+ (NSArray<NSString *> *)gdprUrlChoicesWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[gdprUrlIndia, gdprUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[gdprUrlChina, gdprUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCn]) {
        return @[gdprUrlCn, gdprUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCnOnly]) {
        return @[gdprUrlCn];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyEU]) {
        return @[gdprUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyTR]) {
        return @[gdprUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyUS]) {
        return @[gdprUrlUS];
    } else {
        return @[gdprUrl, gdprUrlIndia, gdprUrlChina];
    }
}

+ (NSArray<NSString *> *)subscriptionUrlChoicesWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[subscriptionUrlIndia, subscriptionUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[subscriptionUrlChina, subscriptionUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCn]) {
        return @[subscriptionUrlCn, subscriptionUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCnOnly]) {
        return @[subscriptionUrlCn];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyEU]) {
        return @[subscriptionUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyTR]) {
        return @[subscriptionUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyUS]) {
        return @[subscriptionUrlUS];
    } else {
        return @[subscriptionUrl, subscriptionUrlIndia, subscriptionUrlChina];
    }
}

+ (NSArray<NSString *> *)purchaseVerificationUrlChoicesWithUrlStrategyInfo:(NSString *)urlStrategyInfo {
    if ([urlStrategyInfo isEqualToString:ADJUrlStrategyIndia]) {
        return @[purchaseVerificationUrlIndia, purchaseVerificationUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyChina]) {
        return @[purchaseVerificationUrlChina, purchaseVerificationUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCn]) {
        return @[purchaseVerificationUrlCn, purchaseVerificationUrl];
    } else if ([urlStrategyInfo isEqualToString:ADJUrlStrategyCnOnly]) {
        return @[purchaseVerificationUrlCn];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyEU]) {
        return @[purchaseVerificationUrlEU];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyTR]) {
        return @[purchaseVerificationUrlTR];
    } else if ([urlStrategyInfo isEqualToString:ADJDataResidencyUS]) {
        return @[purchaseVerificationUrlUS];
    } else {
        return @[purchaseVerificationUrl, purchaseVerificationUrlIndia, purchaseVerificationUrlChina];
    }
}

- (nonnull NSString *)urlHostStringByPackageKind:(ADJActivityKind)activityKind
                        isConsentOrElseAnalytics:(BOOL)isConsentOrElseAnalytics
                            sendingParametersMut:(NSMutableDictionary *)sendingParametersMut
{
    NSString *_Nonnull urlByActivityKind =
        [self chooseUrlWithActivityKind:activityKind
               isConsentOrElseAnalytics:isConsentOrElseAnalytics];

    if (self.urlOverwrite != nil) {
        [sendingParametersMut setObject:urlByActivityKind
                                 forKey:testServerAdjustEndPointKey];

        return self.urlOverwrite;
    }

    return urlByActivityKind;
}
- (nonnull NSString *)chooseUrlWithActivityKind:(ADJActivityKind)activityKind
                      isConsentOrElseAnalytics:(BOOL)isConsentOrElseAnalytics
{
    if (activityKind == ADJActivityKindGdpr) {
        return [self.gdprUrlChoicesArray objectAtIndex:self.choiceIndex];
    }

    if (activityKind == ADJActivityKindSubscription) {
        return [self.subscriptionUrlChoicesArray objectAtIndex:self.choiceIndex];
    }

    if (activityKind == ADJActivityKindPurchaseVerification) {
        return [self.purchaseVerificationUrlChoicesArray objectAtIndex:self.choiceIndex];
    }

    if (isConsentOrElseAnalytics) {
        return [self.cBaseUrlChoicesArray objectAtIndex:self.choiceIndex];
    } else {
        return [self.aBaseUrlChoicesArray objectAtIndex:self.choiceIndex];
    }
}

- (void)resetAfterSuccess {
    self.startingChoiceIndex = self.choiceIndex;
    self.wasLastAttemptSuccess = YES;
}

- (BOOL)shouldRetryAfterFailure:(ADJActivityKind)activityKind {
    self.wasLastAttemptSuccess = NO;

    NSUInteger choiceListSize;
    if (activityKind == ADJActivityKindGdpr) {
        choiceListSize = [self.gdprUrlChoicesArray count];
    } else if (activityKind == ADJActivityKindSubscription) {
        choiceListSize = [self.subscriptionUrlChoicesArray count];
    } else if (activityKind == ADJActivityKindPurchaseVerification) {
        choiceListSize = [self.purchaseVerificationUrlChoicesArray count];
    } else {
        // cBaseUrlChoicesArray or aBaseUrlChoicesArray should be of equal size
        choiceListSize = [self.cBaseUrlChoicesArray count];
    }

    NSUInteger nextChoiceIndex = (self.choiceIndex + 1) % choiceListSize;
    self.choiceIndex = nextChoiceIndex;
    BOOL nextChoiceHasNotReturnedToStartingChoice = self.choiceIndex != self.startingChoiceIndex;

    return nextChoiceHasNotReturnedToStartingChoice;
}

@end

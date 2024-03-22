//
//  Adjust.m
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 23rd July 2013.
//  Copyright (c) 2012-2021 Adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJUserDefaults.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"
#import "ADJSKAdNetwork.h"

#if !__has_feature(objc_arc)
#error Adjust requires ARC
// See README for details: https://github.com/adjust/ios_sdk/blob/master/README.md
#endif

NSString * const ADJEnvironmentSandbox = @"sandbox";
NSString * const ADJEnvironmentProduction = @"production";

NSString * const ADJAdRevenueSourceAppLovinMAX = @"applovin_max_sdk";
NSString * const ADJAdRevenueSourceMopub = @"mopub";
NSString * const ADJAdRevenueSourceAdMob = @"admob_sdk";
NSString * const ADJAdRevenueSourceIronSource = @"ironsource_sdk";
NSString * const ADJAdRevenueSourceAdMost = @"admost_sdk";
NSString * const ADJAdRevenueSourceUnity = @"unity_sdk";
NSString * const ADJAdRevenueSourceHeliumChartboost = @"helium_chartboost_sdk";
NSString * const ADJAdRevenueSourcePublisher = @"publisher_sdk";
NSString * const ADJAdRevenueSourceTopOn = @"topon_sdk";
NSString * const ADJAdRevenueSourceADX = @"adx_sdk";
NSString * const ADJAdRevenueSourceTradplus = @"tradplus_sdk";

NSString * const ADJUrlStrategyIndia = @"UrlStrategyIndia";
NSString * const ADJUrlStrategyChina = @"UrlStrategyChina";
NSString * const ADJUrlStrategyCn = @"UrlStrategyCn";
NSString * const ADJUrlStrategyCnOnly = @"UrlStrategyCnOnly";

NSString * const ADJDataResidencyEU = @"DataResidencyEU";
NSString * const ADJDataResidencyTR = @"DataResidencyTR";
NSString * const ADJDataResidencyUS = @"DataResidencyUS";

@implementation AdjustTestOptions
@end

@interface Adjust()

@property (nonatomic, weak) id<ADJLogger> logger;

@property (nonatomic, strong) id<ADJActivityHandler> activityHandler;

@property (nonatomic, strong) ADJSavedPreLaunch *savedPreLaunch;

@property (nonatomic) AdjustResolvedDeeplinkBlock cachedResolvedDeeplinkBlock;

@end

@implementation Adjust

#pragma mark - Object lifecycle methods

static Adjust *defaultInstance = nil;
static dispatch_once_t onceToken = 0;

+ (instancetype)getInstance {
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

    self.activityHandler = nil;
    self.logger = [ADJAdjustFactory logger];
    self.savedPreLaunch = [[ADJSavedPreLaunch alloc] init];
    self.cachedResolvedDeeplinkBlock = nil;
    return self;
}

#pragma mark - Public static methods

+ (void)appDidLaunch:(ADJConfig *)adjustConfig {
    @synchronized (self) {
        [[Adjust getInstance] appDidLaunch:adjustConfig];
    }
}

+ (void)trackEvent:(ADJEvent *)event {
    @synchronized (self) {
        [[Adjust getInstance] trackEvent:event];
    }
}

+ (void)trackSubsessionStart {
    @synchronized (self) {
        [[Adjust getInstance] trackSubsessionStart];
    }
}

+ (void)trackSubsessionEnd {
    @synchronized (self) {
        [[Adjust getInstance] trackSubsessionEnd];
    }
}

+ (void)setEnabled:(BOOL)enabled {
    @synchronized (self) {
        Adjust *instance = [Adjust getInstance];
        [instance setEnabled:enabled];
    }
}

+ (BOOL)isEnabled {
    @synchronized (self) {
        return [[Adjust getInstance] isEnabled];
    }
}

+ (void)appWillOpenUrl:(NSURL *)url {
    @synchronized (self) {
        [[Adjust getInstance] appWillOpenUrl:[url copy]];
    }
}

+ (void)processDeeplink:(nonnull NSURL *)deeplink
      completionHandler:(void (^_Nonnull)(NSString * _Nonnull resolvedLink))completionHandler {
    @synchronized (self) {
        [[Adjust getInstance] processDeeplink:deeplink completionHandler:completionHandler];
    }
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    @synchronized (self) {
        [[Adjust getInstance] setDeviceToken:[deviceToken copy]];
    }
}

+ (void)setPushToken:(NSString *)pushToken {
    @synchronized (self) {
        [[Adjust getInstance] setPushToken:[pushToken copy]];
    }
}

+ (void)setOfflineMode:(BOOL)enabled {
    @synchronized (self) {
        [[Adjust getInstance] setOfflineMode:enabled];
    }
}

+ (void)sendAdWordsRequest {
    [[ADJAdjustFactory logger] warn:@"Send AdWords Request functionality removed"];
}

+ (NSString *)idfa {
    @synchronized (self) {
        return [[Adjust getInstance] idfa];
    }
}

+ (NSString *)idfv {
    @synchronized (self) {
        return [[Adjust getInstance] idfv];
    }
}

+ (NSString *)sdkVersion {
    @synchronized (self) {
        return [[Adjust getInstance] sdkVersion];
    }
}

+ (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    @synchronized (self) {
        return [[Adjust getInstance] convertUniversalLink:[url copy] scheme:[scheme copy]];
    }
}

+ (void)sendFirstPackages {
    @synchronized (self) {
        [[Adjust getInstance] sendFirstPackages];
    }
}

+ (void)addSessionCallbackParameter:(NSString *)key value:(NSString *)value {
    @synchronized (self) {
        [[Adjust getInstance] addSessionCallbackParameter:[key copy] value:[value copy]];
    }
}

+ (void)addSessionPartnerParameter:(NSString *)key value:(NSString *)value {
    @synchronized (self) {
        [[Adjust getInstance] addSessionPartnerParameter:[key copy] value:[value copy]];
    }
}

+ (void)removeSessionCallbackParameter:(NSString *)key {
    @synchronized (self) {
        [[Adjust getInstance] removeSessionCallbackParameter:[key copy]];
    }
}

+ (void)removeSessionPartnerParameter:(NSString *)key {
    @synchronized (self) {
        [[Adjust getInstance] removeSessionPartnerParameter:[key copy]];
    }
}

+ (void)resetSessionCallbackParameters {
    @synchronized (self) {
        [[Adjust getInstance] resetSessionCallbackParameters];
    }
}

+ (void)resetSessionPartnerParameters {
    @synchronized (self) {
        [[Adjust getInstance] resetSessionPartnerParameters];
    }
}

+ (void)gdprForgetMe {
    @synchronized (self) {
        [[Adjust getInstance] gdprForgetMe];
    }
}

+ (void)trackAdRevenue:(nonnull NSString *)source payload:(nonnull NSData *)payload {
    @synchronized (self) {
        [[Adjust getInstance] trackAdRevenue:[source copy] payload:[payload copy]];
    }
}

+ (void)disableThirdPartySharing {
    @synchronized (self) {
        [[Adjust getInstance] disableThirdPartySharing];
    }
}

+ (void)trackThirdPartySharing:(nonnull ADJThirdPartySharing *)thirdPartySharing {
    @synchronized (self) {
        [[Adjust getInstance] trackThirdPartySharing:thirdPartySharing];
    }
}

+ (void)trackMeasurementConsent:(BOOL)enabled {
    @synchronized (self) {
        [[Adjust getInstance] trackMeasurementConsent:enabled];
    }
}

+ (void)trackSubscription:(nonnull ADJSubscription *)subscription {
    @synchronized (self) {
        [[Adjust getInstance] trackSubscription:subscription];
    }
}

+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^_Nullable)(NSUInteger status))completion {
    @synchronized (self) {
        [[Adjust getInstance] requestTrackingAuthorizationWithCompletionHandler:completion];
    }
}

+ (int)appTrackingAuthorizationStatus {
    @synchronized (self) {
        return [[Adjust getInstance] appTrackingAuthorizationStatus];
    }
}

+ (void)updateConversionValue:(NSInteger)conversionValue {
    @synchronized (self) {
        [[Adjust getInstance] updateConversionValue:conversionValue];
    }
}

+ (void)updatePostbackConversionValue:(NSInteger)conversionValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    @synchronized (self) {
        [[Adjust getInstance] updatePostbackConversionValue:conversionValue
                                          completionHandler:completion];
    }
}

+ (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    @synchronized (self) {
        [[Adjust getInstance] updatePostbackConversionValue:fineValue
                                                coarseValue:coarseValue
                                          completionHandler:completion];
    }
}

+ (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                           lockWindow:(BOOL)lockWindow
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    @synchronized (self) {
        [[Adjust getInstance] updatePostbackConversionValue:fineValue
                                                coarseValue:coarseValue
                                                 lockWindow:lockWindow
                                          completionHandler:completion];
    }
}

+ (void)trackAdRevenue:(ADJAdRevenue *)adRevenue {
    @synchronized (self) {
        [[Adjust getInstance] trackAdRevenue:adRevenue];
    }
}

+ (ADJAttribution *)attribution {
    @synchronized (self) {
        return [[Adjust getInstance] attribution];
    }
}

+ (NSString *)adid {
    @synchronized (self) {
        return [[Adjust getInstance] adid];
    }
}

+ (void)checkForNewAttStatus {
    @synchronized (self) {
        [[Adjust getInstance] checkForNewAttStatus];
    }
}

+ (NSURL *)lastDeeplink {
    @synchronized (self) {
        return [[Adjust getInstance] lastDeeplink];
    }
}

+ (void)verifyPurchase:(nonnull ADJPurchase *)purchase
     completionHandler:(void (^_Nonnull)(ADJPurchaseVerificationResult * _Nonnull verificationResult))completionHandler {
    @synchronized (self) {
        [[Adjust getInstance] verifyPurchase:purchase completionHandler:completionHandler];
    }
}

+ (void)setTestOptions:(AdjustTestOptions *)testOptions {
    @synchronized (self) {
        if (testOptions.teardown) {
            if (defaultInstance != nil) {
                [defaultInstance teardown];
            }
            defaultInstance = nil;
            onceToken = 0;
            [ADJAdjustFactory teardown:testOptions.deleteState];
        }
        [[Adjust getInstance] setTestOptions:(AdjustTestOptions *)testOptions];
    }
}

#pragma mark - Public instance methods

- (void)appDidLaunch:(ADJConfig *)adjustConfig {
    if (self.activityHandler != nil) {
        [self.logger error:@"Adjust already initialized"];
        return;
    }
    self.activityHandler = [[ADJActivityHandler alloc] initWithConfig:adjustConfig
                                                       savedPreLaunch:self.savedPreLaunch
                                           deeplinkResolutionCallback:self.cachedResolvedDeeplinkBlock];
}

- (void)trackEvent:(ADJEvent *)event {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackEvent:event];
}

- (void)trackSubsessionStart {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler applicationDidBecomeActive];
}

- (void)trackSubsessionEnd {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler applicationWillResignActive];
}

- (void)setEnabled:(BOOL)enabled {
    self.savedPreLaunch.enabled = [NSNumber numberWithBool:enabled];

    if ([self checkActivityHandler:enabled
                       trueMessage:@"enabled mode"
                      falseMessage:@"disabled mode"]) {
        [self.activityHandler setEnabled:enabled];
    }
}

- (BOOL)isEnabled {
    if (![self checkActivityHandler]) {
        return [self isInstanceEnabled];
    }
    return [self.activityHandler isEnabled];
}

- (void)appWillOpenUrl:(NSURL *)url {
    [ADJUserDefaults cacheDeeplinkUrl:url];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADJUserDefaults saveDeeplinkUrl:url andClickTime:clickTime];
        return;
    }
    [self.activityHandler appWillOpenUrl:url withClickTime:clickTime];
}

- (void)processDeeplink:(nonnull NSURL *)deeplink
      completionHandler:(void (^_Nonnull)(NSString * _Nonnull resolvedLink))completionHandler {
    // if resolution result is not wanted, fallback to default method
    if (completionHandler == nil) {
        [self appWillOpenUrl:deeplink];
        return;
    }
    // if deep link processing is triggered prior to SDK being initialized
    [ADJUserDefaults cacheDeeplinkUrl:deeplink];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADJUserDefaults saveDeeplinkUrl:deeplink andClickTime:clickTime];
        self.cachedResolvedDeeplinkBlock = completionHandler;
        return;
    }
    // if deep link processing was triggered with SDK being initialized
    [self.activityHandler processDeeplink:deeplink
                                clickTime:clickTime
                        completionHandler:completionHandler];
}

- (void)setDeviceToken:(NSData *)deviceToken {
    [ADJUserDefaults savePushTokenData:deviceToken];

    if ([self checkActivityHandler:@"device token"]) {
        if (self.activityHandler.isEnabled) {
            [self.activityHandler setDeviceToken:deviceToken];
        }
    }
}

- (void)setPushToken:(NSString *)pushToken {
    [ADJUserDefaults savePushTokenString:pushToken];

    if ([self checkActivityHandler:@"device token"]) {
        if (self.activityHandler.isEnabled) {
            [self.activityHandler setPushToken:pushToken];
        }
    }
}

- (void)setOfflineMode:(BOOL)enabled {
    if (![self checkActivityHandler:enabled
                        trueMessage:@"offline mode"
                       falseMessage:@"online mode"]) {
        self.savedPreLaunch.offline = enabled;
    } else {
        [self.activityHandler setOfflineMode:enabled];
    }
}

- (NSString *)idfa {
    return [ADJUtil idfa];
}

- (NSString *)idfv {
    return [ADJUtil idfv];
}

- (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    return [ADJUtil convertUniversalLink:url scheme:scheme];
}

- (void)sendFirstPackages {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler sendFirstPackages];
}

- (void)addSessionCallbackParameter:(NSString *)key value:(NSString *)value {
    if ([self checkActivityHandler:@"adding session callback parameter"]) {
        [self.activityHandler addSessionCallbackParameter:key value:value];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler addSessionCallbackParameterI:activityHandler key:key value:value];
    }];
}

- (void)addSessionPartnerParameter:(NSString *)key value:(NSString *)value {
    if ([self checkActivityHandler:@"adding session partner parameter"]) {
        [self.activityHandler addSessionPartnerParameter:key value:value];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler addSessionPartnerParameterI:activityHandler key:key value:value];
    }];
}

- (void)removeSessionCallbackParameter:(NSString *)key {
    if ([self checkActivityHandler:@"removing session callback parameter"]) {
        [self.activityHandler removeSessionCallbackParameter:key];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler removeSessionCallbackParameterI:activityHandler key:key];
    }];
}

- (void)removeSessionPartnerParameter:(NSString *)key {
    if ([self checkActivityHandler:@"removing session partner parameter"]) {
        [self.activityHandler removeSessionPartnerParameter:key];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler removeSessionPartnerParameterI:activityHandler key:key];
    }];
}

- (void)resetSessionCallbackParameters {
    if ([self checkActivityHandler:@"resetting session callback parameters"]) {
        [self.activityHandler resetSessionCallbackParameters];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler resetSessionCallbackParametersI:activityHandler];
    }];
}

- (void)resetSessionPartnerParameters {
    if ([self checkActivityHandler:@"resetting session partner parameters"]) {
        [self.activityHandler resetSessionPartnerParameters];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler resetSessionPartnerParametersI:activityHandler];
    }];
}

- (void)gdprForgetMe {
    [ADJUserDefaults setGdprForgetMe];
    if ([self checkActivityHandler:@"GDPR forget me"]) {
        if (self.activityHandler.isEnabled) {
            [self.activityHandler setGdprForgetMe];
        }
    }
}

- (void)trackAdRevenue:(NSString *)source payload:(NSData *)payload {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackAdRevenue:source payload:payload];
}

- (void)disableThirdPartySharing {
    if (![self checkActivityHandler:@"disable third party sharing"]) {
        [ADJUserDefaults setDisableThirdPartySharing];
        return;
    }
    [self.activityHandler disableThirdPartySharing];
}

- (void)trackThirdPartySharing:(nonnull ADJThirdPartySharing *)thirdPartySharing {
    if (![self checkActivityHandler]) {
        if (self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray == nil) {
            self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray =
                [[NSMutableArray alloc] init];
        }
        [self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray addObject:thirdPartySharing];
        return;
    }
    [self.activityHandler trackThirdPartySharing:thirdPartySharing];
}

- (void)trackMeasurementConsent:(BOOL)enabled {
    if (![self checkActivityHandler]) {
        self.savedPreLaunch.lastMeasurementConsentTracked = [NSNumber numberWithBool:enabled];
        return;
    }
    [self.activityHandler trackMeasurementConsent:enabled];
}

- (void)trackSubscription:(ADJSubscription *)subscription {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackSubscription:subscription];
}

- (void)requestTrackingAuthorizationWithCompletionHandler:(void (^_Nullable)(NSUInteger status))completion {
    [ADJUtil requestTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
        if (completion) {
            completion(status);
        }
        if (![self checkActivityHandler:@"request Tracking Authorization"]) {
            return;
        }
        [self.activityHandler updateAttStatusFromUserCallback:(int)status];
    }];
}

- (int)appTrackingAuthorizationStatus {
    return [ADJUtil attStatus];
}

- (void)updateConversionValue:(NSInteger)conversionValue {
    [[ADJSKAdNetwork getInstance] updateConversionValue:conversionValue];
}

- (void)updatePostbackConversionValue:(NSInteger)conversionValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADJSKAdNetwork getInstance] updatePostbackConversionValue:conversionValue
                                              completionHandler:completion];
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADJSKAdNetwork getInstance] updatePostbackConversionValue:fineValue
                                                    coarseValue:coarseValue
                                              completionHandler:completion];
}

- (void)updatePostbackConversionValue:(NSInteger)fineValue
                          coarseValue:(nonnull NSString *)coarseValue
                           lockWindow:(BOOL)lockWindow
                    completionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADJSKAdNetwork getInstance] updatePostbackConversionValue:fineValue
                                                    coarseValue:coarseValue
                                                     lockWindow:lockWindow
                                              completionHandler:completion];
}

- (void)trackAdRevenue:(ADJAdRevenue *)adRevenue {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackAdRevenue:adRevenue];
}

- (ADJAttribution *)attribution {
    if (![self checkActivityHandler]) {
        return nil;
    }
    return [self.activityHandler attribution];
}

- (NSString *)adid {
    if (![self checkActivityHandler]) {
        return nil;
    }
    return [self.activityHandler adid];
}

- (NSString *)sdkVersion {
    return [ADJUtil sdkVersion];
}

- (void)checkForNewAttStatus {
    if (![self checkActivityHandler]) {
        return;
    }
    
    [self.activityHandler checkForNewAttStatus];
}

- (NSURL *)lastDeeplink {
    return [ADJUserDefaults getCachedDeeplinkUrl];
}

- (void)verifyPurchase:(nonnull ADJPurchase *)purchase
     completionHandler:(void (^_Nonnull)(ADJPurchaseVerificationResult * _Nonnull verificationResult))completionHandler {
    if (![self checkActivityHandler]) {
        if (completionHandler != nil) {
            ADJPurchaseVerificationResult *result = [[ADJPurchaseVerificationResult alloc] init];
            result.verificationStatus = @"not_verified";
            result.code = 100;
            result.message = @"SDK needs to be initialized before making purchase verification request";
            completionHandler(result);
        }
        return;
    }
    [self.activityHandler verifyPurchase:purchase completionHandler:completionHandler];
}

- (void)teardown {
    if (self.activityHandler == nil) {
        [self.logger error:@"Adjust already down or not initialized"];
        return;
    }
    [self.activityHandler teardown];
    self.activityHandler = nil;
}

- (void)setTestOptions:(AdjustTestOptions *)testOptions {
    if (testOptions.extraPath != nil) {
        self.savedPreLaunch.extraPath = testOptions.extraPath;
    }
    if (testOptions.urlOverwrite != nil) {
        [ADJAdjustFactory setUrlOverwrite:testOptions.urlOverwrite];
    }
    if (testOptions.timerIntervalInMilliseconds != nil) {
        NSTimeInterval timerIntervalInSeconds = [testOptions.timerIntervalInMilliseconds intValue] / 1000.0;
        [ADJAdjustFactory setTimerInterval:timerIntervalInSeconds];
    }
    if (testOptions.timerStartInMilliseconds != nil) {
        NSTimeInterval timerStartInSeconds = [testOptions.timerStartInMilliseconds intValue] / 1000.0;
        [ADJAdjustFactory setTimerStart:timerStartInSeconds];
    }
    if (testOptions.sessionIntervalInMilliseconds != nil) {
        NSTimeInterval sessionIntervalInSeconds = [testOptions.sessionIntervalInMilliseconds intValue] / 1000.0;
        [ADJAdjustFactory setSessionInterval:sessionIntervalInSeconds];
    }
    if (testOptions.subsessionIntervalInMilliseconds != nil) {
        NSTimeInterval subsessionIntervalInSeconds = [testOptions.subsessionIntervalInMilliseconds intValue] / 1000.0;
        [ADJAdjustFactory setSubsessionInterval:subsessionIntervalInSeconds];
    }
    if (testOptions.attStatusInt != nil) {
        [ADJAdjustFactory setAttStatus:testOptions.attStatusInt];
    }
    if (testOptions.idfa != nil) {
        [ADJAdjustFactory setIdfa:testOptions.idfa];
    }
    if (testOptions.noBackoffWait) {
        [ADJAdjustFactory setSdkClickHandlerBackoffStrategy:[ADJBackoffStrategy backoffStrategyWithType:ADJNoWait]];
        [ADJAdjustFactory setPackageHandlerBackoffStrategy:[ADJBackoffStrategy backoffStrategyWithType:ADJNoWait]];
    }
    if (testOptions.enableSigning) {
        [ADJAdjustFactory enableSigning];
    }
    if (testOptions.disableSigning) {
        [ADJAdjustFactory disableSigning];
    }

    [ADJAdjustFactory setAdServicesFrameworkEnabled:testOptions.adServicesFrameworkEnabled];
}

#pragma mark - Private & helper methods

- (BOOL)checkActivityHandler {
    return [self checkActivityHandler:nil];
}

- (BOOL)checkActivityHandler:(BOOL)status
                 trueMessage:(NSString *)trueMessage
                falseMessage:(NSString *)falseMessage {
    if (status) {
        return [self checkActivityHandler:trueMessage];
    } else {
        return [self checkActivityHandler:falseMessage];
    }
}

- (BOOL)checkActivityHandler:(NSString *)savedForLaunchWarningSuffixMessage {
    if (self.activityHandler == nil) {
        if (savedForLaunchWarningSuffixMessage != nil) {
            [self.logger warn:@"Adjust not initialized, but %@ saved for launch", savedForLaunchWarningSuffixMessage];
        } else {
            [self.logger error:@"Please initialize Adjust by calling 'appDidLaunch' before"];
        }
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)isInstanceEnabled {
    return self.savedPreLaunch.enabled == nil || self.savedPreLaunch.enabled;
}

@end

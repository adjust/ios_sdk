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

+ (void)initSdk:(ADJConfig *)adjustConfig {
    @synchronized (self) {
        [[Adjust getInstance] initSdk:adjustConfig];
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

+ (void)enable {
    @synchronized (self) {
        Adjust *instance = [Adjust getInstance];
        [instance enable];
    }
}

+ (void)disable {
    @synchronized (self) {
        Adjust *instance = [Adjust getInstance];
        [instance disable];
    }
}

+ (void)isEnabledWithCallback:(nonnull id<ADJIsEnabledCallback>)isEnabledCallback {
    @synchronized (self) {
        [[Adjust getInstance] isEnabledWithCallback:isEnabledCallback];
    }
}

+ (void)processDeeplink:(NSURL *)deeplink {
    @synchronized (self) {
        [[Adjust getInstance] processDeeplink:[deeplink copy]];
    }
}

+ (void)processAndResolveDeeplink:(nonnull NSURL *)deeplink
            withCompletionHandler:(void (^_Nonnull)(NSString * _Nonnull resolvedLink))completion {
    @synchronized (self) {
        [[Adjust getInstance] processAndResolveDeeplink:deeplink
                                  withCompletionHandler:completion];
    }
}

+ (void)setPushToken:(NSData *)pushToken {
    @synchronized (self) {
        [[Adjust getInstance] setPushToken:[pushToken copy]];
    }
}

+ (void)setPushTokenAsString:(NSString *)pushToken {
    @synchronized (self) {
        [[Adjust getInstance] setPushTokenAsString:[pushToken copy]];
    }
}

+ (void)switchToOfflineMode {
    @synchronized (self) {
        [[Adjust getInstance] switchToOfflineMode];
    }
}

+ (void)switchBackToOnlineMode {
    @synchronized (self) {
        [[Adjust getInstance] switchBackToOnlineMode];
    }
}

+ (void)idfaWithCallback:(nonnull id<ADJIdfaCallback>)idfaCallback {
    @synchronized (self) {
        [[Adjust getInstance] idfaWithCallback:idfaCallback];
    }
}

+ (void)idfvWithCallback:(nonnull id<ADJIdfvCallback>)idfvCallback {
    @synchronized (self) {
        [[Adjust getInstance] idfvWithCallback:idfvCallback];
    }
}

+ (void)sdkVersionWithCallback:(nonnull id<ADJSdkVersionCallback>)sdkVersionCallback {
    @synchronized (self) {
        [[Adjust getInstance] sdkVersionWithCallback:sdkVersionCallback];
    }
}

+ (NSURL *)convertUniversalLink:(NSURL *)url withScheme:(NSString *)scheme {
    @synchronized (self) {
        return [[Adjust getInstance] convertUniversalLink:[url copy] withScheme:[scheme copy]];
    }
}

+ (void)addGlobalCallbackParameter:(NSString *)param forKey:(NSString *)key {
    @synchronized (self) {
        [[Adjust getInstance] addGlobalCallbackParameter:[param copy] forKey:[key copy]];
    }
}

+ (void)addGlobalPartnerParameter:(NSString *)param forKey:(NSString *)key {
    @synchronized (self) {
        [[Adjust getInstance] addGlobalPartnerParameter:[param copy] forKey:[key copy]];
    }
}

+ (void)removeGlobalCallbackParameterForKey:(NSString *)key {
    @synchronized (self) {
        [[Adjust getInstance] removeGlobalCallbackParameterForKey:[key copy]];
    }
}

+ (void)removeGlobalPartnerParameterForKey:(NSString *)key {
    @synchronized (self) {
        [[Adjust getInstance] removeGlobalPartnerParameterForKey:[key copy]];
    }
}

+ (void)removeGlobalCallbackParameters {
    @synchronized (self) {
        [[Adjust getInstance] removeGlobalCallbackParameters];
    }
}

+ (void)removeGlobalPartnerParameters {
    @synchronized (self) {
        [[Adjust getInstance] removeGlobalPartnerParameters];
    }
}

+ (void)gdprForgetMe {
    @synchronized (self) {
        [[Adjust getInstance] gdprForgetMe];
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

+ (void)trackAppStoreSubscription:(nonnull ADJAppStoreSubscription *)subscription {
    @synchronized (self) {
        [[Adjust getInstance] trackAppStoreSubscription:subscription];
    }
}

+ (void)requestAppTrackingAuthorizationWithCompletionHandler:(void (^_Nullable)(NSUInteger status))completion {
    @synchronized (self) {
        [[Adjust getInstance] requestAppTrackingAuthorizationWithCompletionHandler:completion];
    }
}

+ (int)appTrackingAuthorizationStatus {
    @synchronized (self) {
        return [[Adjust getInstance] appTrackingAuthorizationStatus];
    }
}

+ (void)updateSkanConversionValue:(NSInteger)conversionValue
                      coarseValue:(nullable NSString *)coarseValue
                       lockWindow:(nullable NSNumber *)lockWindow
            withCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    @synchronized (self) {
        [[Adjust getInstance] updateSkanConversionValue:conversionValue
                                            coarseValue:coarseValue
                                             lockWindow:lockWindow
                                  withCompletionHandler:completion];
    }
}

+ (void)trackAdRevenue:(ADJAdRevenue *)adRevenue {
    @synchronized (self) {
        [[Adjust getInstance] trackAdRevenue:adRevenue];
    }
}

+ (void)attributionWithCallback:(nonnull id<ADJAttributionCallback>)attributionCallback {
    @synchronized (self) {
        [[Adjust getInstance] attributionWithCallback:attributionCallback];
    }
}

+ (void)adidWithCallback:(id<ADJAdidCallback>)adidCallback {
    @synchronized (self) {
        [[Adjust getInstance] adidWithCallback:adidCallback];
    }
}

+ (void)lastDeeplinkWithCallback:(nonnull id<ADJLastDeeplinkCallback>)lastDeeplinkCallback {
    @synchronized (self) {
        [[Adjust getInstance] lastDeeplinkWithCallback:lastDeeplinkCallback];
    }
}

+ (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(void (^_Nonnull)(ADJPurchaseVerificationResult * _Nonnull verificationResult))completion {
    @synchronized (self) {
        [[Adjust getInstance] verifyAppStorePurchase:purchase
                               withCompletionHandler:completion];
    }
}

+ (void)enableCoppaCompliance {
    [[Adjust getInstance] enableCoppaCompliance];
}

+ (void)disableCoppaCompliance {
    [[Adjust getInstance] disableCoppaCompliance];
}

+ (void)verifyAndTrackAppStorePurchase:(nonnull ADJEvent *)event
                 withCompletionHandler:(void (^_Nonnull)(ADJPurchaseVerificationResult * _Nonnull verificationResult))completion {
    @synchronized (self) {
        [[Adjust getInstance] verifyAndTrackAppStorePurchase:event
                                       withCompletionHandler:completion];
    }
}

+ (void)setTestOptions:(NSDictionary *)testOptions {
    @synchronized (self) {
        if ([testOptions[@"teardown"] boolValue]) {
            if (defaultInstance != nil) {
                [defaultInstance teardown];
            }
            defaultInstance = nil;
            onceToken = 0;
            [ADJAdjustFactory teardown:[testOptions[@"deleteState"] boolValue]];
        }
        [[Adjust getInstance] setTestOptions:testOptions];
    }
}

#pragma mark - Public instance methods

- (void)initSdk:(ADJConfig *)adjustConfig {
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

- (void)enable {
    self.savedPreLaunch.enabled = @YES;

    if ([self checkActivityHandler:YES
                       trueMessage:@"enabled mode"
                      falseMessage:@"disabled mode"]) {
        [self.activityHandler setEnabled:YES];
    }
}

- (void)disable {
    self.savedPreLaunch.enabled = @NO;

    if ([self checkActivityHandler:NO
                       trueMessage:@"enabled mode"
                      falseMessage:@"disabled mode"]) {
        [self.activityHandler setEnabled:NO];
    }
}

- (void)isEnabledWithCallback:(nonnull id<ADJIsEnabledCallback>)isEnabledCallback {
    if (![self checkActivityHandler]) {
        [ADJUtil isEnabledFromActivityStateFile:^(BOOL isEnabled) {
            [ADJUtil launchInMainThread:^{
                [isEnabledCallback didReadWithIsEnabled:isEnabled];
            }];
        }];
        return;
    }
    [self.activityHandler isEnabledWithCallback:isEnabledCallback];
}

- (void)processDeeplink:(NSURL *)deeplink {
    [ADJUserDefaults cacheDeeplinkUrl:deeplink];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADJUserDefaults saveDeeplinkUrl:deeplink andClickTime:clickTime];
        return;
    }
    [self.activityHandler processDeeplink:deeplink withClickTime:clickTime];
}

- (void)processAndResolveDeeplink:(nonnull NSURL *)deeplink
            withCompletionHandler:(void (^_Nonnull)(NSString * _Nonnull resolvedLink))completion {
    // if resolution result is not wanted, fallback to default method
    if (completion == nil) {
        [self processDeeplink:deeplink];
        return;
    }
    // if deep link processing is triggered prior to SDK being initialized
    [ADJUserDefaults cacheDeeplinkUrl:deeplink];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADJUserDefaults saveDeeplinkUrl:deeplink andClickTime:clickTime];
        self.cachedResolvedDeeplinkBlock = completion;
        return;
    }
    // if deep link processing was triggered with SDK being initialized
    [self.activityHandler processAndResolveDeeplink:deeplink
                                          clickTime:clickTime
                              withCompletionHandler:completion];
}

- (void)setPushToken:(NSData *)pushToken {
    [ADJUserDefaults savePushTokenData:pushToken];

    if ([self checkActivityHandler:@"push token"]) {
        [self.activityHandler setPushTokenData:pushToken];
    }
}

- (void)setPushTokenAsString:(NSString *)pushToken {
    [ADJUserDefaults savePushTokenString:pushToken];

    if ([self checkActivityHandler:@"push token as string"]) {
        [self.activityHandler setPushTokenString:pushToken];
    }
}

- (void)switchToOfflineMode {
    if (![self checkActivityHandler:YES
                        trueMessage:@"offline mode"
                       falseMessage:@"online mode"]) {
        self.savedPreLaunch.offline = YES;
    } else {
        [self.activityHandler setOfflineMode:YES];
    }
}

- (void)switchBackToOnlineMode {
    if (![self checkActivityHandler:NO
                        trueMessage:@"offline mode"
                       falseMessage:@"online mode"]) {
        self.savedPreLaunch.offline = NO;
    } else {
        [self.activityHandler setOfflineMode:NO];
    }
}

- (void)idfaWithCallback:(nonnull id<ADJIdfaCallback>)idfaCallback {
    if (idfaCallback == nil) {
        [self.logger error:@"Callback for getting IDFA can't be null"];
        return;
    }

    NSString *idfa = [ADJUtil idfa];
    [ADJUtil launchInMainThread:^{
        [idfaCallback didReadWithIdfa:idfa];
    }];
}

- (void)idfvWithCallback:(nonnull id<ADJIdfvCallback>)idfvCallback {
    if (idfvCallback == nil) {
        [self.logger error:@"Callback for getting IDFV can't be null"];
        return;
    }

    NSString *idfv = [ADJUtil idfv];
    [ADJUtil launchInMainThread:^{
        [idfvCallback didReadWithIdfv:idfv];
    }];
}

- (NSURL *)convertUniversalLink:(NSURL *)url withScheme:(NSString *)scheme {
    return [ADJUtil convertUniversalLink:url withScheme:scheme];
}

- (void)addGlobalCallbackParameter:(nonnull NSString *)param forKey:(nonnull NSString *)key {
    if ([self checkActivityHandler:@"adding global callback parameter"]) {
        [self.activityHandler addGlobalCallbackParameter:param forKey:key];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler addGlobalCallbackParameterI:activityHandler param:param forKey:key];
    }];
}

- (void)addGlobalPartnerParameter:(nonnull NSString *)param forKey:(nonnull NSString *)key {
    if ([self checkActivityHandler:@"adding global partner parameter"]) {
        [self.activityHandler addGlobalPartnerParameter:param forKey:key];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler addGlobalPartnerParameterI:activityHandler param:param forKey:key];
    }];
}

- (void)removeGlobalCallbackParameterForKey:(nonnull NSString *)key {

    if ([self checkActivityHandler:@"removing global callback parameter"]) {
        [self.activityHandler removeGlobalCallbackParameterForKey:key];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler removeGlobalCallbackParameterI:activityHandler forKey:key];
    }];

}

- (void)removeGlobalPartnerParameterForKey:(nonnull NSString *)key {
    if ([self checkActivityHandler:@"removing global partner parameter"]) {
        [self.activityHandler removeGlobalPartnerParameterForKey:key];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler removeGlobalPartnerParameterI:activityHandler forKey:key];
    }];

}

- (void)removeGlobalCallbackParameters {

    if ([self checkActivityHandler:@"removing all global callback parameters"]) {
        [self.activityHandler removeGlobalCallbackParameters];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler removeGlobalCallbackParametersI:activityHandler];
    }];

}

- (void)removeGlobalPartnerParameters {
    if ([self checkActivityHandler:@"removing all global partner parameters"]) {
        [self.activityHandler removeGlobalPartnerParameters];
        return;
    }
    if (self.savedPreLaunch.preLaunchActionsArray == nil) {
        self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
    }
    [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
        [activityHandler removeGlobalPartnerParametersI:activityHandler];
    }];
}

- (void)gdprForgetMe {
    [ADJUserDefaults setGdprForgetMe];
    if ([self checkActivityHandler:@"GDPR forget me"]) {
        [self.activityHandler setGdprForgetMe];
    }
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

- (void)trackAppStoreSubscription:(ADJAppStoreSubscription *)subscription {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackAppStoreSubscription:subscription];
}

- (void)requestAppTrackingAuthorizationWithCompletionHandler:(void (^_Nullable)(NSUInteger status))completion {
    [ADJUtil requestAppTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
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

- (void)updateSkanConversionValue:(NSInteger)conversionValue
                      coarseValue:(nullable NSString *)coarseValue
                       lockWindow:(nullable NSNumber *)lockWindow
            withCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADJSKAdNetwork getInstance] updateConversionValue:conversionValue
                                            coarseValue:coarseValue
                                             lockWindow:lockWindow
                                  withCompletionHandler:completion];
}

- (void)trackAdRevenue:(ADJAdRevenue *)adRevenue {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackAdRevenue:adRevenue];
}

- (void)attributionWithCallback:(nonnull id<ADJAttributionCallback>)attributionCallback {
    if (attributionCallback == nil) {
        [self.logger error:@"Callback for getting attribution can't be null"];
        return;
    }

    if (![self checkActivityHandler]) {
        if (self.savedPreLaunch.cachedAttributionReadCallbacksArray == nil) {
            self.savedPreLaunch.cachedAttributionReadCallbacksArray = [NSMutableArray array];
        }

        [self.savedPreLaunch.cachedAttributionReadCallbacksArray addObject:attributionCallback];
        return;
    }
    return [self.activityHandler attributionWithCallback:attributionCallback];
}

- (void)adidWithCallback:(id<ADJAdidCallback>)adidCallback {
    if (adidCallback == nil) {
        [self.logger error:@"Callback for getting adid can't be null"];
        return;
    }

    if (![self checkActivityHandler]) {
        if (self.savedPreLaunch.cachedAdidReadCallbacksArray == nil) {
            self.savedPreLaunch.cachedAdidReadCallbacksArray = [NSMutableArray array];
        }

        [self.savedPreLaunch.cachedAdidReadCallbacksArray addObject:adidCallback];
        return;
    }
    return [self.activityHandler adidWithCallback:adidCallback];
}

- (void)sdkVersionWithCallback:(nonnull id<ADJSdkVersionCallback>)sdkVersionCallback {
    if (sdkVersionCallback == nil) {
        [self.logger error:@"Callback for getting SDK version can't be null"];
        return;
    }

    NSString *sdkVersion = [ADJUtil sdkVersion];
    [ADJUtil launchInMainThread:^{
        [sdkVersionCallback didReadWithSdkVersion:sdkVersion];
    }];
}

- (void)lastDeeplinkWithCallback:(nonnull id<ADJLastDeeplinkCallback>)lastDeeplinkCallback {
    if (lastDeeplinkCallback == nil) {
        [self.logger error:@"Callback for getting last opened deep link can't be null"];
        return;
    }

    NSURL *lastDeeplink = [ADJUserDefaults getCachedDeeplinkUrl];
    [ADJUtil launchInMainThread:^{
        [lastDeeplinkCallback didReadWithLastDeeplink:lastDeeplink];
    }];
}

- (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(void (^_Nonnull)(ADJPurchaseVerificationResult * _Nonnull verificationResult))completion {
    if (![self checkActivityHandler]) {
        if (completion != nil) {
            ADJPurchaseVerificationResult *result = [[ADJPurchaseVerificationResult alloc] init];
            result.verificationStatus = @"not_verified";
            result.code = 100;
            result.message = @"SDK needs to be initialized before making purchase verification request";
            completion(result);
        }
        return;
    }
    [self.activityHandler verifyAppStorePurchase:purchase
                           withCompletionHandler:completion];
}

- (void)enableCoppaCompliance {
    [ADJUserDefaults saveCoppaComplianceWithValue:YES];
    if ([self checkActivityHandler:@"enable coppa compliance"]) {
        [self.activityHandler setCoppaCompliance:YES];
    } else {
        if (self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray == nil) {
            self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray =
                [[NSMutableArray alloc] init];
        }
        [self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray addObject:@(YES)];
    }
}

- (void)disableCoppaCompliance {
    [ADJUserDefaults saveCoppaComplianceWithValue:NO];
    if ([self checkActivityHandler:@"disable coppa compliance"]) {
        [self.activityHandler setCoppaCompliance:NO];
    } else {
        if (self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray == nil) {
            self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray =
                [[NSMutableArray alloc] init];
        }
        [self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray addObject:@(NO)];
    }
}

- (void)verifyAndTrackAppStorePurchase:(nonnull ADJEvent *)event
                 withCompletionHandler:(void (^_Nonnull)(ADJPurchaseVerificationResult * _Nonnull verificationResult))completion {
    if (![self checkActivityHandler]) {
        if (completion != nil) {
            ADJPurchaseVerificationResult *result = [[ADJPurchaseVerificationResult alloc] init];
            result.verificationStatus = @"not_verified";
            result.code = 100;
            result.message = @"SDK needs to be initialized before making purchase verification request";
            completion(result);
        }
        return;
    }
    [self.activityHandler verifyAndTrackAppStorePurchase:event withCompletionHandler:completion];
}

- (void)teardown {
    if (self.activityHandler == nil) {
        [self.logger error:@"Adjust already down or not initialized"];
        return;
    }
    [self.activityHandler teardown];
    self.activityHandler = nil;
}

- (void)setTestOptions:(NSDictionary *)testOptions {
    if (testOptions[@"extraPath"] != nil) {
        self.savedPreLaunch.extraPath = testOptions[@"extraPath"];
    }
    if (testOptions[@"testUrlOverwrite"] != nil) {
        [ADJAdjustFactory setTestUrlOverwrite:testOptions[@"testUrlOverwrite"]];
    }
    if (testOptions[@"timerIntervalInMilliseconds"] != nil) {
        NSTimeInterval timerIntervalInSeconds = [testOptions[@"timerIntervalInMilliseconds"] intValue] / 1000.0;
        [ADJAdjustFactory setTimerInterval:timerIntervalInSeconds];
    }
    if (testOptions[@"timerStartInMilliseconds"] != nil) {
        NSTimeInterval timerStartInSeconds = [testOptions[@"timerStartInMilliseconds"] intValue] / 1000.0;
        [ADJAdjustFactory setTimerStart:timerStartInSeconds];
    }
    if (testOptions[@"sessionIntervalInMilliseconds"] != nil) {
        NSTimeInterval sessionIntervalInSeconds = [testOptions[@"sessionIntervalInMilliseconds"] intValue] / 1000.0;
        [ADJAdjustFactory setSessionInterval:sessionIntervalInSeconds];
    }
    if (testOptions[@"subsessionIntervalInMilliseconds"] != nil) {
        NSTimeInterval subsessionIntervalInSeconds = [testOptions[@"subsessionIntervalInMilliseconds"] intValue] / 1000.0;
        [ADJAdjustFactory setSubsessionInterval:subsessionIntervalInSeconds];
    }
    if (testOptions[@"attStatusInt"] != nil) {
        [ADJAdjustFactory setAttStatus:testOptions[@"attStatusInt"]];
    }
    if (testOptions[@"idfa"] != nil) {
        [ADJAdjustFactory setIdfa:testOptions[@"idfa"]];
    }
    if ([testOptions[@"noBackoffWait"] boolValue] == YES) {
        [ADJAdjustFactory setSdkClickHandlerBackoffStrategy:[ADJBackoffStrategy backoffStrategyWithType:ADJNoWait]];
        [ADJAdjustFactory setPackageHandlerBackoffStrategy:[ADJBackoffStrategy backoffStrategyWithType:ADJNoWait]];
    }

    [ADJAdjustFactory setAdServicesFrameworkEnabled:[testOptions[@"adServicesFrameworkEnabled"] boolValue]];
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
            [self.logger error:@"Please initialize Adjust by calling initSdk: before"];
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

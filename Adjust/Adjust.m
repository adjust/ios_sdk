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
#import "ADJPurchaseVerificationResult.h"
#import "ADJDeeplink.h"

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

@property (nonatomic) ADJResolvedDeeplinkBlock cachedResolvedDeeplinkBlock;

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

+ (void)isEnabledWithCompletionHandler:(nonnull ADJIsEnabledGetterBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] isEnabledWithCompletionHandler:completion];
    }
}

+ (void)processDeeplink:(ADJDeeplink *)deeplink {
    @synchronized (self) {
        [[Adjust getInstance] processDeeplink:deeplink];
    }
}

+ (void)processAndResolveDeeplink:(nonnull ADJDeeplink *)deeplink
            withCompletionHandler:(nonnull ADJResolvedDeeplinkBlock)completion {
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

+ (void)idfaWithCompletionHandler:(nonnull ADJIdfaGetterBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] idfaWithCompletionHandler:completion];
    }
}

+ (void)idfvWithCompletionHandler:(nonnull ADJIdfvGetterBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] idfvWithCompletionHandler:completion];
    }
}

+ (void)sdkVersionWithCompletionHandler:(nonnull ADJSdkVersionGetterBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] sdkVersionWithCompletionHandler:completion];
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

+ (void)attributionWithCompletionHandler:(nonnull ADJAttributionGetterBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] attributionWithCompletionHandler:completion];
    }
}

+ (void)adidWithCompletionHandler:(nonnull ADJAdidGetterBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] adidWithCompletionHandler:completion];
    }
}

+ (void)lastDeeplinkWithCompletionHandler:(nonnull ADJLastDeeplinkGetterBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] lastDeeplinkWithCompletionHandler:completion];
    }
}

+ (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(nonnull ADJVerificationResultBlock)completion {
    @synchronized (self) {
        [[Adjust getInstance] verifyAppStorePurchase:purchase
                               withCompletionHandler:completion];
    }
}

 + (void)enableCoppaComplianceInDelay {
     @synchronized (self) {
         [[Adjust getInstance] enableCoppaComplianceInDelay];
     }
 }

 + (void)disableCoppaComplianceInDelay {
     @synchronized (self) {
         [[Adjust getInstance] disableCoppaComplianceInDelay];
     }
 }

+ (void)setExternalDeviceIdInDelay:(nullable NSString *)externalDeviceId {
    @synchronized (self) {
        [[Adjust getInstance] setExternalDeviceIdInDelay:externalDeviceId];
    }
}

+ (void)verifyAndTrackAppStorePurchase:(nonnull ADJEvent *)event
                 withCompletionHandler:(void (^_Nonnull)(ADJPurchaseVerificationResult * _Nonnull verificationResult))completion {
    @synchronized (self) {
        [[Adjust getInstance] verifyAndTrackAppStorePurchase:event
                                       withCompletionHandler:completion];
    }
}

+ (void)endFirstSessionDelay {
    @synchronized (self) {
        [[Adjust getInstance] endFirstSessionDelay];
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
    if (![self isSignerPresent]) {
        [self.logger error:@"Missing signature library, SDK can't be initialised"];
        return;
    }
    if (self.activityHandler != nil) {
        [self.logger error:@"Adjust already initialized"];
        return;
    }
    self.activityHandler = [[ADJActivityHandler alloc] initWithConfig:adjustConfig
                                                       savedPreLaunch:self.savedPreLaunch
                                           deeplinkResolutionCallback:self.cachedResolvedDeeplinkBlock];
}
- (BOOL)isSignerPresent {
    _Nullable Class signerClass = NSClassFromString(@"ADJSigner");
    if (signerClass == nil) {
        return NO;
    }

    return [signerClass respondsToSelector:
            NSSelectorFromString(@"sign:withExtraParams:withOutputParams:")];
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

    if ([self checkActivityHandler:@"enable SDK"]) {
        [self.activityHandler setEnabled:YES];
    }
}

- (void)disable {
    self.savedPreLaunch.enabled = @NO;

    if ([self checkActivityHandler:@"disable SDK"]) {
        [self.activityHandler setEnabled:NO];
    }
}

- (void)isEnabledWithCompletionHandler:(nonnull ADJIsEnabledGetterBlock)completion {
    if (![self checkActivityHandler]) {
        [ADJUtil isEnabledFromActivityStateFile:^(BOOL isEnabled) {
            __block ADJIsEnabledGetterBlock localIsEnabledCallback = completion;
            [ADJUtil launchInMainThread:^{
                localIsEnabledCallback(isEnabled);
            }];
        }];
        return;
    }
    [self.activityHandler isEnabledWithCompletionHandler:completion];
}

- (void)processDeeplink:(ADJDeeplink *)deeplink {
    [ADJUserDefaults cacheDeeplinkUrl:deeplink.deeplink];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler:@"process deep link"]) {
        [ADJUserDefaults saveDeeplink:deeplink clickTime:clickTime];
        return;
    }
    [self.activityHandler processDeeplink:deeplink withClickTime:clickTime];
}

- (void)processAndResolveDeeplink:(nonnull ADJDeeplink *)deeplink
            withCompletionHandler:(nonnull ADJResolvedDeeplinkBlock)completion {
    // if resolution result is not wanted, fallback to default method
    if (completion == nil) {
        [self processDeeplink:deeplink];
        return;
    }
    // if deep link processing is triggered prior to SDK being initialized
    [ADJUserDefaults cacheDeeplinkUrl:deeplink.deeplink];
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler:@"process and resolve deep link"]) {
        [ADJUserDefaults saveDeeplink:deeplink clickTime:clickTime];
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
    if (![self checkActivityHandler:@"switch to offline mode"]) {
        self.savedPreLaunch.offline = YES;
    } else {
        [self.activityHandler setOfflineMode:YES];
    }
}

- (void)switchBackToOnlineMode {
    if (![self checkActivityHandler:@"switch back to online mode"]) {
        self.savedPreLaunch.offline = NO;
    } else {
        [self.activityHandler setOfflineMode:NO];
    }
}

- (void)idfaWithCompletionHandler:(nonnull ADJIdfaGetterBlock)completion {
    if (completion == nil) {
        [self.logger error:@"Completion block for getting IDFA can't be null"];
        return;
    }

    NSString *idfa = [ADJUtil idfa];
    __block ADJIdfaGetterBlock localIdfaCallback = completion;
    [ADJUtil launchInMainThread:^{
        localIdfaCallback(idfa);
    }];
}

- (void)idfvWithCompletionHandler:(nonnull ADJIdfvGetterBlock)completion {
    if (completion == nil) {
        [self.logger error:@"Completion block for getting IDFV can't be null"];
        return;
    }

    NSString *idfv = [ADJUtil idfv];
    __block ADJIdfaGetterBlock localIdfvCallback = completion;
    [ADJUtil launchInMainThread:^{
        localIdfvCallback(idfv);
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
    if (![self checkActivityHandler:@"track third party sharing"]) {
        if (self.savedPreLaunch.preLaunchActionsArray == nil) {
            self.savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
        }
        [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
            [activityHandler tryTrackThirdPartySharingI:thirdPartySharing];
        }];
        return;
    }
    [self.activityHandler trackThirdPartySharing:thirdPartySharing];
}

- (void)trackMeasurementConsent:(BOOL)enabled {
    if (![self checkActivityHandler:@"track measurement consent"]) {
        if (self.savedPreLaunch.preLaunchActionsArray == nil) {
            self.savedPreLaunch.preLaunchActionsArray =
                [[NSMutableArray alloc] init];
        }
        [self.savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler *activityHandler) {
            [activityHandler tryTrackMeasurementConsentI:enabled];
        }];
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
        [self.activityHandler updateAndTrackAttStatusFromUserCallback:(int)status];
    }];
}

- (int)appTrackingAuthorizationStatus {
    return [ADJUtil attStatus];
}

- (void)updateSkanConversionValue:(NSInteger)conversionValue
                      coarseValue:(nullable NSString *)coarseValue
                       lockWindow:(nullable NSNumber *)lockWindow
            withCompletionHandler:(void (^_Nullable)(NSError *_Nullable error))completion {
    [[ADJSKAdNetwork getInstance] updateConversionValue:[NSNumber numberWithInteger:conversionValue]
                                            coarseValue:coarseValue
                                             lockWindow:lockWindow
                                                 source:ADJSkanSourceClient
                                  withCompletionHandler:^(NSDictionary * _Nonnull result)
     {
        if ([self checkActivityHandler]) {
            [self.activityHandler invokeClientSkanUpdateCallbackWithResult:result];
        }
        if (completion != nil) {
            completion([result objectForKey:ADJSkanClientCompletionErrorKey]);
        }
    }];
}

- (void)trackAdRevenue:(ADJAdRevenue *)adRevenue {
    if (![self checkActivityHandler]) {
        return;
    }
    [self.activityHandler trackAdRevenue:adRevenue];
}

- (void)attributionWithCompletionHandler:(nonnull ADJAttributionGetterBlock)completion {
    if (completion == nil) {
        [self.logger error:@"Completion block for getting attribution can't be null"];
        return;
    }

    if (![self checkActivityHandler:@"read attribution request"]) {
        if (self.savedPreLaunch.cachedAttributionReadCallbacksArray == nil) {
            self.savedPreLaunch.cachedAttributionReadCallbacksArray = [NSMutableArray array];
        }

        [self.savedPreLaunch.cachedAttributionReadCallbacksArray addObject:completion];
        return;
    }
    return [self.activityHandler attributionWithCompletionHandler:completion];
}

- (void)adidWithCompletionHandler:(nonnull ADJAdidGetterBlock)completion {
    if (completion == nil) {
        [self.logger error:@"Completion block for getting adid can't be null"];
        return;
    }

    if (![self checkActivityHandler:@"read adid request"]) {
        if (self.savedPreLaunch.cachedAdidReadCallbacksArray == nil) {
            self.savedPreLaunch.cachedAdidReadCallbacksArray = [NSMutableArray array];
        }

        [self.savedPreLaunch.cachedAdidReadCallbacksArray addObject:completion];
        return;
    }
    return [self.activityHandler adidWithCompletionHandler:completion];
}

- (void)sdkVersionWithCompletionHandler:(nonnull ADJSdkVersionGetterBlock)completion {
    if (completion == nil) {
        [self.logger error:@"Completion block for getting SDK version can't be null"];
        return;
    }

    NSString *sdkVersion = [ADJUtil sdkVersion];
    __block ADJSdkVersionGetterBlock localSdkVersionCallback = completion;
    [ADJUtil launchInMainThread:^{
        localSdkVersionCallback(sdkVersion);
    }];
}

- (void)lastDeeplinkWithCompletionHandler:(nonnull ADJLastDeeplinkGetterBlock)completion {
    if (completion == nil) {
        [self.logger error:@"Completion block for getting last opened deep link can't be null"];
        return;
    }

    NSURL *lastDeeplink = [ADJUserDefaults getCachedDeeplinkUrl];
    __block ADJLastDeeplinkGetterBlock localLastDeeplinkCallback = completion;
    [ADJUtil launchInMainThread:^{
        localLastDeeplinkCallback(lastDeeplink);
    }];
}

- (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(nonnull ADJVerificationResultBlock)completion {
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

- (void)enableCoppaComplianceInDelay {
    if (![self checkActivityHandler:@"enable coppa compliance in delay"]) {
        return;
    }

    [self.activityHandler setCoppaComplianceInDelay:YES];
}

- (void)disableCoppaComplianceInDelay {
    if (![self checkActivityHandler:@"disable coppa compliance in delay"]) {
        return;
    }

    [self.activityHandler setCoppaComplianceInDelay:NO];
}

- (void)setExternalDeviceIdInDelay:(nullable NSString *)externalDeviceId {
    if (![self checkActivityHandler:@"set external device id in delay"]) {
        return;
    }

    [self.activityHandler setExternalDeviceIdInDelay:externalDeviceId];
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

- (void)endFirstSessionDelay {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler endFirstSessionDelay];
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

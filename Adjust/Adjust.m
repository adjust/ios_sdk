//
//  Adjust.m
//  Adjust
//
//  Created by Christian Wellenbrock (wellle) on 23rd July 2013.
//  Copyright © 2012-2017 Adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJUserDefaults.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"

#if !__has_feature(objc_arc)
#error Adjust requires ARC
// See README for details: https://github.com/adjust/ios_sdk/blob/master/README.md
#endif

NSString * const ADJEnvironmentSandbox = @"sandbox";
NSString * const ADJEnvironmentProduction = @"production";

NSString * const ADJAdRevenueSourceMopub = @"mopub";
NSString * const ADJAdRevenueSourceAdmob = @"admob";
NSString * const ADJAdRevenueSourceFbNativeAd = @"facebook_native_ad";
NSString * const ADJAdRevenueSourceIronsource = @"ironsource";
NSString * const ADJAdRevenueSourceFyber = @"fyber";
NSString * const ADJAdRevenueSourceAerserv = @"aerserv";
NSString * const ADJAdRevenueSourceAppodeal = @"appodeal";
NSString * const ADJAdRevenueSourceAdincube = @"adincube";
NSString * const ADJAdRevenueSourceFusePowered = @"fusepowered";
NSString * const ADJAdRevenueSourceAddaptr = @"addapptr";
NSString * const ADJAdRevenueSourceMillennialMeditation = @"millennial_mediation";
NSString * const ADJAdRevenueSourceFlurry = @"flurry";
NSString * const ADJAdRevenueSourceAdmost = @"admost";
NSString * const ADJAdRevenueSourceDeltadna = @"deltadna";
NSString * const ADJAdRevenueSourceUpsight = @"upsight";
NSString * const ADJAdRevenueSourceUnityads = @"unityads";
NSString * const ADJAdRevenueSourceAdtoapp = @"adtoapp";
NSString * const ADJAdRevenueSourceTapdaq = @"tapdaq";

@implementation AdjustTestOptions
@end

@interface Adjust()

@property (nonatomic, weak) id<ADJLogger> logger;

@property (nonatomic, strong) id<ADJActivityHandler> activityHandler;

@property (nonatomic, strong) ADJSavedPreLaunch *savedPreLaunch;

@end

@implementation Adjust

#pragma mark - Object lifecycle methods

static Adjust *defaultInstance = nil;
static dispatch_once_t onceToken = 0;

+ (id)getInstance {
    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.activityHandler = nil;
    self.logger = [ADJAdjustFactory logger];
    self.savedPreLaunch = [[ADJSavedPreLaunch alloc] init];

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

+ (void)trackSubscription:(nonnull ADJSubscription *)subscription {
    @synchronized (self) {
        [[Adjust getInstance] trackSubscription:subscription];
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

    self.activityHandler = [[ADJActivityHandler alloc]
                                initWithConfig:adjustConfig
                                savedPreLaunch:self.savedPreLaunch];
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
    NSDate *clickTime = [NSDate date];
    if (![self checkActivityHandler]) {
        [ADJUserDefaults saveDeeplinkUrl:url andClickTime:clickTime];
        return;
    }

    [self.activityHandler appWillOpenUrl:url withClickTime:clickTime];
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

- (void)trackSubscription:(ADJSubscription *)subscription {
    if (![self checkActivityHandler]) {
        return;
    }

    [self.activityHandler trackSubscription:subscription];
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
    if (testOptions.baseUrl != nil) {
        [ADJAdjustFactory setBaseUrl:testOptions.baseUrl];
    }
    if (testOptions.gdprUrl != nil) {
        [ADJAdjustFactory setGdprUrl:testOptions.gdprUrl];
    }
    if (testOptions.subscriptionUrl != nil) {
        [ADJAdjustFactory setSubscriptionUrl:testOptions.subscriptionUrl];
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

    [ADJAdjustFactory setiAdFrameworkEnabled:testOptions.iAdFrameworkEnabled];
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

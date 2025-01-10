//
//  ADJActivityHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADJActivityPackage.h"
#import "ADJActivityHandler.h"
#import "ADJPackageBuilder.h"
#import "ADJPackageHandler.h"
#import "ADJLogger.h"
#import "ADJTimerCycle.h"
#import "ADJTimerOnce.h"
#import "ADJUtil.h"
#import "ADJAdjustFactory.h"
#import "ADJAttributionHandler.h"
#import "ADJAdditions.h"
#import "ADJSdkClickHandler.h"
#import "ADJUserDefaults.h"
#import "ADJUrlStrategy.h"
#import "ADJSKAdNetwork.h"
#import "ADJPurchaseVerificationHandler.h"
#import "ADJPurchaseVerificationResult.h"
#import "ADJAdRevenue.h"
#import "ADJDeeplink.h"

NSString * const ADJAdServicesPackageKey = @"apple_ads";

typedef void (^activityHandlerBlockI)(ADJActivityHandler * activityHandler);

static NSString   * const kActivityStateFilename                = @"AdjustIoActivityState";
static NSString   * const kAttributionFilename                  = @"AdjustIoAttribution";
static NSString   * const kGlobalCallbackParametersFilename     = @"AdjustSessionCallbackParameters";
static NSString   * const kGlobalPartnerParametersFilename      = @"AdjustSessionPartnerParameters";
static NSString   * const kAdjustPrefix                         = @"adjust_";
static const char * const kInternalQueueName                    = "io.adjust.ActivityQueue";
static const char * const kWaitingForAttQueueName               = "io.adjust.WaitingForAttQueue";
static NSString   * const kForegroundTimerName                  = @"Foreground timer";
static NSString   * const kBackgroundTimerName                  = @"Background timer";
static NSString   * const kSkanConversionValueResponseKey       = @"skadn_conv_value";
static NSString   * const kSkanCoarseValueResponseKey           = @"skadn_coarse_value";
static NSString   * const kSkanLockWindowResponseKey            = @"skadn_lock_window";

static NSTimeInterval kForegroundTimerInterval;
static NSTimeInterval kForegroundTimerStart;
static NSTimeInterval kBackgroundTimerInterval;
static double kSessionInterval;
static double kSubSessionInterval;
static const int kAdServicesdRetriesCount = 1;
const NSUInteger kWaitingForAttStatusLimitSeconds = 360;

// SKAN constants
const NSInteger kSkanRegisterConversionValue = 0;
static NSString * const kSkanRegisterCoarseValue = @"low";
const BOOL kSkanRegisterLockWindow = NO;

@implementation ADJInternalState

- (BOOL)isEnabled { return self.enabled; }
- (BOOL)isDisabled { return !self.enabled; }
- (BOOL)isOffline { return self.offline; }
- (BOOL)isOnline { return !self.offline; }
- (BOOL)isInBackground { return self.background; }
- (BOOL)isInForeground { return !self.background; }
- (BOOL)itHasToUpdatePackagesAttData { return self.updatePackagesAttData; }
- (BOOL)isFirstLaunch { return self.firstLaunch; }
- (BOOL)hasSessionResponseNotBeenProcessed { return !self.sessionResponseProcessed; }
- (BOOL)isWaitingForAttStatus { return self.waitingForAttStatus;}

@end

@implementation ADJSavedPreLaunch

- (id)init {
    self = [super init];
    if (self) {
        // online by default
        self.offline = NO;
    }
    return self;
}

@end

#pragma mark -
@interface ADJActivityHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADJPackageHandler *packageHandler;
@property (nonatomic, strong) ADJAttributionHandler *attributionHandler;
@property (nonatomic, strong) ADJSdkClickHandler *sdkClickHandler;
@property (nonatomic, strong) ADJPurchaseVerificationHandler *purchaseVerificationHandler;
@property (nonatomic, strong) ADJActivityState *activityState;
@property (nonatomic, strong) ADJTimerCycle *foregroundTimer;
@property (nonatomic, strong) ADJTimerOnce *backgroundTimer;
@property (nonatomic, assign) NSInteger adServicesRetriesLeft;
@property (nonatomic, strong) ADJInternalState *internalState;
@property (nonatomic, strong) ADJPackageParams *packageParams;
@property (nonatomic, strong) ADJGlobalParameters *globalParameters;
// weak for object that Activity Handler does not "own"
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, weak) NSObject<AdjustDelegate> *adjustDelegate;
// copy for objects shared with the user
@property (nonatomic, copy) ADJConfig *adjustConfig;
@property (nonatomic, weak) ADJSavedPreLaunch *savedPreLaunch;
@property (nonatomic, copy) NSString* basePath;
@property (nonatomic, copy) NSString* gdprPath;
@property (nonatomic, copy) NSString* subscriptionPath;
@property (nonatomic, copy) NSString* purchaseVerificationPath;
@property (nonatomic, copy) ADJResolvedDeeplinkBlock cachedDeeplinkResolutionCallback;
@property (nonatomic, copy) ADJAttribution *attribution;

- (void)prepareDeeplinkI:(ADJActivityHandler *_Nullable)selfI
            responseData:(ADJAttributionResponseData *_Nullable)attributionResponseData NS_EXTENSION_UNAVAILABLE_IOS("");

@end

#pragma mark -
@implementation ADJActivityHandler

@synthesize trackingStatusManager = _trackingStatusManager;

- (id)initWithConfig:(ADJConfig *_Nullable)adjustConfig
      savedPreLaunch:(ADJSavedPreLaunch * _Nullable)savedPreLaunch
      deeplinkResolutionCallback:(ADJResolvedDeeplinkBlock _Nullable)deepLinkResolutionCallback {
    self = [super init];
    if (self == nil) return nil;

    if (adjustConfig == nil) {
        [ADJAdjustFactory.logger error:@"AdjustConfig missing"];
        return nil;
    }

    if (![adjustConfig isValid]) {
        [ADJAdjustFactory.logger error:@"AdjustConfig not initialized correctly"];
        return nil;
    }
    
    // check if ASA and IDFA/IDFV tracking were switched off and warn just in case
    if (adjustConfig.isIdfaReadingEnabled == NO) {
        [ADJAdjustFactory.logger warn:@"IDFA reading has been switched off"];
    }
    if (adjustConfig.isIdfvReadingEnabled == NO) {
        [ADJAdjustFactory.logger warn:@"IDFV reading has been switched off"];
    }
    if (adjustConfig.isAdServicesEnabled == NO) {
        [ADJAdjustFactory.logger warn:@"AdServices info reading has been switched off"];
    }

    // check if ATT consent delay has been configured
    if (adjustConfig.attConsentWaitingInterval > 0) {
        [ADJAdjustFactory.logger info:@"ATT consent waiting interval has been configured to %d",
         adjustConfig.attConsentWaitingInterval];
    }

    self.adjustConfig = adjustConfig;
    self.savedPreLaunch = savedPreLaunch;
    self.adjustDelegate = adjustConfig.delegate;
    self.cachedDeeplinkResolutionCallback = deepLinkResolutionCallback;

    // init logger to be available everywhere
    self.logger = ADJAdjustFactory.logger;

    [self.logger lockLogLevel];

    // inject app token be available in activity state
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        [ADJActivityState saveAppToken:adjustConfig.appToken];
        [ADJActivityState setEventDeduplicationIdsArraySize:adjustConfig.eventDeduplicationIdsMaxSize];
    }];

    // read files to have sync values available
    [self readAttribution];
    [self readActivityState];
    
    // register SKAdNetwork attribution if we haven't already
    if (self.adjustConfig.isSkanAttributionEnabled) {
        NSNumber *numConversionValue = [NSNumber numberWithInteger:kSkanRegisterConversionValue];
        NSNumber *numLockWindow = [NSNumber numberWithBool:kSkanRegisterLockWindow];

        [[ADJSKAdNetwork getInstance] registerWithConversionValue:numConversionValue
                                                      coarseValue:kSkanRegisterCoarseValue
                                                       lockWindow:numLockWindow
                                            withCompletionHandler:^(NSDictionary * _Nonnull result) {
            [self invokeClientSkanUpdateCallbackWithResult:result];
        }];
    }

    self.internalState = [[ADJInternalState alloc] init];

    if (savedPreLaunch.enabled != nil) {
        if (savedPreLaunch.preLaunchActionsArray == nil) {
            savedPreLaunch.preLaunchActionsArray = [[NSMutableArray alloc] init];
        }

        BOOL newEnabled = [savedPreLaunch.enabled boolValue];
        [savedPreLaunch.preLaunchActionsArray addObject:^(ADJActivityHandler * activityHandler){
            [activityHandler setEnabledI:activityHandler enabled:newEnabled];
        }];
    }

    // check if SDK is enabled/disabled
    self.internalState.enabled = savedPreLaunch.enabled != nil ? [savedPreLaunch.enabled boolValue] : YES;
    // reads offline mode from pre launch
    self.internalState.offline = savedPreLaunch.offline;
    // in the background by default
    self.internalState.background = YES;
    // does not need to update packages by default
    if (self.activityState == nil) {
        self.internalState.updatePackagesAttData = NO;
    } else {
        self.internalState.updatePackagesAttData = self.activityState.updatePackagesAttData;
    }
    if (self.activityState == nil) {
        self.internalState.firstLaunch = YES;
    } else {
        self.internalState.firstLaunch = NO;
    }
    // does not have the session response by default
    self.internalState.sessionResponseProcessed = NO;

    self.adServicesRetriesLeft = kAdServicesdRetriesCount;

    self.trackingStatusManager = [[ADJTrackingStatusManager alloc] initWithActivityHandler:self];

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI initI:selfI
                     preLaunchActions:savedPreLaunch];
                     }];

    [self addNotificationObserver];

    return self;
}

- (void)applicationDidBecomeActive {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI handleAppForegroundI:selfI];
    }];
}

- (void)applicationWillResignActive {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI handleAppBackgroundI:selfI];
    }];
}

- (void)trackEvent:(ADJEvent *)event {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         // track event called before app started
                         if (selfI.activityState == nil) {
                             [selfI startI:selfI];
                         }
                         [selfI eventI:selfI event:event];
                     }];
}

- (void)finishedTracking:(ADJResponseData *)responseData {
    [self checkConversionValue:responseData];

    // redirect session responses to attribution handler to check for attribution information
    if ([responseData isKindOfClass:[ADJSessionResponseData class]]) {
        [self.attributionHandler checkSessionResponse:(ADJSessionResponseData*)responseData];
        return;
    }

    // redirect sdk_click responses to attribution handler to check for attribution information
    if ([responseData isKindOfClass:[ADJSdkClickResponseData class]]) {
        [self.attributionHandler checkSdkClickResponse:(ADJSdkClickResponseData*)responseData];
        return;
    }

    // check if it's an event response
    if ([responseData isKindOfClass:[ADJEventResponseData class]]) {
        [self launchEventResponseTasks:(ADJEventResponseData*)responseData];
        return;
    }

    // check if it's a purchase verification response
    if ([responseData isKindOfClass:[ADJPurchaseVerificationResponseData class]]) {
        [self launchPurchaseVerificationResponseTasks:(ADJPurchaseVerificationResponseData *)responseData];
        return;
    }
}

- (void)launchEventResponseTasks:(ADJEventResponseData *)eventResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI launchEventResponseTasksI:selfI eventResponseData:eventResponseData];
                     }];
}

- (void)launchSessionResponseTasks:(ADJSessionResponseData *)sessionResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI launchSessionResponseTasksI:selfI sessionResponseData:sessionResponseData];
                     }];
}

- (void)launchSdkClickResponseTasks:(ADJSdkClickResponseData *)sdkClickResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI launchSdkClickResponseTasksI:selfI sdkClickResponseData:sdkClickResponseData];
                     }];
}

- (void)launchAttributionResponseTasks:(ADJAttributionResponseData *)attributionResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI launchAttributionResponseTasksI:selfI attributionResponseData:attributionResponseData];
                     }];
}

- (void)launchPurchaseVerificationResponseTasks:(ADJPurchaseVerificationResponseData *)purchaseVerificationResponseData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI launchPurchaseVerificationResponseTasksI:selfI
                                        purchaseVerificationResponseData:purchaseVerificationResponseData];
                     }];
}

- (void)setEnabled:(BOOL)enabled {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI setEnabledI:selfI enabled:enabled];
                     }];
}

- (void)setOfflineMode:(BOOL)offline {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI setOfflineModeI:selfI offline:offline];
                     }];
}

- (void)isEnabledWithCompletionHandler:(nonnull ADJIsEnabledGetterBlock)completion {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI isEnabledI:selfI withCompletionHandler:completion];
    }];
}

- (BOOL)isGdprForgotten {
    return [self isGdprForgottenI:self];
}

- (void)processDeeplink:(ADJDeeplink *)deeplink withClickTime:(NSDate *)clickTime {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI processDeeplinkI:selfI
                                             url:deeplink.deeplink
                                       clickTime:clickTime];
                     }];
}

- (void)processAndResolveDeeplink:(ADJDeeplink * _Nullable)deeplink
                        clickTime:(NSDate * _Nullable)clickTime
            withCompletionHandler:(ADJResolvedDeeplinkBlock _Nullable)completion {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        selfI.cachedDeeplinkResolutionCallback = completion;
        [selfI processDeeplinkI:selfI
                            url:deeplink.deeplink
                      clickTime:clickTime];
    }];
}

- (void)setPushTokenData:(NSData *)pushTokenData {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI setPushTokenI:selfI pushTokenData:pushTokenData];
                     }];
}

- (void)setPushTokenString:(NSString *)pushTokenString {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI setPushTokenI:selfI pushTokenString:pushTokenString];
                     }];
}

- (void)setGdprForgetMe {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI setGdprForgetMeI:selfI];
                     }];
}

- (void)setTrackingStateOptedOut {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI setTrackingStateOptedOutI:selfI];
                     }];
}

- (void)setAdServicesAttributionToken:(NSString *)token
                                error:(NSError *)error {
    if (![ADJUtil isNull:error]) {
        [self.logger warn:@"Unable to read AdServices details"];
        
        // 3 == platform not supported
        if (error.code != 3 && self.adServicesRetriesLeft > 0) {
            self.adServicesRetriesLeft = self.adServicesRetriesLeft - 1;
            // retry after 5 seconds
            dispatch_time_t retryTime = dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC);
            dispatch_after(retryTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self checkForAdServicesAttributionI:self];
            });
        } else {
            [self sendAdServicesClickPackage:self
                                      token:nil
                            errorCodeNumber:[NSNumber numberWithInteger:error.code]];
        }
    } else {
        [self sendAdServicesClickPackage:self
                                  token:token
                        errorCodeNumber:nil];
    }
}

- (void)sendAdServicesClickPackage:(ADJActivityHandler *)selfI
                             token:(NSString *)token
                   errorCodeNumber:(NSNumber *)errorCodeNumber
 {
     if (![selfI isEnabledI:selfI]) {
         return;
     }

     if (ADJAdjustFactory.adServicesFrameworkEnabled == NO) {
         [self.logger verbose:@"Sending AdServices attribution to server suppressed."];
         return;
     }

     double now = [NSDate.date timeIntervalSince1970];
     if (selfI.activityState != nil) {
         [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                         block:^{
             double lastInterval = now - selfI.activityState.lastActivity;
             selfI.activityState.lastInterval = lastInterval;
         }];
     }
     ADJPackageBuilder *clickBuilder = [[ADJPackageBuilder alloc]
                                        initWithPackageParams:selfI.packageParams
                                        activityState:selfI.activityState
                                        config:selfI.adjustConfig
                                        globalParameters:self.globalParameters
                                        trackingStatusManager:self.trackingStatusManager
                                        createdAt:now];
     clickBuilder.internalState = selfI.internalState;

     ADJActivityPackage *clickPackage =
        [clickBuilder buildClickPackage:ADJAdServicesPackageKey
                                  token:token
                        errorCodeNumber:errorCodeNumber];
     [selfI.sdkClickHandler sendSdkClick:clickPackage];
}

- (void)setAskingAttribution:(BOOL)askingAttribution {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI setAskingAttributionI:selfI
                                   askingAttribution:askingAttribution];
                     }];
}

- (void)foregroundTimerFired {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI foregroundTimerFiredI:selfI];
                     }];
}

- (void)backgroundTimerFired {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI backgroundTimerFiredI:selfI];
                     }];
}

- (void)resumeActivityFromWaitingForAttStatus {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI resumeActivityFromWaitingForAttStatusI:selfI];
    }];
}

- (void)addGlobalCallbackParameter:(NSString *)param
                            forKey:(NSString *)key {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI addGlobalCallbackParameterI:selfI param:param forKey:key];
                     }];
}

- (void)addGlobalPartnerParameter:(NSString *)param
                           forKey:(NSString *)key {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI addGlobalPartnerParameterI:selfI param:param forKey:key];
                     }];
}

- (void)removeGlobalCallbackParameterForKey:(NSString *)key {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI removeGlobalCallbackParameterI:selfI forKey:key];
                     }];
}

- (void)removeGlobalPartnerParameterForKey:(NSString *)key {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI removeGlobalPartnerParameterI:selfI forKey:key];
                     }];
}

- (void)removeGlobalCallbackParameters {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI removeGlobalCallbackParametersI:selfI];
                     }];
}

- (void)removeGlobalPartnerParameters {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI removeGlobalPartnerParametersI:selfI];
                     }];
}

- (void)trackAppStoreSubscription:(ADJAppStoreSubscription *)subscription {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI trackAppStoreSubscriptionI:selfI subscription:subscription];
    }];
}

- (void)trackThirdPartySharing:(nonnull ADJThirdPartySharing *)thirdPartySharing {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        BOOL tracked =
            [selfI trackThirdPartySharingI:selfI thirdPartySharing:thirdPartySharing];
        if (! tracked) {
            if (self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray == nil) {
                self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray =
                    [[NSMutableArray alloc] init];
            }

            [self.savedPreLaunch.preLaunchAdjustThirdPartySharingArray
                addObject:thirdPartySharing];
        }
    }];
}

- (void)trackMeasurementConsent:(BOOL)enabled {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        BOOL tracked =
            [selfI trackMeasurementConsentI:selfI enabled:enabled];
        if (! tracked) {
            selfI.savedPreLaunch.lastMeasurementConsentTracked =
                [NSNumber numberWithBool:enabled];
        }
    }];
}

- (void)trackAdRevenue:(ADJAdRevenue *)adRevenue {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI trackAdRevenueI:selfI adRevenue:adRevenue];
    }];
}

- (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(nonnull ADJVerificationResultBlock)completion {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI verifyAppStorePurchaseI:selfI purchase:purchase withCompletionHandler:completion];
    }];
}

- (void)attributionWithCompletionHandler:(nonnull ADJAttributionGetterBlock)completion {
    __block ADJAttribution *_Nullable localAttribution = self.attribution;

    if (localAttribution == nil) {
        if (self.savedPreLaunch.cachedAttributionReadCallbacksArray == nil) {
            self.savedPreLaunch.cachedAttributionReadCallbacksArray = [NSMutableArray array];
        }
        [self.savedPreLaunch.cachedAttributionReadCallbacksArray addObject:completion];
        return;
    }

    __block ADJAttributionGetterBlock localAttributionCallback = completion;
    [ADJUtil launchInMainThread:^{
        localAttributionCallback(localAttribution);
    }];
}

- (void)adidWithCompletionHandler:(nonnull ADJAdidGetterBlock)completion {
    __block NSString *_Nullable localAdid = self.activityState == nil ? nil : self.activityState.adid;

    if (localAdid == nil) {
        if (self.savedPreLaunch.cachedAdidReadCallbacksArray == nil) {
            self.savedPreLaunch.cachedAdidReadCallbacksArray = [NSMutableArray array];
        }

        [self.savedPreLaunch.cachedAdidReadCallbacksArray addObject:completion];
        return;
    }

    __block ADJAdidGetterBlock localAdidCallback = completion;
    [ADJUtil launchInMainThread:^{
        localAdidCallback(localAdid);
    }];
}

- (void)verifyAndTrackAppStorePurchase:(nonnull ADJEvent *)event
                 withCompletionHandler:(nonnull ADJVerificationResultBlock)completion {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
        [selfI verifyAndTrackAppStorePurchaseI:selfI event:event withCompletionHandler:completion];
    }];
}

- (void)writeActivityState {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                         [selfI writeActivityStateI:selfI];
                     }];
}

- (void)trackAttStatusUpdate {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJActivityHandler * selfI) {
                        [selfI trackAttStatusUpdateI:selfI];
                     }];
}

- (NSString *)getBasePath {
    return _basePath;
}

- (NSString *)getGdprPath {
    return _gdprPath;
}

- (NSString *)getSubscriptionPath {
    return _subscriptionPath;
}

- (NSString *)getPurchaseVerificationPath {
    return _purchaseVerificationPath;
}

- (void)teardown
{
    [ADJAdjustFactory.logger verbose:@"ADJActivityHandler teardown"];
    [self removeNotificationObserver];
    if (self.backgroundTimer != nil) {
        [self.backgroundTimer cancel];
    }
    if (self.foregroundTimer != nil) {
        [self.foregroundTimer cancel];
    }
    if (self.attributionHandler != nil) {
        [self.attributionHandler teardown];
    }
    if (self.packageHandler != nil) {
        [self.packageHandler teardown];
    }
    if (self.sdkClickHandler != nil) {
        [self.sdkClickHandler teardown];
    }
    if (self.purchaseVerificationHandler != nil) {
        [self.purchaseVerificationHandler teardown];
    }
    [self teardownActivityStateS];
    [self teardownAttributionS];
    [self teardownAllGlobalParametersS];

    [ADJUtil teardown];

    self.internalQueue = nil;
    self.packageHandler = nil;
    self.attributionHandler = nil;
    self.sdkClickHandler = nil;
    self.purchaseVerificationHandler = nil;
    self.foregroundTimer = nil;
    self.backgroundTimer = nil;
    self.adjustDelegate = nil;
    self.adjustConfig = nil;
    self.internalState = nil;
    self.packageParams = nil;
    self.logger = nil;
}

+ (void)deleteState {
    [ADJActivityHandler deleteActivityState];
    [ADJActivityHandler deleteAttribution];
    [ADJActivityHandler deleteGlobalCallbackParameters];
    [ADJActivityHandler deleteGlobalPartnerParameters];
    [ADJUserDefaults clearAdjustStuff];
}

+ (void)deleteActivityState {
    [ADJUtil deleteFileWithName:kActivityStateFilename];
}

+ (void)deleteAttribution {
    [ADJUtil deleteFileWithName:kAttributionFilename];
}

+ (void)deleteGlobalCallbackParameters {
    [ADJUtil deleteFileWithName:kGlobalCallbackParametersFilename];
}

+ (void)deleteGlobalPartnerParameters {
    [ADJUtil deleteFileWithName:kGlobalPartnerParametersFilename];
}

#pragma mark - internal
- (void)initI:(ADJActivityHandler *)selfI
preLaunchActions:(ADJSavedPreLaunch*)preLaunchActions
{
    // get session values
    kSessionInterval = ADJAdjustFactory.sessionInterval;
    kSubSessionInterval = ADJAdjustFactory.subsessionInterval;
    // get timer values
    kForegroundTimerStart = ADJAdjustFactory.timerStart;
    kForegroundTimerInterval = ADJAdjustFactory.timerInterval;
    kBackgroundTimerInterval = ADJAdjustFactory.timerInterval;

    selfI.packageParams = [ADJPackageParams packageParamsWithSdkPrefix:selfI.adjustConfig.sdkPrefix];

    // read files that are accessed only in Internal sections
    selfI.globalParameters = [[ADJGlobalParameters alloc] init];
    [selfI readGlobalCallbackParametersI:selfI];
    [selfI readGlobalPartnerParametersI:selfI];

    if (selfI.adjustConfig.defaultTracker != nil) {
        [selfI.logger info:@"Default tracker: '%@'", selfI.adjustConfig.defaultTracker];
    }

    if (selfI.activityState != nil) {
        NSData *pushTokenData = [ADJUserDefaults getPushTokenData];
        [selfI setPushTokenData:pushTokenData];
        NSString *pushTokenString = [ADJUserDefaults getPushTokenString];
        [selfI setPushTokenString:pushTokenString];
    }

    if (selfI.activityState != nil) {
        if ([ADJUserDefaults getGdprForgetMe]) {
            [selfI setGdprForgetMe];
        }
    }

    selfI.foregroundTimer = [ADJTimerCycle timerWithBlock:^{
        [selfI foregroundTimerFired];
    }
                                                    queue:selfI.internalQueue
                                                startTime:kForegroundTimerStart
                                             intervalTime:kForegroundTimerInterval
                                                     name:kForegroundTimerName
    ];

    if (selfI.adjustConfig.isSendingInBackgroundEnabled) {
        [selfI.logger info:@"Send in background configured"];
        selfI.backgroundTimer = [ADJTimerOnce timerWithBlock:^{ [selfI backgroundTimerFired]; }
                                                      queue:selfI.internalQueue
                                                        name:kBackgroundTimerName];
    }

    // Update Waiting for ATT status state - should be done before the package handler is created.
    selfI.internalState.waitingForAttStatus = [selfI.trackingStatusManager shouldWaitForAttStatus];

    [ADJUtil updateUrlSessionConfiguration:selfI.adjustConfig];

    ADJUrlStrategy *packageHandlerUrlStrategy =
    [[ADJUrlStrategy alloc] initWithUrlStrategyDomains:selfI.adjustConfig.urlStrategyDomains
                                             extraPath:preLaunchActions.extraPath
                                         useSubdomains:selfI.adjustConfig.useSubdomains];

    selfI.packageHandler = [[ADJPackageHandler alloc]
                                initWithActivityHandler:selfI
                                startsSending:
                                    [selfI toSendI:selfI sdkClickHandlerOnly:NO]
                                urlStrategy:packageHandlerUrlStrategy];

    ADJUrlStrategy *attributionHandlerUrlStrategy =
    [[ADJUrlStrategy alloc] initWithUrlStrategyDomains:selfI.adjustConfig.urlStrategyDomains
                                             extraPath:preLaunchActions.extraPath
                                         useSubdomains:selfI.adjustConfig.useSubdomains];

    selfI.attributionHandler = [[ADJAttributionHandler alloc]
                                    initWithActivityHandler:selfI
                                    startsSending:
                                        [selfI toSendI:selfI sdkClickHandlerOnly:NO]
                                    urlStrategy:attributionHandlerUrlStrategy];

    ADJUrlStrategy *sdkClickHandlerUrlStrategy =
    [[ADJUrlStrategy alloc] initWithUrlStrategyDomains:selfI.adjustConfig.urlStrategyDomains
                                             extraPath:preLaunchActions.extraPath
                                         useSubdomains:selfI.adjustConfig.useSubdomains];

    selfI.sdkClickHandler = [[ADJSdkClickHandler alloc]
                             initWithActivityHandler:selfI
                             startsSending:[selfI toSendI:selfI sdkClickHandlerOnly:YES]
                             urlStrategy:sdkClickHandlerUrlStrategy];
    selfI.purchaseVerificationHandler = [[ADJPurchaseVerificationHandler alloc]
                                         initWithActivityHandler:selfI
                                         startsSending:[selfI toSendI:selfI sdkClickHandlerOnly:YES]
                                         urlStrategy:sdkClickHandlerUrlStrategy];

    // Update ATT status and IDFA, if necessary, in packages and sdk_click/verify packages queues.
    // This should be done after packageHandler, sdkClickHandler and purchaseVerificationHandler are created.
    if (selfI.internalState.waitingForAttStatus) {
        selfI.internalState.updatePackagesAttData = YES;
        if (selfI.activityState != nil) {
            [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                            block:^{
                selfI.activityState.updatePackagesAttData = YES;
            }];
            [selfI writeActivityStateI:selfI];
        }
    } else {
        // update ATT Data in package queue
        if ([selfI itHasToUpdatePackagesAttDataI:selfI]) {
            [selfI updatePackagesAttStatusAndIdfaI:selfI];
        }
    }

    [selfI checkLinkMeI:selfI];
    [selfI.trackingStatusManager checkForNewAttStatus];

    [selfI preLaunchActionsI:selfI
       preLaunchActionsArray:preLaunchActions.preLaunchActionsArray];

    [selfI processCachedAttributionReadCallback];
    [selfI processCachedAdidReadCallback];

    [ADJUtil launchInMainThreadWithInactive:^(BOOL isInactive) {
        [ADJUtil launchInQueue:self.internalQueue selfInject:self block:^(ADJActivityHandler * selfI) {
            if (!isInactive) {
                [selfI.logger debug:@"Start sdk, since the app is already in the foreground"];
                [selfI handleAppForegroundI:selfI];
            } else {
                [selfI.logger debug:@"Wait for the app to go to the foreground to start the sdk"];
            }
        }];
    }];
}

- (void)handleAppForegroundI:(ADJActivityHandler *)selfI {
    if (selfI.internalState.background == NO)
        return;

    selfI.internalState.background = NO;
    [selfI activateWaitingForAttStatusI:selfI];
    [selfI stopBackgroundTimerI:selfI];
    [selfI startForegroundTimerI:selfI];
    [selfI.logger verbose:@"Subsession start"];
    [selfI startI:selfI];
}

- (void)handleAppBackgroundI:(ADJActivityHandler *)selfI {

    selfI.internalState.background = YES;
    [selfI pauseWaitingForAttStatusI:selfI];
    [selfI stopForegroundTimerI:selfI];
    [selfI startBackgroundTimerI:selfI];
    [selfI.logger verbose:@"Subsession end"];
    [selfI endI:selfI];
}

- (void)startI:(ADJActivityHandler *)selfI {
    // it shouldn't start if it was disabled after a first session
    if (selfI.activityState != nil
        && !selfI.activityState.enabled) {
        return;
    }

    [selfI updateHandlersStatusAndSendI:selfI];

    [selfI processCoppaComplianceI:selfI];

    [selfI processSessionI:selfI];

    [selfI checkAttributionStateI:selfI];

    [selfI processCachedDeeplinkI:selfI];
}

- (void)processSessionI:(ADJActivityHandler *)selfI {
    double now = [NSDate.date timeIntervalSince1970];

    // very first session
    if (selfI.activityState == nil) {
        selfI.activityState = [[ADJActivityState alloc] init];

        NSData *pushTokenData = [ADJUserDefaults getPushTokenData];
        NSString *pushTokenDataAsString = [ADJUtil pushTokenDataAsString:pushTokenData];
        NSString *pushTokenString = [ADJUserDefaults getPushTokenString];
        [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                        block:^{
            selfI.activityState.pushToken = pushTokenDataAsString != nil ? pushTokenDataAsString : pushTokenString;
        }];

        // track the first session package only if it's enabled
        if ([selfI.internalState isEnabled]) {
            // If user chose to be forgotten before install has ever tracked, don't track it.
            if ([ADJUserDefaults getGdprForgetMe]) {
                [selfI setGdprForgetMeI:selfI];
            } else {
                [selfI processCoppaComplianceI:selfI];
                if (selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray != nil) {
                    for (ADJThirdPartySharing *thirdPartySharing
                         in selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray) {
                        [selfI trackThirdPartySharingI:selfI
                                     thirdPartySharing:thirdPartySharing];
                    }

                    selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray = nil;
                }
                if (selfI.savedPreLaunch.lastMeasurementConsentTracked != nil) {
                    [selfI
                        trackMeasurementConsentI:selfI
                        enabled:[selfI.savedPreLaunch.lastMeasurementConsentTracked boolValue]];

                    selfI.savedPreLaunch.lastMeasurementConsentTracked = nil;
                }

                [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                                block:^{
                    selfI.activityState.sessionCount = 1; // this is the first session
                }];
                [selfI transferSessionPackageI:selfI now:now];
            }
        }

        [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                        block:^{
            [selfI.activityState resetSessionAttributes:now];
            selfI.activityState.enabled = [selfI.internalState isEnabled];
            selfI.activityState.updatePackagesAttData = [selfI.internalState itHasToUpdatePackagesAttData];
        }];

        if (selfI.adjustConfig.isAdServicesEnabled == YES) {
            [selfI checkForAdServicesAttributionI:selfI];
        }

        [selfI writeActivityStateI:selfI];
        [ADJUserDefaults removePushToken];

        return;
    } else {
        if (selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray != nil) {
            for (ADJThirdPartySharing *thirdPartySharing
                 in selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray) {
                [selfI trackThirdPartySharingI:selfI
                             thirdPartySharing:thirdPartySharing];
            }

            selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray = nil;
        }
        if (selfI.savedPreLaunch.lastMeasurementConsentTracked != nil) {
            [selfI
                trackMeasurementConsentI:selfI
                enabled:[selfI.savedPreLaunch.lastMeasurementConsentTracked boolValue]];

            selfI.savedPreLaunch.lastMeasurementConsentTracked = nil;
        }
    }

    double lastInterval = now - selfI.activityState.lastActivity;
    if (lastInterval < 0) {
        [selfI.logger error:@"Time travel!"];
        [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                        block:^{
            selfI.activityState.lastActivity = now;
        }];
        [selfI writeActivityStateI:selfI];
        return;
    }

    // new session
    if (lastInterval > kSessionInterval) {
        [self trackNewSessionI:now withActivityHandler:selfI];
        return;
    }

    // new subsession
    if (lastInterval > kSubSessionInterval) {
        [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                        block:^{
            selfI.activityState.subsessionCount++;
            selfI.activityState.sessionLength += lastInterval;
            selfI.activityState.lastActivity = now;
        }];
        [selfI.logger verbose:@"Started subsession %d of session %d",
         selfI.activityState.subsessionCount,
         selfI.activityState.sessionCount];
        [selfI writeActivityStateI:selfI];
        return;
    }

    [selfI.logger verbose:@"Time span since last activity too short for a new subsession"];
}

- (void)trackNewSessionI:(double)now withActivityHandler:(ADJActivityHandler *)selfI {
    if (selfI.activityState.isGdprForgotten) {
        return;
    }

    [selfI checkForAdServicesAttributionI:selfI];

    double lastInterval = now - selfI.activityState.lastActivity;
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.sessionCount++;
        selfI.activityState.lastInterval = lastInterval;
    }];
    [selfI transferSessionPackageI:selfI now:now];
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        [selfI.activityState resetSessionAttributes:now];
    }];
    [selfI writeActivityStateI:selfI];
}

- (void)transferSessionPackageI:(ADJActivityHandler *)selfI
                            now:(double)now {
    ADJPackageBuilder *sessionBuilder = [[ADJPackageBuilder alloc]
                                         initWithPackageParams:selfI.packageParams
                                         activityState:selfI.activityState
                                         config:selfI.adjustConfig
                                         globalParameters:selfI.globalParameters
                                         trackingStatusManager:self.trackingStatusManager
                                         createdAt:now];
    sessionBuilder.internalState = selfI.internalState;
    ADJActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage];
    [selfI.packageHandler addPackage:sessionPackage];
    [selfI.packageHandler sendFirstPackage];
}

- (void)checkAttributionStateI:(ADJActivityHandler *)selfI {
    if (![selfI checkActivityStateI:selfI]) return;

    // if it's the first launch
    if ([selfI.internalState isFirstLaunch]) {
        // and it hasn't received the session response
        if ([selfI.internalState hasSessionResponseNotBeenProcessed]) {
            return;
        }
    }

    // if there is already an attribution saved and there was no attribution being asked
    if (selfI.attribution != nil && !selfI.activityState.askingAttribution) {
        return;
    }

    [selfI.attributionHandler getAttribution];
}

- (void)trackAttStatusUpdateI:(ADJActivityHandler *)selfI {
    double now = [NSDate.date timeIntervalSince1970];

    ADJPackageBuilder *infoBuilder = [[ADJPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                      activityState:selfI.activityState
                                      config:selfI.adjustConfig
                                      globalParameters:selfI.globalParameters
                                      trackingStatusManager:self.trackingStatusManager
                                      createdAt:now];
    infoBuilder.internalState = selfI.internalState;

    ADJActivityPackage *infoPackage = [infoBuilder buildInfoPackage:@"att"];
    [selfI.packageHandler addPackage:infoPackage];
    [selfI.packageHandler sendFirstPackage];
}

- (void)processCachedDeeplinkI:(ADJActivityHandler *)selfI {
    if (![selfI checkActivityStateI:selfI]) return;

    NSURL *cachedDeeplinkUrl = [ADJUserDefaults getDeeplinkUrl];
    if (cachedDeeplinkUrl == nil) {
        return;
    }
    NSDate *cachedDeeplinkClickTime = [ADJUserDefaults getDeeplinkClickTime];
    if (cachedDeeplinkClickTime == nil) {
        return;
    }

    [selfI processDeeplinkI:selfI 
                        url:cachedDeeplinkUrl
                  clickTime:cachedDeeplinkClickTime];
    [ADJUserDefaults removeDeeplink];
}

- (void)endI:(ADJActivityHandler *)selfI {
    // pause sending if it's not allowed to send
    if (![selfI toSendI:selfI]) {
        [selfI pauseSendingI:selfI];
    }

    double now = [NSDate.date timeIntervalSince1970];
    if ([selfI updateActivityStateI:selfI now:now]) {
        [selfI writeActivityStateI:selfI];
    }
}

- (void)eventI:(ADJActivityHandler *)selfI
         event:(ADJEvent *)event {
    if (![selfI isEnabledI:selfI]) return;
    if (![selfI checkEventI:selfI event:event]) return;
    if (selfI.activityState.isGdprForgotten) return;
    if (![self shouldProcessEventI:selfI withDeduplicationId:event.deduplicationId]) return;

    double now = [NSDate.date timeIntervalSince1970];

    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.eventCount++;
    }];
    [selfI updateActivityStateI:selfI now:now];

    // create and populate event package
    ADJPackageBuilder *eventBuilder = [[ADJPackageBuilder alloc]
                                       initWithPackageParams:selfI.packageParams
                                       activityState:selfI.activityState
                                       config:selfI.adjustConfig
                                       globalParameters:selfI.globalParameters
                                       trackingStatusManager:self.trackingStatusManager
                                       createdAt:now];
    eventBuilder.internalState = selfI.internalState;
    ADJActivityPackage *eventPackage = [eventBuilder buildEventPackage:event];
    [selfI.packageHandler addPackage:eventPackage];
    [selfI.packageHandler sendFirstPackage];

    // if it is in the background and it can send, start the background timer
    if (selfI.adjustConfig.isSendingInBackgroundEnabled && [selfI.internalState isInBackground]) {
        [selfI startBackgroundTimerI:selfI];
    }

    [selfI writeActivityStateI:selfI];
}

- (void)trackAppStoreSubscriptionI:(ADJActivityHandler *)selfI
                      subscription:(ADJAppStoreSubscription *)subscription {
    if (!selfI.activityState) {
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // Create and submit ad revenue package.
    ADJPackageBuilder *subscriptionBuilder = [[ADJPackageBuilder alloc]
                                              initWithPackageParams:selfI.packageParams
                                              activityState:selfI.activityState
                                              config:selfI.adjustConfig
                                              globalParameters:selfI.globalParameters
                                              trackingStatusManager:self.trackingStatusManager
                                              createdAt:now];
    subscriptionBuilder.internalState = selfI.internalState;

    ADJActivityPackage *subscriptionPackage = [subscriptionBuilder buildSubscriptionPackage:subscription];
    [selfI.packageHandler addPackage:subscriptionPackage];
    [selfI.packageHandler sendFirstPackage];
}

- (BOOL)trackThirdPartySharingI:(ADJActivityHandler *)selfI
                thirdPartySharing:(nonnull ADJThirdPartySharing *)thirdPartySharing
{
    if (!selfI.activityState) {
        return NO;
    }
    if (![selfI isEnabledI:selfI]) {
        return NO;
    }
    if (selfI.activityState.isGdprForgotten) {
        return NO;
    }
    if (selfI.adjustConfig.isCoppaComplianceEnabled) {
        [selfI.logger warn:@"Calling third party sharing API not allowed when COPPA compliance is enabled"];
        return NO;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // build package
    ADJPackageBuilder *tpsBuilder = [[ADJPackageBuilder alloc]
                                     initWithPackageParams:selfI.packageParams
                                     activityState:selfI.activityState
                                     config:selfI.adjustConfig
                                     globalParameters:selfI.globalParameters
                                     trackingStatusManager:self.trackingStatusManager
                                     createdAt:now];
    tpsBuilder.internalState = selfI.internalState;
    ADJActivityPackage *dtpsPackage = [tpsBuilder buildThirdPartySharingPackage:thirdPartySharing];

    [selfI.packageHandler addPackage:dtpsPackage];
    [selfI.packageHandler sendFirstPackage];

    return YES;
}

- (BOOL)trackMeasurementConsentI:(ADJActivityHandler *)selfI
                         enabled:(BOOL)enabled
{
    if (!selfI.activityState) {
        return NO;
    }
    if (![selfI isEnabledI:selfI]) {
        return NO;
    }
    if (selfI.activityState.isGdprForgotten) {
        return NO;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // build package
    ADJPackageBuilder *mcBuilder = [[ADJPackageBuilder alloc]
                                    initWithPackageParams:selfI.packageParams
                                    activityState:selfI.activityState
                                    config:selfI.adjustConfig
                                    globalParameters:selfI.globalParameters
                                    trackingStatusManager:self.trackingStatusManager
                                    createdAt:now];
    mcBuilder.internalState = selfI.internalState;
    ADJActivityPackage *mcPackage = [mcBuilder buildMeasurementConsentPackage:enabled];

    [selfI.packageHandler addPackage:mcPackage];
    [selfI.packageHandler sendFirstPackage];

    return YES;
}

- (void)trackAdRevenueI:(ADJActivityHandler *)selfI
              adRevenue:(ADJAdRevenue *)adRevenue
{
    if (!selfI.activityState) {
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }
    if (![selfI checkAdRevenueI:selfI adRevenue:adRevenue]) {
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];

    // Create and submit ad revenue package.
    ADJPackageBuilder *adRevenueBuilder = [[ADJPackageBuilder alloc] initWithPackageParams:selfI.packageParams
                                                                             activityState:selfI.activityState
                                                                                    config:selfI.adjustConfig
                                                                          globalParameters:selfI.globalParameters
                                                                     trackingStatusManager:self.trackingStatusManager
                                                                                 createdAt:now];
    adRevenueBuilder.internalState = selfI.internalState;

    ADJActivityPackage *adRevenuePackage = [adRevenueBuilder buildAdRevenuePackage:adRevenue];
    [selfI.packageHandler addPackage:adRevenuePackage];
    [selfI.packageHandler sendFirstPackage];
}

- (void)verifyAppStorePurchaseI:(ADJActivityHandler *)selfI
                       purchase:(nonnull ADJAppStorePurchase *)purchase
          withCompletionHandler:(nonnull ADJVerificationResultBlock)completion {
    if ([ADJUtil isNull:completion]) {
        [selfI.logger warn:@"Purchase verification aborted because completion handler is null"];
        return;
    }
    if (selfI.adjustConfig.isDataResidency) {
        [selfI.logger warn:@"Purchase verification not available for data residency users right now"];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 109;
        verificationResult.message = @"Purchase verification not available for data residency users right now";
        completion(verificationResult);
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        [selfI.logger warn:@"Purchase verification aborted because SDK is disabled"];
        return;
    }
    if ([ADJUtil isNull:purchase]) {
        [selfI.logger warn:@"Purchase verification aborted because purchase instance is null"];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 101;
        verificationResult.message = @"Purchase verification aborted because purchase instance is null";
        completion(verificationResult);
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        double lastInterval = now - selfI.activityState.lastActivity;
        selfI.activityState.lastInterval = lastInterval;
    }];

    ADJPackageBuilder *purchaseVerificationBuilder = 
    [[ADJPackageBuilder alloc] initWithPackageParams:selfI.packageParams
                                       activityState:selfI.activityState
                                              config:selfI.adjustConfig
                                    globalParameters:selfI.globalParameters
                               trackingStatusManager:self.trackingStatusManager
                                           createdAt:now];
    purchaseVerificationBuilder.internalState = selfI.internalState;

    ADJActivityPackage *purchaseVerificationPackage = 
    [purchaseVerificationBuilder buildPurchaseVerificationPackageWithPurchase:purchase];
    purchaseVerificationPackage.purchaseVerificationCallback = completion;
    [selfI.purchaseVerificationHandler sendPurchaseVerificationPackage:purchaseVerificationPackage];
}

- (void)verifyAndTrackAppStorePurchaseI:(ADJActivityHandler *)selfI
                                  event:(nonnull ADJEvent *)event
                  withCompletionHandler:(nonnull ADJVerificationResultBlock)completion {
    if ([ADJUtil isNull:completion]) {
        [selfI.logger warn:@"Purchase verification aborted because completion handler is null"];
        return;
    }
    if (selfI.adjustConfig.isDataResidency) {
        [selfI.logger warn:@"Purchase verification not available for data residency users right now"];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 109;
        verificationResult.message = @"Purchase verification not available for data residency users right now";
        completion(verificationResult);
        return;
    }
    if (![selfI isEnabledI:selfI]) {
        [selfI.logger warn:@"Purchase verification aborted because SDK is disabled"];
        return;
    }
    if ([ADJUtil isNull:event]) {
        [selfI.logger warn:@"Purchase verification aborted because event instance is null"];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 101;
        verificationResult.message = @"Purchase verification aborted because purchase instance is null";
        completion(verificationResult);
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        double lastInterval = now - selfI.activityState.lastActivity;
        selfI.activityState.lastInterval = lastInterval;
    }];
    ADJPackageBuilder *purchaseVerificationBuilder =
    [[ADJPackageBuilder alloc] initWithPackageParams:selfI.packageParams
                                       activityState:selfI.activityState
                                              config:selfI.adjustConfig
                                    globalParameters:selfI.globalParameters
                               trackingStatusManager:self.trackingStatusManager
                                           createdAt:now];

    ADJActivityPackage *purchaseVerificationPackage =
    [purchaseVerificationBuilder buildPurchaseVerificationPackageWithEvent:event];
    purchaseVerificationPackage.purchaseVerificationCallback = completion;
    purchaseVerificationPackage.event = event;
    [selfI.purchaseVerificationHandler sendPurchaseVerificationPackage:purchaseVerificationPackage];
}

- (void)launchEventResponseTasksI:(ADJActivityHandler *)selfI
                eventResponseData:(ADJEventResponseData *)eventResponseData {
    [selfI updateAdidI:selfI adid:eventResponseData.adid];

    // event success callback
    if (eventResponseData.success
        && [selfI.adjustDelegate respondsToSelector:@selector(adjustEventTrackingSucceeded:)])
    {
        [selfI.logger debug:@"Launching success event tracking delegate"];
        [ADJUtil launchInMainThread:selfI.adjustDelegate
                           selector:@selector(adjustEventTrackingSucceeded:)
                         withObject:[eventResponseData successResponseData]];
        return;
    }
    // event failure callback
    if (!eventResponseData.success
        && [selfI.adjustDelegate respondsToSelector:@selector(adjustEventTrackingFailed:)])
    {
        [selfI.logger debug:@"Launching failed event tracking delegate"];
        [ADJUtil launchInMainThread:selfI.adjustDelegate
                           selector:@selector(adjustEventTrackingFailed:)
                         withObject:[eventResponseData failureResponseData]];
        return;
    }
}

- (void)launchSessionResponseTasksI:(ADJActivityHandler *)selfI
                sessionResponseData:(ADJSessionResponseData *)sessionResponseData {
    [selfI updateAdidI:selfI adid:sessionResponseData.adid];

    BOOL toLaunchAttributionDelegate = [selfI updateAttributionI:selfI attribution:sessionResponseData.attribution];

    // mark install as tracked on success
    if (sessionResponseData.success) {
        [ADJUserDefaults setInstallTracked];
    }

    // session success callback
    if (sessionResponseData.success
        && [selfI.adjustDelegate respondsToSelector:@selector(adjustSessionTrackingSucceeded:)])
    {
        [selfI.logger debug:@"Launching success session tracking delegate"];
        [ADJUtil launchInMainThread:selfI.adjustDelegate
                           selector:@selector(adjustSessionTrackingSucceeded:)
                         withObject:[sessionResponseData successResponseData]];
    }
    // session failure callback
    if (!sessionResponseData.success
        && [selfI.adjustDelegate respondsToSelector:@selector(adjustSessionTrackingFailed:)])
    {
        [selfI.logger debug:@"Launching failed session tracking delegate"];
        [ADJUtil launchInMainThread:selfI.adjustDelegate
                           selector:@selector(adjustSessionTrackingFailed:)
                         withObject:[sessionResponseData failureResponseData]];
    }

    // try to update and launch the attribution changed delegate
    if (toLaunchAttributionDelegate) {
        [selfI.logger debug:@"Launching attribution changed delegate"];
        [ADJUtil launchInMainThread:selfI.adjustDelegate
                           selector:@selector(adjustAttributionChanged:)
                         withObject:sessionResponseData.attribution];
    }

    // if attribution didn't update and it's still null -> ask for attribution
    if (selfI.attribution == nil && selfI.activityState.askingAttribution == NO) {
        [selfI.attributionHandler getAttribution];
    }

    selfI.internalState.sessionResponseProcessed = YES;
}

- (void)launchSdkClickResponseTasksI:(ADJActivityHandler *)selfI
                sdkClickResponseData:(ADJSdkClickResponseData *)sdkClickResponseData {
    [selfI updateAdidI:selfI adid:sdkClickResponseData.adid];

    BOOL toLaunchAttributionDelegate = [selfI updateAttributionI:selfI attribution:sdkClickResponseData.attribution];

    // try to update and launch the attribution changed delegate
    if (toLaunchAttributionDelegate) {
        [selfI.logger debug:@"Launching attribution changed delegate"];
        [ADJUtil launchInMainThread:selfI.adjustDelegate
                           selector:@selector(adjustAttributionChanged:)
                         withObject:sdkClickResponseData.attribution];
    }

    // check if we got resolved deep link in the response
    if (sdkClickResponseData.resolvedDeeplink != nil) {
        if (selfI.cachedDeeplinkResolutionCallback != nil) {
            NSString *resolvedDeepLink = sdkClickResponseData.resolvedDeeplink;
            ADJResolvedDeeplinkBlock callback = selfI.cachedDeeplinkResolutionCallback;
            [ADJUtil launchInMainThread:^{
                callback(resolvedDeepLink);
            }];
            selfI.cachedDeeplinkResolutionCallback = nil;
        }
    }
}

- (void)launchAttributionResponseTasksI:(ADJActivityHandler *)selfI
                attributionResponseData:(ADJAttributionResponseData *)attributionResponseData {
    [selfI checkConversionValue:attributionResponseData];

    [selfI updateAdidI:selfI adid:attributionResponseData.adid];

    BOOL toLaunchAttributionDelegate = [selfI updateAttributionI:selfI
                                                     attribution:attributionResponseData.attribution];

    // try to update and launch the attribution changed delegate non-blocking
    if (toLaunchAttributionDelegate) {
        [selfI.logger debug:@"Launching attribution changed delegate"];
        [ADJUtil launchInMainThread:selfI.adjustDelegate
                           selector:@selector(adjustAttributionChanged:)
                         withObject:attributionResponseData.attribution];
    }

    [selfI prepareDeeplinkI:selfI responseData:attributionResponseData];
}

- (void)launchPurchaseVerificationResponseTasksI:(ADJActivityHandler *)selfI
                purchaseVerificationResponseData:(ADJPurchaseVerificationResponseData *)purchaseVerificationResponseData {
    [selfI.logger debug:
        @"Got purchase_verification JSON response with message: %@", purchaseVerificationResponseData.message];
    ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
    verificationResult.verificationStatus = purchaseVerificationResponseData.jsonResponse[@"verification_status"];
    verificationResult.code = [(NSNumber *)purchaseVerificationResponseData.jsonResponse[@"code"] intValue];
    verificationResult.message = purchaseVerificationResponseData.jsonResponse[@"message"];
    purchaseVerificationResponseData.purchaseVerificationPackage.purchaseVerificationCallback(verificationResult);

    if (purchaseVerificationResponseData.purchaseVerificationPackage &&
        purchaseVerificationResponseData.purchaseVerificationPackage.event)
    {
        [self trackEvent:purchaseVerificationResponseData.purchaseVerificationPackage.event];
    }
}

- (void)prepareDeeplinkI:(ADJActivityHandler *)selfI
            responseData:(ADJAttributionResponseData *)attributionResponseData {
    if (attributionResponseData == nil) {
        return;
    }

    if (attributionResponseData.deeplink == nil) {
        return;
    }

    [selfI.logger info:@"Open deep link (%@)", attributionResponseData.deeplink.absoluteString];

    [ADJUtil launchInMainThread:^{
        BOOL toLaunchDeeplink = YES;

        if ([selfI.adjustDelegate respondsToSelector:@selector(adjustDeferredDeeplinkReceived:)]) {
            toLaunchDeeplink = [selfI.adjustDelegate
                                adjustDeferredDeeplinkReceived:attributionResponseData.deeplink];
        }

        if (toLaunchDeeplink) {
            [ADJUtil launchDeepLinkMain:attributionResponseData.deeplink];
        }
    }];
}

- (void)updateAdidI:(ADJActivityHandler *)selfI
               adid:(NSString *)adid {
    if (adid == nil) {
        return;
    }

    if ([adid isEqualToString:selfI.activityState.adid]) {
        return;
    }

    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.adid = adid;
    }];
    [selfI writeActivityStateI:selfI];
    [selfI processCachedAdidReadCallback];
}

- (BOOL)updateAttributionI:(ADJActivityHandler *)selfI
               attribution:(ADJAttribution *)attribution {
    if (attribution == nil) {
        return NO;
    }
    if ([attribution isEqual:selfI.attribution]) {
        return NO;
    }
    // copy attribution property
    //  to avoid using the same object for the delegate
    selfI.attribution = attribution;
    [selfI writeAttributionI:selfI];

    [selfI processCachedAttributionReadCallback];

    if (selfI.adjustDelegate == nil) {
        return NO;
    }

    if (![selfI.adjustDelegate respondsToSelector:@selector(adjustAttributionChanged:)]) {
        return NO;
    }

    return YES;
}

- (void)processCachedAttributionReadCallback {
    __block ADJAttribution *_Nullable localAttribution = self.attribution;
    if (localAttribution == nil) {
        return;
    }
    if (self.savedPreLaunch.cachedAttributionReadCallbacksArray == nil) {
        return;
    }

    for (ADJAttributionGetterBlock attributionCallback in
         self.savedPreLaunch.cachedAttributionReadCallbacksArray) {
        __block ADJAttributionGetterBlock localAttributionCallback = attributionCallback;
        [ADJUtil launchInMainThread:^{
            localAttributionCallback(localAttribution);
        }];
    }

    [self.savedPreLaunch.cachedAttributionReadCallbacksArray removeAllObjects];
}

- (void)processCachedAdidReadCallback {
    __block NSString *_Nullable localAdid = self.activityState == nil ? nil : self.activityState.adid;
    if (localAdid == nil) {
        return;
    }
    if (self.savedPreLaunch.cachedAdidReadCallbacksArray == nil) {
        return;
    }

    for (ADJAdidGetterBlock adidCallback in self.savedPreLaunch.cachedAdidReadCallbacksArray) {
        __block ADJAdidGetterBlock localAdidCallback = adidCallback;
        [ADJUtil launchInMainThread:^{
            localAdidCallback(localAdid);
        }];
    }

    [self.savedPreLaunch.cachedAdidReadCallbacksArray removeAllObjects];
}

- (void)setEnabledI:(ADJActivityHandler *)selfI enabled:(BOOL)enabled {
    // compare with the saved or internal state
    if (![selfI hasChangedStateI:selfI
                   previousState:[selfI isEnabledI:selfI]
                       nextState:enabled
                     trueMessage:@"Adjust already enabled"
                    falseMessage:@"Adjust already disabled"]) {
        return;
    }

    // If user is forgotten, forbid re-enabling.
    if (enabled) {
        if ([selfI isGdprForgottenI:selfI]) {
            [selfI.logger debug:@"Re-enabling SDK for forgotten user not allowed"];
            return;
        }
    }

    // save new enabled state in internal state
    selfI.internalState.enabled = enabled;

    if (selfI.activityState == nil) {
        [selfI checkStatusI:selfI
               pausingState:!enabled
              pausingMessage:@"Handlers will start as paused due to the SDK being disabled"
        remainsPausedMessage:@"Handlers will still start as paused"
            unPausingMessage:@"Handlers will start as active due to the SDK being enabled"];
        return;
    }

    // Save new enabled state in activity state.
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.enabled = enabled;
    }];
    [selfI writeActivityStateI:selfI];

    // Check if upon enabling install has been tracked.
    if (enabled) {
        if ([ADJUserDefaults getGdprForgetMe]) {
            [selfI setGdprForgetMe];
        } else {
            [selfI processCoppaComplianceI:selfI];
            if (selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray != nil) {
                for (ADJThirdPartySharing *thirdPartySharing
                     in selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray)
                {
                    [selfI trackThirdPartySharingI:selfI thirdPartySharing:thirdPartySharing];
                }

                selfI.savedPreLaunch.preLaunchAdjustThirdPartySharingArray = nil;
            }
            if (selfI.savedPreLaunch.lastMeasurementConsentTracked != nil) {
                [selfI
                    trackMeasurementConsent:
                        [selfI.savedPreLaunch.lastMeasurementConsentTracked boolValue]];

                selfI.savedPreLaunch.lastMeasurementConsentTracked = nil;
            }

            [selfI checkLinkMeI:selfI];
        }

        if (![ADJUserDefaults getInstallTracked]) {
            double now = [NSDate.date timeIntervalSince1970];
            [self trackNewSessionI:now withActivityHandler:selfI];
        }
        NSData *pushTokenData = [ADJUserDefaults getPushTokenData];
        if (pushTokenData != nil && ![selfI.activityState.pushToken isEqualToString:[ADJUtil pushTokenDataAsString:pushTokenData]]) {
            [self setPushTokenData:pushTokenData];
        }
        NSString *pushTokenString = [ADJUserDefaults getPushTokenString];
        if (pushTokenString != nil && ![selfI.activityState.pushToken isEqualToString:pushTokenString]) {
            [self setPushTokenString:pushTokenString];
        }
        if (selfI.adjustConfig.isAdServicesEnabled == YES) {
            [selfI checkForAdServicesAttributionI:selfI];
        }
    }

    [selfI checkStatusI:selfI
           pausingState:!enabled
          pausingMessage:@"Pausing handlers due to SDK being disabled"
    remainsPausedMessage:@"Handlers remain paused"
        unPausingMessage:@"Resuming handlers due to SDK being enabled"];
}

- (BOOL)shouldFetchAdServicesI:(ADJActivityHandler *)selfI {
    if (selfI.adjustConfig.isAdServicesEnabled == NO) {
        return NO;
    }
    
    // Fetch if no attribution OR not sent to backend yet
    if ([ADJUserDefaults getAdServicesTracked]) {
        [selfI.logger debug:@"AdServices attribution info already read"];
    }
    return (selfI.attribution == nil || ![ADJUserDefaults getAdServicesTracked]);
}

- (void)checkForAdServicesAttributionI:(ADJActivityHandler *)selfI {
    if (@available(iOS 14.3, tvOS 14.3, *)) {
        if ([selfI shouldFetchAdServicesI:selfI]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error = nil;
                NSString *token = [ADJUtil fetchAdServicesAttribution:&error];
                [selfI setAdServicesAttributionToken:token error:error];
            });
        }
    }
}

- (void)setOfflineModeI:(ADJActivityHandler *)selfI
                offline:(BOOL)offline {
    // compare with the internal state
    if (![selfI hasChangedStateI:selfI
                   previousState:[selfI.internalState isOffline]
                       nextState:offline
                     trueMessage:@"Adjust already in offline mode"
                    falseMessage:@"Adjust already in online mode"])
    {
        return;
    }

    // save new offline state in internal state
    selfI.internalState.offline = offline;

    if (selfI.activityState == nil) {
        [selfI checkStatusI:selfI
               pausingState:offline
             pausingMessage:@"Handlers will start paused due to SDK being offline"
       remainsPausedMessage:@"Handlers will still start as paused"
           unPausingMessage:@"Handlers will start as active due to SDK being online"];
        return;
    }

    [selfI checkStatusI:selfI
           pausingState:offline
         pausingMessage:@"Pausing handlers to put SDK offline mode"
   remainsPausedMessage:@"Handlers remain paused"
       unPausingMessage:@"Resuming handlers to put SDK in online mode"];
}

- (void)isEnabledI:(ADJActivityHandler *)selfI withCompletionHandler:(ADJIsEnabledGetterBlock)completion {
    __block ADJIsEnabledGetterBlock localIsEnabledCallback = completion;
    [ADJUtil launchInMainThread:^{
        localIsEnabledCallback([selfI isEnabledI:selfI]);
    }];
}

- (BOOL)hasChangedStateI:(ADJActivityHandler *)selfI
           previousState:(BOOL)previousState
               nextState:(BOOL)nextState
             trueMessage:(NSString *)trueMessage
            falseMessage:(NSString *)falseMessage
{
    if (previousState != nextState) {
        return YES;
    }

    if (previousState) {
        [selfI.logger debug:trueMessage];
    } else {
        [selfI.logger debug:falseMessage];
    }

    return NO;
}

- (void)checkStatusI:(ADJActivityHandler *)selfI
        pausingState:(BOOL)pausingState
      pausingMessage:(NSString *)pausingMessage
remainsPausedMessage:(NSString *)remainsPausedMessage
    unPausingMessage:(NSString *)unPausingMessage
{
    // it is changing from an active state to a pause state
    if (pausingState) {
        [selfI.logger info:pausingMessage];
    }
    // check if it's remaining in a pause state
    else if ([selfI pausedI:selfI sdkClickHandlerOnly:NO]) {
        // including the sdk click handler
        if ([selfI pausedI:selfI sdkClickHandlerOnly:YES]) {
            [selfI.logger info:remainsPausedMessage];
        } else {
            // or except it
            [selfI.logger info:[remainsPausedMessage stringByAppendingString:@", except the Sdk Click Handler"]];
        }
    } else {
        // it is changing from a pause state to an active state
        [selfI.logger info:unPausingMessage];
    }

    [selfI updateHandlersStatusAndSendI:selfI];
}

- (void)processDeeplinkI:(ADJActivityHandler *)selfI
                     url:(NSURL *)deeplink
               clickTime:(NSDate *)clickTime {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if ([ADJUtil isNull:deeplink]) {
        return;
    }
    if (![ADJUtil isDeeplinkValid:deeplink]) {
        return;
    }

    NSArray *queryArray = [deeplink.query componentsSeparatedByString:@"&"];
    if (queryArray == nil) {
        queryArray = @[];
    }

    NSMutableDictionary *adjustDeepLinks = [NSMutableDictionary dictionary];
    ADJAttribution *deeplinkAttribution = [[ADJAttribution alloc] init];
    for (NSString *fieldValuePair in queryArray) {
        [selfI readDeeplinkQueryStringI:selfI
                            queryString:fieldValuePair
                        adjustDeepLinks:adjustDeepLinks
                            attribution:deeplinkAttribution];
    }

    double now = [NSDate.date timeIntervalSince1970];
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        double lastInterval = now - selfI.activityState.lastActivity;
        selfI.activityState.lastInterval = lastInterval;
    }];
    ADJPackageBuilder *clickBuilder =
    [[ADJPackageBuilder alloc] initWithPackageParams:selfI.packageParams
                                       activityState:selfI.activityState
                                              config:selfI.adjustConfig
                                    globalParameters:selfI.globalParameters
                               trackingStatusManager:self.trackingStatusManager
                                           createdAt:now];
    clickBuilder.internalState = selfI.internalState;
    clickBuilder.deeplinkParameters = [adjustDeepLinks copy];
    clickBuilder.attribution = deeplinkAttribution;
    clickBuilder.clickTime = clickTime;
    clickBuilder.deeplink = [deeplink absoluteString];

    ADJActivityPackage *clickPackage = [clickBuilder buildClickPackage:@"deeplink"];
    [selfI.sdkClickHandler sendSdkClick:clickPackage];
}

- (BOOL)readDeeplinkQueryStringI:(ADJActivityHandler *)selfI
                     queryString:(NSString *)queryString
                 adjustDeepLinks:(NSMutableDictionary*)adjustDeepLinks
                     attribution:(ADJAttribution *)deeplinkAttribution
{
    NSArray* pairComponents = [queryString componentsSeparatedByString:@"="];
    if (pairComponents.count != 2) return NO;

    NSString* key = [pairComponents objectAtIndex:0];
    if (![key hasPrefix:kAdjustPrefix]) return NO;

    // NSString* keyDecoded = [key adjUrlDecode];
    NSString *keyDecoded = [ADJAdditions adjUrlDecode:key];

    NSString* value = [pairComponents objectAtIndex:1];
    if (value.length == 0) return NO;

    // NSString* valueDecoded = [value adjUrlDecode];
    NSString *valueDecoded = [ADJAdditions adjUrlDecode:value];
    if (!valueDecoded) return NO;

    NSString* keyWOutPrefix = [keyDecoded substringFromIndex:kAdjustPrefix.length];
    if (keyWOutPrefix.length == 0) return NO;

    if (![selfI trySetAttributionDeeplink:deeplinkAttribution withKey:keyWOutPrefix withValue:valueDecoded]) {
        [adjustDeepLinks setObject:valueDecoded forKey:keyWOutPrefix];
    }

    return YES;
}

- (BOOL)trySetAttributionDeeplink:(ADJAttribution *)deeplinkAttribution
                          withKey:(NSString *)key
                        withValue:(NSString*)value
{
    if ([key isEqualToString:@"tracker"]) {
        deeplinkAttribution.trackerName = value;
        return YES;
    }

    if ([key isEqualToString:@"campaign"]) {
        deeplinkAttribution.campaign = value;
        return YES;
    }

    if ([key isEqualToString:@"adgroup"]) {
        deeplinkAttribution.adgroup = value;
        return YES;
    }

    if ([key isEqualToString:@"creative"]) {
        deeplinkAttribution.creative = value;
        return YES;
    }

    return NO;
}

- (void)setPushTokenI:(ADJActivityHandler *)selfI
        pushTokenData:(NSData *)pushTokenData {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (!selfI.activityState) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }

    NSString *pushTokenDataAsString = [ADJUtil pushTokenDataAsString:pushTokenData];

    if (pushTokenDataAsString == nil) {
        return;
    }
    if ([pushTokenDataAsString isEqualToString:selfI.activityState.pushToken]) {
        return;
    }

    // save new push token
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.pushToken = pushTokenDataAsString;
    }];
    [selfI writeActivityStateI:selfI];

    // send info package
    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder *infoBuilder = [[ADJPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                      activityState:selfI.activityState
                                      config:selfI.adjustConfig
                                      globalParameters:selfI.globalParameters
                                      trackingStatusManager:self.trackingStatusManager
                                      createdAt:now];
    infoBuilder.internalState = selfI.internalState;
    ADJActivityPackage *infoPackage = [infoBuilder buildInfoPackage:@"push"];
    [selfI.packageHandler addPackage:infoPackage];
    [selfI.packageHandler sendFirstPackage];

    // if push token was cached, remove it
    [ADJUserDefaults removePushToken];
}

- (void)setPushTokenI:(ADJActivityHandler *)selfI
      pushTokenString:(NSString *)pushTokenString {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (!selfI.activityState) {
        return;
    }
    if (selfI.activityState.isGdprForgotten) {
        return;
    }
    if (pushTokenString == nil) {
        return;
    }
    if ([pushTokenString isEqualToString:selfI.activityState.pushToken]) {
        return;
    }

    // save new push token
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.pushToken = pushTokenString;
    }];
    [selfI writeActivityStateI:selfI];

    // send info package
    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder *infoBuilder = [[ADJPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                      activityState:selfI.activityState
                                      config:selfI.adjustConfig
                                      globalParameters:selfI.globalParameters
                                      trackingStatusManager:self.trackingStatusManager
                                      createdAt:now];
    infoBuilder.internalState = selfI.internalState;
    ADJActivityPackage *infoPackage = [infoBuilder buildInfoPackage:@"push"];
    [selfI.packageHandler addPackage:infoPackage];
    [selfI.packageHandler sendFirstPackage];

    // if push token was cached, remove it
    [ADJUserDefaults removePushToken];
}

- (void)setGdprForgetMeI:(ADJActivityHandler *)selfI {
    if (![selfI isEnabledI:selfI]) {
        return;
    }
    if (!selfI.activityState) {
        return;
    }
    if (selfI.activityState.isGdprForgotten == YES) {
        [ADJUserDefaults removeGdprForgetMe];
        return;
    }

    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.isGdprForgotten = YES;
    }];
    [selfI writeActivityStateI:selfI];

    // Send GDPR package
    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder *gdprBuilder = [[ADJPackageBuilder alloc]
                                      initWithPackageParams:selfI.packageParams
                                      activityState:selfI.activityState
                                      config:selfI.adjustConfig
                                      globalParameters:selfI.globalParameters
                                      trackingStatusManager:self.trackingStatusManager
                                      createdAt:now];
    gdprBuilder.internalState = selfI.internalState;
    ADJActivityPackage *gdprPackage = [gdprBuilder buildGdprPackage];
    [selfI.packageHandler addPackage:gdprPackage];
    [selfI.packageHandler sendFirstPackage];

    [ADJUserDefaults removeGdprForgetMe];
}

- (void)setTrackingStateOptedOutI:(ADJActivityHandler *)selfI {
    // In case of web opt out, once response from backend arrives isGdprForgotten field in this moment defaults to NO.
    // Set it to YES regardless of state, since at this moment it should be YES.
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.isGdprForgotten = YES;
    }];
    [selfI writeActivityStateI:selfI];

    [selfI setEnabled:NO];
    [selfI.packageHandler flush];
}

- (void)checkLinkMeI:(ADJActivityHandler *)selfI {
#if TARGET_OS_IOS
    if (@available(iOS 15.0, *)) {
        if (selfI.adjustConfig.isLinkMeEnabled == NO) {
            [self.logger debug:@"LinkMe not allowed by client"];
            return;
        }
        if ([ADJUserDefaults getLinkMeChecked] == YES) {
            [self.logger debug:@"LinkMe already checked"];
            return;
        }
        if (selfI.internalState.isFirstLaunch == NO) {
            [self.logger debug:@"LinkMe only valid for install"];
            return;
        }
        if ([ADJUserDefaults getGdprForgetMe]) {
            [self.logger debug:@"LinkMe not happening for GDPR forgotten user"];
            return;
        }
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        if ([pasteboard hasURLs] == NO) {
            [self.logger debug:@"LinkMe general board not found"];
            return;
        }
        
        NSURL *pasteboardUrl = [pasteboard URL];
        if (pasteboardUrl == nil) {
            [self.logger debug:@"LinkMe content not found"];
            return;
        }
        
        NSString *pasteboardUrlString = [pasteboardUrl absoluteString];
        if (pasteboardUrlString == nil) {
            [self.logger debug:@"LinkMe content could not be converted to string"];
            return;
        }
        
        // send sdk_click
        double now = [NSDate.date timeIntervalSince1970];
        ADJPackageBuilder *clickBuilder = [[ADJPackageBuilder alloc] initWithPackageParams:selfI.packageParams
                                                                             activityState:selfI.activityState
                                                                                    config:selfI.adjustConfig
                                                                          globalParameters:selfI.globalParameters
                                                                     trackingStatusManager:self.trackingStatusManager
                                                                                 createdAt:now];
        clickBuilder.internalState = selfI.internalState;
        clickBuilder.clickTime = [NSDate dateWithTimeIntervalSince1970:now];
        ADJActivityPackage *clickPackage = [clickBuilder buildClickPackage:@"linkme" linkMeUrl:pasteboardUrlString];
        [selfI.sdkClickHandler sendSdkClick:clickPackage];
        
        [ADJUserDefaults setLinkMeChecked];
    } else {
        [self.logger warn:@"LinkMe feature is supported on iOS 15.0 and above"];
    }
#endif
}

#pragma mark - private

- (BOOL)isEnabledI:(ADJActivityHandler *)selfI {
    if (selfI.activityState != nil) {
        return selfI.activityState.enabled;
    } else {
        return [selfI.internalState isEnabled];
    }
}

- (BOOL)isGdprForgottenI:(ADJActivityHandler *)selfI {
    if (selfI.activityState != nil) {
        return selfI.activityState.isGdprForgotten;
    } else {
        return NO;
    }
}

- (BOOL)itHasToUpdatePackagesAttDataI:(ADJActivityHandler *)selfI {
    if (selfI.activityState != nil) {
        return selfI.activityState.updatePackagesAttData;
    } else {
        return [selfI.internalState itHasToUpdatePackagesAttData];
    }
}

// returns whether or not the activity state should be written
- (BOOL)updateActivityStateI:(ADJActivityHandler *)selfI
                         now:(double)now {
    if (![selfI checkActivityStateI:selfI]) return NO;

    double lastInterval = now - selfI.activityState.lastActivity;

    // ignore late updates
    if (lastInterval > kSessionInterval) return NO;

    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.lastActivity = now;
    }];

    if (lastInterval < 0) {
        [selfI.logger error:@"Time travel!"];
        return YES;
    } else {
        [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                        block:^{
            selfI.activityState.sessionLength += lastInterval;
            selfI.activityState.timeSpent += lastInterval;
        }];
    }

    return YES;
}

- (void)writeActivityStateI:(ADJActivityHandler *)selfI
{
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        if (selfI.activityState == nil) {
            return;
        }
        [ADJUtil writeObject:selfI.activityState
                    fileName:kActivityStateFilename
                  objectName:@"Activity state"
                  syncObject:[ADJActivityState class]];
    }];
}

- (void)teardownActivityStateS
{
    @synchronized ([ADJActivityState class]) {
        if (self.activityState == nil) {
            return;
        }
        self.activityState = nil;
    }
}

- (void)writeAttributionI:(ADJActivityHandler *)selfI {
    @synchronized ([ADJAttribution class]) {
        if (selfI.attribution == nil) {
            return;
        }
        [ADJUtil writeObject:selfI.attribution
                    fileName:kAttributionFilename
                  objectName:@"Attribution"
                  syncObject:[ADJAttribution class]];
    }
}

- (void)teardownAttributionS
{
    @synchronized ([ADJAttribution class]) {
        if (self.attribution == nil) {
            return;
        }
        self.attribution = nil;
    }
}

- (void)readActivityState {
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        [NSKeyedUnarchiver setClass:[ADJActivityState class] forClassName:@"AIActivityState"];
        self.activityState = [ADJUtil readObject:kActivityStateFilename
                                      objectName:@"Activity state"
                                           class:[ADJActivityState class]
                                      syncObject:[ADJActivityState class]];
    }];
}

- (void)readAttribution {
    self.attribution = [ADJUtil readObject:kAttributionFilename
                                objectName:@"Attribution"
                                     class:[ADJAttribution class]
                                syncObject:[ADJAttribution class]];
}

- (void)writeGlobalCallbackParametersI:(ADJActivityHandler *)selfI {
    @synchronized ([ADJGlobalParameters class]) {
        if (selfI.globalParameters == nil) {
            return;
        }
        [ADJUtil writeObject:selfI.globalParameters.callbackParameters
                    fileName:kGlobalCallbackParametersFilename
                  objectName:@"Global Callback parameters"
                  syncObject:[ADJGlobalParameters class]];
    }
}

- (void)writeGlobalPartnerParametersI:(ADJActivityHandler *)selfI {
    @synchronized ([ADJGlobalParameters class]) {
        if (selfI.globalParameters == nil) {
            return;
        }
        [ADJUtil writeObject:selfI.globalParameters.partnerParameters
                    fileName:kGlobalPartnerParametersFilename
                  objectName:@"Global Partner parameters"
                  syncObject:[ADJGlobalParameters class]];
    }
}

- (void)teardownAllGlobalParametersS {
    @synchronized ([ADJGlobalParameters class]) {
        if (self.globalParameters == nil) {
            return;
        }
        [self.globalParameters.callbackParameters removeAllObjects];
        [self.globalParameters.partnerParameters removeAllObjects];
        self.globalParameters = nil;
    }
}

- (void)readGlobalCallbackParametersI:(ADJActivityHandler *)selfI {
    selfI.globalParameters.callbackParameters = [ADJUtil readObject:kGlobalCallbackParametersFilename
                                                         objectName:@"Global Callback parameters"
                                                              class:[NSDictionary class]
                                                         syncObject:[ADJGlobalParameters class]];
}

- (void)readGlobalPartnerParametersI:(ADJActivityHandler *)selfI {
    selfI.globalParameters.partnerParameters = [ADJUtil readObject:kGlobalPartnerParametersFilename
                                                        objectName:@"Global Partner parameters"
                                                             class:[NSDictionary class]
                                                        syncObject:[ADJGlobalParameters class]];
}

# pragma mark - handlers status
- (void)updateHandlersStatusAndSendI:(ADJActivityHandler *)selfI {
    // check if it should stop sending
    if (![selfI toSendI:selfI]) {
        [selfI pauseSendingI:selfI];
        return;
    }

    [selfI resumeSendingI:selfI];

    // try to send
    [selfI.packageHandler sendFirstPackage];
}

- (void)pauseSendingI:(ADJActivityHandler *)selfI {
    [selfI.attributionHandler pauseSending];
    [selfI.packageHandler pauseSending];
    // the conditions to pause the sdk click handler are less restrictive
    // it's possible for the sdk click handler to be active while others are paused
    if (![selfI toSendI:selfI sdkClickHandlerOnly:YES]) {
        [selfI.sdkClickHandler pauseSending];
        [selfI.purchaseVerificationHandler pauseSending];
    } else {
        [selfI.sdkClickHandler resumeSending];
        [selfI.purchaseVerificationHandler resumeSending];
    }
}

- (void)resumeSendingI:(ADJActivityHandler *)selfI {
    [selfI.attributionHandler resumeSending];
    [selfI.packageHandler resumeSending];
    [selfI.sdkClickHandler resumeSending];
    [selfI.purchaseVerificationHandler resumeSending];
}

- (BOOL)pausedI:(ADJActivityHandler *)selfI sdkClickHandlerOnly:(BOOL)sdkClickHandlerOnly {
    if (sdkClickHandlerOnly) {
        // sdk click handler is paused if either:
        return [selfI.internalState isOffline]              // it's offline
        || ![selfI isEnabledI:selfI]                        // is disabled
        || [selfI.internalState isWaitingForAttStatus];     // Waiting for ATT status
    }
    // other handlers are paused if either:
    return [selfI.internalState isOffline]                  // it's offline
    || ![selfI isEnabledI:selfI]                            // is disabled
    || [selfI.internalState isWaitingForAttStatus];         // Waiting for ATT status
}

- (BOOL)toSendI:(ADJActivityHandler *)selfI {
    return [selfI toSendI:selfI sdkClickHandlerOnly:NO];
}

- (BOOL)toSendI:(ADJActivityHandler *)selfI
sdkClickHandlerOnly:(BOOL)sdkClickHandlerOnly
{
    // don't send when it's paused
    if ([selfI pausedI:selfI sdkClickHandlerOnly:sdkClickHandlerOnly]) {
        return NO;
    }

    // has the option to send in the background -> is to send
    if (selfI.adjustConfig.isSendingInBackgroundEnabled) {
        return YES;
    }

    // doesn't have the option -> depends on being on the background/foreground
    return [selfI.internalState isInForeground];
}

- (void)setAskingAttributionI:(ADJActivityHandler *)selfI
            askingAttribution:(BOOL)askingAttribution
{
    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.askingAttribution = askingAttribution;
    }];
    [selfI writeActivityStateI:selfI];
}

# pragma mark - timer
- (void)startForegroundTimerI:(ADJActivityHandler *)selfI {
    // don't start the timer when it's disabled
    if (![selfI isEnabledI:selfI]) {
        return;
    }

    [selfI.foregroundTimer resume];
}

- (void)stopForegroundTimerI:(ADJActivityHandler *)selfI {
    [selfI.foregroundTimer suspend];
}

- (void)foregroundTimerFiredI:(ADJActivityHandler *)selfI {
    // stop the timer cycle when it's disabled
    if (![selfI isEnabledI:selfI]) {
        [selfI stopForegroundTimerI:selfI];
        return;
    }

    if ([selfI toSendI:selfI]) {
        [selfI.packageHandler sendFirstPackage];
    }

    double now = [NSDate.date timeIntervalSince1970];
    if ([selfI updateActivityStateI:selfI now:now]) {
        [selfI writeActivityStateI:selfI];
    }

    [selfI.trackingStatusManager checkForNewAttStatus];
}

- (void)startBackgroundTimerI:(ADJActivityHandler *)selfI {
    if (selfI.backgroundTimer == nil) {
        return;
    }

    // check if it can send in the background
    if (![selfI toSendI:selfI]) {
        return;
    }

    // background timer already started
    if ([selfI.backgroundTimer fireIn] > 0) {
        return;
    }

    [selfI.backgroundTimer startIn:kBackgroundTimerInterval];
}

- (void)stopBackgroundTimerI:(ADJActivityHandler *)selfI {
    if (selfI.backgroundTimer == nil) {
        return;
    }

    [selfI.backgroundTimer cancel];
}

- (void)backgroundTimerFiredI:(ADJActivityHandler *)selfI {
    if ([selfI toSendI:selfI]) {
        [selfI.packageHandler sendFirstPackage];
    }
}

#pragma mark - waiting for ATT status

- (void)activateWaitingForAttStatusI:(ADJActivityHandler *)selfI {
    if (![selfI.internalState isWaitingForAttStatus]) {
        return;
    }
    [selfI.trackingStatusManager setAppInActiveState:YES];
}

- (void)pauseWaitingForAttStatusI:(ADJActivityHandler *)selfI {
    if (![selfI.internalState isWaitingForAttStatus]) {
        return;
    }
    [selfI.trackingStatusManager setAppInActiveState:NO];
}

- (void)resumeActivityFromWaitingForAttStatusI:(ADJActivityHandler *)selfI  {
    // update packages in queue
    [selfI updatePackagesAttStatusAndIdfaI:selfI];
    // update waiting for ATT status flag
    selfI.internalState.waitingForAttStatus = NO;
    // update the status and try to send first package
    [selfI updateHandlersStatusAndSendI:selfI];
}

- (void)updatePackagesAttStatusAndIdfaI:(ADJActivityHandler *)selfI {
    // update activity packages
    int attStatus = [ADJUtil attStatus];
    if (attStatus != 0) {
        [selfI.packageHandler updatePackagesWithAttStatus:attStatus];
        [selfI.sdkClickHandler updatePackagesWithAttStatus:attStatus];
        [selfI.purchaseVerificationHandler updatePackagesWithAttStatus:attStatus];
    }

    selfI.internalState.updatePackagesAttData = NO;
    if (selfI.activityState != nil) {
        [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                        block:^{
            selfI.activityState.updatePackagesAttData = NO;
        }];
        [selfI writeActivityStateI:selfI];
    }
}

#pragma mark - session parameters
- (void)addGlobalCallbackParameterI:(ADJActivityHandler *)selfI
                              param:(NSString *)param
                             forKey:(NSString *)key {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Global Callback"]) {
        return;
    }

    if (![ADJUtil isValidParameter:param
                     attributeType:@"value"
                     parameterName:@"Global Callback"]) {
        return;
    }

    if (selfI.globalParameters.callbackParameters == nil) {
        selfI.globalParameters.callbackParameters = [NSMutableDictionary dictionary];
    }

    NSString *oldValue = [selfI.globalParameters.callbackParameters objectForKey:key];

    if (oldValue != nil) {
        if ([oldValue isEqualToString:param]) {
            [selfI.logger verbose:@"Key %@ already present with the same value", key];
            return;
        }
        [selfI.logger warn:@"Key %@ will be overwritten", key];
    }

    [selfI.globalParameters.callbackParameters setObject:param forKey:key];
    [selfI writeGlobalCallbackParametersI:selfI];
}

- (void)addGlobalPartnerParameterI:(ADJActivityHandler *)selfI
                               param:(NSString *)param
                             forKey:(NSString *)key {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Global Partner"]) {
        return;
    }

    if (![ADJUtil isValidParameter:param
                     attributeType:@"value"
                     parameterName:@"Global Partner"]) {
        return;
    }

    if (selfI.globalParameters.partnerParameters == nil) {
        selfI.globalParameters.partnerParameters = [NSMutableDictionary dictionary];
    }

    NSString *oldValue = [selfI.globalParameters.partnerParameters objectForKey:key];

    if (oldValue != nil) {
        if ([oldValue isEqualToString:param]) {
            [selfI.logger verbose:@"Key %@ already present with the same value", key];
            return;
        }
        [selfI.logger warn:@"Key %@ will be overwritten", key];
    }


    [selfI.globalParameters.partnerParameters setObject:param forKey:key];
    [selfI writeGlobalPartnerParametersI:selfI];
}

- (void)removeGlobalCallbackParameterI:(ADJActivityHandler *)selfI
                                forKey:(NSString *)key {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Global Callback"]) return;

    if (selfI.globalParameters.callbackParameters == nil) {
        [selfI.logger warn:@"Global Callback parameters are not set"];
        return;
    }

    NSString *oldValue = [selfI.globalParameters.callbackParameters objectForKey:key];
    if (oldValue == nil) {
        [selfI.logger warn:@"Key %@ does not exist", key];
        return;
    }

    [selfI.logger debug:@"Key %@ will be removed", key];
    [selfI.globalParameters.callbackParameters removeObjectForKey:key];
    [selfI writeGlobalCallbackParametersI:selfI];
}

- (void)removeGlobalPartnerParameterI:(ADJActivityHandler *)selfI
                               forKey:(NSString *)key {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Global Partner"]) {
        return;
    }

    if (selfI.globalParameters.partnerParameters == nil) {
        [selfI.logger warn:@"Global Partner parameters are not set"];
        return;
    }

    NSString *oldValue = [selfI.globalParameters.partnerParameters objectForKey:key];
    if (oldValue == nil) {
        [selfI.logger warn:@"Key %@ does not exist", key];
        return;
    }

    [selfI.logger debug:@"Key %@ will be removed", key];
    [selfI.globalParameters.partnerParameters removeObjectForKey:key];
    [selfI writeGlobalPartnerParametersI:selfI];
}

- (void)removeGlobalCallbackParametersI:(ADJActivityHandler *)selfI {
    if (selfI.globalParameters.callbackParameters == nil) {
        [selfI.logger warn:@"Global Callback parameters are not set"];
        return;
    }
    selfI.globalParameters.callbackParameters = nil;
    [selfI writeGlobalCallbackParametersI:selfI];
}

- (void)removeGlobalPartnerParametersI:(ADJActivityHandler *)selfI {
    if (selfI.globalParameters.partnerParameters == nil) {
        [selfI.logger warn:@"Global Partner parameters are not set"];
        return;
    }
    selfI.globalParameters.partnerParameters = nil;
    [selfI writeGlobalPartnerParametersI:selfI];
}

- (void)preLaunchActionsI:(ADJActivityHandler *)selfI
    preLaunchActionsArray:(NSArray*)preLaunchActionsArray
{
    if (preLaunchActionsArray == nil) {
        return;
    }
    for (activityHandlerBlockI activityHandlerActionI in preLaunchActionsArray) {
        activityHandlerActionI(selfI);
    }
}

#pragma mark - notifications
- (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center removeObserver:self];
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(applicationWillResignActive)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(removeNotificationObserver)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
}

- (void)removeNotificationObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - checks

- (BOOL)shouldProcessEventI:(ADJActivityHandler *)selfI
        withDeduplicationId:(NSString *)deduplicationId {
    if (deduplicationId == nil || deduplicationId.length == 0) {
        return YES; // no deduplication ID given
    }

    if ([selfI.activityState eventDeduplicationIdExists:deduplicationId]) {
        [selfI.logger info:@"Skipping duplicate event with deduplication ID '%@'", deduplicationId];
        [selfI.logger verbose:@"Found deduplication ID in %@", selfI.activityState.eventDeduplicationIds];
        return NO; // deduplication ID found -> used already
    }

    [selfI.logger verbose:@"Adding deduplication ID [%@] to array [%@]",
     deduplicationId,
     self.activityState.eventDeduplicationIds];

    [selfI.activityState addEventDeduplicationId:deduplicationId];
    // activity state will get written by caller
    return YES;
}

- (BOOL)checkEventI:(ADJActivityHandler *)selfI
              event:(ADJEvent *)event {
    if (event == nil) {
        [selfI.logger error:@"Event missing"];
        return NO;
    }

    if (![event isValid]) {
        [selfI.logger error:@"Event not initialized correctly"];
        return NO;
    }

    return YES;
}

- (BOOL)checkActivityStateI:(ADJActivityHandler *)selfI {
    if (selfI.activityState == nil) {
        [selfI.logger error:@"Missing activity state"];
        return NO;
    }
    return YES;
}

- (BOOL)checkAdRevenueI:(ADJActivityHandler *)selfI
              adRevenue:(ADJAdRevenue *)adRevenue {
    if (adRevenue == nil) {
        [selfI.logger error:@"Ad revenue missing"];
        return NO;
    }

    if (![adRevenue isValid]) {
        [selfI.logger error:@"Ad revenue not initialized correctly"];
        return NO;
    }

    return YES;
}

- (void)checkConversionValue:(ADJResponseData *)responseData {
    if (!self.adjustConfig.isSkanAttributionEnabled) {
        return;
    }
    if (responseData.jsonResponse == nil) {
        return;
    }

    NSNumber *conversionValue = [responseData.jsonResponse objectForKey:kSkanConversionValueResponseKey];
    if (!conversionValue) {
        return;
    }
    NSString *coarseValue = [responseData.jsonResponse objectForKey:kSkanCoarseValueResponseKey];
    NSNumber *lockWindow = [responseData.jsonResponse objectForKey:kSkanLockWindowResponseKey];

    [[ADJSKAdNetwork getInstance] updateConversionValue:conversionValue
                                            coarseValue:coarseValue
                                             lockWindow:lockWindow
                                                 source:ADJSkanSourceBackend
                                  withCompletionHandler:^(NSDictionary * _Nonnull result) {
        [self invokeClientSkanUpdateCallbackWithResult:result];
    }];
}

- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser {
    [self.trackingStatusManager updateAttStatusFromUserCallback:newAttStatusFromUser];
}

- (void)processCoppaComplianceI:(ADJActivityHandler *)selfI {
    if (!selfI.adjustConfig.isCoppaComplianceEnabled) {
        [self resetThirdPartySharingCoppaActivityStateI:selfI];
        return;
    }
    
    [self disableThirdPartySharingForCoppaEnabledI:selfI];
}

- (void)disableThirdPartySharingForCoppaEnabledI:(ADJActivityHandler *)selfI {
    if (![selfI shouldDisableThirdPartySharingWhenCoppaEnabled:selfI]) {
        return;
    }

    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        selfI.activityState.isThirdPartySharingDisabledForCoppa = YES;
    }];
    [selfI writeActivityStateI:selfI];
    
    ADJThirdPartySharing *thirdPartySharing =
    [[ADJThirdPartySharing alloc] initWithIsEnabled:[NSNumber numberWithBool:NO]];
    
    double now = [NSDate.date timeIntervalSince1970];
    
    // build package
    ADJPackageBuilder *tpsBuilder =
    [[ADJPackageBuilder alloc] initWithPackageParams:selfI.packageParams
                                       activityState:selfI.activityState
                                              config:selfI.adjustConfig
                                    globalParameters:selfI.globalParameters
                               trackingStatusManager:selfI.trackingStatusManager
                                           createdAt:now];
    tpsBuilder.internalState = selfI.internalState;

    ADJActivityPackage *dtpsPackage = [tpsBuilder buildThirdPartySharingPackage:thirdPartySharing];
    [selfI.packageHandler addPackage:dtpsPackage];
    [selfI.packageHandler sendFirstPackage];
}

- (void)resetThirdPartySharingCoppaActivityStateI:(ADJActivityHandler *)selfI {
    if (selfI.activityState == nil) {
        return;
    }
    
    if(selfI.activityState.isThirdPartySharingDisabledForCoppa) {
        [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                        block:^{
            selfI.activityState.isThirdPartySharingDisabledForCoppa = NO;
        }];
        [selfI writeActivityStateI:selfI];
    }
}

- (BOOL)shouldDisableThirdPartySharingWhenCoppaEnabled:(ADJActivityHandler *)selfI {
    if (selfI.activityState == nil) {
        return NO;
    }
    if (![selfI isEnabledI:selfI]) {
        return NO;
    }
    if (selfI.activityState.isGdprForgotten) {
        return NO;
    }
    
    return !selfI.activityState.isThirdPartySharingDisabledForCoppa;
}

- (void)invokeClientSkanUpdateCallbackWithResult:(NSDictionary * _Nonnull)result {
    NSDictionary *conversionParams = [result objectForKey:ADJSkanClientCallbackParamsKey];
    // Ping the callback method if implemented
    if ([self.adjustDelegate respondsToSelector:@selector(adjustSkanUpdatedWithConversionData:)]) {
        [self.logger debug:@"Launching delegate's method adjustSkanUpdatedWithConversionData:"];
        [ADJUtil launchInMainThread:^{
            [self.adjustDelegate adjustSkanUpdatedWithConversionData:conversionParams];
        }];
    }
}

@end

@interface ADJTrackingStatusManager ()
@property (nonatomic, readonly, weak) ADJActivityHandler *activityHandler;
@property (nonatomic, assign) BOOL activeState;
@property (nonatomic, strong) dispatch_queue_t waitingForAttQueue;
@end

@implementation ADJTrackingStatusManager
// constructors
- (instancetype)initWithActivityHandler:(ADJActivityHandler *)activityHandler {
    self = [super init];

    _activityHandler = activityHandler;
    _waitingForAttQueue = dispatch_queue_create(kWaitingForAttQueueName, DISPATCH_QUEUE_SERIAL);

    return self;
}
// public api
- (BOOL)canGetAttStatus {
    if (@available(iOS 14.0, tvOS 14.0, *)) {
        return YES;
    }
    return NO;
}

- (BOOL)trackingEnabled {
    return [ADJUtil trackingEnabled];
}

- (int)attStatus {
    int readAttStatus = [ADJUtil attStatus];
    [self updateAttStatus:readAttStatus];
    return readAttStatus;
}

- (void)checkForNewAttStatus {
    int readAttStatus = [ADJUtil attStatus];
    [self updateAttStatusWithStatus:readAttStatus];
}

- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser {
    [self updateAttStatusWithStatus:newAttStatusFromUser];
}

- (void)updateAttStatusWithStatus:(int)status {
    BOOL statusHasBeenUpdated = [self updateAttStatus:status];
    if (statusHasBeenUpdated) {
        [self.activityHandler trackAttStatusUpdate];
    }
}

// internal methods
- (BOOL)updateAttStatus:(int)readAttStatus {
    if (readAttStatus < 0) {
        return NO;
    }

    if (self.activityHandler == nil || self.activityHandler.activityState == nil) {
        return NO;
    }

    if (readAttStatus == self.activityHandler.activityState.trackingManagerAuthorizationStatus) {
        return NO;
    }

    [ADJUtil launchSynchronisedWithObject:[ADJActivityState class]
                                    block:^{
        self.activityHandler.activityState.trackingManagerAuthorizationStatus = readAttStatus;
    }];
    [self.activityHandler writeActivityState];

    return YES;
}


- (void)setAppInActiveState:(BOOL)activeState {
    dispatch_async(self.waitingForAttQueue, ^{
        // skip in case active state didn't change
        if (self.activeState == activeState) {
            return;
        }
        self.activeState = activeState;
        if (self.activeState) {
            [self startWaitingForAttStatus];
        }
    });
}

- (BOOL)shouldWaitForAttStatus {
    if (![self canGetAttStatus]) {
        return NO;
    }

    // check current ATT status
    int attStatus = [ADJUtil attStatus];

    // return if the status is not ATTrackingManagerAuthorizationStatusNotDetermined
    if (attStatus != 0) {
        // Delete att_waiting_seconds key from UserDefaults.
        [ADJUserDefaults removeAttWaitingRemainingSeconds];
        return NO;
    }

    BOOL keyExists = [ADJUserDefaults attWaitingRemainingSecondsKeyExists];
    // check ATT timeout configuration
    if (self.activityHandler.adjustConfig.attConsentWaitingInterval == 0) {
        // ATT timmeout is not configured in ADJConfig for current SDK running session.
        // Already existing NSUserDefaults key means ATT timeout was configured in the previous SDK initialization.
        // Setting `0` to the NSUserDefaults key for skipping ATT waiting configuration in next SDK initializations,
        // no matter it is confgured in Adjust configuration or not.
        if (keyExists) {
            [ADJUserDefaults setAttWaitingRemainingSeconds:0];
        }
        return NO;
    }

    // Setting timeout value according to configured/predefined_limit number of seconds.
    NSUInteger timeoutSec = (self.activityHandler.adjustConfig.attConsentWaitingInterval <= kWaitingForAttStatusLimitSeconds) ?
    self.activityHandler.adjustConfig.attConsentWaitingInterval : kWaitingForAttStatusLimitSeconds;
    if (keyExists && [ADJUserDefaults getAttWaitingRemainingSeconds] == 0) {
        // Existing NSUserDefaults key with `0` value means:
        // OR timeout has elapsed and user didn't succeed to invoke ATT dialog during this time
        // OR SDK already has been initialized without AttTimeout.
        // We are skipping this ATT status waiting logic.
        return NO;
    }

    // NSUserDefaults key doesn't exist means => first SDK init with timeout configured).
    // OR
    // NSUserDefaults key exists with value > 0 means => application was killed before the timeout has been elapsed.

    // We have to set the configured waiting timeout and start ATT status monitoring logic.
    [ADJUserDefaults setAttWaitingRemainingSeconds:timeoutSec];

    return YES;
}

- (void)startWaitingForAttStatus {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), self.waitingForAttQueue, ^{
        [self checkAttStatusPeriodic];
    });
}

- (void)checkAttStatusPeriodic {
    if (!self.activeState) {
        return;
    }
    // check current ATT status
    int attStatus = [ADJUtil attStatus];
    if (attStatus != 0) {
        [self.activityHandler.logger info:@"ATT consent status udated to: %d", attStatus];
        [ADJUserDefaults removeAttWaitingRemainingSeconds];
        [self.activityHandler resumeActivityFromWaitingForAttStatus];
        return;
    }

    NSUInteger seconds = [ADJUserDefaults getAttWaitingRemainingSeconds];
    if (seconds == 0) {
        [self.activityHandler.logger warn:@"ATT status waiting timeout elapsed without receiving any consent status update"];
        [self.activityHandler resumeActivityFromWaitingForAttStatus];
        return;
    }

    [ADJUserDefaults setAttWaitingRemainingSeconds:(seconds-1)];
    [self startWaitingForAttStatus];
}

@end

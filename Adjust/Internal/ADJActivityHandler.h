//
//  ADJActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJResponseData.h"
#import "ADJActivityState.h"
#import "ADJPackageParams.h"
#import "ADJGlobalParameters.h"
#import "ADJThirdPartySharing.h"

@interface ADJInternalState : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, assign) BOOL background;
@property (nonatomic, assign) BOOL updatePackagesAttData;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) BOOL sessionResponseProcessed;
@property (nonatomic, assign) BOOL waitingForAttStatus;

- (BOOL)isEnabled;
- (BOOL)isDisabled;
- (BOOL)isOffline;
- (BOOL)isOnline;
- (BOOL)isInBackground;
- (BOOL)isInForeground;
- (BOOL)itHasToUpdatePackagesAttData;
- (BOOL)isFirstLaunch;
- (BOOL)hasSessionResponseNotBeenProcessed;
- (BOOL)isWaitingForAttStatus;

@end

@interface ADJSavedPreLaunch : NSObject

@property (nonatomic, strong) NSMutableArray * _Nullable preLaunchActionsArray;
@property (nonatomic, strong) NSMutableArray * _Nullable cachedAttributionReadCallbacksArray;
@property (nonatomic, strong) NSMutableArray * _Nullable cachedAdidReadCallbacksArray;
@property (nonatomic, copy) NSNumber *_Nullable enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, copy) NSString *_Nullable extraPath;
@property (nonatomic, strong) NSMutableArray *_Nullable preLaunchAdjustThirdPartySharingArray;
@property (nonatomic, copy) NSNumber *_Nullable lastMeasurementConsentTracked;

- (nonnull id)init;

@end

@class ADJTrackingStatusManager;

@protocol ADJActivityHandler <NSObject>

@property (nonatomic, strong) ADJTrackingStatusManager * _Nullable trackingStatusManager;

- (id _Nullable)initWithConfig:(ADJConfig *_Nullable)adjustConfig
                savedPreLaunch:(ADJSavedPreLaunch * _Nullable)savedPreLaunch
    deeplinkResolutionCallback:(ADJResolvedDeeplinkBlock _Nullable)deepLinkResolutionCallback;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

- (void)trackEvent:(ADJEvent * _Nullable)event;

- (void)finishedTracking:(ADJResponseData * _Nullable)responseData;
- (void)launchEventResponseTasks:(ADJEventResponseData * _Nullable)eventResponseData;
- (void)launchSessionResponseTasks:(ADJSessionResponseData * _Nullable)sessionResponseData;
- (void)launchSdkClickResponseTasks:(ADJSdkClickResponseData * _Nullable)sdkClickResponseData;
- (void)launchAttributionResponseTasks:(ADJAttributionResponseData * _Nullable)attributionResponseData;
- (void)setEnabled:(BOOL)enabled;
- (void)isEnabledWithCompletionHandler:(nonnull ADJIsEnabledGetterBlock)completion;
- (BOOL)isGdprForgotten;

- (void)processDeeplink:(ADJDeeplink * _Nullable)deeplink
          withClickTime:(NSDate * _Nullable)clickTime;
- (void)processAndResolveDeeplink:(ADJDeeplink * _Nullable)deeplink
                        clickTime:(NSDate * _Nullable)clickTime
            withCompletionHandler:(ADJResolvedDeeplinkBlock _Nullable)completion;
- (void)setPushTokenData:(NSData * _Nullable)pushTokenData;
- (void)setPushTokenString:(NSString * _Nullable)pushTokenString;
- (void)setGdprForgetMe;
- (void)setTrackingStateOptedOut;
- (void)setAskingAttribution:(BOOL)askingAttribution;

- (BOOL)updateAttributionI:(id<ADJActivityHandler> _Nullable)selfI
               attribution:(ADJAttribution * _Nullable)attribution;
- (void)setAdServicesAttributionToken:(NSString * _Nullable)token
                                error:(NSError * _Nullable)error;

- (void)setOfflineMode:(BOOL)offline;

- (void)addGlobalCallbackParameter:(NSString *_Nonnull)param forKey:(NSString *_Nonnull)key;
- (void)addGlobalPartnerParameter:(NSString *_Nonnull)param forKey:(NSString *_Nonnull)key;
- (void)removeGlobalCallbackParameterForKey:(NSString *_Nullable)key;
- (void)removeGlobalPartnerParameterForKey:(NSString *_Nonnull)key;
- (void)removeGlobalCallbackParameters;
- (void)removeGlobalPartnerParameters;

- (void)trackThirdPartySharing:(nonnull ADJThirdPartySharing *)thirdPartySharing;
- (void)trackMeasurementConsent:(BOOL)enabled;
- (void)trackAppStoreSubscription:(ADJAppStoreSubscription * _Nullable)subscription;
- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser;
- (void)trackAdRevenue:(ADJAdRevenue * _Nullable)adRevenue;
- (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(nonnull ADJVerificationResultBlock)completion;
- (void)attributionWithCompletionHandler:(nonnull ADJAttributionGetterBlock)completion;
- (void)adidWithCompletionHandler:(nonnull ADJAdidGetterBlock)completion;
- (void)verifyAndTrackAppStorePurchase:(nonnull ADJEvent *)event
                 withCompletionHandler:(nonnull ADJVerificationResultBlock)completion;
- (void)invokeClientSkanUpdateCallbackWithResult:(NSDictionary * _Nonnull)result;

- (ADJPackageParams * _Nullable)packageParams;
- (ADJActivityState * _Nullable)activityState;
- (ADJConfig * _Nullable)adjustConfig;
- (ADJGlobalParameters * _Nullable)globalParameters;

- (void)teardown;
+ (void)deleteState;
@end

@interface ADJActivityHandler : NSObject <ADJActivityHandler>

- (id _Nullable)initWithConfig:(ADJConfig *_Nullable)adjustConfig
                savedPreLaunch:(ADJSavedPreLaunch * _Nullable)savedPreLaunch
    deeplinkResolutionCallback:(ADJResolvedDeeplinkBlock _Nullable)deepLinkResolutionCallback;

- (void)addGlobalCallbackParameterI:(ADJActivityHandler *_Nonnull)selfI
                              param:(NSString *_Nonnull)param
                             forKey:(NSString *_Nonnull)key;
- (void)addGlobalPartnerParameterI:(ADJActivityHandler *_Nonnull)selfI
                             param:(NSString *_Nonnull)param
                            forKey:(NSString *_Nonnull)key;
- (void)removeGlobalCallbackParameterI:(ADJActivityHandler *_Nonnull)selfI
                                forKey:(NSString *_Nonnull)key;
- (void)removeGlobalPartnerParameterI:(ADJActivityHandler *_Nonnull)selfI
                               forKey:(NSString *_Nonnull)key;
- (void)removeGlobalCallbackParametersI:(ADJActivityHandler *_Nonnull)selfI;
- (void)removeGlobalPartnerParametersI:(ADJActivityHandler *_Nonnull)selfI;
@end

@interface ADJTrackingStatusManager : NSObject

@property (nonatomic, readonly, assign) BOOL trackingEnabled;
@property (nonatomic, readonly, assign) int attStatus;

- (instancetype _Nullable)initWithActivityHandler:(ADJActivityHandler * _Nullable)activityHandler;
- (void)checkForNewAttStatus;
- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser;
- (BOOL)canGetAttStatus;
- (void)setAppInActiveState:(BOOL)activeState;
- (BOOL)shouldWaitForAttStatus;

@end

extern NSString * _Nullable const ADJAdServicesPackageKey;

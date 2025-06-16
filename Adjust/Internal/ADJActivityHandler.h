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
- (void)updateAndTrackAttStatusFromUserCallback:(int)newAttStatusFromUser;
- (void)trackAdRevenue:(ADJAdRevenue * _Nullable)adRevenue;
- (void)verifyAppStorePurchase:(nonnull ADJAppStorePurchase *)purchase
         withCompletionHandler:(nonnull ADJVerificationResultBlock)completion;
- (void)attributionWithCompletionHandler:(nonnull ADJAttributionGetterBlock)completion;
- (void)adidWithCompletionHandler:(nonnull ADJAdidGetterBlock)completion;
- (void)setCoppaComplianceInDelay:(BOOL)isCoppaComplianceEnabled;
- (void)setExternalDeviceIdInDelay:(nullable NSString *)externalDeviceId;
- (void)verifyAndTrackAppStorePurchase:(nonnull ADJEvent *)event
                 withCompletionHandler:(nonnull ADJVerificationResultBlock)completion;
- (void)invokeClientSkanUpdateCallbackWithResult:(NSDictionary * _Nonnull)result;

- (void)endFirstSessionDelay;

- (ADJPackageParams * _Nullable)packageParams;
- (ADJActivityState * _Nullable)activityState;
- (ADJConfig * _Nullable)adjustConfig;
- (ADJGlobalParameters * _Nullable)globalParameters;
- (BOOL)isOdmEnabled;

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

- (void)tryTrackThirdPartySharingI:(nonnull ADJThirdPartySharing *)thirdPartySharing;
- (void)tryTrackMeasurementConsentI:(BOOL)enabled;
@end


@interface ADJFirstSessionDelayManager : NSObject

- (nonnull instancetype)initWithActivityHandler:(ADJActivityHandler * _Nonnull)activityHandler;

- (void)delayOrInitWithBlock:(void (^_Nonnull)(ADJActivityHandler *_Nonnull selfI, BOOL isInactive))initBlock;
- (void)endFirstSessionDelay;
- (void)setCoppaComplianceInDelay:(BOOL)isCoppaComplianceEnabled;
- (void)setExternalDeviceIdInDelay:(NSString * _Nullable)externalDeviceId;
- (void)processApiAction:(NSString * _Nonnull)actionName
             isPreLaunch:(BOOL)isPreLaunch
               withBlock:(void (^_Nonnull)(_Nonnull id))selfInjectedBlock;



- (BOOL)wasSet;

@end

@interface ADJTrackingStatusManager : NSObject

- (instancetype _Nullable)initWithActivityHandler:(ADJActivityHandler * _Nullable)activityHandler;
- (BOOL)isAttSupported;
- (int)attStatus;
- (int)updateAndGetAttStatus;
- (BOOL)isTrackingEnabled;
- (void)updateAndTrackAttStatus;
- (void)updateAndTrackAttStatusFromUserCallback:(int)attStatusFromUser;
- (void)setAppInActiveState:(BOOL)activeState;
- (BOOL)shouldWaitForAttStatus;

@end

extern NSString * _Nullable const ADJClickSourceAdServices;
extern NSString * _Nullable const ADJClickSourceGoogleOdm;


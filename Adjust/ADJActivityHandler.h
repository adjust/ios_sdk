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
#import "ADJSessionParameters.h"
#import "ADJThirdPartySharing.h"

@interface ADJInternalState : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, assign) BOOL background;
@property (nonatomic, assign) BOOL delayStart;
@property (nonatomic, assign) BOOL updatePackages;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) BOOL sessionResponseProcessed;

- (BOOL)isEnabled;
- (BOOL)isDisabled;
- (BOOL)isOffline;
- (BOOL)isOnline;
- (BOOL)isInBackground;
- (BOOL)isInForeground;
- (BOOL)isInDelayedStart;
- (BOOL)isNotInDelayedStart;
- (BOOL)itHasToUpdatePackages;
- (BOOL)isFirstLaunch;
- (BOOL)hasSessionResponseNotBeenProcessed;

@end

@interface ADJSavedPreLaunch : NSObject

@property (nonatomic, strong) NSMutableArray * _Nullable preLaunchActionsArray;
@property (nonatomic, copy) NSData *_Nullable deviceTokenData;
@property (nonatomic, copy) NSNumber *_Nullable enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, copy) NSString *_Nullable extraPath;
@property (nonatomic, strong) NSMutableArray *_Nullable preLaunchAdjustThirdPartySharingArray;
@property (nonatomic, copy) NSNumber *_Nullable lastMeasurementConsentTracked;

- (nonnull id)init;

@end

@class ADJTrackingStatusManager;

@protocol ADJActivityHandler <NSObject>

@property (nonatomic, copy) ADJAttribution * _Nullable attribution;
@property (nonatomic, strong) ADJTrackingStatusManager * _Nullable trackingStatusManager;

- (NSString *_Nullable)adid;

- (id _Nullable)initWithConfig:(ADJConfig *_Nullable)adjustConfig
                savedPreLaunch:(ADJSavedPreLaunch * _Nullable)savedPreLaunch;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

- (void)trackEvent:(ADJEvent * _Nullable)event;

- (void)finishedTracking:(ADJResponseData * _Nullable)responseData;
- (void)launchEventResponseTasks:(ADJEventResponseData * _Nullable)eventResponseData;
- (void)launchSessionResponseTasks:(ADJSessionResponseData * _Nullable)sessionResponseData;
- (void)launchSdkClickResponseTasks:(ADJSdkClickResponseData * _Nullable)sdkClickResponseData;
- (void)launchAttributionResponseTasks:(ADJAttributionResponseData * _Nullable)attributionResponseData;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (BOOL)isGdprForgotten;

- (void)appWillOpenUrl:(NSURL * _Nullable)url
         withClickTime:(NSDate * _Nullable)clickTime;
- (void)setDeviceToken:(NSData * _Nullable)deviceToken;
- (void)setPushToken:(NSString * _Nullable)deviceToken;
- (void)setGdprForgetMe;
- (void)setTrackingStateOptedOut;
- (void)setAskingAttribution:(BOOL)askingAttribution;

- (BOOL)updateAttributionI:(id<ADJActivityHandler> _Nullable)selfI
               attribution:(ADJAttribution * _Nullable)attribution;
- (void)setAdServicesAttributionToken:(NSString * _Nullable)token
                                error:(NSError * _Nullable)error;

- (void)setOfflineMode:(BOOL)offline;
- (void)sendFirstPackages;

- (void)addSessionCallbackParameter:(NSString * _Nullable)key
                              value:(NSString * _Nullable)value;
- (void)addSessionPartnerParameter:(NSString * _Nullable)key
                             value:(NSString * _Nullable)value;
- (void)removeSessionCallbackParameter:(NSString * _Nullable)key;
- (void)removeSessionPartnerParameter:(NSString * _Nullable)key;
- (void)resetSessionCallbackParameters;
- (void)resetSessionPartnerParameters;
- (void)trackAdRevenue:(NSString * _Nullable)soruce
               payload:(NSData * _Nullable)payload;
- (void)disableThirdPartySharing;
- (void)trackThirdPartySharing:(nonnull ADJThirdPartySharing *)thirdPartySharing;
- (void)trackMeasurementConsent:(BOOL)enabled;
- (void)trackSubscription:(ADJSubscription * _Nullable)subscription;
- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser;
- (void)trackAdRevenue:(ADJAdRevenue * _Nullable)adRevenue;
- (void)checkForNewAttStatus;

- (ADJPackageParams * _Nullable)packageParams;
- (ADJActivityState * _Nullable)activityState;
- (ADJConfig * _Nullable)adjustConfig;
- (ADJSessionParameters * _Nullable)sessionParameters;

- (void)teardown;
+ (void)deleteState;
@end

@interface ADJActivityHandler : NSObject <ADJActivityHandler>

- (id _Nullable)initWithConfig:(ADJConfig * _Nullable)adjustConfig
                savedPreLaunch:(ADJSavedPreLaunch * _Nullable)savedPreLaunch;

- (void)addSessionCallbackParameterI:(ADJActivityHandler * _Nullable)selfI
                                 key:(NSString * _Nullable)key
                               value:(NSString * _Nullable)value;

- (void)addSessionPartnerParameterI:(ADJActivityHandler * _Nullable)selfI
                                key:(NSString * _Nullable)key
                              value:(NSString * _Nullable)value;
- (void)removeSessionCallbackParameterI:(ADJActivityHandler * _Nullable)selfI
                                    key:(NSString * _Nullable)key;
- (void)removeSessionPartnerParameterI:(ADJActivityHandler * _Nullable)selfI
                                   key:(NSString * _Nullable)key;
- (void)resetSessionCallbackParametersI:(ADJActivityHandler * _Nullable)selfI;
- (void)resetSessionPartnerParametersI:(ADJActivityHandler * _Nullable)selfI;

@end

@interface ADJTrackingStatusManager : NSObject

- (instancetype _Nullable)initWithActivityHandler:(ADJActivityHandler * _Nullable)activityHandler;

- (void)checkForNewAttStatus;
- (void)updateAttStatusFromUserCallback:(int)newAttStatusFromUser;

- (BOOL)canGetAttStatus;

@property (nonatomic, readonly, assign) BOOL trackingEnabled;
@property (nonatomic, readonly, assign) int attStatus;

@end

extern NSString * _Nullable const ADJAdServicesPackageKey;

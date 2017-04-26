//
//  ADJActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJResponseData.h"

@interface ADJInternalState : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL offline;
@property (nonatomic, assign) BOOL background;
@property (nonatomic, assign) BOOL delayStart;
@property (nonatomic, assign) BOOL updatePackages;
@property (nonatomic, assign) BOOL firstLaunch;
@property (nonatomic, assign) BOOL sessionResponseProcessed;

- (id)init;

- (BOOL)isEnabled;
- (BOOL)isDisabled;
- (BOOL)isOffline;
- (BOOL)isOnline;
- (BOOL)isBackground;
- (BOOL)isForeground;
- (BOOL)isDelayStart;
- (BOOL)isToStartNow;
- (BOOL)isToUpdatePackages;
- (BOOL)isFirstLaunch;
- (BOOL)hasSessionResponseNotProcessed;

@end

@protocol ADJActivityHandler <NSObject>

@property (nonatomic, copy) ADJAttribution *attribution;
- (NSString *)adid;

- (id)initWithConfig:(ADJConfig *)adjustConfig
sessionParametersActionsArray:(NSArray*)sessionParametersActionsArray
         deviceToken:(NSData*)deviceToken;

- (void)applicationDidBecomeActive;
- (void)applicationWillResignActive;

- (void)trackEvent:(ADJEvent *)event;

- (void)finishedTracking:(ADJResponseData *)responseData;
- (void)launchEventResponseTasks:(ADJEventResponseData *)eventResponseData;
- (void)launchSessionResponseTasks:(ADJSessionResponseData *)sessionResponseData;
- (void)launchSdkClickResponseTasks:(ADJSdkClickResponseData *)sdkClickResponseData;
- (void)launchAttributionResponseTasks:(ADJAttributionResponseData *)attributionResponseData;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;

- (void)appWillOpenUrl:(NSURL*)url;
- (void)setDeviceToken:(NSData *)deviceToken;

- (void)setAskingAttribution:(BOOL)askingAttribution;

- (BOOL)updateAttributionI:(id<ADJActivityHandler>)selfI attribution:(ADJAttribution *)attribution;
- (void)setIadDate:(NSDate*)iAdImpressionDate withPurchaseDate:(NSDate*)appPurchaseDate;
- (void)setAttributionDetails:(NSDictionary *)attributionDetails
                        error:(NSError *)error
                  retriesLeft:(int)retriesLeft;

- (void)setOfflineMode:(BOOL)offline;
- (ADJInternalState*) internalState;
- (void)sendFirstPackages;

- (void)addSessionCallbackParameter:(NSString *)key
                              value:(NSString *)value;
- (void)addSessionPartnerParameter:(NSString *)key
                             value:(NSString *)value;
- (void)removeSessionCallbackParameter:(NSString *)key;
- (void)removeSessionPartnerParameter:(NSString *)key;
- (void)resetSessionCallbackParameters;
- (void)resetSessionPartnerParameters;

- (void)teardown:(BOOL)deleteState;
@end

@interface ADJActivityHandler : NSObject <ADJActivityHandler>

+ (id<ADJActivityHandler>)handlerWithConfig:(ADJConfig *)adjustConfig
             sessionParametersActionsArray:(NSArray*)sessionParametersActionsArray
                                deviceToken:(NSData*)deviceToken;

- (void)addSessionCallbackParameterI:(ADJActivityHandler *)selfI
                                 key:(NSString *)key
                               value:(NSString *)value;

- (void)addSessionPartnerParameterI:(ADJActivityHandler *)selfI
                                key:(NSString *)key
                              value:(NSString *)value;
- (void)removeSessionCallbackParameterI:(ADJActivityHandler *)selfI
                                    key:(NSString *)key;
- (void)removeSessionPartnerParameterI:(ADJActivityHandler *)selfI
                                   key:(NSString *)key;
- (void)resetSessionCallbackParametersI:(ADJActivityHandler *)selfI;
- (void)resetSessionPartnerParametersI:(ADJActivityHandler *)selfI;

@end

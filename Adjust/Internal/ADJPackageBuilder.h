//
//  ADJPackageBuilder.h
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 3rd July 2013.
//  Copyright (c) 2013-2018 Adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJPackageParams.h"
#import "ADJActivityState.h"
#import "ADJActivityPackage.h"
#import "ADJGlobalParameters.h"
#import "ADJActivityHandler.h"
#import "ADJThirdPartySharing.h"

@interface ADJPackageBuilder : NSObject

@property (nonatomic, copy) NSString * _Nullable deeplink;

@property (nonatomic, copy) NSString * _Nullable referrer;

@property (nonatomic, copy) NSString * _Nullable reftag;

@property (nonatomic, copy) NSDate * _Nullable clickTime;

@property (nonatomic, copy) NSDate * _Nullable purchaseTime;

@property (nonatomic, strong) NSDictionary * _Nullable deeplinkParameters;

@property (nonatomic, copy) ADJAttribution * _Nullable attribution;

@property (nonatomic, weak) ADJInternalState * _Nullable internalState;

- (id _Nullable)initWithPackageParams:(ADJPackageParams * _Nullable)packageParams
                        activityState:(ADJActivityState * _Nullable)activityState
                               config:(ADJConfig * _Nullable)adjustConfig
                     globalParameters:(ADJGlobalParameters * _Nullable)globalParameters
                trackingStatusManager:(ADJTrackingStatusManager * _Nullable)trackingStatusManager
                            createdAt:(double)createdAt;

- (ADJActivityPackage * _Nullable)buildSessionPackage;

- (ADJActivityPackage * _Nullable)buildEventPackage:(ADJEvent * _Nullable)event;

- (ADJActivityPackage * _Nullable)buildInfoPackage:(NSString * _Nullable)infoSource;

- (ADJActivityPackage * _Nullable)buildClickPackage:(NSString * _Nullable)clickSource;

- (ADJActivityPackage * _Nullable)buildClickPackage:(NSString * _Nullable)clickSource
                                              token:(NSString * _Nullable)token
                                    errorCodeNumber:(NSNumber * _Nullable)errorCodeNumber;

- (ADJActivityPackage * _Nullable)buildClickPackage:(NSString * _Nullable)clickSource
                                          linkMeUrl:(NSString * _Nullable)linkMeUrl;

- (ADJActivityPackage * _Nullable)buildPurchaseVerificationPackageWithPurchase:(ADJAppStorePurchase * _Nullable)purchase;

- (ADJActivityPackage * _Nullable)buildPurchaseVerificationPackageWithEvent:(ADJEvent * _Nullable)event;

- (ADJActivityPackage * _Nullable)buildAttributionPackage:(NSString * _Nullable)initiatedBy;

- (ADJActivityPackage * _Nullable)buildGdprPackage;

- (ADJActivityPackage * _Nullable)buildThirdPartySharingPackage:(nonnull ADJThirdPartySharing *)thirdPartySharing;

- (ADJActivityPackage * _Nullable)buildMeasurementConsentPackage:(BOOL)enabled;

- (ADJActivityPackage * _Nullable)buildSubscriptionPackage:(ADJAppStoreSubscription * _Nullable)subscription;

- (ADJActivityPackage * _Nullable)buildAdRevenuePackage:(ADJAdRevenue * _Nullable)adRevenue;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
     setDictionary:(NSDictionary * _Nullable)dictionary
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
         setString:(NSString * _Nullable)value
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
            setInt:(int)value
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
         setDouble:(double)value
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
       setDate1970:(double)value
            forKey:(NSString * _Nullable)key;

+ (void)parameters:(NSMutableDictionary * _Nullable)parameters
setNumberWithoutRounding:(NSNumber * _Nullable)value
            forKey:(NSString * _Nullable)key;

+ (BOOL)isAdServicesPackage:(ADJActivityPackage * _Nullable)activityPackage;

+ (void)addConsentDataToParameters:(NSMutableDictionary * _Nullable)parameters
                   forActivityKind:(ADJActivityKind)activityKind
                     withAttStatus:(int)attStatus
                     configuration:(ADJConfig * _Nullable)adjConfig
                     packageParams:(ADJPackageParams * _Nullable)packageParams
                     activityState:(ADJActivityState *_Nullable)activityState;

+ (void)removeConsentDataFromParameters:(nonnull NSMutableDictionary *)parameters;

+ (void)updateAttStatus:(int)attStatus
           inParameters:(nonnull NSMutableDictionary *)parameters;

+ (void)removeAttStatusFromParameters:(nonnull NSMutableDictionary *)parameters;


@end
// TODO change to ADJ...
extern NSString * _Nullable const ADJAttributionTokenParameter;

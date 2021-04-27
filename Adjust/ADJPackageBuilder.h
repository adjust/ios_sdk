//
//  ADJPackageBuilder.h
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 3rd July 2013.
//  Copyright (c) 2013-2018 Adjust GmbH. All rights reserved.
//

#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJPackageParams.h"
#import "ADJActivityState.h"
#import "ADJActivityPackage.h"
#import "ADJSessionParameters.h"
#import <Foundation/Foundation.h>
#import "ADJActivityHandler.h"
#import "ADJThirdPartySharing.h"

@interface ADJPackageBuilder : NSObject

@property (nonatomic, copy) NSString * _Nullable deeplink;

@property (nonatomic, copy) NSDate * _Nullable clickTime;

@property (nonatomic, copy) NSDate * _Nullable purchaseTime;

@property (nonatomic, strong) NSDictionary * _Nullable attributionDetails;

@property (nonatomic, strong) NSDictionary * _Nullable deeplinkParameters;

@property (nonatomic, copy) ADJAttribution * _Nullable attribution;

- (id _Nullable)initWithPackageParams:(ADJPackageParams * _Nullable)packageParams
                        activityState:(ADJActivityState * _Nullable)activityState
                               config:(ADJConfig * _Nullable)adjustConfig
                    sessionParameters:(ADJSessionParameters * _Nullable)sessionParameters
                trackingStatusManager:(ADJTrackingStatusManager * _Nullable)trackingStatusManager
                            createdAt:(double)createdAt;

- (ADJActivityPackage * _Nullable)buildSessionPackage:(BOOL)isInDelay;

- (ADJActivityPackage * _Nullable)buildEventPackage:(ADJEvent * _Nullable)event
                                isInDelay:(BOOL)isInDelay;

- (ADJActivityPackage * _Nullable)buildInfoPackage:(NSString * _Nullable)infoSource;

- (ADJActivityPackage * _Nullable)buildAdRevenuePackage:(NSString * _Nullable)source
                                                payload:(NSData * _Nullable)payload;

- (ADJActivityPackage * _Nullable)buildClickPackage:(NSString * _Nullable)clickSource;

- (ADJActivityPackage * _Nullable)buildClickPackage:(NSString * _Nullable)clickSource
                                              token:(NSString * _Nullable)token
                                    errorCodeNumber:(NSNumber * _Nullable)errorCodeNumber;

- (ADJActivityPackage * _Nullable)buildAttributionPackage:(NSString * _Nullable)initiatedBy;

- (ADJActivityPackage * _Nullable)buildGdprPackage;

- (ADJActivityPackage * _Nullable)buildDisableThirdPartySharingPackage;

- (ADJActivityPackage * _Nullable)buildThirdPartySharingPackage:(nonnull ADJThirdPartySharing *)thirdPartySharing;

- (ADJActivityPackage * _Nullable)buildMeasurementConsentPackage:(BOOL)enabled;

- (ADJActivityPackage * _Nullable)buildSubscriptionPackage:( ADJSubscription * _Nullable)subscription
                                                 isInDelay:(BOOL)isInDelay;

- (ADJActivityPackage * _Nullable)buildAdRevenuePackage:(ADJAdRevenue * _Nullable)adRevenue
                                              isInDelay:(BOOL)isInDelay;

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
       setDate1970:(double)value
            forKey:(NSString * _Nullable)key;

+ (BOOL)isAdServicesPackage:(ADJActivityPackage * _Nullable)activityPackage;

@end
// TODO change to ADJ...
extern NSString * _Nullable const ADJAttributionTokenParameter;

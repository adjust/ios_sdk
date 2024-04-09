//
//  ADJUtil.h
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 5th July 2013.
//  Copyright (c) 2013-2021 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJEvent.h"
#import "ADJConfig.h"
#import "ADJActivityKind.h"
#import "ADJResponseData.h"
#import "ADJActivityPackage.h"
#import "ADJBackoffStrategy.h"
#import "ADJActivityHandler.h"

typedef void (^selfInjectedBlock)(id);
typedef void (^synchronisedBlock)(void);
typedef void (^isInactiveInjected)(BOOL);

@interface ADJUtil : NSObject

+ (void)teardown;

+ (id)readObject:(NSString *)fileName
      objectName:(NSString *)objectName
           class:(Class)classToRead
      syncObject:(id)syncObject;

+ (void)excludeFromBackup:(NSString *)filename;

+ (void)launchDeepLinkMain:(NSURL *)deepLinkUrl NS_EXTENSION_UNAVAILABLE_IOS("");

+ (void)launchInMainThread:(dispatch_block_t)block;

+ (BOOL)isMainThread;

+ (BOOL)isInactive NS_EXTENSION_UNAVAILABLE_IOS("");

+ (void)launchInMainThreadWithInactive:(isInactiveInjected)isInactiveblock;

+ (void)updateUrlSessionConfiguration:(ADJConfig *)config;

+ (void)writeObject:(id)object
           fileName:(NSString *)fileName
         objectName:(NSString *)objectName
         syncObject:(id)syncObject;

+ (void)launchInMainThread:(NSObject *)receiver
                  selector:(SEL)selector
                withObject:(id)object;

+ (void)launchInQueue:(dispatch_queue_t)queue
           selfInject:(id)selfInject
                block:(selfInjectedBlock)block;

+ (void)launchSynchronisedWithObject:(id)synchronisationObject
                               block:(synchronisedBlock)block;

+ (NSString *)clientSdk;

+ (NSString *)formatDate:(NSDate *)value;

+ (NSString *)formatSeconds1970:(double)value;

+ (NSString *)secondsNumberFormat:(double)seconds;

+ (NSString *)queryString:(NSDictionary *)parameters;

+ (NSString *)queryString:(NSDictionary *)parameters
                queueSize:(NSUInteger)queueSize;

+ (NSString *)convertDeviceToken:(NSData *)deviceToken;

+ (BOOL)isNull:(id)value;

+ (BOOL)isNotNull:(id)value;

+ (BOOL)deleteFileWithName:(NSString *)filename;

+ (BOOL)isValidParameter:(NSString *)attribute
           attributeType:(NSString *)attributeType
           parameterName:(NSString *)parameterName;

+ (NSDictionary *)convertDictionaryValues:(NSDictionary *)dictionary;

+ (NSDictionary *)mergeParameters:(NSDictionary *)target
                           source:(NSDictionary *)source
                    parameterName:(NSString *)parameterName;

+ (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme;

+ (NSTimeInterval)waitingTime:(NSInteger)retries
              backoffStrategy:(ADJBackoffStrategy *)backoffStrategy;

+ (BOOL)isDeeplinkValid:(NSURL *)url;

+ (NSString *)sdkVersion;

+ (Class)adSupportManager;

+ (Class)appTrackingManager;

+ (BOOL)trackingEnabled;

+ (NSString *)idfa;

+ (NSString *)idfv;

+ (NSString *)fbAnonymousId;

+ (NSString *)deviceType;

+ (NSString *)deviceName;

+ (NSUInteger)startedAt;

+ (int)attStatus;

+ (NSString *)fetchAdServicesAttribution:(NSError **)errorPtr;

+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(NSUInteger status))completion;

+ (NSString *)bundleIdentifier;

+ (NSString *)buildNumber;

+ (NSString *)versionNumber;

+ (NSString *)osVersion;

+ (NSString *)installedAt;

+ (NSString *)generateRandomUuid;

+ (NSString *)getPersistedRandomToken;

+ (BOOL)setPersistedRandomToken:(NSString *)randomToken;

+ (NSMutableDictionary *)deepCopyOfDictionary:(NSDictionary *)dictionary;

+ (BOOL)shouldUseConsentParamsForActivityKind:(ADJActivityKind)activityKind;

+ (BOOL)shouldUseConsentParamsForActivityKind:(ADJActivityKind)activityKind
                                 andAttStatus:(NSString *)attStatusString;

@end

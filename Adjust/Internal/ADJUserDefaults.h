//
//  ADJUserDefaults.h
//  Adjust
//
//  Created by Uglješa Erceg on 16.08.17.
//  Copyright © 2017 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJDeeplink.h"

@interface ADJUserDefaults : NSObject

+ (void)savePushTokenData:(NSData *)pushToken;

+ (void)savePushTokenString:(NSString *)pushToken;

+ (NSData *)getPushTokenData;

+ (NSString *)getPushTokenString;

+ (void)removePushToken;

+ (void)setInstallTracked;

+ (BOOL)getInstallTracked;

+ (void)setGdprForgetMe;

+ (BOOL)getGdprForgetMe;

+ (void)removeGdprForgetMe;

+ (void)saveDeeplink:(ADJDeeplink *)deeplink
           clickTime:(NSDate *)clickTime;

+ (NSURL *)getDeeplinkUrl;

+ (NSURL *)getDeeplinkReferrer;

+ (NSDate *)getDeeplinkClickTime;

+ (void)removeDeeplink;

+ (void)clearAdjustStuff;

+ (void)setAdServicesTracked;

+ (BOOL)getAdServicesTracked;

+ (void)saveSkadRegisterCallTimestamp:(NSDate *)callTime;

+ (NSDate *)getSkadRegisterCallTimestamp;

+ (void)setLinkMeChecked;

+ (BOOL)getLinkMeChecked;

+ (void)cacheDeeplinkUrl:(NSURL *)deeplink;

+ (NSURL *)getCachedDeeplinkUrl;

+ (BOOL)attWaitingRemainingSecondsKeyExists;

+ (void)setAttWaitingRemainingSeconds:(NSUInteger)seconds;

+ (NSUInteger)getAttWaitingRemainingSeconds;

+ (void)removeAttWaitingRemainingSeconds;

+ (void)saveControlParams:(NSDictionary *)controlParams;

+ (NSDictionary *)getControlParams;

+ (void)saveLastSkanUpdateData:(NSDictionary *)skanData;

+ (NSDictionary *)getLastSkanUpdateData;

+ (void)saveAppFirstLaunchTimestamp:(NSDate *)initTime;

+ (NSDate *)getAppFirstLaunchTimestamp;

+ (void)setGoogleOdmInfo:(NSString *)conversionInfo;

+ (NSString *)getGoogleOdmInfo;

+ (void)setGoogleOdmInfoProcessed;

+ (BOOL)getGoogleOdmInfoProcessed;


@end

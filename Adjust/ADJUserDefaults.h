//
//  ADJUserDefaults.h
//  Adjust
//
//  Created by Uglješa Erceg on 16.08.17.
//  Copyright © 2017 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJUserDefaults : NSObject

+ (void)savePushToken:(NSData *)pushToken;

+ (NSData *)getPushToken;

+ (void)removePushToken;

+ (void)setInstallTracked;

+ (BOOL)getInstallTracked;

+ (void)setGdprForgetMe;

+ (BOOL)getGdprForgetMe;

+ (void)removeGdprForgetMe;

+ (void)saveDeeplinkUrl:(NSURL *)deeplink
           andClickTime:(NSDate *)clickTime;

+ (NSURL *)getDeeplinkUrl;

+ (NSDate *)getDeeplinkClickTime;

+ (void)removeDeeplink;

+ (void)clearAdjustStuff;

@end

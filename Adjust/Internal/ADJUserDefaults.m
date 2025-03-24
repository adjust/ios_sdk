//
//  ADJUserDefaults.m
//  Adjust
//
//  Created by Uglješa Erceg on 16.08.17.
//  Copyright © 2017 adjust GmbH. All rights reserved.
//

#import "ADJUserDefaults.h"

static NSString * const PREFS_KEY_PUSH_TOKEN_DATA = @"adj_push_token";
static NSString * const PREFS_KEY_PUSH_TOKEN_STRING = @"adj_push_token_string";
static NSString * const PREFS_KEY_GDPR_FORGET_ME = @"adj_gdpr_forget_me";
static NSString * const PREFS_KEY_INSTALL_TRACKED = @"adj_install_tracked";
static NSString * const PREFS_KEY_DEEPLINK_URL = @"adj_deeplink_url";
static NSString * const PREFS_KEY_DEEPLINK_REFERRER = @"adj_deeplink_referrer";
static NSString * const PREFS_KEY_DEEPLINK_CLICK_TIME = @"adj_deeplink_click_time";
static NSString * const PREFS_KEY_ADSERVICES_TRACKED = @"adj_adservices_tracked";
static NSString * const PREFS_KEY_SKAD_REGISTER_CALL_TIME = @"adj_skad_register_call_time";
static NSString * const PREFS_KEY_LINK_ME_CHECKED = @"adj_link_me_checked";
static NSString * const PREFS_KEY_DEEPLINK_URL_CACHED = @"adj_deeplink_url_cached";
static NSString * const PREFS_KEY_ATT_WAITING_REMAINING_SECONDS = @"adj_att_waiting_remaining_seconds";
static NSString * const PREFS_KEY_CONTROL_PARAMS = @"adj_control_params";
static NSString * const PREFS_KEY_LAST_SKAN_UPDATE_DATA = @"adj_last_skan_update";

@implementation ADJUserDefaults

#pragma mark - Public methods

+ (void)savePushTokenData:(NSData *)pushToken {
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:PREFS_KEY_PUSH_TOKEN_DATA];
}

+ (void)savePushTokenString:(NSString *)pushToken {
    [[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:PREFS_KEY_PUSH_TOKEN_STRING];
}

+ (NSData *)getPushTokenData {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_PUSH_TOKEN_DATA];
}

+ (NSString *)getPushTokenString {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_PUSH_TOKEN_STRING];
}

+ (void)removePushToken {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_STRING];
}

+ (void)setInstallTracked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_INSTALL_TRACKED];
}

+ (BOOL)getInstallTracked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_INSTALL_TRACKED];
}

+ (void)setGdprForgetMe {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_GDPR_FORGET_ME];
}

+ (BOOL)getGdprForgetMe {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_GDPR_FORGET_ME];
}

+ (void)removeGdprForgetMe {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_GDPR_FORGET_ME];
}

+ (void)saveDeeplink:(ADJDeeplink *)deeplink
           clickTime:(NSDate *)clickTime {
    [[NSUserDefaults standardUserDefaults] setURL:deeplink.deeplink forKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] setURL:deeplink.referrer forKey:PREFS_KEY_DEEPLINK_REFERRER];
    [[NSUserDefaults standardUserDefaults] setObject:clickTime forKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (NSURL *)getDeeplinkUrl {
    return [[NSUserDefaults standardUserDefaults] URLForKey:PREFS_KEY_DEEPLINK_URL];
}

+ (NSURL *)getDeeplinkReferrer {
    return [[NSUserDefaults standardUserDefaults] URLForKey:PREFS_KEY_DEEPLINK_REFERRER];
}

+ (NSDate *)getDeeplinkClickTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (void)removeDeeplink {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_REFERRER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (void)setAdServicesTracked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_ADSERVICES_TRACKED];
}

+ (BOOL)getAdServicesTracked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_ADSERVICES_TRACKED];
}

+ (void)saveSkadRegisterCallTimestamp:(NSDate *)callTime {
    [[NSUserDefaults standardUserDefaults] setObject:callTime forKey:PREFS_KEY_SKAD_REGISTER_CALL_TIME];
}

+ (NSDate *)getSkadRegisterCallTimestamp {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_SKAD_REGISTER_CALL_TIME];
}

+ (void)setLinkMeChecked {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_LINK_ME_CHECKED];
}

+ (BOOL)getLinkMeChecked {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_LINK_ME_CHECKED];
}

+ (void)cacheDeeplinkUrl:(NSURL *)deeplink {
    [[NSUserDefaults standardUserDefaults] setURL:deeplink forKey:PREFS_KEY_DEEPLINK_URL_CACHED];
}

+ (NSURL *)getCachedDeeplinkUrl {
    return [[NSUserDefaults standardUserDefaults] URLForKey:PREFS_KEY_DEEPLINK_URL_CACHED];
}

+ (BOOL)attWaitingRemainingSecondsKeyExists {
    return (nil != [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_ATT_WAITING_REMAINING_SECONDS]);
}

+ (void)setAttWaitingRemainingSeconds:(NSUInteger)seconds {
    [[NSUserDefaults standardUserDefaults] setInteger:seconds forKey:PREFS_KEY_ATT_WAITING_REMAINING_SECONDS];
}

+ (NSUInteger)getAttWaitingRemainingSeconds {
    NSInteger iSeconds = [[NSUserDefaults standardUserDefaults] integerForKey:PREFS_KEY_ATT_WAITING_REMAINING_SECONDS];
    NSUInteger uiSeconds = (iSeconds < 0) ? 0 : iSeconds;
    return uiSeconds;
}

+ (void)removeAttWaitingRemainingSeconds {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_ATT_WAITING_REMAINING_SECONDS];
}

+ (void)saveControlParams:(NSDictionary *)controlParams {
    [[NSUserDefaults standardUserDefaults] setObject:controlParams forKey:PREFS_KEY_CONTROL_PARAMS];
}

+ (NSDictionary *)getControlParams {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:PREFS_KEY_CONTROL_PARAMS];
}

+ (void)saveLastSkanUpdateData:(NSDictionary *)skanUpdateData {
    [[NSUserDefaults standardUserDefaults] setObject:skanUpdateData forKey:PREFS_KEY_LAST_SKAN_UPDATE_DATA];
}

+ (NSDictionary *)getLastSkanUpdateData {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:PREFS_KEY_LAST_SKAN_UPDATE_DATA];
}

+ (void)clearAdjustStuff {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_STRING];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_INSTALL_TRACKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_GDPR_FORGET_ME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_REFERRER];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_ADSERVICES_TRACKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_SKAD_REGISTER_CALL_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_LINK_ME_CHECKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL_CACHED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_ATT_WAITING_REMAINING_SECONDS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_CONTROL_PARAMS];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_LAST_SKAN_UPDATE_DATA];
}

@end

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
static NSString * const PREFS_KEY_DEEPLINK_CLICK_TIME = @"adj_deeplink_click_time";
static NSString * const PREFS_KEY_DISABLE_THIRD_PARTY_SHARING = @"adj_disable_third_party_sharing";
static NSString * const PREFS_KEY_ADSERVICES_TRACKED = @"adj_adservices_tracked";
static NSString * const PREFS_KEY_SKAD_REGISTER_CALL_TIME = @"adj_skad_register_call_time";
static NSString * const PREFS_KEY_LINK_ME_CHECKED = @"adj_link_me_checked";
static NSString * const PREFS_KEY_DEEPLINK_URL_CACHED = @"adj_deeplink_url_cached";
static NSString * const PREFS_KEY_ATT_WAITING_REMAINING_SECONDS = @"adj_att_waiting_remaining_seconds";

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

+ (void)saveDeeplinkUrl:(NSURL *)deeplink andClickTime:(NSDate *)clickTime {
    [[NSUserDefaults standardUserDefaults] setURL:deeplink forKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] setObject:clickTime forKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (NSURL *)getDeeplinkUrl {
    return [[NSUserDefaults standardUserDefaults] URLForKey:PREFS_KEY_DEEPLINK_URL];
}

+ (NSDate *)getDeeplinkClickTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (void)removeDeeplink {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
}

+ (void)setDisableThirdPartySharing {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
}

+ (BOOL)getDisableThirdPartySharing {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
}

+ (void)removeDisableThirdPartySharing {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
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

+ (void)clearAdjustStuff {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_DATA];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_PUSH_TOKEN_STRING];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_INSTALL_TRACKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_GDPR_FORGET_ME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_CLICK_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DISABLE_THIRD_PARTY_SHARING];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_ADSERVICES_TRACKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_SKAD_REGISTER_CALL_TIME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_LINK_ME_CHECKED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_DEEPLINK_URL_CACHED];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PREFS_KEY_ATT_WAITING_REMAINING_SECONDS];
}

@end

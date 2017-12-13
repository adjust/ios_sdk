//
//  ADJKeychain.m
//  Adjust
//
//  Created by Uglješa Erceg on 25/08/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJLogger.h"
#import "ADJKeychain.h"
#import "ADJAdjustFactory.h"
#include <dlfcn.h>

@implementation ADJKeychain

#pragma mark - Object lifecycle methods

+ (id)getInstance {
    static ADJKeychain *defaultInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    return self;
}

#pragma mark - Public methods

+ (BOOL)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    if (key == nil) {
        return NO;
    }

    return [[ADJKeychain getInstance] setValue:value forKeychainKey:key inService:service];
}

+ (NSString *)valueForKeychainKeyV1:(NSString *)key service:(NSString *)service {
    if (key == nil) {
        return nil;
    }

    return [[ADJKeychain getInstance] valueForKeychainKeyV1:key service:service];
}

+ (NSString *)valueForKeychainKeyV2:(NSString *)key service:(NSString *)service {
    if (key == nil) {
        return nil;
    }

    return [[ADJKeychain getInstance] valueForKeychainKeyV2:key service:service];
}

+ (CFStringRef *)getSecAttrAccessGroupToken {
    CFStringRef *stringRef = dlsym(RTLD_SELF, "kSecAttrAccessGroupToken");
    return stringRef;
}

#pragma mark - Private & helper methods

- (BOOL)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    OSStatus status = [self setValueWithStatus:value forKeychainKey:key inService:service];

    if (status != noErr) {
        [[ADJAdjustFactory logger] warn:@"Value unsuccessfully written to the keychain v1 way"];

        return NO;
    } else {
        // Check was writing successful.
        BOOL wasSuccessful = [self wasWritingSuccessful:value forKeychainKey:key inService:service];

        if (wasSuccessful) {
            [[ADJAdjustFactory logger] warn:@"Value successfully written in v1 way to the keychain after the check"];
        }

        return wasSuccessful;
    }
}

- (NSString *)valueForKeychainKeyV2:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *v2KeychainItem = [self keychainItemForKeyV2:key service:service];

    return [self valueForKeychainItem:v2KeychainItem key:key service:service];
}

- (NSString *)valueForKeychainKeyV1:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *v1KeychainItem = [self keychainItemForKeyV1:key service:service];

    return [self valueForKeychainItem:v1KeychainItem key:key service:service];
}

- (NSString *)valueForKeychainItem:(NSMutableDictionary *)keychainItem key:(NSString *)key service:(NSString *)service {
    if (!keychainItem) {
        return nil;
    }

    CFDictionaryRef result = nil;

    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;

    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);

    if (status != noErr) {
        return nil;
    }

    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
    NSData *data = resultDict[(__bridge id)kSecValueData];

    if (!data) {
        return nil;
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSMutableDictionary *)keychainItemForKeyV2:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];

    CFStringRef *cStringSecAttrAccessGroupToken = [ADJKeychain getSecAttrAccessGroupToken];

    if (!cStringSecAttrAccessGroupToken) {
        return nil;
    }

    keychainItem[(__bridge id)kSecAttrAccessGroup] = (__bridge id)(* cStringSecAttrAccessGroupToken);
    [self keychainItemForKey:keychainItem key:key service:service];

    return keychainItem;
}

- (NSMutableDictionary *)keychainItemForKeyV1:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];

    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAlways;
    [self keychainItemForKey:keychainItem key:key service:service];

    return keychainItem;
}

- (void)keychainItemForKey:(NSMutableDictionary *)keychainItem key:(NSString *)key service:(NSString *)service {
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = key;
    keychainItem[(__bridge id)kSecAttrService] = service;
}

- (OSStatus)setValueWithStatus:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSMutableDictionary *keychainItem;

    keychainItem = [self keychainItemForKeyV1:key service:service];
    keychainItem[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];

    return SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

- (BOOL)wasWritingSuccessful:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSString *writtenValue;

    writtenValue = [self valueForKeychainKeyV1:key service:service];
    
    if ([writtenValue isEqualToString:value]) {
        return YES;
    } else {
        return NO;
    }
}

@end

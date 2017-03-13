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
    return [[ADJKeychain getInstance] setValue:value forKeychainKey:key inService:service];
}

+ (NSString *)valueForKeychainKeyOld:(NSString *)key service:(NSString *)service {
    return [[ADJKeychain getInstance] valueForKeychainKeyOld:key service:service];
}

+ (NSString *)valueForKeychainKeyNew:(NSString *)key service:(NSString *)service {
    return [[ADJKeychain getInstance] valueForKeychainKeyNew:key service:service];
}

#pragma mark - Private & helper methods

- (BOOL)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    OSStatus status = [self setValueWithStatus:value forKeychainKey:key inService:service];

    if (status != noErr) {
        if (NULL == &kSecAttrAccessGroupToken) {
            [[ADJAdjustFactory logger] warn:@"Value unsuccessfully written to the keychain old way"];
        } else {
            [[ADJAdjustFactory logger] warn:@"Value unsuccessfully written to the keychain new way"];
        }

        return NO;
    } else {
        // Check was writing successful.
        BOOL wasSuccessful = [self wasWritingSuccessful:value forKeychainKey:key inService:service];

        if (wasSuccessful) {
            if (NULL == &kSecAttrAccessGroupToken) {
                [[ADJAdjustFactory logger] verbose:@"Value successfully written to the keychain old way"];
            } else {
                [[ADJAdjustFactory logger] verbose:@"Value successfully written to the keychain new way"];
            }
        } else {
            if (NULL == &kSecAttrAccessGroupToken) {
                [[ADJAdjustFactory logger] warn:@"Value unsuccessfully written to the keychain after the check old way"];
            } else {
                [[ADJAdjustFactory logger] warn:@"Value unsuccessfully written to the keychain after the check new way"];
            }
        }

        return wasSuccessful;
    }
}

- (NSString *)valueForKeychainKeyNew:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *newKeychainItem = [self keychainItemForKeyNew:key service:service];

    return [self valueForKeychainItem:newKeychainItem key:key service:service];
}

- (NSString *)valueForKeychainKeyOld:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *oldKeychainItem = [self keychainItemForKeyOld:key service:service];

    return [self valueForKeychainItem:oldKeychainItem key:key service:service];
}

- (NSString *)valueForKeychainItem:(NSMutableDictionary *)keychainItem key:(NSString *)key service:(NSString *)service {
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

- (NSMutableDictionary *)keychainItemForKeyNew:(NSString *)key service:(NSString *)service {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];

    keychainItem[(__bridge id)kSecAttrAccessGroup] = (__bridge id)kSecAttrAccessGroupToken;
    [self keychainItemForKey:keychainItem key:key service:service];

    return keychainItem;
}

- (NSMutableDictionary *)keychainItemForKeyOld:(NSString *)key service:(NSString *)service {
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

    if (NULL == &kSecAttrAccessGroupToken) {
        keychainItem = [self keychainItemForKeyOld:key service:service];
    } else {
        keychainItem = [self keychainItemForKeyNew:key service:service];
    }

    keychainItem[(__bridge id)kSecValueData] = [value dataUsingEncoding:NSUTF8StringEncoding];

    return SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
}

- (BOOL)wasWritingSuccessful:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service {
    NSString *writtenValue;

    if (NULL == &kSecAttrAccessGroupToken) {
        writtenValue = [self valueForKeychainKeyOld:key service:service];
    } else {
        writtenValue = [self valueForKeychainKeyNew:key service:service];
    }

    if ([writtenValue isEqualToString:value]) {
        return YES;
    } else {
        return NO;
    }
}

@end

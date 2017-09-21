//
//  ADJKeychain.h
//  Adjust
//
//  Created by Uglješa Erceg on 25/08/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJKeychain : NSObject

+ (NSString *)valueForKeychainKeyV1:(NSString *)key service:(NSString *)service;
+ (NSString *)valueForKeychainKeyV2:(NSString *)key service:(NSString *)service;
+ (BOOL)setValue:(NSString *)value forKeychainKey:(NSString *)key inService:(NSString *)service;

@end

//
//  AIUtil.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AIUtil : NSObject

+ (NSString *)baseUrl;
+ (NSString *)clientSdk;
+ (NSString *)userAgent;

+ (void)excludeFromBackup:(NSString *)filename;
+ (NSString *)dateFormat:(double)value;

@end

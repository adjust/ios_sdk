//
//  ADJUtil.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface ADJUtil : NSObject

+ (NSString *)baseUrl;
+ (NSString *)clientSdk;

+ (void)excludeFromBackup:(NSString *)filename;
+ (NSString *)dateFormat:(double)value;
+ (NSDictionary *) buildJsonDict:(NSString *)jsonString;

+ (NSString *)getFullFilename:(NSString *) baseFilename;

+ (id)readObject:(NSString *)filename
      objectName:(NSString *)objectName;

+ (void)writeObject:(id)object
           filename:(NSString *)filename
         objectName:(NSString *)objectName;

@end

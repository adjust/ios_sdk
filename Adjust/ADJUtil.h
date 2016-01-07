//
//  ADJUtil.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "ADJActivityKind.h"
#import "ADJResponseData.h"
#import "ADJActivityPackage.h"
#import "ADJEvent.h"

@interface ADJUtil : NSObject

+ (NSString *)baseUrl;
+ (NSString *)clientSdk;

+ (void)excludeFromBackup:(NSString *)filename;
+ (NSString *)formatSeconds1970:(double)value;
+ (NSString *)formatDate:(NSDate *)value;
+ (NSDictionary *) buildJsonDict:(NSData *)jsonData
                    exceptionPtr:(NSException **)exceptionPtr
                        errorPtr:(NSError **)error;

+ (NSString *)getFullFilename:(NSString *) baseFilename;

+ (id)readObject:(NSString *)filename
      objectName:(NSString *)objectName
           class:(Class) classToRead;

+ (void)writeObject:(id)object
           filename:(NSString *)filename
         objectName:(NSString *)objectName;

+ (NSString *) queryString:(NSDictionary *)parameters;
+ (BOOL)isNull:(id)value;
+ (BOOL)isNotNull:(id)value;
+ (void)sendRequest:(NSMutableURLRequest *)request
 prefixErrorMessage:(NSString *)prefixErrorMessage
    activityPackage:(ADJActivityPackage *)activityPackage
responseDataHandler:(void (^) (ADJResponseData * responseData))responseDataHandler;

+ (void)sendRequest:(NSMutableURLRequest *)request
 prefixErrorMessage:(NSString *)prefixErrorMessage
 suffixErrorMessage:(NSString *)suffixErrorMessage
    activityPackage:(ADJActivityPackage *)activityPackage
responseDataHandler:(void (^) (ADJResponseData * responseData))responseDataHandler;

+ (NSDictionary *)convertDictionaryValues:(NSDictionary *)dictionary;

+ (NSURL*)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme;
+ (NSString*)idfa;

@end

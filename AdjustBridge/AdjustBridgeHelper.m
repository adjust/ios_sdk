//
//  AdjustBridgeHelper.m
//  Adjust
//
//  Created by Aditi Agrawal on 29/07/24.
//

#import "AdjustBridgeHelper.h"

@implementation AdjustBridgeHelper

#pragma mark - Private & helper methods

+ (BOOL)isFieldValid:(NSObject *)field {
    if (field == nil) {
        return NO;
    }
    if ([field isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[field description] length] == 0) {
        return NO;
    }
    return !!field;
}

+ (NSString *)convertJsonDictionaryToNSString:(NSDictionary *)jsonDictionary {
    if (jsonDictionary == nil) {
        return nil;
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Unable to conver NSDictionary with JSON response to JSON string: %@", error);
        return nil;
    }

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)serializeData:(id)data pretty:(BOOL)pretty {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:0 error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

+ (NSString *)serializeMutuableDictionary:(NSMutableDictionary *)data pretty:(BOOL)pretty {
    NSString *messageJSON = [self serializeData:data pretty:NO];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    messageJSON = [messageJSON stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    return messageJSON;
}

+ (NSDictionary *)getTestOptions:(id)data {
    NSString *urlOverwrite = [data objectForKey:@"urlOverwrite"];
    NSString *extraPath = [data objectForKey:@"extraPath"];
    NSNumber *timerIntervalInMilliseconds = [data objectForKey:@"timerIntervalInMilliseconds"];
    NSNumber *timerStartInMilliseconds = [data objectForKey:@"timerStartInMilliseconds"];
    NSNumber *sessionIntervalInMilliseconds = [data objectForKey:@"sessionIntervalInMilliseconds"];
    NSNumber *subsessionIntervalInMilliseconds = [data objectForKey:@"subsessionIntervalInMilliseconds"];
    NSNumber *teardown = [data objectForKey:@"teardown"];
    NSNumber *deleteState = [data objectForKey:@"deleteState"];
    NSNumber *noBackoffWait = [data objectForKey:@"noBackoffWait"];
    NSNumber *adServicesFrameworkEnabled = [data objectForKey:@"adServicesFrameworkEnabled"];
    NSNumber *attStatus = [data objectForKey:@"attStatus"];
    NSString *idfa = [data objectForKey:@"idfa"];

    NSMutableDictionary *testOptions = [NSMutableDictionary dictionary];

    if ([self isFieldValid:urlOverwrite]) {
        [testOptions setObject:urlOverwrite forKey:@"testUrlOverwrite"];
    }
    if ([self isFieldValid:extraPath]) {
        [testOptions setObject:extraPath forKey:@"extraPath"];
    }
    if ([self isFieldValid:timerIntervalInMilliseconds]) {
        [testOptions setObject:timerIntervalInMilliseconds forKey:@"timerIntervalInMilliseconds"];
    }
    if ([self isFieldValid:timerStartInMilliseconds]) {
        [testOptions setObject:timerStartInMilliseconds forKey:@"timerStartInMilliseconds"];
    }
    if ([self isFieldValid:sessionIntervalInMilliseconds]) {
        [testOptions setObject:sessionIntervalInMilliseconds forKey:@"sessionIntervalInMilliseconds"];
    }
    if ([self isFieldValid:subsessionIntervalInMilliseconds]) {
        [testOptions setObject:subsessionIntervalInMilliseconds forKey:@"subsessionIntervalInMilliseconds"];
    }
    if ([self isFieldValid:attStatus]) {
        [testOptions setObject:attStatus forKey:@"attStatusInt"];
    }
    if ([self isFieldValid:idfa]) {
        [testOptions setObject:idfa forKey:@"idfa"];
    }
    if ([self isFieldValid:teardown]) {
        [testOptions setObject:teardown forKey:@"teardown"];
    }
    if ([self isFieldValid:deleteState]) {
        [testOptions setObject:deleteState forKey:@"deleteState"];
    }
    if ([self isFieldValid:noBackoffWait]) {
        [testOptions setObject:noBackoffWait forKey:@"noBackoffWait"];
    }
    if ([self isFieldValid:adServicesFrameworkEnabled]) {
        [testOptions setObject:adServicesFrameworkEnabled forKey:@"adServicesFrameworkEnabled"];
    }

    return testOptions;
}

+ (NSString *)getFbAppId {
    NSString *facebookLoggingOverrideAppID = [[self class] 
                                              getValueFromBundleByKey:@"FacebookLoggingOverrideAppID"];
    if (facebookLoggingOverrideAppID != nil) {
        return facebookLoggingOverrideAppID;
    }

    return [[self class] getValueFromBundleByKey:@"FacebookAppID"];
}

- (NSString *)getValueFromBundleByKey:(NSString *)key {
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:key] copy];
}

@end

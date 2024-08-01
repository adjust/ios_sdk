//
//  AdjustBridgeUtil.m
//  Adjust
//
//  Created by Aditi Agrawal on 29/07/24.
//  Copyright © 2024-Present Adjust GmbH. All rights reserved.
//

#import "AdjustBridgeUtil.h"

@implementation AdjustBridgeUtil

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

+ (void)launchInMainThread:(dispatch_block_t)block {
    dispatch_async(dispatch_get_main_queue(), block);
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
    NSString *jsonString =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@"\\r"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\f" withString:@"\\f"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\u2028" withString:@"\\u2028"];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\u2029" withString:@"\\u2029"];
    return jsonString;
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


@end


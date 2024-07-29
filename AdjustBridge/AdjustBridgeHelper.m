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

@end

//
//  ADJUtilF.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJUtilF.h"

#import <math.h>
#import "ADJBooleanWrapper.h"
#import "ADJConstants.h"
#import "ADJUtilConv.h"
#import "ADJUtilObj.h"

@interface ADJUtilF ()
#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) NSLocale *usLocale;
//@property (nonnull, readonly, strong, nonatomic) NSNumberFormatter *integerFormatter;
@property (nonnull, readonly, strong, nonatomic) NSNumberFormatter *decimalStyleFormatter;
@property (nonnull, readonly, strong, nonatomic) NSNumberFormatter *secondsFormatter;
@property (nonnull, readonly, strong, nonatomic) NSDateFormatter *serverDateFormatter;
@property (nonnull, readonly, strong, nonatomic) NSCharacterSet *urlUnreservedCharacterSet;

@end

@implementation ADJUtilF
#pragma mark Instantiation
#pragma mark - Private constructors
- (nonnull instancetype)init {
    self = [super init];

    _usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //_integerFormatter = [ADJUtilF createIntegerFormatter];
    _decimalStyleFormatter = [ADJUtilF createDecimalStyleFormatterWithLocale:self.usLocale];
    _secondsFormatter = [ADJUtilF createSecondsFormatterWithLocale:self.usLocale];
    _serverDateFormatter = [ADJUtilF createServerDateFormatterWithLocale:self.usLocale];
    _urlUnreservedCharacterSet = [ADJUtilF createUrlUnreservedCharacterSet];

    return self;
}
/*
 + (nonnull NSNumberFormatter *)createIntegerFormatter {
 NSNumberFormatter *_Nonnull integerFormatter = [[NSNumberFormatter alloc] init];
 [integerFormatter setNumberStyle:NSNumberFormatterNoStyle];

 return integerFormatter;
 }
 */
+ (nonnull NSNumberFormatter *)createDecimalStyleFormatterWithLocale:(nonnull NSLocale *)locale {
    NSNumberFormatter *_Nonnull decimalStyleFormatter = [[NSNumberFormatter alloc] init];
    [decimalStyleFormatter setLocale:locale];
    [decimalStyleFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    return decimalStyleFormatter;
}

+ (nonnull NSNumberFormatter *)createSecondsFormatterWithLocale:(nonnull NSLocale *)locale {
    NSNumberFormatter *_Nonnull secondsFormatter = [[NSNumberFormatter alloc] init];
    [secondsFormatter setPositiveFormat:@"0.0"];
    [secondsFormatter setLocale:locale];

    return secondsFormatter;
}

+ (nonnull NSDateFormatter *)createServerDateFormatterWithLocale:(nonnull NSLocale *)locale {
    NSDateFormatter *_Nonnull dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setCalendar:
     [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z"];

    return dateFormatter;
}

// Follows the unreserved character set of https://tools.ietf.org/html/rfc3986#section-2.3
+ (nonnull NSCharacterSet *)createUrlUnreservedCharacterSet {
    // digit
    NSMutableCharacterSet *_Nonnull urlAllowCharacterSetBuilder =
    [NSMutableCharacterSet characterSetWithCharactersInString:@"0123456789"];

    // lower alpha
    NSRange lowerAlphaRange;
    lowerAlphaRange.location = (unsigned int)'a';
    lowerAlphaRange.length = 26;

    [urlAllowCharacterSetBuilder formUnionWithCharacterSet:
     [NSCharacterSet characterSetWithRange:lowerAlphaRange]];

    // upper alpha
    NSRange upperAlpha;
    upperAlpha.location = (unsigned int)'A';
    upperAlpha.length = 26;

    [urlAllowCharacterSetBuilder formUnionWithCharacterSet:
     [NSCharacterSet characterSetWithRange:upperAlpha]];

    // special non-escaped characters
    // space ' ' is later replaced by plus '+'
    [urlAllowCharacterSetBuilder formUnionWithCharacterSet:
     [NSCharacterSet characterSetWithCharactersInString:@"-._~ "]];

    return [urlAllowCharacterSetBuilder copy];
}

#pragma mark - Private singleton
+ (nonnull ADJUtilF *)sharedInstance {
    static ADJUtilF *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark Public API
+ (nonnull NSLocale *)usLocale {
    return [self sharedInstance].usLocale;
}

+ (nonnull NSNumberFormatter *)decimalStyleFormatter {
    return [self sharedInstance].decimalStyleFormatter;
}

+ (nonnull NSString *)boolFormat:(BOOL)boolValue {
    return boolValue ? ADJBooleanTrueString : ADJBooleanFalseString;
}

+ (nonnull NSString *)intFormat:(int)intValue {
    return [NSString stringWithFormat:@"%d", intValue];
}

+ (nonnull NSString *)uIntFormat:(unsigned int)uIntValue {
    return [NSString stringWithFormat:@"%u", uIntValue];
}

+ (nonnull NSString *)uLongFormat:(unsigned long)uLongValue {
    return [NSString stringWithFormat:@"%lu", uLongValue];
}

+ (nonnull NSString *)uLongLongFormat:(unsigned long long)uLongLongValue {
    return [NSString stringWithFormat:@"%llu", uLongLongValue];
}

+ (nonnull NSString *)integerFormat:(NSInteger)integerValue {
    return [NSString stringWithFormat:@"%ld", (long)integerValue];
}

+ (nonnull NSString *)uIntegerFormat:(NSUInteger)uIntegerFormat {
    return [NSString stringWithFormat:@"%lu", (unsigned long)uIntegerFormat];
}

+ (nonnull NSString *)longLongFormat:(long long)longLongValue {
    return [NSString stringWithFormat:@"%lld", longLongValue];
}

+ (nonnull NSString *)errorFormat:(nonnull NSError *)error {
    return [ADJUtilObj formatInlineKeyValuesWithName:@"NSError",
            @"domain", error.domain,
            @"code", @(error.code),
            @"localizedDescription", error.localizedDescription,
            @"localizedFailureReason", error.localizedFailureReason,
            @"localizedRecoverySuggestion", error.localizedRecoverySuggestion,
            nil];
}

+ (nullable NSString *)jsonDataFormat:(nonnull NSData *)jsonData {
    NSString *_Nullable converted =
    [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    if (converted == nil) {
        return nil;
    }

    return [converted stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (nullable NSString *)jsonFoundationValueFormat:(nullable id)jsonFoundationValue {
    if (jsonFoundationValue == nil) { return nil; }

    NSError *error;
    NSData *_Nullable jsonData =
    [ADJUtilConv convertToJsonDataWithJsonFoundationValue:jsonFoundationValue
                                                 errorPtr:&error];

    if (jsonData == nil) {
        return nil;
    }

    return [ADJUtilF jsonDataFormat:jsonData];
}

+ (nonnull NSString *)secondsFormat:(nonnull NSNumber *)secondsNumber {
    ADJUtilF *_Nonnull sharedInstance = [self sharedInstance];
    return [sharedInstance.secondsFormatter stringFromNumber:secondsNumber];
}

+ (nonnull NSString *)dateTimestampFormat:(nonnull ADJTimestampMilli *)timestamp {
    ADJUtilF *_Nonnull sharedInstance = [self sharedInstance];
    return [sharedInstance.serverDateFormatter stringFromDate:
            [NSDate dateWithTimeIntervalSince1970:
             [ADJUtilConv convertToSecondsWithMilliseconds:
              timestamp.millisecondsSince1970Int.uIntegerValue]]];
}

+ (nonnull NSString *)logMessageAndParamsFormat:
    (nonnull ADJInputLogMessageData *)inputLogMessageData
{
    if (inputLogMessageData.messageParams == nil) {
        return inputLogMessageData.message;
    }

    return [NSString stringWithFormat:@"%@ %@", inputLogMessageData.message,
            [ADJLogMessageData generateJsonFromFoundationDictionary:
             inputLogMessageData.messageParams]];
}
+ (nonnull id)stringOrNsNull:(nullable NSString *)string {
    return string == nil ? [NSNull null] : string;
}


+ (BOOL)matchesWithString:(nonnull NSString *)stringValue
                    regex:(nonnull NSRegularExpression *)regex {
    return [regex matchesInString:stringValue
                          options:0
                            range:NSMakeRange(0, stringValue.length)].count > 0;
}

+ (BOOL)isNotANumber:(nonnull NSNumber *)numberValue {
    return [[NSDecimalNumber notANumber] isEqualToNumber:numberValue];
}

+ (nullable NSString *)urlReservedEncodeWithSpaceAsPlus:(nonnull NSString *)stringToEncode {
    ADJUtilF *_Nonnull sharedInstance = [self sharedInstance];

    NSString *_Nullable urlEncoded =
    [stringToEncode
     stringByAddingPercentEncodingWithAllowedCharacters:
         sharedInstance.urlUnreservedCharacterSet];

    if (urlEncoded == nil) {
        return nil;
    }

    return [urlEncoded stringByReplacingOccurrencesOfString:@" "
                                                 withString:@"+"];
}

+ (nonnull NSString *)normaliseFilename:(nonnull NSString *)filename {
    // TODO: add rules as mentioned here https://stackoverflow.com/questions/6102333/what-characters-are-allowed-in-a-ios-file-name
    return filename;
}

+ (nonnull NSString *)joinString:(nonnull NSString *)first, ... {
    NSString *iter, *_Nonnull result = first;
    va_list strings;
    va_start(strings, first);

    while ((iter = va_arg(strings, NSString*))) {
        NSString *capitalized = iter.capitalizedString;
        result = [result stringByAppendingString:capitalized];
    }

    va_end(strings);

    return result;
}

+ (nullable NSString *)stringValueOrNil:(nullable ADJNonEmptyString *)value {
    if (value == nil) {
        return nil;
    }

    return value.stringValue;
}

+ (void)transferExternalParametersWithFoundationMapToRead:(nonnull NSDictionary<NSString *, NSString *> *)foundationMapToRead
                                        parametersToWrite:(nonnull ADJStringMapBuilder *)parametersToWrite
                                                   source:(nonnull NSString *)source
                                                   logger:(nonnull ADJLogger *)logger {
    NSDictionary<NSString *, NSString *> *_Nonnull foundationMapToReadCopy = [foundationMapToRead copy];

    for (NSString *_Nonnull readKey in foundationMapToReadCopy) {
        ADJNonEmptyString *_Nullable keyToWrite = [ADJNonEmptyString
                                                   instanceFromString:readKey
                                                   sourceDescription:[NSString stringWithFormat:@"Parameter %@ key to write", source]
                                                   logger:logger];

        if (keyToWrite == nil) {
            continue;
        }

        NSString *_Nonnull readValue = [foundationMapToReadCopy objectForKey:readKey];

        ADJNonEmptyString *_Nullable valueToWrite = [ADJNonEmptyString
                                                     instanceFromString:readValue
                                                     sourceDescription:[NSString stringWithFormat:@"Parameter %@ value to write", source]
                                                     logger:logger];

        if (valueToWrite == nil) {
            continue;
        }

        [parametersToWrite addPairWithValue:valueToWrite key:keyToWrite.stringValue];
    }
}

@end

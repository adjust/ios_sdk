//
//  ADJBooleanWrapper.m
//  Adjust
//
//  Created by Aditi Agrawal on 18/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJBooleanWrapper.h"

#import "ADJConstants.h"
#import "ADJUtilF.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonatomic, readonly, assign) BOOL boolValue;
 */

#pragma mark - Public constants
NSString *const ADJBooleanTrueString = @"true";
NSString *const ADJBooleanFalseString = @"false";

@implementation ADJBooleanWrapper
#pragma mark Instantiation
+ (nonnull instancetype)instanceFromBool:(BOOL)boolValue {
    return boolValue ? [self trueInstance] : [self falseInstance];
}

+ (nullable instancetype)instanceFromNumberBoolean:(nullable NSNumber *)numberBooleanValue {
    if (numberBooleanValue == nil) {
        return nil;
    }

    return [self instanceFromBool:[numberBooleanValue boolValue]];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromIoValue:
    (nullable ADJNonEmptyString *)ioValue
{
    if (ioValue == nil) {
        return [ADJResult nilInputWithMessage:@"Cannot create boolean wrapper with nil io value"];
    }

    if ([ioValue.stringValue isEqualToString:ADJBooleanTrueString]) {
        return [ADJResult okWithValue:[self trueInstance]];
    }

    if ([ioValue.stringValue isEqualToString:ADJBooleanFalseString]) {
        return [ADJResult okWithValue:[self falseInstance]];
    }

    return [ADJResult failWithMessage:@"Could not match io value to valid boolean value"
                                  key:@"io value"
                          stringValue:ioValue.stringValue];
}

+ (nonnull ADJResult<ADJBooleanWrapper *> *)instanceFromString:(nullable NSString *)stringValue {
    ADJResult<ADJNonEmptyString *> *_Nonnull booleanStringResult =
        [ADJNonEmptyString instanceFromString:stringValue];

    if (booleanStringResult.wasInputNil) {
        return [ADJResult nilInputWithMessage:@"Cannot create boolean with nil string"];
    }
    if (booleanStringResult.fail != nil) {
        return [ADJResult failWithMessage:@"Cannot create boolean with invalid string"
                                      key:@"string fail"
                                otherFail:booleanStringResult.fail];
    }

    return [ADJBooleanWrapper instanceFromIoValue:booleanStringResult.value];
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private constructors
+ (nonnull ADJBooleanWrapper *)trueInstance {
    static dispatch_once_t onceTrueInstanceToken;
    static ADJBooleanWrapper * trueInstance;
    dispatch_once(&onceTrueInstanceToken, ^{
        trueInstance = [[ADJBooleanWrapper alloc] initWithBoolValue:YES];
    });
    return trueInstance;
}

+ (nonnull ADJBooleanWrapper *)falseInstance {
    static dispatch_once_t onceFalseInstanceToken;
    static ADJBooleanWrapper * falseInstance;
    dispatch_once(&onceFalseInstanceToken, ^{
        falseInstance = [[ADJBooleanWrapper alloc] initWithBoolValue:NO];
    });
    return falseInstance;
}

+ (nonnull ADJNonEmptyString *)trueString {
    static dispatch_once_t onceTrueStringToken;
    static ADJNonEmptyString * trueString;
    dispatch_once(&onceTrueStringToken, ^{
        trueString = [[ADJNonEmptyString alloc]
                      initWithConstStringValue:ADJBooleanTrueString];
    });
    return trueString;
}

+ (nonnull ADJNonEmptyString *)falseString {
    static dispatch_once_t onceFalseStringToken;
    static ADJNonEmptyString * falseString;
    dispatch_once(&onceFalseStringToken, ^{
        falseString = [[ADJNonEmptyString alloc]
                       initWithConstStringValue:ADJBooleanFalseString];
    });
    return falseString;
}

- (nonnull instancetype)initWithBoolValue:(BOOL)boolValue {
    self = [super init];

    _boolValue = boolValue;
    _numberBoolValue = [NSNumber numberWithBool:boolValue];

    return self;
}

#pragma mark Public API
#pragma mark - ADJIoValueSerializable
- (nonnull ADJNonEmptyString *)toIoValue {
    return self.boolValue ? [ADJBooleanWrapper trueString] : [ADJBooleanWrapper falseString];
}

#pragma mark - ADJPackageParamValueSerializable
- (nullable ADJNonEmptyString *)toParamValue {
    // TODO: change all boolean values to be "true"/"false" instead of "0"/"1" in the backend
    return self.boolValue ? [ADJBooleanWrapper trueString] : [ADJBooleanWrapper falseString];
}

#pragma mark - NSObject
- (nonnull NSString *)description {
    return [ADJUtilF boolFormat:self.boolValue];
}

- (NSUInteger)hash {
    NSUInteger hashCode = ADJInitialHashCode;

    hashCode = ADJHashCodeMultiplier * hashCode + [@(self.boolValue) hash];

    return hashCode;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:[ADJBooleanWrapper class]]) {
        return NO;
    }

    ADJBooleanWrapper *other = (ADJBooleanWrapper *)object;
    return self.boolValue == other.boolValue;
}

@end


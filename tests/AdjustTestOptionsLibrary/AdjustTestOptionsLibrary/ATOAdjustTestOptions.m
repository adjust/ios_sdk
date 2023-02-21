//
//  ATOAdjustTestOptions.m
//  AdjustTestApp
//
//  Created by Pedro S. on 07.05.21.
//  Copyright © 2021 adjust. All rights reserved.
//

#import "ATOAdjustTestOptions.h"

#import "ADJSdkConfigDataBuilder.h"
#import "ADJSdkConfigData.h"
#import "ADJNetworkEndpointData.h"
#import "ADJTimeLengthMilli.h"
#import "ADJAdjustInternal.h"
#import "ATOLogger.h"

static NSString *baseLocalEmulatorIp = @"127.0.0.1";

@interface ATOAdjustTestOptions ()

@property (nullable, readwrite, strong, nonatomic) NSString *urlOverwrite;
@property (nullable, readwrite, strong, nonatomic) NSString *extraPath;
@property (nullable, readwrite, strong, nonatomic) NSNumber *foregroundTimerIntervalMilli;
@property (nullable, readwrite, strong, nonatomic) NSNumber *foregroundTimerStartMilli;
@property (nullable, readwrite, strong, nonatomic) NSNumber *minSdkSessionIntervalMilli;
@property (nullable, readwrite, strong, nonatomic) NSNumber *minLifecycleIntervalMilli;
@property (nullable, readwrite, strong, nonatomic) NSNumber *overwriteFirstSdkSessionIntervalMilli;

@property (readwrite, assign, nonatomic) BOOL clearStorage;
@property (readwrite, assign, nonatomic) BOOL doNotReadCurrentLifecycleStatus;
@property (readwrite, assign, nonatomic) BOOL doNotInitiateAttributionFromSdk;
@property (readwrite, assign, nonatomic) BOOL doNotReadAsaAttribution;
@property (readwrite, assign, nonatomic) BOOL doCreateEntryRootInstance;

@end

@implementation ATOAdjustTestOptions

- (nonnull instancetype)init {
    self = [super init];

    return self;
}

+ (void)initialize {
    [ATOAdjustTestOptions clearAndResetCachedOptions];
}

+ (void)addToOptionsSetWithKey:(nonnull NSString *)key value:(nonnull NSString *)value {
    NSMutableOrderedSet<NSArray<NSString *> *> *_Nonnull cachedTestOptionsSet =
        [self cachedTestOptionsSet];

    [cachedTestOptionsSet addObject:@[key, value]];
}

+ (nullable NSString *)
    teardownAndApplyAddedTestOptionsSetWithUrlOverwrite:(nonnull NSString *)urlOverwrite
{
    return [self
                teardownAndApplyAddedTestOptionsSetWithUrlOverwrite:urlOverwrite
                testOptionsSet:[self cachedTestOptionsSet]];
}

+ (nullable NSString *)
    teardownAndExecuteTestOptionsCommandWithUrlOverwrite:(nonnull NSString *)urlOverwrite
    commandParameters:
        (nonnull NSDictionary<NSString *, NSArray<NSString* > *> *)commandParameters
{
    // merge command parameters into cached test options set
    for (NSString *_Nonnull key in commandParameters) {
        NSArray<NSString* > *_Nonnull commandEntry = commandParameters[key];
        if ([commandEntry count] == 0) {
            [ATOAdjustTestOptions addToOptionsSetWithKey:key
                                                   value:@""];
            continue;
        }
        for (NSString *_Nonnull value in commandEntry) {
            [ATOAdjustTestOptions addToOptionsSetWithKey:key
                                                   value:value];
        }
    }

    // teardown using cached test options set
    return [self teardownAndApplyAddedTestOptionsSetWithUrlOverwrite:urlOverwrite];
}

+ (nonnull NSMutableOrderedSet<NSArray<NSString *> *> *)cachedTestOptionsSet {
    static dispatch_once_t cachedTestOptionsSetToken;
    static NSMutableOrderedSet<NSArray<NSString *> *> *cachedTestOptionsSet;
    dispatch_once(&cachedTestOptionsSetToken, ^{
        cachedTestOptionsSet = [[NSMutableOrderedSet alloc] init];
    });
    return cachedTestOptionsSet;
}

+ (nonnull ATOAdjustTestOptions *)cachedTestOptions {
    static dispatch_once_t cachedTestOptionsToken;
    static ATOAdjustTestOptions *cachedTestOptions;
    dispatch_once(&cachedTestOptionsToken, ^{
        cachedTestOptions = [[ATOAdjustTestOptions alloc] init];
    });
    return cachedTestOptions;
}


+ (nullable NSString *)
    teardownAndApplyAddedTestOptionsSetWithUrlOverwrite:(nonnull NSString *)urlOverwrite
    testOptionsSet: (nonnull NSMutableOrderedSet<NSArray<NSString *> *> *)testOptionsSet
{
    ATOAdjustTestOptions *_Nonnull cachedTestOptions = [self cachedTestOptions];

    // save injected fields into cached Adjust test options
    cachedTestOptions.urlOverwrite = urlOverwrite;

    // merge test options set into cached test options, if they are not the same
    NSMutableOrderedSet<NSArray<NSString *> *> *_Nonnull cachedTestOptionsSet =
        [self cachedTestOptionsSet];

    if (testOptionsSet != cachedTestOptionsSet) {
        [cachedTestOptionsSet unionSet:(NSSet<NSArray<NSString *> *> *)testOptionsSet];
    }

    // merge cached test options set into cached Adjust test options
    [self mergeIntoTestOptionsWithSet:[cachedTestOptionsSet copy]
                    adjustTestOptions:cachedTestOptions];

    // teardown using cached Adjust test options
    return [self teardownAndApplyAdjustTestOptions:cachedTestOptions];
}

+ (nullable NSString *)
    teardownAndApplyAdjustTestOptions:(nonnull ATOAdjustTestOptions *)adjustTestOptions
{
    [self mergeIntoCachedWithTestOptions:adjustTestOptions];
    ATOAdjustTestOptions *_Nonnull mergedTestOptions = [self cachedTestOptions];

    ADJSdkConfigData *_Nullable sdkConfigData =
        [self sdkConfigDataWithTestOptions:mergedTestOptions];

    NSString *_Nonnull returnMessage =
        [ADJAdjustInternal teardownWithSdkConfigData:sdkConfigData
                                  shouldClearStorage:mergedTestOptions.clearStorage];

    [[ATOLogger sharedInstance] debugDev:returnMessage
                                     key:@"from"
                                   value:@"teardownAndApplySdkConfig"];

    NSString *_Nullable extraPath = mergedTestOptions.extraPath;

    [self clearAndResetCachedOptions];

    if (sdkConfigData != nil) {
        return sdkConfigData.networkEndpointData.extraPath;
    } else {
        return extraPath;
    }
}

+ (nullable ADJSdkConfigData *)
    sdkConfigDataWithTestOptions:(nonnull ATOAdjustTestOptions *)testOptions
{
    if (! testOptions.doCreateEntryRootInstance) {
        return nil;
    }

    ADJSdkConfigDataBuilder *_Nonnull sdkConfigDataBuilder =
        [[ADJSdkConfigDataBuilder alloc] initWithDefaultValues];

    sdkConfigDataBuilder.assumeSandboxEnvironmentForLogging = YES;
    sdkConfigDataBuilder.assumeDevLogs = YES;

    [self mergeIntoSdkConfigWithAdjustTestOptions:testOptions
                             sdkConfigDataBuilder:sdkConfigDataBuilder];

    return [[ADJSdkConfigData alloc] initWithBuilderData:sdkConfigDataBuilder];
}

+ (void)mergeIntoTestOptionsWithSet:(nonnull NSSet<NSArray<NSString *> *> *)testOptionsSet
                  adjustTestOptions:(nonnull ATOAdjustTestOptions *)adjustTestOptions
{
    for (NSArray<NSString *> *kvPair in testOptionsSet) {
        NSString *_Nonnull key = kvPair[0];
        NSString *_Nonnull value = kvPair[1];

        if ([@"extraPath" isEqualToString:key]) {
            adjustTestOptions.extraPath = value;
            [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                             key:@"extraPath"
                                           value:adjustTestOptions.extraPath];
        }

        if ([@"foregroundTimerIntervalMilli" isEqual:key]) {
            NSNumber *_Nullable foregroundTimerIntervalMilliNumber =
                [self convertToNSNumberIntWithStringValue:value];

            if (foregroundTimerIntervalMilliNumber != nil) {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"foregroundTimerIntervalMilli"
                                               value:foregroundTimerIntervalMilliNumber.description];
                adjustTestOptions.foregroundTimerIntervalMilli = foregroundTimerIntervalMilliNumber;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet foregroundTimerIntervalMilli unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"foregroundTimerStartMilli" isEqual:key]) {
            NSNumber *_Nullable foregroundTimerStartMilliNumber =
                [self convertToNSNumberIntWithStringValue:value];

            if (foregroundTimerStartMilliNumber != nil) {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"foregroundTimerStartMilli"
                                               value:foregroundTimerStartMilliNumber.description];
                adjustTestOptions.foregroundTimerStartMilli = foregroundTimerStartMilliNumber;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet foregroundTimerStartMilli unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"minSdkSessionIntervalMilli" isEqual:key]) {
            NSNumber *_Nullable minSdkSessionIntervalMilliNumber =
                [self convertToNSNumberIntWithStringValue:value];

            if (minSdkSessionIntervalMilliNumber != nil) {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"minSdkSessionIntervalMilli"
                                               value:minSdkSessionIntervalMilliNumber.description];
                adjustTestOptions.minSdkSessionIntervalMilli = minSdkSessionIntervalMilliNumber;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet minSdkSessionIntervalMilli unread"
                                                 key:@"value read"
                                               value:value];
            }
        }
        
        if ([@"minLifecycleIntervalMilli" isEqual:key]) {
            NSNumber *_Nullable minLifecycleIntervalMilliNumber =
                [self convertToNSNumberIntWithStringValue:value];

            if (minLifecycleIntervalMilliNumber != nil) {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"minLifecycleIntervalMilli"
                                               value:minLifecycleIntervalMilliNumber.description];
                adjustTestOptions.minLifecycleIntervalMilli = minLifecycleIntervalMilliNumber;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet minLifecycleIntervalMilli unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"overwriteFirstSdkSessionIntervalMilli" isEqual:key]) {
            NSNumber *_Nullable overwriteFirstSdkSessionIntervalMilliNumber =
                [self convertToNSNumberIntWithStringValue:value];

            if (overwriteFirstSdkSessionIntervalMilliNumber != nil) {
                [[ATOLogger sharedInstance]
                 debugDev:@"mergeIntoTestOptionsWithSet"
                 key:@"overwriteFirstSdkSessionIntervalMilli"
                 value:overwriteFirstSdkSessionIntervalMilliNumber.description];
                adjustTestOptions.overwriteFirstSdkSessionIntervalMilli =
                    overwriteFirstSdkSessionIntervalMilliNumber;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet overwriteFirstMeasurementSessionIntervalMilli unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"doReadCurrentLifecycleStatus" isEqualToString:key]) {
            NSNumber *_Nullable doReadCurrentLifecycleStatusBoolNumber =
                [self strictParseNumberBooleanWithString:value];

            if (doReadCurrentLifecycleStatusBoolNumber != nil
                && doReadCurrentLifecycleStatusBoolNumber.boolValue)
            {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"doReadCurrentLifecycleStatus"
                                               value:doReadCurrentLifecycleStatusBoolNumber.description];
                adjustTestOptions.doNotReadCurrentLifecycleStatus = NO;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet doReadCurrentLifecycleStatus unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"initiateAttributionFromSdk" isEqual:key]) {
            NSNumber *_Nullable initiateAttributionFromSdkBoolNumber =
                [self strictParseNumberBooleanWithString:value];

            if (initiateAttributionFromSdkBoolNumber != nil
                && initiateAttributionFromSdkBoolNumber.boolValue)
            {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"initiateAttributionFromSdk"
                                               value:initiateAttributionFromSdkBoolNumber.description];
                adjustTestOptions.doNotInitiateAttributionFromSdk = NO;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet initiateAttributionFromSdk unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"adServicesFrameworkEnabled" isEqual:key]) {
            NSNumber *_Nullable adServicesFrameworkEnabledNumber =
                [self strictParseNumberBooleanWithString:value];

            if (adServicesFrameworkEnabledNumber != nil
                && adServicesFrameworkEnabledNumber.boolValue)
            {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"adServicesFrameworkEnabled"
                                               value:adServicesFrameworkEnabledNumber.description];
                adjustTestOptions.doNotReadAsaAttribution = NO;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet adServicesFrameworkEnabled unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"doNotCreateEntryRootInstance" isEqual:key]) {
            NSNumber *_Nullable doNotCreateEntryRootInstanceBoolNumber =
                [self strictParseNumberBooleanWithString:value];

            if (doNotCreateEntryRootInstanceBoolNumber != nil
                && doNotCreateEntryRootInstanceBoolNumber.boolValue)
            {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"doNotCreateEntryRootInstance"
                                               value:doNotCreateEntryRootInstanceBoolNumber.description];
                adjustTestOptions.doCreateEntryRootInstance = NO;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet doNotCreateEntryRootInstance unread"
                                                 key:@"value read"
                                               value:value];
            }
        }

        if ([@"deleteState" isEqual:key]) {
            NSNumber *_Nullable deleteStateBoolNumber = [self strictParseNumberBooleanWithString:value];

            if (deleteStateBoolNumber != nil
                && deleteStateBoolNumber.boolValue)
            {
                [[ATOLogger sharedInstance] debugDev:@"mergeIntoTestOptionsWithSet"
                                                 key:@"deleteState"
                                               value:deleteStateBoolNumber.description];
                adjustTestOptions.clearStorage = YES;
            } else {
                [[ATOLogger sharedInstance] debugDev:
                 @"mergeIntoTestOptionsWithSet deleteState unread"
                                                 key:@"value read"
                                               value:value];
            }
        }
        // ...
    }
}

/*
         if (key.equals("minLifecycleIntervalMilli")) {
             adjustTestOptions.minLifecycleIntervalMilli = Long.parseLong(value);
             UtilTO.logger().debug(
                     "mergeOptionsSetIntoAdjustTestOptions minLifecycleIntervalMilli: %d",
                     adjustTestOptions.minLifecycleIntervalMilli);
         }

         if (key.equals("noBackoffForAll")) {
             @Nullable final Boolean noBackoffWaitBoolean =
                     UtilTO.strictParseStringToBoolean(value);
             if (noBackoffWaitBoolean != null && ! noBackoffWaitBoolean.booleanValue()) {
                 UtilTO.logger().debug(
                         "mergeOptionsSetIntoAdjustTestOptions noBackoffForAll");
                 adjustTestOptions.noBackoffForAll = true;
             }
         }
         if (key.equals("v4NamespacePrefix")) {
             UtilTO.logger().debug(
                     "mergeOptionsSetIntoAdjustTestOptions v4NamespacePrefix: %s",
                     value);
             adjustTestOptions.v4NamespacePrefix = value;
         }
     }
 }

 */

+ (void)mergeIntoCachedWithTestOptions:(nonnull ATOAdjustTestOptions *)adjustTestOptions {
    ATOAdjustTestOptions *_Nonnull cachedTestOptions = [self cachedTestOptions];

    // if it's the same instance, it's already merged
    if (cachedTestOptions == adjustTestOptions) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions same instance"];
        return;
    }

    if (adjustTestOptions.extraPath != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                         key:@"extraPath"
                                       value:adjustTestOptions.extraPath];
        cachedTestOptions.extraPath = adjustTestOptions.extraPath;
    }

    if (adjustTestOptions.urlOverwrite != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                         key:@"urlOverwrite"
                                       value:adjustTestOptions.urlOverwrite];
        cachedTestOptions.urlOverwrite = adjustTestOptions.urlOverwrite;
    }

    if (adjustTestOptions.foregroundTimerIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                         key:@"foregroundTimerIntervalMilli"
                                       value:adjustTestOptions.foregroundTimerIntervalMilli.description];
        cachedTestOptions.foregroundTimerIntervalMilli = adjustTestOptions.foregroundTimerIntervalMilli;
    }

    if (adjustTestOptions.foregroundTimerStartMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                         key:@"foregroundTimerStartMilli"
                                       value:adjustTestOptions.foregroundTimerStartMilli.description];
        cachedTestOptions.foregroundTimerStartMilli = adjustTestOptions.foregroundTimerStartMilli;
    }

    if (adjustTestOptions.minSdkSessionIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                         key:@"minSdkSessionIntervalMilli"
                                       value:adjustTestOptions.minSdkSessionIntervalMilli.description];
        cachedTestOptions.minSdkSessionIntervalMilli = adjustTestOptions.minSdkSessionIntervalMilli;
    }
    
    if (adjustTestOptions.minLifecycleIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                         key:@"minLifecycleIntervalMilli"
                                       value:adjustTestOptions.minLifecycleIntervalMilli.description];
        cachedTestOptions.minLifecycleIntervalMilli = adjustTestOptions.minLifecycleIntervalMilli;
    }

    if (adjustTestOptions.overwriteFirstSdkSessionIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                         key:@"overwriteFirstSdkSessionIntervalMilli"
                                       value:adjustTestOptions.overwriteFirstSdkSessionIntervalMilli.description];
        cachedTestOptions.overwriteFirstSdkSessionIntervalMilli =
            adjustTestOptions.overwriteFirstSdkSessionIntervalMilli;
    }

    // ...

    // non-nullable values
    cachedTestOptions.doNotReadCurrentLifecycleStatus =
        adjustTestOptions.doNotReadCurrentLifecycleStatus;
    [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                     key:@"doNotReadCurrentLifecycleStatus"
                                   value:
     @(adjustTestOptions.doNotReadCurrentLifecycleStatus).description];

    cachedTestOptions.doNotInitiateAttributionFromSdk =
        adjustTestOptions.doNotInitiateAttributionFromSdk;
    [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                     key:@"doNotInitiateAttributionFromSdk"
                                   value:
     @(adjustTestOptions.doNotInitiateAttributionFromSdk).description];

    cachedTestOptions.doNotReadAsaAttribution = adjustTestOptions.doNotReadAsaAttribution;
    [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                     key:@"doNotReadAsaAttribution"
                                   value:
     @(adjustTestOptions.doNotReadAsaAttribution).description];

    cachedTestOptions.doCreateEntryRootInstance =
        adjustTestOptions.doCreateEntryRootInstance;
    [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                     key:@"doCreateEntryRootInstance"
                                   value:
     @(adjustTestOptions.doCreateEntryRootInstance).description];

    cachedTestOptions.clearStorage = adjustTestOptions.clearStorage;
    [[ATOLogger sharedInstance] debugDev:@"mergeIntoCachedWithTestOptions"
                                     key:@"clearStorage"
                                   value:
     @(adjustTestOptions.clearStorage).description];
}

/*
     if (adjustTestOptions.minLifecycleIntervalMilli != null) {
         UtilTO.logger().debug(
                 "mergeAdjustTestOptionsIntoCachedTestOptions minLifecycleIntervalMilli %d",
                 adjustTestOptions.minLifecycleIntervalMilli);
         CACHED_ADJUST_TEST_OPTIONS.minLifecycleIntervalMilli
                 = adjustTestOptions.minLifecycleIntervalMilli;
     }
     if (adjustTestOptions.noBackoffForAll != null) {
         UtilTO.logger().debug(
                 "mergeAdjustTestOptionsIntoCachedTestOptions noBackoffForAll %b",
                 adjustTestOptions.noBackoffForAll);
         CACHED_ADJUST_TEST_OPTIONS.noBackoffForAll = adjustTestOptions.noBackoffForAll;
     }
     if (adjustTestOptions.v4NamespacePrefix != null) {
         UtilTO.logger().debug("mergeAdjustTestOptionsIntoCachedTestOptions v4NamespacePrefix %s",
                 adjustTestOptions.v4NamespacePrefix);
         CACHED_ADJUST_TEST_OPTIONS.v4NamespacePrefix = adjustTestOptions.v4NamespacePrefix;
     }

     // non-nullable values
     CACHED_ADJUST_TEST_OPTIONS.useTestConnection = adjustTestOptions.useTestConnection;
     UtilTO.logger().debug(
             "mergeAdjustTestOptionsIntoCachedTestOptions useTestConnection %b",
             adjustTestOptions.useTestConnection);
 }
 */

+ (void)
    mergeIntoSdkConfigWithAdjustTestOptions:(nonnull ATOAdjustTestOptions *)adjustTestOptions
    sdkConfigDataBuilder:(nonnull ADJSdkConfigDataBuilder *)sdkConfigDataBuilder
{
    [self mergeNetworkOptionsWithTestOptions:adjustTestOptions
                        sdkConfigDataBuilder:sdkConfigDataBuilder];

    // set direct variables
    if (adjustTestOptions.foregroundTimerIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoSdkConfigWithAdjustTestOptions"
                                         key:@"foregroundTimerIntervalMilli"
                                       value:adjustTestOptions.foregroundTimerIntervalMilli.description];

        ADJResultNN<ADJNonNegativeInt *> *_Nonnull foregroundTimerIntervalMilliNumberResult =
            [ADJNonNegativeInt instanceFromIntegerNumber:
             adjustTestOptions.foregroundTimerIntervalMilli];
        if (foregroundTimerIntervalMilliNumberResult.failMessage != nil) {
            [[ATOLogger sharedInstance] debugDev:@"Invalid foregroundTimerIntervalMilliNumber"
                                     failMessage:foregroundTimerIntervalMilliNumberResult.failMessage
                                       issueType:ADJIssueExternalApi];
        } else {
            sdkConfigDataBuilder.foregroundTimerIntervalMilli =
                [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                    foregroundTimerIntervalMilliNumberResult.value];
        }
    }

    if (adjustTestOptions.foregroundTimerStartMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoSdkConfigWithAdjustTestOptions"
                                         key:@"foregroundTimerStartMilli"
                                       value:adjustTestOptions.foregroundTimerStartMilli.description];

        ADJResultNN<ADJNonNegativeInt *> *_Nonnull foregroundTimerStartMilliNumberResult =
            [ADJNonNegativeInt instanceFromIntegerNumber:
             adjustTestOptions.foregroundTimerStartMilli];
        if (foregroundTimerStartMilliNumberResult.failMessage != nil) {
            [[ATOLogger sharedInstance] debugDev:@"Invalid foregroundTimerStartMilliNumber"
                                     failMessage:foregroundTimerStartMilliNumberResult.failMessage
                                       issueType:ADJIssueExternalApi];
        } else {
            sdkConfigDataBuilder.foregroundTimerStartMilli =
                [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                 foregroundTimerStartMilliNumberResult.value];
        }
    }

    if (adjustTestOptions.minSdkSessionIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoSdkConfigWithAdjustTestOptions"
                                         key:@"minSdkSessionIntervalMilli"
                                       value:adjustTestOptions.minSdkSessionIntervalMilli.description];

        ADJResultNN<ADJNonNegativeInt *> *_Nonnull minSdkSessionIntervalMilliNumberResult =
            [ADJNonNegativeInt instanceFromIntegerNumber:
             adjustTestOptions.minSdkSessionIntervalMilli];
        if (minSdkSessionIntervalMilliNumberResult.failMessage != nil) {
            [[ATOLogger sharedInstance] debugDev:@"Invalid minSdkSessionIntervalMilliNumber"
                                     failMessage:minSdkSessionIntervalMilliNumberResult.failMessage
                                       issueType:ADJIssueExternalApi];
        } else {
            sdkConfigDataBuilder.minMeasurementSessionIntervalMilli =
                [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                 minSdkSessionIntervalMilliNumberResult.value];
        }
    }
    
    // TODO: is this needed for iOS having in mind that we don't have activity switching issue on that platform?
    /*
    if (adjustTestOptions.minLifecycleIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debug:
            @"mergeIntoSdkConfigWithAdjustTestOptions minLifecycleIntervalMilli: %@",
            adjustTestOptions.minLifecycleIntervalMilli];

        ADJNonNegativeInt *_Nullable minLifecycleIntervalMilliNumber =
            [ADJNonNegativeInt instanceFromIntegerNumber:adjustTestOptions.minLifecycleIntervalMilli
                                               logger:[ATOLogger sharedInstance]];

        if (minLifecycleIntervalMilliNumber != nil) {
            sdkConfigDataBuilder.lifecycleBackgroundDelayChangeTimeout =
                [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:minLifecycleIntervalMilliNumber];
        }
    }
    */

    if (adjustTestOptions.overwriteFirstSdkSessionIntervalMilli != nil) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoSdkConfigWithAdjustTestOptions"
                                         key:@"overwriteFirstSdkSessionIntervalMilli"
                                       value:adjustTestOptions.overwriteFirstSdkSessionIntervalMilli.description];

        ADJResultNN<ADJNonNegativeInt *> *_Nonnull
        overwriteFirstSdkSessionIntervalMilliNumberResult =
            [ADJNonNegativeInt
                instanceFromIntegerNumber:
                 adjustTestOptions.overwriteFirstSdkSessionIntervalMilli];
        if (overwriteFirstSdkSessionIntervalMilliNumberResult.failMessage != nil) {
            [[ATOLogger sharedInstance] debugDev:
             @"Invalid overwriteFirstSdkSessionIntervalMilliNumber"
                                     failMessage:
             overwriteFirstSdkSessionIntervalMilliNumberResult.failMessage
                                       issueType:ADJIssueExternalApi];
        } else {
            sdkConfigDataBuilder.overwriteFirstSdkSessionInterval =
                [[ADJTimeLengthMilli alloc] initWithMillisecondsSpan:
                 overwriteFirstSdkSessionIntervalMilliNumberResult.value];
        }
    }

    // Interpret remaining variables
    if (adjustTestOptions.doNotReadCurrentLifecycleStatus) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoSdkConfigWithAdjustTestOptions"
                                         key:@"doNotReadCurrentLifecycleStatus"
                                       value:
         @(adjustTestOptions.doNotReadCurrentLifecycleStatus).description];

        sdkConfigDataBuilder.doNotReadCurrentLifecycleStatus = YES;
    }

    if (adjustTestOptions.doNotInitiateAttributionFromSdk) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoSdkConfigWithAdjustTestOptions"
                                         key:@"doNotInitiateAttributionFromSdk"
                                       value:
         @(adjustTestOptions.doNotInitiateAttributionFromSdk).description];

        sdkConfigDataBuilder.doNotInitiateAttributionFromSdk = YES;
    }

    if (adjustTestOptions.doNotReadAsaAttribution) {
        [[ATOLogger sharedInstance] debugDev:@"mergeIntoSdkConfigWithAdjustTestOptions"
                                         key:@"doNotReadAsaAttribution"
                                       value:
         @(adjustTestOptions.doNotReadAsaAttribution).description];

        sdkConfigDataBuilder.asaAttributionConfigData =
            [[ADJExternalConfigData alloc] initWithTimeoutPerAttempt:nil
                                               libraryMaxReadAttempts:nil
                                                 delayBetweenAttempts:nil
                                                  cacheValidityPeriod:nil];
    }
}
/*
     // set direct variables
     if (adjustTestOptions.minLifecycleIntervalMilli != null) {
         UtilTO.logger().debug(
                 "mergeAdjustOptionsIntoSdkConfig minLifecycleIntervalMilli: %d",
                 adjustTestOptions.minLifecycleIntervalMilli);

         @Nullable final TimeLengthMilli lifecyleBackgroundDelayChangeTimeout =
                 TimeLengthMilli.instanceFromLong(
                         adjustTestOptions.minLifecycleIntervalMilli.longValue(),
                         UtilTO.logger());

         if (lifecyleBackgroundDelayChangeTimeout != null) {
             sdkConfigDataBuilder.lifecycleBackgroundDelayChangeTimeout =
                     lifecyleBackgroundDelayChangeTimeout;
         }
     }
     if (adjustTestOptions.v4NamespacePrefix != null) {
         UtilTO.logger().debug(
                 "mergeAdjustOptionsIntoSdkConfig v4NamespacePrefix: %s",
                 adjustTestOptions.v4NamespacePrefix);

         @Nullable final NonEmptyString v4NamespacePrefix =
                 NonEmptyString.instanceFromString(adjustTestOptions.v4NamespacePrefix,
                         "v4 namespace prefix",
                         UtilTO.logger());

         if (v4NamespacePrefix != null) {
             sdkConfigDataBuilder.v4NamespacePrefix = v4NamespacePrefix;
         }
     }

      TODO
     if (adjustTestOptions.noBackoffForAll != null && adjustTestOptions.noBackoffForAll) {
         UtilTO.logVerbose("mergeAdjustOptionsIntoSdkConfig noBackoffForAll: %b",
                 adjustTestOptions.noBackoffForAll);
         sdkConfig.attributionBackoffStrategy = BackoffStrategy.createNoWaitBackoffStrategy();
         sdkConfig.mainQueueBackoffStrategy = BackoffStrategy.createNoWaitBackoffStrategy();
         sdkConfig.gdprForgetBackoffStrategy = BackoffStrategy.createNoWaitBackoffStrategy();
     }

 }

 */

+ (void)
    mergeNetworkOptionsWithTestOptions:(nonnull ATOAdjustTestOptions *)adjustTestOptions
    sdkConfigDataBuilder:(nonnull ADJSdkConfigDataBuilder *)sdkConfigDataBuilder
{
    NSString *_Nullable extraPath = sdkConfigDataBuilder.networkEndpointData.extraPath;
    if (adjustTestOptions.extraPath != nil) {
        extraPath = adjustTestOptions.extraPath;
        [[ATOLogger sharedInstance] debugDev:@"mergeNetworkOptionsWithTestOptions"
                                         key:@"extraPath"
                                       value:extraPath];
    }

    NSString *_Nullable urlOverwrite = sdkConfigDataBuilder.networkEndpointData.urlOverwrite;
    if (adjustTestOptions.urlOverwrite != nil) {
        urlOverwrite = adjustTestOptions.urlOverwrite;
        [[ATOLogger sharedInstance] debugDev:@"mergeNetworkOptionsWithTestOptions"
                                         key:@"urlOverwrite"
                                       value:urlOverwrite];
    }

    ADJNetworkEndpointData *_Nonnull networkEndpointData =
        [[ADJNetworkEndpointData alloc]
            initWithExtraPath:extraPath
            urlOverwrite:urlOverwrite
            timeoutMilli:sdkConfigDataBuilder.networkEndpointData.timeoutMilli];

    sdkConfigDataBuilder.networkEndpointData = networkEndpointData;
}

+ (void)clearAndResetCachedOptions {
    ATOAdjustTestOptions *_Nonnull cachedTestOptions = [self cachedTestOptions];
    NSMutableOrderedSet<NSArray<NSString *> *> *_Nonnull cachedTestOptionsSet =
        [self cachedTestOptionsSet];

    [cachedTestOptions clear];
    [cachedTestOptionsSet removeAllObjects];

    // set default values
    // reset URLs to use local emulator URL
    cachedTestOptions.urlOverwrite = [self generateBaseUrlWithIp:baseLocalEmulatorIp];

    // always use test connection
    //CACHED_ADJUST_TEST_OPTIONS.useTestConnection = true;
    cachedTestOptions.doNotReadCurrentLifecycleStatus = YES;
    // do not initiate attribution request from SDK by default
    cachedTestOptions.doNotInitiateAttributionFromSdk = YES;
    // do not read ASA attribution by default
    cachedTestOptions.doNotReadAsaAttribution = YES;
    // create entry root instance by default
    cachedTestOptions.doCreateEntryRootInstance = YES;
    // do not clear storage by default
    cachedTestOptions.clearStorage = NO;
}

+ (nonnull NSString *)generateBaseUrlWithIp:(nonnull NSString *)ip {
    return [NSString stringWithFormat:@"http://%@:8080", ip];
}

+ (nullable NSNumber *)strictParseNumberBooleanWithString:(nullable NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }
    if ([stringValue isEqualToString:@"true"]) {
        return [NSNumber numberWithBool:YES];
    }
    if ([stringValue isEqualToString:@"false"]) {
        return [NSNumber numberWithBool:NO];
    }
    return nil;
}

/*
+ (void)logDebug:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATOAdjustTestOptions][Debug] %@", logMessage);
}
+ (void)logError:(nonnull NSString *)message, ... {
    va_list parameters; va_start(parameters, message);
    NSString *logMessage = [[NSString alloc] initWithFormat:message arguments:parameters];
    va_end(parameters);

    NSLog(@"\t[ATOAdjustTestOptions][Error] %@", logMessage);
}
*/
- (void)clear {
    self.urlOverwrite = nil;
    self.extraPath = nil;
    self.foregroundTimerIntervalMilli = nil;
    self.foregroundTimerStartMilli = nil;
    self.minLifecycleIntervalMilli = nil;
    self.minSdkSessionIntervalMilli = nil;
    self.overwriteFirstSdkSessionIntervalMilli = nil;
    self.doNotReadCurrentLifecycleStatus = NO;
    self.doNotInitiateAttributionFromSdk = NO;
    self.doCreateEntryRootInstance = NO;
    self.clearStorage = NO;
}

+ (nullable NSNumber *)convertToNSNumberIntWithStringValue:(nullable NSString *)stringValue {
    if (stringValue == nil) {
        return nil;
    }
/*
    static dispatch_once_t integerFormatterInstanceToken;
    static NSNumberFormatter * integerFormatter;
    dispatch_once(&integerFormatterInstanceToken, ^{
        integerFormatter = [[NSNumberFormatter alloc] init];
        [integerFormatter setNumberStyle:NSNumberFormatterNoStyle];
    });

    return [integerFormatter numberFromString:stringValue];
 */
    NSScanner *_Nonnull scanner = [NSScanner scannerWithString:stringValue];
    NSInteger scannedInteger;
    if (! [scanner scanInteger:&scannedInteger]) {
        return nil;
    }

    if (scannedInteger == INT_MAX || scannedInteger == INT_MIN) {
        return nil;
    }

    return @(scannedInteger);
}

@end

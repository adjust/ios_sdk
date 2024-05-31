//
//  ADJUtil.m
//  Adjust SDK
//
//  Created by Christian Wellenbrock (@wellle) on 5th July 2013.
//  Copyright (c) 2013-2021 Adjust GmbH. All rights reserved.
//

#include <math.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <sys/xattr.h>

#import <objc/message.h>
#import <sys/utsname.h>
#import <sys/types.h>
#import <sys/sysctl.h>

#import <UIKit/UIKit.h>

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJResponseData.h"
#import "ADJAdjustFactory.h"
#import "NSString+ADJAdditions.h"

#if !ADJUST_NO_IDFA
#import <AdSupport/ASIdentifierManager.h>
#endif

static NSString *userAgent = nil;
static NSRegularExpression *universalLinkRegex = nil;
static NSNumberFormatter *secondsNumberFormatter = nil;
static NSRegularExpression *optionalRedirectRegex = nil;
static NSRegularExpression *shortUniversalLinkRegex = nil;
static NSRegularExpression *excludedDeeplinkRegex = nil;

static NSString * const kClientSdk                  = @"ios4.38.4";
static NSString * const kDeeplinkParam              = @"deep_link=";
static NSString * const kSchemeDelimiter            = @"://";
static NSString * const kDefaultScheme              = @"AdjustUniversalScheme";
static NSString * const kUniversalLinkPattern       = @"https://[^.]*\\.ulink\\.adjust\\.com/ulink/?(.*)";
static NSString * const kOptionalRedirectPattern    = @"adjust_redirect=[^&#]*";
static NSString * const kShortUniversalLinkPattern  = @"http[s]?://[a-z0-9]{4}\\.(?:[a-z]{2}\\.)?adj\\.st/?(.*)";
static NSString * const kExcludedDeeplinksPattern   = @"^(fb|vk)[0-9]{5,}[^:]*://authorize.*access_token=.*";
static NSString * const kDateFormat                 = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z";

@implementation ADJUtil

+ (void)initialize {
    if (self != [ADJUtil class]) {
        return;
    }

    [self initializeUniversalLinkRegex];
    [self initializeSecondsNumberFormatter];
    [self initializeShortUniversalLinkRegex];
    [self initializeOptionalRedirectRegex];
    [self initializeExcludedDeeplinkRegex];
}

+ (void)teardown {
    universalLinkRegex = nil;
    secondsNumberFormatter = nil;
    optionalRedirectRegex = nil;
    shortUniversalLinkRegex = nil;
}

+ (void)initializeUniversalLinkRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kUniversalLinkPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADJUtil isNotNull:error]) {
        [ADJAdjustFactory.logger error:@"Universal link regex rule error (%@)", [error description]];
        return;
    }
    universalLinkRegex = regex;
}

+ (void)initializeShortUniversalLinkRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kShortUniversalLinkPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADJUtil isNotNull:error]) {
        [ADJAdjustFactory.logger error:@"Short Universal link regex rule error (%@)", [error description]];
        return;
    }
    shortUniversalLinkRegex = regex;
}

+ (void)initializeOptionalRedirectRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kOptionalRedirectPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADJUtil isNotNull:error]) {
        [ADJAdjustFactory.logger error:@"Optional redirect regex rule error (%@)", [error description]];
        return;
    }
    optionalRedirectRegex = regex;
}

+ (void)initializeExcludedDeeplinkRegex {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kExcludedDeeplinksPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if ([ADJUtil isNotNull:error]) {
        [ADJAdjustFactory.logger error:@"Excluded deep link regex rule error (%@)", [error description]];
        return;
    }
    excludedDeeplinkRegex = regex;
}

+ (void)initializeSecondsNumberFormatter {
    secondsNumberFormatter = [[NSNumberFormatter alloc] init];
    [secondsNumberFormatter setPositiveFormat:@"0.0"];
}

+ (void)updateUrlSessionConfiguration:(ADJConfig *)config {
    userAgent = config.userAgent;
}

+ (NSString *)clientSdk {
    return kClientSdk;
}

+ (NSDateFormatter *)getDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    [dateFormatter setDateFormat:kDateFormat];

    Class class = NSClassFromString([NSString adjJoin:@"N", @"S", @"locale", nil]);
    if (class != nil) {
        NSString *keyLwli = [NSString adjJoin:@"locale", @"with", @"locale", @"identifier:", nil];
        SEL selLwli = NSSelectorFromString(keyLwli);
        if ([class respondsToSelector:selLwli]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            id loc = [class performSelector:selLwli withObject:@"en_US"];
            [dateFormatter setLocale:loc];
#pragma clang diagnostic pop
        }
    }

    return dateFormatter;
}

// Inspired by https://gist.github.com/kevinbarrett/2002382
+ (void)excludeFromBackup:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    id<ADJLogger> logger = ADJAdjustFactory.logger;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    if (&NSURLIsExcludedFromBackupKey == nil) {
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        if (result != 0) {
            [logger debug:@"Failed to exclude '%@' from backup", url.lastPathComponent];
        }
    } else { // iOS 5.0 and higher
        // First try and remove the extended attribute if it is present
        ssize_t result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                [logger debug:@"Removed extended attribute on file '%@'", url];
            }
        }

        // Set the new key
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES]
                                      forKey:NSURLIsExcludedFromBackupKey
                                       error:&error];
        if (!success || error != nil) {
            [logger debug:@"Failed to exclude '%@' from backup (%@)", url.lastPathComponent, error.localizedDescription];
        }
    }
#pragma clang diagnostic pop
}

+ (NSString *)formatSeconds1970:(double)value {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];
    return [self formatDate:date];
}

+ (NSString *)formatDate:(NSDate *)value {
    NSDateFormatter *dateFormatter = [ADJUtil getDateFormatter];
    if (dateFormatter == nil) {
        return nil;
    }
    return [dateFormatter stringFromDate:value];
}

+ (id)readObject:(NSString *)fileName
      objectName:(NSString *)objectName
           class:(Class)classToRead
      syncObject:(id)syncObject {
#if TARGET_OS_TV
    return nil;
#endif
    @synchronized(syncObject) {
        NSString *documentsFilePath = [ADJUtil getFilePathInDocumentsDir:fileName];
        NSString *appSupportFilePath = [ADJUtil getFilePathInAppSupportDir:fileName];

        // Try to read from Application Support directory first.
        @try {
            id appSupportObject;
            if (@available(iOS 11.0, tvOS 11.0, *)) {
                NSData *data = [NSData dataWithContentsOfFile:appSupportFilePath];
                // API introduced in iOS 11.
                NSError *errorUnarchiver = nil;
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data
                                                                                            error:&errorUnarchiver];
                if (errorUnarchiver == nil) {
                    [unarchiver setRequiresSecureCoding:NO];
                    appSupportObject = [unarchiver decodeObjectOfClass:classToRead forKey:NSKeyedArchiveRootObjectKey];
                } else {
                    // TODO: try to make this error fit the logging flow; if not, remove it
                    // [[ADJAdjustFactory logger] debug:@"Failed to read %@ with error: %@", objectName, errorUnarchiver.localizedDescription];
                }
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // API_DEPRECATED [2.0-12.0]
                // "Use +unarchivedObjectOfClass:fromData:error: instead"
                appSupportObject = [NSKeyedUnarchiver unarchiveObjectWithFile:appSupportFilePath];
#pragma clang diagnostic pop
            }

            if (appSupportObject != nil) {
                if ([appSupportObject isKindOfClass:classToRead]) {
                    // Successfully read object from Application Support folder, return it.
                    if ([appSupportObject isKindOfClass:[NSArray class]]) {
                        [[ADJAdjustFactory logger] debug:@"Package handler read %d packages", [appSupportObject count]];
                    } else {
                        [[ADJAdjustFactory logger] debug:@"Read %@: %@", objectName, appSupportObject];
                    }

                    // Just in case check if old file exists in Documents folder and if yes, remove it.
                    [ADJUtil deleteFileInPath:documentsFilePath];

                    return appSupportObject;
                }
            } else {
                // [[ADJAdjustFactory logger] error:@"Failed to read %@ file", appSupportFilePath];
                [[ADJAdjustFactory logger] debug:@"File %@ not found in \"Application Support/Adjust\" folder", fileName];
            }
        } @catch (NSException *ex) {
            // [[ADJAdjustFactory logger] error:@"Failed to read %@ file  (%@)", appSupportFilePath, ex];
            [[ADJAdjustFactory logger] error:@"Failed to read %@ file from \"Application Support/Adjust\" folder (%@)", fileName, ex];
        }

        // If in here, for some reason, reading of file from Application Support folder failed.
        // Let's check the Documents folder.
        @try {
            id documentsObject;
            if (@available(iOS 11.0, tvOS 11.0, *)) {
                NSData *data = [NSData dataWithContentsOfFile:documentsFilePath];
                // API introduced in iOS 11.
                NSError *errorUnarchiver = nil;
                NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data
                                                                                            error:&errorUnarchiver];
                if (errorUnarchiver == nil) {
                    [unarchiver setRequiresSecureCoding:NO];
                    documentsObject = [unarchiver decodeObjectOfClass:classToRead forKey:NSKeyedArchiveRootObjectKey];
                } else {
                    // TODO: try to make this error fit the logging flow; if not, remove it
                    // [[ADJAdjustFactory logger] debug:@"Failed to read %@ with error: %@", objectName, errorUnarchiver.localizedDescription];
                }
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                // API_DEPRECATED [2.0-12.0]
                // "Use +unarchivedObjectOfClass:fromData:error: instead"
                documentsObject = [NSKeyedUnarchiver unarchiveObjectWithFile:documentsFilePath];
#pragma clang diagnostic pop
            }

            if (documentsObject != nil) {
                // Successfully read object from Documents folder.
                if ([documentsObject isKindOfClass:[NSArray class]]) {
                    [[ADJAdjustFactory logger] debug:@"Package handler read %d packages", [documentsObject count]];
                } else {
                    [[ADJAdjustFactory logger] debug:@"Read %@: %@", objectName, documentsObject];
                }

                // Do the file migration.
                [[ADJAdjustFactory logger] verbose:@"Migrating %@ file from Documents to \"Application Support/Adjust\" folder", fileName];
                [ADJUtil migrateFileFromPath:documentsFilePath toPath:appSupportFilePath];

                return documentsObject;
            } else {
                // [[ADJAdjustFactory logger] error:@"Failed to read %@ file", documentsFilePath];
                [[ADJAdjustFactory logger] debug:@"File %@ not found in Documents folder", fileName];
            }
        } @catch (NSException *ex) {
            // [[ADJAdjustFactory logger] error:@"Failed to read %@ file (%@)", documentsFilePath, ex];
            [[ADJAdjustFactory logger] error:@"Failed to read %@ file from Documents folder (%@)", fileName, ex];
        }

        return nil;
    }
}

+ (void)writeObject:(id)object
           fileName:(NSString *)fileName
         objectName:(NSString *)objectName
         syncObject:(id)syncObject {
#if TARGET_OS_TV
    return;
#endif
    @synchronized(syncObject) {
        @try {
            BOOL result;
            NSString *filePath = [ADJUtil getFilePathInAppSupportDir:fileName];
            if (!filePath) {
                [[ADJAdjustFactory logger] error:@"Cannot get filepath from filename: %@, to write %@ file", fileName, objectName];
                return;
            }

            if (@available(iOS 11.0, tvOS 11.0, *)) {
                @autoreleasepool {
                    NSError *errorArchiving = nil;
                    // API introduced in iOS 11.
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object requiringSecureCoding:NO error:&errorArchiving];
                    if (data && errorArchiving == nil) {
                        NSError *errorWriting = nil;
                        result = [data writeToFile:filePath options:NSDataWritingAtomic error:&errorWriting];
                        result = result && (errorWriting == nil);
                    } else {
                        result = NO;
                    }
                }
            } else {
                // API_DEPRECATED [2.0-12.0]
                // Use +archivedDataWithRootObject:requiringSecureCoding:error: and -writeToURL:options:error: instead
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                result = [NSKeyedArchiver archiveRootObject:object toFile:filePath];
#pragma clang diagnostic pop
            }
            if (result == YES) {
                [ADJUtil excludeFromBackup:filePath];
                if ([object isKindOfClass:[NSArray class]]) {
                    [[ADJAdjustFactory logger] debug:@"Package handler wrote %d packages", [object count]];
                } else {
                    [[ADJAdjustFactory logger] debug:@"Wrote %@: %@", objectName, object];
                }
            } else {
                [[ADJAdjustFactory logger] error:@"Failed to write %@ file", objectName];
            }
        } @catch (NSException *exception) {
            [[ADJAdjustFactory logger] error:@"Failed to write %@ file (%@)", objectName, exception];
        }
    }
}

+ (BOOL)migrateFileFromPath:(NSString *)oldPath toPath:(NSString *)newPath {
    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    Class class = NSClassFromString([NSString adjJoin:@"N", @"S", @"file", @"manager", nil]);
    if (class == nil) {
        return NO;
    }
    NSString *keyDm = [NSString adjJoin:@"default", @"manager", nil];
    SEL selDm = NSSelectorFromString(keyDm);
    if (![class respondsToSelector:selDm]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id man = [class performSelector:selDm];
#pragma clang diagnostic pop
    NSString *keyCpy = [NSString stringWithFormat:@"%@%@%@",
                        [NSString adjJoin:@"copy", @"item", @"at", @"path", @":", nil],
                        [NSString adjJoin:@"to", @"path", @":", nil],
                        [NSString adjJoin:@"error", @":", nil]];
    SEL selCpy = NSSelectorFromString(keyCpy);
    if (![man respondsToSelector:selCpy]) {
        return NO;
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selCpy]];
    [inv setSelector:selCpy];
    [inv setTarget:man];
    [inv setArgument:&oldPath atIndex:2];
    [inv setArgument:&newPath atIndex:3];
    [inv setArgument:&errorPointer atIndex:4];
    [inv invoke];

    if (error != nil) {
        [[ADJAdjustFactory logger] error:@"Error while copying from %@ to %@", oldPath, newPath];
        [[ADJAdjustFactory logger] error:[error description]];
        return NO;
    }
    // Migration successful.
    return YES;
}

+ (NSString *)getFilePathInDocumentsDir:(NSString *)fileName {
    // Documents directory exists by default inside app bundle, no need to check for it's presence.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSString *)getFilePathInAppSupportDir:(NSString *)fileName {
    // Application Support directory doesn't exist by default inside app bundle.
    // All Adjust files are going to be stored in Adjust sub-directory inside Application Support directory.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appSupportDir = [paths firstObject];
    NSString *adjustDirName = @"Adjust";
    if (![ADJUtil checkForDirectoryPresenceInPath:appSupportDir forFolder:[appSupportDir lastPathComponent]]) {
        return nil;
    }
    NSString *adjustDir = [appSupportDir stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", adjustDirName]];
    if (![ADJUtil checkForDirectoryPresenceInPath:adjustDir forFolder:adjustDirName]) {
        return nil;
    }
    NSString *filePath = [adjustDir stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (BOOL)checkForDirectoryPresenceInPath:(NSString *)path forFolder:(NSString *)folderName {
    // Check for presence of directory first.
    // If it doesn't exist, make one.
    Class class = NSClassFromString([NSString adjJoin:@"N", @"S", @"file", @"manager", nil]);
    if (class == nil) {
        return NO;
    }
    NSString *keyDm = [NSString adjJoin:@"default", @"manager", nil];
    SEL selDm = NSSelectorFromString(keyDm);
    if (![class respondsToSelector:selDm]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id man = [class performSelector:selDm];
#pragma clang diagnostic pop
    NSString *keyExi = [NSString adjJoin:@"file", @"exists", @"at", @"path", @":", nil];
    SEL selExi = NSSelectorFromString(keyExi);
    if (![man respondsToSelector:selExi]) {
        return NO;
    }
    
    NSInvocation *invMan = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selExi]];
    [invMan setSelector:selExi];
    [invMan setTarget:man];
    [invMan setArgument:&path atIndex:2];
    [invMan invoke];
    
    BOOL exists;
    [invMan getReturnValue:&exists];
    
    if (!exists) {
        [[ADJAdjustFactory logger] debug:@"%@ directory not present and will be created", folderName];
        BOOL withIntermediateDirectories = NO;
        NSDictionary *attributes = nil;
        __autoreleasing NSError *error;
        __autoreleasing NSError **errorPointer = &error;
        NSString *keyCrt = [NSString stringWithFormat:@"%@%@%@%@",
                            [NSString adjJoin:@"create", @"directory", @"at", @"path", @":", nil],
                            [NSString adjJoin:@"with", @"intermediate", @"directories", @":", nil],
                            [NSString adjJoin:@"attributes", @":", nil],
                            [NSString adjJoin:@"error", @":", nil]];
        SEL selCrt = NSSelectorFromString(keyCrt);
        if (![man respondsToSelector:selCrt]) {
            return NO;
        }

        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selCrt]];
        [inv setSelector:selCrt];
        [inv setTarget:man];
        [inv setArgument:&path atIndex:2];
        [inv setArgument:&withIntermediateDirectories atIndex:3];
        [inv setArgument:&attributes atIndex:4];
        [inv setArgument:&errorPointer atIndex:5];
        [inv invoke];

        if (error != nil) {
            [[ADJAdjustFactory logger] error:@"Error while creating %@ directory", path];
            [[ADJAdjustFactory logger] error:[error description]];
            return NO;
        }
    }
    return YES;
}

+ (NSString *)queryString:(NSDictionary *)parameters {
    return [ADJUtil queryString:parameters queueSize:0];
}

+ (NSString *)queryString:(NSDictionary *)parameters
                queueSize:(NSUInteger)queueSize {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in parameters) {
        NSString *value = [parameters objectForKey:key];
        NSString *escapedValue = [value adjUrlEncode];
        NSString *escapedKey = [key adjUrlEncode];
        NSString *pair = [NSString stringWithFormat:@"%@=%@", escapedKey, escapedValue];
        [pairs addObject:pair];
    }

    double now = [NSDate.date timeIntervalSince1970];
    NSString *dateString = [ADJUtil formatSeconds1970:now];
    NSString *escapedDate = [dateString adjUrlEncode];
    NSString *sentAtPair = [NSString stringWithFormat:@"%@=%@", @"sent_at", escapedDate];
    [pairs addObject:sentAtPair];

    if (queueSize > 0) {
        unsigned long queueSizeNative = (unsigned long)queueSize;
        NSString *queueSizeString = [NSString stringWithFormat:@"%lu", queueSizeNative];
        NSString *escapedQueueSize = [queueSizeString adjUrlEncode];
        NSString *queueSizePair = [NSString stringWithFormat:@"%@=%@", @"queue_size", escapedQueueSize];
        [pairs addObject:queueSizePair];
    }

    NSString *queryString = [pairs componentsJoinedByString:@"&"];
    return queryString;
}

+ (BOOL)isNull:(id)value {
    return value == nil || value == (id)[NSNull null];
}

+ (BOOL)isNotNull:(id)value {
    return value != nil && value != (id)[NSNull null];
}

// Convert all values to strings, if value is dictionary -> recursive call
+ (NSDictionary *)convertDictionaryValues:(NSDictionary *)dictionary {
    NSMutableDictionary *convertedDictionary = [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];
    for (NSString *key in dictionary) {
        id value = [dictionary objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            // Dictionary value, recursive call
            NSDictionary *dictionaryValue = [ADJUtil convertDictionaryValues:(NSDictionary *)value];
            [convertedDictionary setObject:dictionaryValue forKey:key];
        } else if ([value isKindOfClass:[NSDate class]]) {
            // Format date to our custom format
            NSString *dateStingValue = [ADJUtil formatDate:value];
            if (dateStingValue != nil) {
                [convertedDictionary setObject:dateStingValue forKey:key];
            }
        } else {
            // Convert all other objects directly to string
            NSString *stringValue = [NSString stringWithFormat:@"%@", value];
            [convertedDictionary setObject:stringValue forKey:key];
        }
    }
    return convertedDictionary;
}

+ (NSURL *)convertUniversalLink:(NSURL *)url scheme:(NSString *)scheme {
    id<ADJLogger> logger = ADJAdjustFactory.logger;

    if ([ADJUtil isNull:url]) {
        [logger error:@"Received universal link is nil"];
        return nil;
    }
    if ([ADJUtil isNull:scheme] || [scheme length] == 0) {
        [logger warn:@"Non-empty scheme required, using the scheme \"AdjustUniversalScheme\""];
        scheme = kDefaultScheme;
    }
    NSString *urlString = [url absoluteString];
    if ([ADJUtil isNull:urlString]) {
        [logger error:@"Parsed universal link is nil"];
        return nil;
    }
    if (universalLinkRegex == nil) {
        [logger error:@"Universal link regex not correctly configured"];
        return nil;
    }
    if (shortUniversalLinkRegex == nil) {
        [logger error:@"Short Universal link regex not correctly configured"];
        return nil;
    }

    NSArray<NSTextCheckingResult *> *matches = [universalLinkRegex matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
    if ([matches count] == 0) {
        matches = [shortUniversalLinkRegex matchesInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
        if ([matches count] == 0) {
            [logger error:@"Url doesn't match as universal link or short version"];
            return nil;
        }
    }
    if ([matches count] > 1) {
        [logger error:@"Url match as universal link multiple times"];
        return nil;
    }

    NSTextCheckingResult *match = matches[0];
    if ([match numberOfRanges] != 2) {
        [logger error:@"Wrong number of ranges matched"];
        return nil;
    }

    NSString *tailSubString = [urlString substringWithRange:[match rangeAtIndex:1]];
    NSString *finalTailSubString = [ADJUtil removeOptionalRedirect:tailSubString];
    NSString *extractedUrlString = [NSString stringWithFormat:@"%@://%@", scheme, finalTailSubString];
    [logger info:@"Converted deeplink from universal link %@", extractedUrlString];
    NSURL *extractedUrl = [NSURL URLWithString:extractedUrlString];
    if ([ADJUtil isNull:extractedUrl]) {
        [logger error:@"Unable to parse converted deeplink from universal link %@", extractedUrlString];
        return nil;
    }
    return extractedUrl;
}

+ (NSString *)removeOptionalRedirect:(NSString *)tailSubString {
    id<ADJLogger> logger = ADJAdjustFactory.logger;

    if (optionalRedirectRegex == nil) {
        [ADJAdjustFactory.logger error:@"Remove Optional Redirect regex not correctly configured"];
        return tailSubString;
    }
    NSArray<NSTextCheckingResult *> *optionalRedirectmatches = [optionalRedirectRegex matchesInString:tailSubString
                                                                                              options:0
                                                                                                range:NSMakeRange(0, [tailSubString length])];
    if ([optionalRedirectmatches count] == 0) {
        [logger debug:@"Universal link does not contain option adjust_redirect parameter"];
        return tailSubString;
    }
    if ([optionalRedirectmatches count] > 1) {
        [logger error:@"Universal link contains multiple option adjust_redirect parameters"];
        return tailSubString;
    }

    NSTextCheckingResult *redirectMatch = optionalRedirectmatches[0];
    NSRange redirectRange = [redirectMatch rangeAtIndex:0];
    NSString *beforeRedirect = [tailSubString substringToIndex:redirectRange.location];
    NSString *afterRedirect = [tailSubString substringFromIndex:(redirectRange.location + redirectRange.length)];
    if (beforeRedirect.length > 0 && afterRedirect.length > 0) {
        NSString *lastCharacterBeforeRedirect = [beforeRedirect substringFromIndex:beforeRedirect.length - 1];
        NSString *firstCharacterAfterRedirect = [afterRedirect substringToIndex:1];
        if ([@"&" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"&" isEqualToString:firstCharacterAfterRedirect]) {
            beforeRedirect = [beforeRedirect substringToIndex:beforeRedirect.length - 1];
        }
        if ([@"&" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"#" isEqualToString:firstCharacterAfterRedirect]) {
            beforeRedirect = [beforeRedirect substringToIndex:beforeRedirect.length - 1];
        }
        if ([@"?" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"#" isEqualToString:firstCharacterAfterRedirect]) {
            beforeRedirect = [beforeRedirect substringToIndex:beforeRedirect.length - 1];
        }
        if ([@"?" isEqualToString:lastCharacterBeforeRedirect] &&
            [@"&" isEqualToString:firstCharacterAfterRedirect]) {
            afterRedirect = [afterRedirect substringFromIndex:1];
        }
    }
    
    NSString *removedRedirect = [NSString stringWithFormat:@"%@%@", beforeRedirect, afterRedirect];
    return removedRedirect;
}

+ (NSString *)secondsNumberFormat:(double)seconds {
    // Normalize negative zero
    if (seconds < 0) {
        seconds = seconds * -1;
    }
    if (secondsNumberFormatter == nil) {
        return nil;
    }
    return [secondsNumberFormatter stringFromNumber:[NSNumber numberWithDouble:seconds]];
}

+ (double)randomInRange:(double)minRange maxRange:(double)maxRange {
    double range = maxRange - minRange;
    return minRange + (range * arc4random_uniform(100)*1.0/100);
}

+ (NSTimeInterval)waitingTime:(NSInteger)retries
              backoffStrategy:(ADJBackoffStrategy *)backoffStrategy {
    if (retries < backoffStrategy.minRetries) {
        return 0;
    }

    // Start with base 0
    NSInteger base = retries - backoffStrategy.minRetries;
    // Get the exponential Time from the base: 1, 2, 4, 8, 16, ... * times the multiplier
    NSTimeInterval exponentialTime = pow(2.0, base) * backoffStrategy.secondMultiplier;
    // Limit the maximum allowed time to wait
    NSTimeInterval ceilingTime = MIN(exponentialTime, backoffStrategy.maxWait);
    // Add 1 to allow maximum value
    double randomRange = [ADJUtil randomInRange:backoffStrategy.minRange maxRange:backoffStrategy.maxRange];
    // Apply jitter factor
    NSTimeInterval waitingTime =  ceilingTime * randomRange;
    return waitingTime;
}

+ (void)launchInMainThread:(NSObject *)receiver
                  selector:(SEL)selector
                withObject:(id)object {
    if (ADJAdjustFactory.testing) {
        [ADJAdjustFactory.logger debug:@"Launching in the background for testing"];
        [receiver performSelectorInBackground:selector withObject:object];
    } else {
        [receiver performSelectorOnMainThread:selector
                                   withObject:object
                                waitUntilDone:NO];  // non-blocking
    }
}

+ (void)launchInMainThread:(dispatch_block_t)block {
    if (ADJAdjustFactory.testing) {
        [ADJAdjustFactory.logger debug:@"Launching in the background for testing"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (BOOL)isMainThread {
    return [[NSThread currentThread] isMainThread];
}

+ (BOOL)isInactive {
#if ADJUST_IM
    // Assume iMessage extension app can't be started from background.
    return NO;
#else
    return [[UIApplication sharedApplication] applicationState] != UIApplicationStateActive;
#endif
}

+ (void)launchInMainThreadWithInactive:(isInactiveInjected)isInactiveblock {
    dispatch_block_t block = ^void(void) {
        __block BOOL isInactive = [ADJUtil isInactive];
        isInactiveblock(isInactive);
    };
    if ([ADJUtil isMainThread]) {
        block();
        return;
    }
    if (ADJAdjustFactory.testing) {
        [ADJAdjustFactory.logger debug:@"Launching in the background for testing"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (BOOL)isValidParameter:(NSString *)attribute
           attributeType:(NSString *)attributeType
           parameterName:(NSString *)parameterName {
    if ([ADJUtil isNull:attribute]) {
        [ADJAdjustFactory.logger error:@"%@ parameter %@ is missing", parameterName, attributeType];
        return NO;
    }
    if ([attribute isEqualToString:@""]) {
        [ADJAdjustFactory.logger error:@"%@ parameter %@ is empty", parameterName, attributeType];
        return NO;
    }
    return YES;
}

+ (NSDictionary *)mergeParameters:(NSDictionary *)target
                           source:(NSDictionary *)source
                    parameterName:(NSString *)parameterName {
    if (target == nil) {
        return source;
    }
    if (source == nil) {
        return target;
    }

    NSMutableDictionary *mergedParameters = [NSMutableDictionary dictionaryWithDictionary:target];
    [source enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *oldValue = [mergedParameters objectForKey:key];
        if (oldValue != nil) {
            [ADJAdjustFactory.logger warn:@"Key %@ with value %@ from %@ parameter was replaced by value %@",
             key, oldValue, parameterName, obj];
        }
        [mergedParameters setObject:obj forKey:key];
    }];
    return (NSDictionary *)mergedParameters;
}

+ (void)launchInQueue:(dispatch_queue_t)queue
           selfInject:(id)selfInject
                block:(selfInjectedBlock)block {
    if (queue == nil) {
        return;
    }
    __weak __typeof__(selfInject) weakSelf = selfInject;
    dispatch_async(queue, ^{
        __typeof__(selfInject) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        block(strongSelf);
    });
}

+ (void)launchSynchronisedWithObject:(id)synchronisationObject
                               block:(synchronisedBlock)block {
    @synchronized (synchronisationObject) {
        block();
    }
}

+ (BOOL)deleteFileWithName:(NSString *)fileName {
    NSString *documentsFilePath = [ADJUtil getFilePathInDocumentsDir:fileName];
    NSString *appSupportFilePath = [ADJUtil getFilePathInAppSupportDir:fileName];
    BOOL deletedDocumentsFilePath = [ADJUtil deleteFileInPath:documentsFilePath];
    BOOL deletedAppSupportFilePath = [ADJUtil deleteFileInPath:appSupportFilePath];
    return deletedDocumentsFilePath || deletedAppSupportFilePath;
}

+ (BOOL)deleteFileInPath:(NSString *)filePath {
    Class class = NSClassFromString([NSString adjJoin:@"N", @"S", @"file", @"manager", nil]);
    if (class == nil) {
        return NO;
    }
    NSString *keyDm = [NSString adjJoin:@"default", @"manager", nil];
    SEL selDm = NSSelectorFromString(keyDm);
    if (![class respondsToSelector:selDm]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id man = [class performSelector:selDm];
#pragma clang diagnostic pop
    NSString *keyExi = [NSString adjJoin:@"file", @"exists", @"at", @"path", @":", nil];
    SEL selExi = NSSelectorFromString(keyExi);
    if (![man respondsToSelector:selExi]) {
        return NO;
    }

    NSMethodSignature *msExi = [man methodSignatureForSelector:selExi];
    NSInvocation *invExi = [NSInvocation invocationWithMethodSignature:msExi];
    [invExi setSelector:selExi];
    [invExi setTarget:man];
    [invExi setArgument:&filePath atIndex:2];
    [invExi invoke];
    BOOL exists;
    [invExi getReturnValue:&exists];
    if (!exists) {
        return YES;
    }

    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    NSString *keyRm = [NSString stringWithFormat:@"%@%@",
                        [NSString adjJoin:@"remove", @"item", @"at", @"path", @":", nil],
                        [NSString adjJoin:@"error", @":", nil]];
    SEL selRm = NSSelectorFromString(keyRm);
    if (![man respondsToSelector:selRm]) {
        return NO;
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selRm]];
    [inv setSelector:selRm];
    [inv setTarget:man];
    [inv setArgument:&filePath atIndex:2];
    [inv setArgument:&errorPointer atIndex:3];
    [inv invoke];
    BOOL deleted;
    [inv getReturnValue:&deleted];

    if (!deleted) {
        [[ADJAdjustFactory logger] verbose:@"Unable to delete file at path %@", filePath];
    }
    if (error) {
        [[ADJAdjustFactory logger] error:@"Error while deleting file at path %@", filePath];
    }
    return deleted;
}

+ (void)launchDeepLinkMain:(NSURL *)deepLinkUrl {
#if ADJUST_IM
    // No deep linking in iMessage extension apps.
    return;
#else
    UIApplication *sharedUIApplication = [UIApplication sharedApplication];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    SEL openUrlSelector = @selector(openURL:options:completionHandler:);
#pragma clang diagnostic pop
    if ([sharedUIApplication respondsToSelector:openUrlSelector]) {
        /*
         [sharedUIApplication openURL:deepLinkUrl options:@{} completionHandler:^(BOOL success) {
         if (!success) {
         [ADJAdjustFactory.logger error:@"Unable to open deep link (%@)", deepLinkUrl];
         }
         }];
         */
        NSMethodSignature *methSig = [sharedUIApplication methodSignatureForSelector:openUrlSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methSig];
        [invocation setSelector: openUrlSelector];
        [invocation setTarget: sharedUIApplication];
        NSDictionary *emptyDictionary = @{};
        void (^completion)(BOOL) = ^(BOOL success) {
            if (!success) {
                [ADJAdjustFactory.logger error:@"Unable to open deep link (%@)", deepLinkUrl];
            }
        };
        [invocation setArgument:&deepLinkUrl atIndex: 2];
        [invocation setArgument:&emptyDictionary atIndex: 3];
        [invocation setArgument:&completion atIndex: 4];
        [invocation invoke];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        BOOL success = [sharedUIApplication openURL:deepLinkUrl];
#pragma clang diagnostic pop
        if (!success) {
            [ADJAdjustFactory.logger error:@"Unable to open deep link without completionHandler (%@)", deepLinkUrl];
        }
    }
#endif
}

// adapted from https://stackoverflow.com/a/9084784
+ (NSString *)convertDeviceToken:(NSData *)deviceToken {
    NSUInteger dataLength  = [deviceToken length];

    if (dataLength == 0) {
        return nil;
    }

    const unsigned char *dataBuffer = (const unsigned char *)[deviceToken bytes];

    if (!dataBuffer) {
        return nil;
    }

    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];

    for (NSUInteger i = 0; i < dataLength; ++i) {
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }

    return [hexString copy];
}

+ (BOOL)contains:(NSDictionary *)dictionary
        key:(NSString *)key
        value:(NSString *)value {
    id readValue = [dictionary objectForKey:key];
    if ([ADJUtil isNull:readValue]) {
        return NO;
    }
    return [value isEqualToString:[readValue description]];
}

+ (BOOL)isDeeplinkValid:(NSURL *)url {
    if (url == nil) {
        return NO;
    }
    if ([[url absoluteString] length] == 0) {
        return NO;
    }
    if (excludedDeeplinkRegex == nil) {
        [ADJAdjustFactory.logger error:@"Excluded deep link regex not correctly configured"];
        return NO;
    }

    NSString *urlString = [url absoluteString];
    NSArray<NSTextCheckingResult *> *matches = [excludedDeeplinkRegex matchesInString:urlString
                                                                              options:0
                                                                                range:NSMakeRange(0, [urlString length])];
    if ([matches count] > 0) {
        [ADJAdjustFactory.logger debug:@"Deep link (%@) processing skipped", urlString];
        return NO;
    }

    return YES;
}

+ (NSString *)sdkVersion {
    return kClientSdk;
}

+ (Class)adSupportManager {
    NSString *className = [NSString adjJoin:@"A", @"S", @"identifier", @"manager", nil];
    Class class = NSClassFromString(className);
    return class;
}

+ (Class)appTrackingManager {
    NSString *className = [NSString adjJoin:@"A", @"T", @"tracking", @"manager", nil];
    Class class = NSClassFromString(className);
    return class;
}

+ (BOOL)trackingEnabled {
#if ADJUST_NO_IDFA
    return NO;
#else
    // return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    Class adSupportClass = [ADJUtil adSupportManager];
    if (adSupportClass == nil) {
        return NO;
    }

    NSString *keyManager = [NSString adjJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id manager = [adSupportClass performSelector:selManager];
    NSString *keyEnabled = [NSString adjJoin:@"is", @"advertising", @"tracking", @"enabled", nil];
    SEL selEnabled = NSSelectorFromString(keyEnabled);
    if (![manager respondsToSelector:selEnabled]) {
        return NO;
    }
    
    NSMethodSignature *msEnabled = [manager methodSignatureForSelector:selEnabled];
    NSInvocation *invEnabled = [NSInvocation invocationWithMethodSignature:msEnabled];
    [invEnabled setSelector:selEnabled];
    [invEnabled setTarget:manager];
    [invEnabled invoke];
    BOOL enabled;
    [invEnabled getReturnValue:&enabled];
    return enabled;
#pragma clang diagnostic pop
#endif
}

+ (NSString *)idfa {
    if (ADJAdjustFactory.idfa != nil) {
        return ADJAdjustFactory.idfa;
    }

#if ADJUST_NO_IDFA
    return @"";
#else
    // return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    Class adSupportClass = [ADJUtil adSupportManager];
    if (adSupportClass == nil) {
        return @"";
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSString *keyManager = [NSString adjJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return @"";
    }
    id manager = [adSupportClass performSelector:selManager];
    NSString *keyIdentifier = [NSString adjJoin:@"advertising", @"identifier", nil];
    SEL selIdentifier = NSSelectorFromString(keyIdentifier);
    if (![manager respondsToSelector:selIdentifier]) {
        return @"";
    }
    id identifier = [manager performSelector:selIdentifier];
    NSString *keyString = [NSString adjJoin:@"UUID", @"string", nil];
    SEL selString = NSSelectorFromString(keyString);
    if (![identifier respondsToSelector:selString]) {
        return @"";
    }
    NSString *string = [identifier performSelector:selString];
    return string;
#pragma clang diagnostic pop
#endif
}

+ (NSString *)idfv {
    Class class = NSClassFromString([NSString adjJoin:@"U", @"I", @"device", nil]);
    if (class == nil) {
        return nil;
    }
    NSString *keyCd = [NSString adjJoin:@"current", @"device", nil];
    SEL selCd = NSSelectorFromString(keyCd);
    if (![class respondsToSelector:selCd]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id dev = [class performSelector:selCd];
#pragma clang diagnostic pop
    NSString *keyIfv = [NSString adjJoin:@"identifier", @"for", @"vendor", nil];
    SEL selIfv = NSSelectorFromString(keyIfv);
    if (![dev respondsToSelector:selIfv]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSUUID *uuid = (NSUUID *)[dev performSelector:selIfv];
#pragma clang diagnostic pop
    if (uuid == nil) {
        return nil;
    }
    return [uuid UUIDString];
}

+ (NSString *)fbAnonymousId {
#if TARGET_OS_TV
    return @"";
#else
    // pre FB SDK v6.0.0
    // return [FBSDKAppEventsUtility retrievePersistedAnonymousID];
    // post FB SDK v6.0.0
    // return [FBSDKBasicUtility retrievePersistedAnonymousID];
    Class class = nil;
    SEL selGetId = NSSelectorFromString(@"retrievePersistedAnonymousID");
    class = NSClassFromString(@"FBSDKBasicUtility");
    if (class != nil) {
        if ([class respondsToSelector:selGetId]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *fbAnonymousId = (NSString *)[class performSelector:selGetId];
            return fbAnonymousId;
#pragma clang diagnostic pop
        }
    }
    class = NSClassFromString(@"FBSDKAppEventsUtility");
    if (class != nil) {
        if ([class respondsToSelector:selGetId]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *fbAnonymousId = (NSString *)[class performSelector:selGetId];
            return fbAnonymousId;
#pragma clang diagnostic pop
        }
    }
    return @"";
#endif
}

+ (NSString *)deviceType {
    Class class = NSClassFromString([NSString adjJoin:@"U", @"I", @"device", nil]);
    if (class == nil) {
        return nil;
    }
    NSString *keyCd = [NSString adjJoin:@"current", @"device", nil];
    SEL selCd = NSSelectorFromString(keyCd);
    if (![class respondsToSelector:selCd]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id dev = [class performSelector:selCd];
#pragma clang diagnostic pop
    NSString *keyM = [NSString adjJoin:@"model", nil];
    SEL selM = NSSelectorFromString(keyM);
    if (![dev respondsToSelector:selM]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return (NSString *)[dev performSelector:selM];
#pragma clang diagnostic pop
}

+ (NSString *)deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    return @(systemInfo.machine);
}

+ (NSUInteger)startedAt {
    int MIB_SIZE = 2;
    int mib[MIB_SIZE];
    size_t size;
    struct timeval starttime;
    mib[0] = CTL_KERN;
    mib[1] = KERN_BOOTTIME;
    size = sizeof(starttime);

    NSString *m = [[NSString adjJoin:@"s", @"ys", @"ct", @"l", nil] lowercaseString];
    int (*fptr)(int *, u_int, void *, size_t *, void *, size_t);
    *(int**)(&fptr) = dlsym(RTLD_SELF, [m UTF8String]);
    if (fptr) {
        if ((*fptr)(mib, MIB_SIZE, &starttime, &size, NULL, 0) != -1) {
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:starttime.tv_sec];
            return (NSUInteger)round([startDate timeIntervalSince1970]);
        }
    }

    return 0;
}

+ (int)attStatus {
    if (ADJAdjustFactory.attStatus != nil) {
        return ADJAdjustFactory.attStatus.intValue;
    }

    Class appTrackingClass = [self appTrackingManager];
    if (appTrackingClass != nil) {
        NSString *keyAuthorization = [NSString adjJoin:@"tracking", @"authorization", @"status", nil];
        SEL selAuthorization = NSSelectorFromString(keyAuthorization);
        if ([appTrackingClass respondsToSelector:selAuthorization]) {
            NSMethodSignature *msAuthorization = [appTrackingClass methodSignatureForSelector:selAuthorization];
            NSInvocation *invAuthorization = [NSInvocation invocationWithMethodSignature:msAuthorization];
            [invAuthorization setSelector:selAuthorization];
            [invAuthorization setTarget:appTrackingClass];
            [invAuthorization invoke];
            NSUInteger status;
            [invAuthorization getReturnValue:&status];
            return (int)status;
        }
    }
    return -1;
}

+ (NSString *)fetchAdServicesAttribution:(NSError **)errorPtr {
    id<ADJLogger> logger = [ADJAdjustFactory logger];

    // [AAAttribution attributionTokenWithError:...]
    Class attributionClass = NSClassFromString(@"AAAttribution");
    if (attributionClass == nil) {
        [logger warn:@"AdServices framework not found in the app (AAAttribution class not found)"];
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:@"com.adjust.sdk.adServices"
                                            code:100
                                        userInfo:@{@"Error reason": @"AdServices framework not found"}];
        }
        return nil;
    }

    SEL attributionTokenSelector = NSSelectorFromString(@"attributionTokenWithError:");
    if (![attributionClass respondsToSelector:attributionTokenSelector]) {
        [logger warn:@"AdServices framework not found in the app (attributionTokenWithError: method not found)"];
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:@"com.adjust.sdk.adServices"
                                            code:100
                                        userInfo:@{@"Error reason": @"AdServices framework not found"}];
        }
        return nil;
    }
    
    NSMethodSignature *attributionTokenMethodSignature = [attributionClass methodSignatureForSelector:attributionTokenSelector];
    NSInvocation *tokenInvocation = [NSInvocation invocationWithMethodSignature:attributionTokenMethodSignature];
    [tokenInvocation setSelector:attributionTokenSelector];
    [tokenInvocation setTarget:attributionClass];
    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    [tokenInvocation setArgument:&errorPointer atIndex:2];
    [tokenInvocation invoke];

    if (error) {
        [logger error:@"Error while retrieving AdServices attribution token: %@", error];
        if (errorPtr) {
            *errorPtr = error;
        }
        return nil;
    }

    [logger debug:@"AdServices framework successfully found in the app"];
    NSString * __unsafe_unretained tmpToken = nil;
    [tokenInvocation getReturnValue:&tmpToken];
    NSString *token = tmpToken;
    return token;
}

+ (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(NSUInteger status))completion {
    Class appTrackingClass = [self appTrackingManager];
    if (appTrackingClass == nil) {
        return;
    }
    NSString *requestAuthorization = [NSString adjJoin:
                                      @"request",
                                      @"tracking",
                                      @"authorization",
                                      @"with",
                                      @"completion",
                                      @"handler:", nil];
    SEL selRequestAuthorization = NSSelectorFromString(requestAuthorization);
    if (![appTrackingClass respondsToSelector:selRequestAuthorization]) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [appTrackingClass performSelector:selRequestAuthorization withObject:completion];
#pragma clang diagnostic pop
}

+ (NSString *)bundleIdentifier {
    return [[NSBundle mainBundle] bundleIdentifier];
}

+ (NSString *)buildNumber {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleVersion"];
}

+ (NSString *)versionNumber {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    return [infoDictionary objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)osVersion {
    Class class = NSClassFromString([NSString adjJoin:@"U", @"I", @"device", nil]);
    if (class == nil) {
        return nil;
    }
    NSString *keyCd = [NSString adjJoin:@"current", @"device", nil];
    SEL selCd = NSSelectorFromString(keyCd);
    if (![class respondsToSelector:selCd]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id dev = [class performSelector:selCd];
#pragma clang diagnostic pop
    NSString *keySv = [NSString adjJoin:@"system", @"version", nil];
    SEL selSv = NSSelectorFromString(keySv);
    if (![dev respondsToSelector:selSv]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return (NSString *)[dev performSelector:selSv];
#pragma clang diagnostic pop
}

+ (NSString *)installedAt {
    id<ADJLogger> logger = ADJAdjustFactory.logger;
    NSDate *installTime = nil;
    NSString *pathToCheck = nil;
    NSSearchPathDirectory folderToCheck = NSDocumentDirectory;
#if TARGET_OS_TV
    folderToCheck = NSCachesDirectory;
#endif
    @try {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(folderToCheck, NSUserDomainMask, YES);
        if (paths.count > 0) {
            pathToCheck = [paths objectAtIndex:0];
        } else {
            pathToCheck = [[NSBundle mainBundle] bundlePath];
        }

        __autoreleasing NSError *error;
        __autoreleasing NSError **errorPointer = &error;
        Class class = NSClassFromString([NSString adjJoin:@"N", @"S", @"file", @"manager", nil]);
        if (class != nil) {
            NSString *keyDm = [NSString adjJoin:@"default", @"manager", nil];
            SEL selDm = NSSelectorFromString(keyDm);
            if ([class respondsToSelector:selDm]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                id man = [class performSelector:selDm];
#pragma clang diagnostic pop
                NSString *keyChk = [NSString stringWithFormat:@"%@%@",
                        [NSString adjJoin:@"attributes", @"of", @"item", @"at", @"path", @":", nil],
                        [NSString adjJoin:@"error", @":", nil]];
                SEL selChk = NSSelectorFromString(keyChk);
                if ([man respondsToSelector:selChk]) {
                    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[man methodSignatureForSelector:selChk]];
                    [inv setSelector:selChk];
                    [inv setTarget:man];
                    [inv setArgument:&pathToCheck atIndex:2];
                    [inv setArgument:&errorPointer atIndex:3];
                    [inv invoke];
                    NSMutableDictionary * __unsafe_unretained tmpResult;
                    [inv getReturnValue:&tmpResult];
                    NSMutableDictionary *result = tmpResult;
                    CFStringRef *indexRef = dlsym(RTLD_SELF, [[NSString adjJoin:@"N", @"S", @"file", @"creation", @"date", nil] UTF8String]);
                    NSString *ref = (__bridge_transfer id) *indexRef;
                    installTime = result[ref];
                }
            }
        }
    } @catch (NSException *exception) {
        [logger error:@"Error while trying to check install date. Exception: %@", exception];
        return nil;
    }

    return [ADJUtil formatDate:installTime];
}

+ (NSString *)generateRandomUuid {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString *uuidString = (__bridge_transfer NSString*)stringRef;
    NSString *lowerUuid = [uuidString lowercaseString];
    CFRelease(newUniqueId);
    return lowerUuid;
}

+ (NSString *)getPersistedRandomToken {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = @"adjust_uuid";
    keychainItem[(__bridge id)kSecAttrService] = @"deviceInfo";
    if (!keychainItem) {
        return nil;
    }

    keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)keychainItem, (CFTypeRef *)&result);
    if (status != noErr) {
        return nil;
    }

    NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
    NSData *data = resultDict[(__bridge id)kSecValueData];
    if (!data) {
        return nil;
    }

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (BOOL)setPersistedRandomToken:(NSString *)randomToken {
    NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
    keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
    keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    keychainItem[(__bridge id)kSecAttrAccount] = @"adjust_uuid";
    keychainItem[(__bridge id)kSecAttrService] = @"deviceInfo";
    keychainItem[(__bridge id)kSecValueData] = [randomToken dataUsingEncoding:NSUTF8StringEncoding];
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)keychainItem, NULL);
    if (status != noErr) {
        [[ADJAdjustFactory logger] warn:@"Primary dedupe token unsuccessfully written"];
        return NO;
    } else {
        NSString *persistedRandomToken = [ADJUtil getPersistedRandomToken];
        if ([randomToken isEqualToString:persistedRandomToken]) {
            [[ADJAdjustFactory logger] debug:@"Primary dedupe token successfully written"];
            return YES;
        } else {
            return NO;
        }
    }
}

+ (NSMutableDictionary *)deepCopyOfDictionary:(NSMutableDictionary *)dictionary {
    if (dictionary == nil) {
        return nil;
    }

    NSMutableDictionary *deepCopy =
    (NSMutableDictionary *)CFBridgingRelease(CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                          (CFDictionaryRef)dictionary,
                                                                          kCFPropertyListMutableContainersAndLeaves));
    return deepCopy;
}

+ (BOOL)shouldUseConsentParamsForActivityKind:(ADJActivityKind)activityKind {
    if (@available(iOS 14.0, tvOS 14.0, *)) {
        if (activityKind == ADJActivityKindGdpr ||
            activityKind == ADJActivityKindSubscription ||
            activityKind == ADJActivityKindPurchaseVerification) {
            return NO;
        }

        int attStatus = [ADJUtil attStatus];
        return attStatus == 3;
    } else {
        // if iOS lower than 14 can assume consent
        return YES;
    }
}

+ (BOOL)shouldUseConsentParamsForActivityKind:(ADJActivityKind)activityKind
                                 andAttStatus:(nullable NSString *)attStatusString {
    if (@available(iOS 14.0, tvOS 14.0, *)) {
        if (activityKind == ADJActivityKindGdpr ||
            activityKind == ADJActivityKindSubscription ||
            activityKind == ADJActivityKindPurchaseVerification) {
            return NO;
        }

        return [@"3" isEqualToString:attStatusString];
    } else {
        // if iOS lower than 14 can assume consent
        return YES;
    }
}

@end

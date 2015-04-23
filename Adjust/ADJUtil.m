//
//  ADJUtil.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-05.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "UIDevice+ADJAdditions.h"
#import "ADJAdjustFactory.h"
#import "NSString+ADJAdditions.h"
#import "ADJAdjustFactory.h"

#include <sys/xattr.h>

static NSString * const kBaseUrl   = @"https://app.adjust.com";
static NSString * const kClientSdk = @"ios4.2.3";

static NSString * const kDateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z";
static NSDateFormatter *dateFormat;

#pragma mark -
@implementation ADJUtil

+ (void) initialize {
    dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:kDateFormat];
}

+ (NSString *)baseUrl {
    return kBaseUrl;
}

+ (NSString *)clientSdk {
    return kClientSdk;
}

// inspired by https://gist.github.com/kevinbarrett/2002382
+ (void)excludeFromBackup:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    id<ADJLogger> logger = ADJAdjustFactory.logger;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"

#pragma clang diagnostic push
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
#pragma clang diagnostic pop

}

+ (NSString *)formatSeconds1970:(double) value {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:value];

    return [self formatDate:date];
}


+ (NSString *)formatDate:(NSDate *) value {
    return [dateFormat stringFromDate:value];
}


+ (NSDictionary *)buildJsonDict:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSError *error = nil;
    NSDictionary *jsonDict = nil;
    @try {
        jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    } @catch (NSException *ex) {
        return nil;
    }

    if (error != nil) {
        return nil;
    }

    return jsonDict;
}

+ (NSString *)getFullFilename:(NSString *) baseFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:baseFilename];
    return filename;
}

+ (id)readObject:(NSString *)filename
      objectName:(NSString *)objectName
           class:(Class) classToRead
{
    id<ADJLogger> logger = [ADJAdjustFactory logger];
    @try {
        NSString *fullFilename = [ADJUtil getFullFilename:filename];
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:fullFilename];
        if ([object isKindOfClass:classToRead]) {
            [logger debug:@"Read %@: %@", objectName, object];
            return object;
        } else if (object == nil) {
            [logger verbose:@"%@ file not found", objectName];
        } else {
            [logger error:@"Failed to read %@ file", objectName];
        }
    } @catch (NSException *ex ) {
        [logger error:@"Failed to read %@ file (%@)", objectName, ex];
    }

    return nil;
}

+ (void)writeObject:(id)object
           filename:(NSString *)filename
         objectName:(NSString *)objectName {
    id<ADJLogger> logger = [ADJAdjustFactory logger];
    NSString *fullFilename = [ADJUtil getFullFilename:filename];
    BOOL result = [NSKeyedArchiver archiveRootObject:object toFile:fullFilename];
    if (result == YES) {
        [ADJUtil excludeFromBackup:fullFilename];
        [logger debug:@"Wrote %@: %@", objectName, object];
    } else {
        [logger error:@"Failed to write %@ file", objectName];
    }
}

+ (NSString *) queryString:(NSDictionary *)parameters {
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

    NSString *queryString = [pairs componentsJoinedByString:@"&"];
    
    return queryString;
}

@end

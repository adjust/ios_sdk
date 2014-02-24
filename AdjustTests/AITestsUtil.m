//
//  AITestsUtil.m
//  Adjust
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AITestsUtil.h"
#import "AIPackageBuilder.h"
#import "AILoggerMock.h"
#import "AIAdjustFactory.h"

@implementation AITestsUtil

+ (NSString *)getFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filepath = [path stringByAppendingPathComponent:filename];
    return filepath;
}

+ (BOOL)deleteFile:(NSString *)filename logger:(AILoggerMock *)loggerMock {
    NSString *filepath = [AITestsUtil getFilename:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL exists = [fileManager fileExistsAtPath:filepath];
    if (!exists) {
        [loggerMock test:@"file %@ does not exist at path %@", filename, filepath];
        return  YES;
    }
    BOOL deleted = [fileManager removeItemAtPath:filepath error:&error];

    if (!deleted) {
        [loggerMock test:@"unable to delete file %@ at path %@", filename, filepath];
    }

    if (error) {
        [loggerMock test:@"error (%@) deleting file %@", [error localizedDescription], filename];
    }

    return deleted;
}

+ (AIActivityPackage *)buildEmptyPackage {
    AIPackageBuilder *sessionBuilder = [[AIPackageBuilder alloc] init];
    AIActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage];
    return sessionPackage;
}

- (void)adjustFinishedTrackingWithResponse:(AIResponseData *)responseData {
    AILoggerMock *loggerMock = (AILoggerMock *)AIAdjustFactory.logger;

    [loggerMock test:@"AdjustDelegate adjustFinishedTrackingWithResponse"];
}

@end

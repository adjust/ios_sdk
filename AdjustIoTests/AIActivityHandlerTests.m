//
//  AIActivityHandlerTests.m
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AILoggerMock.h"
#import "AIPackageHandlerMock.h"
#import "AIAdjustIoFactory.h"
#import "AIActivityHandler.h"

@interface AIActivityHandlerTests : XCTestCase

@property (atomic,strong) AILoggerMock *loggerMock;
@property (atomic,strong) AIPackageHandlerMock *packageHandlerMock;

@end

@implementation AIActivityHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
    
    self.loggerMock = [[AILoggerMock alloc] init];
    [AIAdjustIoFactory setLogger:self.loggerMock];
    
    self.packageHandlerMock = [AIPackageHandlerMock alloc];
    [AIAdjustIoFactory setPackageHandler:self.packageHandlerMock];
}

- (void)tearDown
{
    [AIAdjustIoFactory setPackageHandler:nil];
    [AIAdjustIoFactory setLogger:nil];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    XCTAssert([AIActivityHandlerTests deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    
}

+ (NSString *)getFilename:(NSString *)filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filepath = [path stringByAppendingPathComponent:filename];
    return filepath;
}

+ (BOOL)deleteFile:(NSString *)filename logger:(AILoggerMock *)loggerMock {
    NSString *filepath = [AIActivityHandlerTests getFilename:filename];
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


@end

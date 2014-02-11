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
    
    self.packageHandlerMock = [[AIPackageHandlerMock alloc] init];
    [AIAdjustIoFactory setPackageHandler:self.packageHandlerMock];
}

- (void)tearDown
{
    [AIAdjustIoFactory setPackageHandler:NULL];
    [AIAdjustIoFactory setLogger:NULL];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    //AIActivityHandler *activityHandler = [AIActivityHandler handlerWithAppToken:@"123456789012"];
    [self.packageHandlerMock pauseSending];
    
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler pauseSending"], @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler resumeSending"], @"%@", self.loggerMock);
}

@end

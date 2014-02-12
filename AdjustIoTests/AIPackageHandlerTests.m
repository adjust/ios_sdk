//
//  AIPackageHandlerTests.m
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AIAdjustIoFactory.h"
#import "AILoggerMock.h"
#import "AIActivityHandlerMock.h"
#import "AIRequestHandlerMock.h"

@interface AIPackageHandlerTests : XCTestCase

@property (atomic,strong) AILoggerMock *loggerMock;
@property (atomic,strong) AIRequestHandlerMock *requestHandlerMock;

@end

@implementation AIPackageHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

    self.loggerMock = [[AILoggerMock alloc] init];
    [AIAdjustIoFactory setLogger:self.loggerMock];

    [[AIActivityHandlerMock alloc] initWithAppToken:@"123456789012"];
    self.requestHandlerMock = [AIRequestHandlerMock alloc];
    [AIAdjustIoFactory setRequestHandler:self.requestHandlerMock];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end

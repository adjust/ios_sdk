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
#import "AITestsUtil.h"

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

    self.requestHandlerMock = [AIRequestHandlerMock alloc];
    [AIAdjustIoFactory setRequestHandler:self.requestHandlerMock];
}

- (void)tearDown
{
    [AIAdjustIoFactory setRequestHandler:nil];
    [AIAdjustIoFactory setLogger:nil];

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testFirstPackage
{
    //  delete previously created Package queue file to make a new queue
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoPackageQueue" logger:self.loggerMock], @"%@", self.loggerMock);

    //  initialize Package Handler
    id<AIPackageHandler> packageHandler =
        [AIAdjustIoFactory packageHandlerForActivityHandler:[[AIActivityHandlerMock alloc] initWithAppToken:@"123456789012"]];

    //  enable sending packages to Request Handler
    [packageHandler resumeSending];

    //  build and add the first package to the queue
    [packageHandler addPackage:[AITestsUtil buildEmptyPackage]];

    //  send the first package in the queue to the mock request handler
    [packageHandler sendFirstPackage];

    //  it's necessary to sleep the activity for a while after each handler call
    //  to let the internal queue act
    [NSThread sleepForTimeInterval:1.0];

    //  check that the request handler mock was created
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIRequestHandler initWithPackageHandler"], @"%@", self.loggerMock);

    //  test that the file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Package queue file not found"], @"%@", self.loggerMock);

    //  check that added first package to a previous empty queue
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Added package 1 "], @"%@", self.loggerMock);

    //TODO add the verbose message

    //  it should write the package queue with the first session package
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Package handler wrote 1 packages"], @"%@", self.loggerMock);

    //  check that the Request Handler was called to send the package
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIRequestHandler sendPackage"],  @"%@", self.loggerMock);

    //  check that the package was removed from the queue and 0 packages were written
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Package handler wrote 0 packages"], @"%@", self.loggerMock);

}

@end

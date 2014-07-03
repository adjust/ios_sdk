//
//  AIPackageHandlerTests.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AIAdjustFactory.h"
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
}

- (void)tearDown
{
    [AIAdjustFactory setRequestHandler:nil];
    [AIAdjustFactory setLogger:nil];

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[AILoggerMock alloc] init];
    [AIAdjustFactory setLogger:self.loggerMock];

    self.requestHandlerMock = [AIRequestHandlerMock alloc];
    [AIAdjustFactory setRequestHandler:self.requestHandlerMock];

}

- (void)testFirstPackage
{
    //  reseting to make the test order independent
    [self reset];

    //  delete previously created Package queue file to make a new queue
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoPackageQueue" logger:self.loggerMock], @"%@", self.loggerMock);

    //  initialize Package Handler
    AIActivityHandlerMock *activityHandler = [[AIActivityHandlerMock alloc] initWithAppToken:@"123456789012"];
    id<AIPackageHandler> packageHandler = [AIAdjustFactory packageHandlerForActivityHandler:activityHandler];

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
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Added package 1 (session)"], @"%@", self.loggerMock);

    //TODO add the verbose message

    //  it should write the package queue with the first session package
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Package handler wrote 1 packages"], @"%@", self.loggerMock);

    //  check that the Request Handler was called to send the package
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIRequestHandler sendPackage"],  @"%@", self.loggerMock);

    //  check that the the request handler called the package callback, that foward it to the activity handler
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIActivityHandler finishedTrackingWithResponse"],
            @"%@", self.loggerMock);

    //  check that the package was removed from the queue and 0 packages were written
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Package handler wrote 0 packages"], @"%@", self.loggerMock);
}

- (void) testPaused {
    //  reseting to make the test order independent
    [self reset];

    //  initialize Package Handler
    AIActivityHandlerMock *activityHandler = [[AIActivityHandlerMock alloc] initWithAppToken:@"123456789012"];
    id<AIPackageHandler> packageHandler = [AIAdjustFactory packageHandlerForActivityHandler:activityHandler];

    //  disable sending packages to Request Handler
    [packageHandler pauseSending];

    // build and add a package the queue
    [packageHandler addPackage:[AITestsUtil buildEmptyPackage]];

    //  try to send the first package in the queue to the mock request handler
    [packageHandler sendFirstPackage];

    [NSThread sleepForTimeInterval:1.0];

    //  check that the request handler mock was created
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIRequestHandler initWithPackageHandler"], @"%@", self.loggerMock);

    //  check that a package was added
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Added package"], @"%@", self.loggerMock);

    //  check that the mock request handler was NOT called to send the package
    XCTAssertFalse([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIRequestHandler sendPackage"], @"%@", self.loggerMock);

    //  check that the package handler is paused
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Package handler is paused"], @"%@", self.loggerMock);
}

- (void) testMultiplePackages {
    //  reseting to make the test order independent
    [self reset];

    //  delete previously created Package queue file to make a new queue
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoPackageQueue" logger:self.loggerMock], @"%@", self.loggerMock);

    //  initialize Package Handler
    AIActivityHandlerMock *activityHandler = [[AIActivityHandlerMock alloc] initWithAppToken:@"123456789012"];
    id<AIPackageHandler> packageHandler = [AIAdjustFactory packageHandlerForActivityHandler:activityHandler];

    //  enable sending packages to Request Handler
    [packageHandler resumeSending];

    //  build and add the 3 packages to the queue
    [packageHandler addPackage:[AITestsUtil buildEmptyPackage]];
    [packageHandler addPackage:[AITestsUtil buildEmptyPackage]];
    [packageHandler addPackage:[AITestsUtil buildEmptyPackage]];

    //  create a new package handler to simulate a new launch
    [NSThread sleepForTimeInterval:1.0];
    packageHandler = [AIAdjustFactory packageHandlerForActivityHandler:activityHandler];

    //  try to send two packages without closing the first
    [packageHandler sendFirstPackage];
    [packageHandler sendFirstPackage];

    [NSThread sleepForTimeInterval:1.0];

    //  check that the request handler mock was created
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIRequestHandler initWithPackageHandler"], @"%@", self.loggerMock);

    //  test that the file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Package queue file not found"], @"%@", self.loggerMock);

    //  check that added the third package to the queue and wrote to a file
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Added package 3 (session)"], @"%@", self.loggerMock);

    //  check that it reads the same 3 packages in the file
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Package handler read 3 packages"], @"%@", self.loggerMock);

    //  check that the package handler was already sending one package before
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Package handler is already sending"], @"%@", self.loggerMock);

}

@end

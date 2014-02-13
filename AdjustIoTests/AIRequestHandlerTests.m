//
//  AIRequestHandlerTests.m
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AIAdjustIoFactory.h"
#import "AILoggerMock.h"
#import <OCMock/OCMock.h>
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"
#import "AIPackageHandlerMock.h"
#import "AIRequestHandlerMock.h"
#import "AITestsUtil.h"
#import "AIResponseData.h"

@interface AIRequestHandlerTests : XCTestCase

@property (atomic,strong) AILoggerMock *loggerMock;
@property (atomic,strong) AIPackageHandlerMock *packageHandlerMock;

@end

@implementation AIRequestHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

    self.loggerMock = [[AILoggerMock alloc] init];
    [AIAdjustIoFactory setLogger:self.loggerMock];

    self.packageHandlerMock = [[AIPackageHandlerMock alloc] init];
}

- (void)tearDown
{
    [AIAdjustIoFactory setLogger:nil];

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testSendFirstPackage
{
    id<AIRequestHandler> requestHandler =[AIAdjustIoFactory requestHandlerForPackageHandler:self.packageHandlerMock];

    [requestHandler sendPackage:[AITestsUtil buildEmptyPackage]];

    [NSThread sleepForTimeInterval:1.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    [self.loggerMock test:[NSString stringWithFormat:@"%@",self.packageHandlerMock.responseData]];

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"Tracked session"],
              @"%@", self.loggerMock);

    //  check that the package handler was called to send the next package
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

}

@end

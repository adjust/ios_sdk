//
//  AIRequestHandlerTests.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AIAdjustFactory.h"
#import "AILoggerMock.h"
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"
#import "AIPackageHandlerMock.h"
#import "AIRequestHandlerMock.h"
#import "AITestsUtil.h"
#import "AIResponseData.h"

@interface AIRequestHandlerTests : XCTestCase

@property (atomic,strong) AILoggerMock *loggerMock;
@property (atomic,strong) AIPackageHandlerMock *packageHandlerMock;
@property (atomic,strong) id<AIRequestHandler> requestHandler;


@end

@implementation AIRequestHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

    [self reset];

}

- (void)tearDown
{
    [AIAdjustFactory setLogger:nil];

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[AILoggerMock alloc] init];
    [AIAdjustFactory setLogger:self.loggerMock];

    self.packageHandlerMock = [[AIPackageHandlerMock alloc] init];
    self.requestHandler =[AIAdjustFactory requestHandlerForPackageHandler:self.packageHandlerMock];
}

- (void)testSendPackage
{
    //  reseting to make the test order independent
    [self reset];

    //  set the connection to respond OK
    [NSURLConnection setConnectionError:NO];
    [NSURLConnection setResponseError:NO];

    [self.requestHandler sendPackage:[AITestsUtil buildEmptyPackage]];

    [NSThread sleepForTimeInterval:1.0];

    NSLog(@"%@", self.loggerMock);

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    //  check the response data, the kind is unknown because is set by the package handler
    NSString *sresponseData= [NSString stringWithFormat:@"%@", self.packageHandlerMock.responseData];
    XCTAssert([sresponseData isEqualToString:@"[kind:unknown success:1 willRetry:0 error:(null) trackerToken:token trackerName:name]"],
                   @"%@", sresponseData);

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"Tracked session"],
              @"%@", self.loggerMock);

    //  check that the package handler was called to send the next package
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler sendNextPackage"],
              @"%@", self.loggerMock);

}

- (void)testConnectionError {
    //  reseting to make the test order independent
    [self reset];

    //  set the connection to return error on the connection
    [NSURLConnection setConnectionError:YES];
    [NSURLConnection setResponseError:NO];

    [self.requestHandler sendPackage:[AITestsUtil buildEmptyPackage]];
    [NSThread sleepForTimeInterval:1.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    //  check the response data,
    NSString *sresponseData= [NSString stringWithFormat:@"%@", self.packageHandlerMock.responseData];
    XCTAssert([sresponseData isEqualToString:@"[kind:unknown success:0 willRetry:1 error:'connection error' trackerToken:(null) trackerName:(null)]"], @"%@", sresponseData);

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Failed to track session. (connection error) Will retry later."],
              @"%@", self.loggerMock);

    //  check that the package handler was called to close the package to retry later
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler closeFirstPackage"],
              @"%@", self.loggerMock);

}

- (void)testResponseError {
    //  reseting to make the test order independent
    [self reset];
    
    //  set the response to return an error
    [NSURLConnection setConnectionError:NO];
    [NSURLConnection setResponseError:YES];

    [self.requestHandler sendPackage:[AITestsUtil buildEmptyPackage]];
    [NSThread sleepForTimeInterval:1.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    //  check the response data,
    NSString *sresponseData= [NSString stringWithFormat:@"%@", self.packageHandlerMock.responseData];
    XCTAssert([sresponseData isEqualToString:@"[kind:unknown success:0 willRetry:0 error:'response error' trackerToken:token trackerName:name]"], @"%@", sresponseData);

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Failed to track session. (response error)"],
              @"%@", sresponseData);

    //  check that the package handler was called to send the next package
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler sendNextPackage"],
              @"%@", self.loggerMock);

}


@end

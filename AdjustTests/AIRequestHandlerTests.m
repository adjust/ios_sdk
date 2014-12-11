//
//  ADJRequestHandlerTests.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ADJAdjustFactory.h"
#import "ADJLoggerMock.h"
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"
#import "ADJPackageHandlerMock.h"
#import "ADJRequestHandlerMock.h"
#import "ADJTestsUtil.h"

@interface ADJRequestHandlerTests : XCTestCase

@property (atomic,strong) ADJLoggerMock *loggerMock;
@property (atomic,strong) ADJPackageHandlerMock *packageHandlerMock;
@property (atomic,strong) id<ADJRequestHandler> requestHandler;


@end

@implementation ADJRequestHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.

    [self reset];

}

- (void)tearDown
{
    [ADJAdjustFactory setLogger:nil];

    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[ADJLoggerMock alloc] init];
    [ADJAdjustFactory setLogger:self.loggerMock];

    self.packageHandlerMock = [[ADJPackageHandlerMock alloc] init];
    self.requestHandler =[ADJAdjustFactory requestHandlerForPackageHandler:self.packageHandlerMock];
}

- (void)testSendPackage {
    // session/event version
    [self checkSendPackage:NO];
    // click version
    [self checkSendPackage:YES];
}

- (void)checkSendPackage:(BOOL)isClickPackage {
    //  reseting to make the test order independent
    [self reset];

    //  set the connection to respond OK
    [NSURLConnection setConnectionError:NO];
    [NSURLConnection setResponse:0];

    if (isClickPackage) {
        [self.requestHandler sendClickPackage:[ADJTestsUtil buildEmptyPackage]];
    } else {
        [self.requestHandler sendPackage:[ADJTestsUtil buildEmptyPackage]];
    }

    [NSThread sleepForTimeInterval:2.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
        beginsWith:@"status code 200 for package response: {\"attribution\":{\"tracker_token\":\"trackerTokenValue\",\"tracker_name\":\"trackerNameValue\", \"network\":\"networkValue\",\"campaign\":\"campaignValue\", \"adgroup\":\"adgroupValue\",\"creative\":\"creativeValue\"}, \"message\":\"response OK\",\"deeplink\":\"testApp://\"}"],
              @"%@", self.loggerMock);

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"response OK"],
              @"%@", self.loggerMock);

    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    if (isClickPackage) {
        //  check that the package handler was not called to send the next package
        XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendNextPackage"], @"%@", self.loggerMock);
    } else {
        //  check that the package handler was called to send the next package
        XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendNextPackage"], @"%@", self.loggerMock);
    }
    // check that the json dict is not nil
    XCTAssertNotNil(self.packageHandlerMock.jsonDict, @"%@", self.loggerMock);
}

- (void)testConnectionError {
    // session/event version
    [self checkConnectionError:NO];
    // click version
    [self checkConnectionError:YES];
}

- (void)checkConnectionError:(BOOL)isClickPackage {
    //  reseting to make the test order independent
    [self reset];

    //  set the connection to return error on the connection
    [NSURLConnection setConnectionError:YES];
    [NSURLConnection setResponse:0];

    if (isClickPackage) {
        [self.requestHandler sendClickPackage:[ADJTestsUtil buildEmptyPackage]];
    } else {
        [self.requestHandler sendPackage:[ADJTestsUtil buildEmptyPackage]];
    }
    [NSThread sleepForTimeInterval:1.0];


    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Failed to track session. (connection error) Will retry later."],
              @"%@", self.loggerMock);

    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    if (isClickPackage) {
        //  check that the package handler was not called to close the package to retry later
        XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler closeFirstPackage"],
                  @"%@", self.loggerMock);

    } else {
        //  check that the package handler was called to close the package to retry later
        XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler closeFirstPackage"],
                  @"%@", self.loggerMock);
    }

    // check that the json dict is nil
    XCTAssertNil(self.packageHandlerMock.jsonDict, @"%@", self.loggerMock);

}

- (void)testResponseError {
    // session/event version
    [self checkResponseError:NO];
    // click version
    [self checkResponseError:YES];

}

- (void)checkResponseError:(BOOL)isClickPackage {

    //  reseting to make the test order independent
    [self reset];

    //  set the response to return an error
    [NSURLConnection setConnectionError:NO];
    [NSURLConnection setResponse:1];

    if (isClickPackage) {
        [self.requestHandler sendClickPackage:[ADJTestsUtil buildEmptyPackage]];
    } else {
        [self.requestHandler sendPackage:[ADJTestsUtil buildEmptyPackage]];
    }
    [NSThread sleepForTimeInterval:1.0];


    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
                                    beginsWith:@"status code 0 for package response: {\"message\":\"response error\"}"],
              @"%@", self.loggerMock);

    //  check that logged error
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"response error"],
              @"%@", self.loggerMock);

    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    if (isClickPackage) {
        //  check that the package handler was not called to send the next package
        XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendNextPackage"],
                  @"%@", self.loggerMock);

    } else {
        //  check that the package handler was called to send the next package
        XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendNextPackage"],
                  @"%@", self.loggerMock);
    }
}

- (void)testResponseNil {
    // session/event version
    [self checkResponseNil:NO];
    // click version
    [self checkResponseNil:YES];
}

- (void)checkResponseNil:(BOOL)isClickPackage {

    //  reseting to make the test order independent
    [self reset];

    //  set the response to return an error
    [NSURLConnection setConnectionError:NO];
    [NSURLConnection setResponse:2];

    if (isClickPackage) {
        [self.requestHandler sendClickPackage:[ADJTestsUtil buildEmptyPackage]];
    } else {
        [self.requestHandler sendPackage:[ADJTestsUtil buildEmptyPackage]];
    }
    [NSThread sleepForTimeInterval:1.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
                                    beginsWith:@"status code 0 for package response: server response"],
              @"%@", self.loggerMock);

    //  check that json was not possible to parse
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Failed to parse json response. (server response) Will retry later."],
              @"%@", self.loggerMock);


    if (isClickPackage) {
        //  check that the package handler was not called to close the package to retry later
        XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler closeFirstPackage"],
                  @"%@", self.loggerMock);

    } else {
        //  check that the package handler was called to close the package to retry later
        XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler closeFirstPackage"],
                  @"%@", self.loggerMock);
    }
}

- (void)testResponseEmpty {
    // session/event version
    [self checkResponseEmpty:NO];
    // click version
    [self checkResponseEmpty:YES];
}


- (void)checkResponseEmpty:(BOOL)isClickPackage {
    //  reseting to make the test order independent
    [self reset];

    //  set the response to return an error
    [NSURLConnection setConnectionError:NO];
    [NSURLConnection setResponse:3];

    if (isClickPackage) {
        [self.requestHandler sendClickPackage:[ADJTestsUtil buildEmptyPackage]];
    } else {
        [self.requestHandler sendPackage:[ADJTestsUtil buildEmptyPackage]];
    }
    [NSThread sleepForTimeInterval:1.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check that no message was found
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError
                                    beginsWith:@"No message found"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
                                    beginsWith:@"status code 0 for package response: {}"],
              @"%@", self.loggerMock);


    //  check that the package handler was pinged after sending
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler finishedTrackingActivity"],
              @"%@", self.loggerMock);

    if (isClickPackage) {
        //  check that the package handler was not called to send the next package
        XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendNextPackage"],
                       @"%@", self.loggerMock);

    } else {
        //  check that the package handler was called to send the next package
        XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendNextPackage"],
                  @"%@", self.loggerMock);
    }
}

@end

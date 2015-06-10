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
#import "ADJTestActivityPackage.h"

@interface ADJRequestHandlerTests : ADJTestActivityPackage

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
    [ADJAdjustFactory setPackageHandler:self.packageHandlerMock];

    self.requestHandler =[ADJAdjustFactory requestHandlerForPackageHandler:self.packageHandlerMock];
}

- (void)testSend
{
    [self testSendPackage:NO];

    [self testSendPackage:YES];
}

- (void)testSendPackage:(BOOL)isClickPackage
{
    // null response
    [NSURLConnection setResponseType:ADJResponseTypeNil];

    [self checkSendPackage:isClickPackage];

    [self checkCloseFirstPackage:isClickPackage];

    // client exception
    [NSURLConnection setResponseType:ADJResponseTypeConnError];

    [self checkSendPackage:isClickPackage];

    aError(@"Failed to track unknown (connection error) Will retry later");

    [self checkCloseFirstPackage:isClickPackage];

    // server error
    [NSURLConnection setResponseType:ADJResponseTypeServerError];

    [self checkSendPackage:isClickPackage];

    aVerbose(@"Response: { \"message\": \"testResponseError\"}");

    aError(@"testResponseError");

    aTest(@"PackageHandler finishedTracking, \"message\" = \"testResponseError\";");

    [self checkSendNext:isClickPackage];

    // wrong json
    [NSURLConnection setResponseType:ADJResponseTypeWrongJson];

    [self checkSendPackage:isClickPackage];

    aVerbose(@"Response: not a json response");

    aError(@"Failed to parse json response. (The operation couldn’t be completed. (Cocoa error 3840.))");

    [self checkCloseFirstPackage:isClickPackage];

    // empty json
    [NSURLConnection setResponseType:ADJResponseTypeEmptyJson];

    [self checkSendPackage:isClickPackage];

    aVerbose(@"Response: { }");

    aInfo(@"No message found");

    aTest(@"PackageHandler finishedTracking, ");

    [self checkSendNext:isClickPackage];

    // message response
    [NSURLConnection setResponseType:ADJResponseTypeMessage];

    [self checkSendPackage:isClickPackage];

    aVerbose(@"Response: { \"message\" : \"response OK\"}");

    aInfo(@"response OK");

    aTest(@"PackageHandler finishedTracking, \"message\" = \"response OK\";");

    [self checkSendNext:isClickPackage];
}

- (void)checkSendNext:(BOOL)isClickPackage
{
    if (isClickPackage) {
        anTest(@"PackageHandler sendNextPackage");
    } else {
        aTest(@"PackageHandler sendNextPackage");
    }
}

- (void)checkSendPackage:(BOOL)isClickPackage
{
    if (isClickPackage) {
        [self.requestHandler sendClickPackage:[ADJTestsUtil getUnknowPackage:@""]];
    } else {
        [self.requestHandler sendPackage:[ADJTestsUtil getUnknowPackage:@""]];
    }

    [NSThread sleepForTimeInterval:1.0];

    aTest(@"NSURLConnection sendSynchronousRequest");
}

- (void)checkCloseFirstPackage:(BOOL)isClickPackage
{
    if (isClickPackage) {
        anTest(@"PackageHandler closeFirstPackage");
    } else {
        aTest(@"PackageHandler closeFirstPackage");
    }
}

@end

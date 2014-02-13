//
//  AIActivityHandlerTests.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AILoggerMock.h"
#import "AIPackageHandlerMock.h"
#import "AIAdjustFactory.h"
#import "AIActivityHandler.h"
#import "AIActivityPackage.h"
#import "AITestsUtil.h"

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
    [AIAdjustFactory setLogger:self.loggerMock];
    
    self.packageHandlerMock = [AIPackageHandlerMock alloc];
    [AIAdjustFactory setPackageHandler:self.packageHandlerMock];
}

- (void)tearDown
{
    [AIAdjustFactory setPackageHandler:nil];
    [AIAdjustFactory setLogger:nil];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testFirstRun
{
    //  deleting the activity state file to simulate a first session
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    
    //  create handler and start the first session
    id<AIActivityHandler> activityHandler = [AIAdjustFactory activityHandlerWithAppToken:@"123456789012"];

    // it's necessary to sleep the activity for a while after each handler call
    //  to let the internal queue act
    [NSThread sleepForTimeInterval:1.0];
    
    //  test that the file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Activity state file not found"], @"%@", self.loggerMock);
    
    //  when a session package is being sent the package handler should resume sending
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler resumeSending"], @"%@", self.loggerMock);

    //  if the package was build, it was sent to the Package Handler
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler addPackage"], @"%@", self.loggerMock);

    // checking the default values of the first session package
    //  should only have one package
    XCTAssertEqual(1, (NSInteger)[self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    AIActivityPackage *activityPackage = (AIActivityPackage *) self.packageHandlerMock.packageQueue[0];

    //  check the Sdk version is being tested
    XCTAssertEqual(@"ios2.2.0", activityPackage.clientSdk, @"%@", activityPackage.extendedString);

    //   packageType should be SESSION_START
    XCTAssertEqual(@"/startup", activityPackage.path, @"%@", activityPackage.extendedString);

    NSDictionary *parameters = activityPackage.parameters;

    //  sessions attributes
    //   sessionCount 1, because is the first session
    XCTAssertEqual(1, [(NSString *)parameters[@"session_count"] intValue], @"%@", activityPackage.extendedString);

    //   subSessionCount -1, because we didn't had any subsessions yet
    //   because only values > 0 are added to parameters, therefore is not present
    XCTAssertNil(parameters[@"subsession_count"], @"%@", activityPackage.extendedString);

    //   sessionLenght -1, same as before
    XCTAssertNil(parameters[@"session_length"], @"%@", activityPackage.extendedString);

    //   timeSpent -1, same as before
    XCTAssertNil(parameters[@"time_spent"], @"%@", activityPackage.extendedString);

    //   lastInterval -1, same as before
    XCTAssertNil(parameters[@"last_interval"], @"%@", activityPackage.extendedString);

    //  after adding, the activity handler ping the Package handler to send the package
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler sendFirstPackage"], @"%@", self.loggerMock);

    // check that the activity state is written by the first session or timer
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Wrote activity state: "], @"%@", self.loggerMock);

    // ending of first session
    XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"First session"], @"%@", self.loggerMock);
}




@end

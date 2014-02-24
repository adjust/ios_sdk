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
    
}

- (void)tearDown
{
    [AIAdjustFactory setPackageHandler:nil];
    [AIAdjustFactory setLogger:nil];
    [AIAdjustFactory setSessionInterval:-1];
    [AIAdjustFactory setSubsessionInterval:-1];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[AILoggerMock alloc] init];
    [AIAdjustFactory setLogger:self.loggerMock];

    self.packageHandlerMock = [AIPackageHandlerMock alloc];
    [AIAdjustFactory setPackageHandler:self.packageHandlerMock];

    [AIAdjustFactory setSessionInterval:-1];
    [AIAdjustFactory setSubsessionInterval:-1];
}

- (void)testFirstRun
{
    //  reseting to make the test order independent
    [self reset];
    
    //  deleting the activity state file to simulate a first session
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    
    //  create handler and start the first session
    id<AIActivityHandler> activityHandler = [AIAdjustFactory activityHandlerWithAppToken:@"123456789012"];

    //  set the delegate to be called at after sending the package
    AITestsUtil * testsUtil = [[AITestsUtil alloc] init];
    [activityHandler setDelegate:testsUtil];

    // it's necessary to sleep the activity for a while after each handler call
    //  to let the internal queue act
    [NSThread sleepForTimeInterval:10.0];
    
    //  test that the file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Activity state file not found"], @"%@", self.loggerMock);
    
    //  when a session package is being sent the package handler should resume sending
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler resumeSending"], @"%@", self.loggerMock);

    //  if the package was build, it was sent to the Package Handler
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler addPackage"], @"%@", self.loggerMock);

    // checking the default values of the first session package
    //  should only have one package
    XCTAssertEqual((NSUInteger)1, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    AIActivityPackage *activityPackage = (AIActivityPackage *) self.packageHandlerMock.packageQueue[0];

    //  check the Sdk version is being tested
    XCTAssertEqual(@"ios3.0.0", activityPackage.clientSdk, @"%@", activityPackage.extendedString);

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

    //  check that the package handler calls back with the delegate
    //XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AdjustDelegate adjustFinishedTrackingWithResponse"],
    //          @"%@", self.loggerMock);

    // check that the activity state is written by the first session or timer
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Wrote activity state: "], @"%@", self.loggerMock);

    // ending of first session
    XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"First session"], @"%@", self.loggerMock);
}

- (void)testSessions {
    //  reseting to make the test order independent
    [self reset];

    //  starting from a clean slate
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);

    //  adjust the intervals for testing
    [AIAdjustFactory setSessionInterval:(2)]; // 2 seconds
    [AIAdjustFactory setSubsessionInterval:(0.1)]; // 0.1 second

    //  create handler to start the session
    id<AIActivityHandler> activityHandler = [AIAdjustFactory activityHandlerWithAppToken:@"123456789012"];

    //  wait enough to be a new subsession, but not a new session
    [NSThread sleepForTimeInterval:1.5];
    [activityHandler trackSubsessionStart];

    //  wait enough to be a new session
    [NSThread sleepForTimeInterval:4];
    [activityHandler trackSubsessionStart];

    //  test the subsession end
    [activityHandler trackSubsessionEnd];
    [NSThread sleepForTimeInterval:1];

    //  check that a new subsession was created
    XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"Processed Subsession 2 of Session 1"],  @"%@", self.loggerMock);

    // check that it's now on the 2nd session
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Session 2"],  @"%@", self.loggerMock);

    //  check that 2 packages were added to the package handler
    XCTAssertEqual((NSUInteger)2, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    //  get the second session package and its parameters
    AIActivityPackage *activityPackage = (AIActivityPackage *) self.packageHandlerMock.packageQueue[1];
    NSDictionary *parameters = activityPackage.parameters;

    //  the session and subsession count should be 2
    //   session_count
    XCTAssertEqual(2, [(NSString *)parameters[@"session_count"] intValue], @"%@", activityPackage.extendedString);

    //   subsession_count
    XCTAssertEqual(2, [(NSString *)parameters[@"subsession_count"] intValue], @"%@", activityPackage.extendedString);

    //  check that the package handler was paused
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler pauseSending"], @"%@", self.loggerMock);
}

- (void)testEventsBuffered {
    //  reseting to make the test order independent
    [self reset];

    //  starting from a clean slate
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);

    //  create handler to start the session
    id<AIActivityHandler> activityHandler = [AIAdjustFactory activityHandlerWithAppToken:@"123456789012"];
    [activityHandler setBufferEvents:YES];

    //  construct the parameters of the the event
    NSDictionary *eventParameters = @{@"key": @"value", @"foo": @"bar" };

    //  the first is a normal event has parameters, the second a revenue
    [activityHandler trackEvent:@"abc123" withParameters:eventParameters];
    [activityHandler trackRevenue:4.45 forEvent:@"abc123" withParameters:eventParameters];

    [NSThread sleepForTimeInterval:2];

    //  check that event buffering is enabled
    //XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"Event buffering is enabled"], @"%@", self.loggerMock);

    //  check that the package builder added the session, event and revenue package
    XCTAssertEqual((NSUInteger)3, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    //  check the first event
    AIActivityPackage *eventPackage = (AIActivityPackage *) self.packageHandlerMock.packageQueue[1];

    //   check the event path
    XCTAssert([eventPackage.path isEqualToString:@"/event"], @"%@", eventPackage.extendedString);

    //   check the event suffix
    XCTAssert([eventPackage.suffix isEqualToString:@" 'abc123'"], @"%@", eventPackage.extendedString);

    NSDictionary *eventPackageParameters = eventPackage.parameters;

    //   check the event count in the package parameters
    XCTAssertEqual(1, [(NSString *)eventPackageParameters[@"event_count"] intValue], @"%@", eventPackage.extendedString);

    //   check the event token
    XCTAssert([(NSString *)eventPackageParameters[@"event_token"] isEqualToString:@"abc123"], @"%@", eventPackage.extendedString);

    //   check the injected parameters
    XCTAssert([(NSString *)eventPackageParameters[@"params"] isEqualToString:@"eyJrZXkiOiJ2YWx1ZSIsImZvbyI6ImJhciJ9"],
              @"%@", eventPackage.extendedString);

    //   check that the event was buffered
    XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"Buffered event 'abc123'"], @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Wrote activity state: ec:1"], @"%@", self.loggerMock);

    //   check the event count in the logger
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Event 1"], @"%@", self.loggerMock);

    //  check the second event/ first revenue
    AIActivityPackage *revenuePackage = (AIActivityPackage *) self.packageHandlerMock.packageQueue[2];

    //   check the revenue path
    XCTAssert([revenuePackage.path isEqualToString:@"/revenue"], @"%@", revenuePackage.extendedString);

    //   check the revenue suffix
    //    note that the amount was rounded to the decimal cents
    XCTAssert([revenuePackage.suffix isEqualToString:@" (4.5 cent, 'abc123')"], @"%@", revenuePackage.extendedString);

    NSDictionary *revenuePackageParameters = revenuePackage.parameters;

    //   check the event count in the package parameters
    XCTAssertEqual(2, [(NSString *)revenuePackageParameters[@"event_count"] intValue], @"%@", revenuePackage.extendedString);

    //   check the amount, transforming cents into rounded decimal cents
    //    note that the 4.45 cents ~> 45 decimal cents
    XCTAssertEqual(45, [(NSString *)revenuePackageParameters[@"amount"] intValue], @"%@", revenuePackage.extendedString);

    //   check the event token
    XCTAssert([(NSString *)revenuePackageParameters[@"event_token"] isEqualToString:@"abc123"], @"%@", revenuePackage.extendedString);

    //   check the injected parameters
    XCTAssert([(NSString *)revenuePackageParameters[@"params"] isEqualToString:@"eyJrZXkiOiJ2YWx1ZSIsImZvbyI6ImJhciJ9"],
              @"%@", eventPackage.extendedString);

    //   check that the revenue was buffered
    XCTAssert([self.loggerMock containsMessage:AILogLevelInfo beginsWith:@"Buffered revenue (4.5 cent, 'abc123')"], @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Wrote activity state: ec:2"], @"%@", self.loggerMock);

    //   check the event count in the logger
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Event 2 (revenue)"], @"%@", self.loggerMock);
}

- (void)testEventsNotBuffered {
    //  reseting to make the test order independent
    [self reset];

    //  starting from a clean slate
    XCTAssert([AITestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);

    //  create handler to start the session
    id<AIActivityHandler> activityHandler = [AIAdjustFactory activityHandlerWithAppToken:@"123456789012"];
    [activityHandler setBufferEvents:NO];

    //  the first is a normal event has parameters, the second a revenue
    [activityHandler trackEvent:@"abc123" withParameters:nil];
    [activityHandler trackRevenue:0 forEvent:nil withParameters:nil];

    [NSThread sleepForTimeInterval:2];

    //  check that the package added the session, event and revenue package
    XCTAssertEqual((NSUInteger)3, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    //  check the first event
    AIActivityPackage *eventPackage = (AIActivityPackage *) self.packageHandlerMock.packageQueue[1];

    //   check the event path
    XCTAssert([eventPackage.path isEqualToString:@"/event"], @"%@", eventPackage.extendedString);

    //   check the event suffix
    XCTAssert([eventPackage.suffix isEqualToString:@" 'abc123'"], @"%@", eventPackage.extendedString);

    NSDictionary *eventPackageParameters = eventPackage.parameters;

    //   check the event count in the package parameters
    XCTAssertEqual(1, [(NSString *)eventPackageParameters[@"event_count"] intValue], @"%@", eventPackage.extendedString);

    //   check the event token
    XCTAssert([(NSString *)eventPackageParameters[@"event_token"] isEqualToString:@"abc123"], @"%@", eventPackage.extendedString);

    //   check the that the parameters were not injected
    XCTAssertNil(eventPackageParameters[@"params"], @"%@", eventPackage.extendedString);

    //   check that the package handler was called
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler sendFirstPackage"], @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Wrote activity state: ec:1"], @"%@", self.loggerMock);

    //   check the event count in the logger
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Event 1"], @"%@", self.loggerMock);

    //  check the second event/ first revenue
    AIActivityPackage *revenuePackage = (AIActivityPackage *) self.packageHandlerMock.packageQueue[2];

    //   check the revenue path
    XCTAssert([revenuePackage.path isEqualToString:@"/revenue"], @"%@", revenuePackage.extendedString);

    //   check the revenue suffix
    //    note that the amount was rounded to the decimal cents
    XCTAssert([revenuePackage.suffix isEqualToString:@" (0.0 cent)"], @"%@", revenuePackage.extendedString);

    NSDictionary *revenuePackageParameters = revenuePackage.parameters;

    //   check the event count in the package parameters
    XCTAssertEqual(2, [(NSString *)revenuePackageParameters[@"event_count"] intValue], @"%@", revenuePackage.extendedString);

    //   check the amount, transforming cents into rounded decimal cents
    //    note that the 4.45 cents ~> 45 decimal cents
    XCTAssertEqual(0, [(NSString *)revenuePackageParameters[@"amount"] intValue], @"%@", revenuePackage.extendedString);

    //   check that the event token is nil
    XCTAssertNil(revenuePackageParameters[@"event_token"], @"%@", revenuePackage.extendedString);

    //   check the that the parameters were not injected
    XCTAssertNil(eventPackageParameters[@"params"], @"%@", eventPackage.extendedString);

    //   check that the package handler was called
    XCTAssert([self.loggerMock containsMessage:AILogLevelTest beginsWith:@"AIPackageHandler sendFirstPackage"], @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:AILogLevelVerbose beginsWith:@"Wrote activity state: ec:2"], @"%@", self.loggerMock);

    //   check the event count in the logger
    XCTAssert([self.loggerMock containsMessage:AILogLevelDebug beginsWith:@"Event 2 (revenue)"], @"%@", self.loggerMock);

}

- (void)testChecks {
    //  reseting to make the test order independent
    [self reset];

    //  activity handler without app token
    id<AIActivityHandler> nilActivityHandler = [AIAdjustFactory activityHandlerWithAppToken:nil];

    // trigger the nil app token a 2nd time for a subsession start
    [nilActivityHandler trackSubsessionStart];

    //  trigger the nil app token a 3rd time for a subsession end
    [nilActivityHandler trackSubsessionStart];

    //  trigger the nil app token a 4th time for a event
    [nilActivityHandler trackEvent:@"ab123" withParameters:nil];

    //  trigger the nil app token a 5th time for a revenue
    [nilActivityHandler trackRevenue:0 forEvent:@"abc123" withParameters:nil];

    [NSThread sleepForTimeInterval:1];
    //  activity with invalid app token
    id<AIActivityHandler> invalidActivityHandler = [AIAdjustFactory activityHandlerWithAppToken:@"12345678901"];

    [NSThread sleepForTimeInterval:1];
    //  activity with valid app token
    id<AIActivityHandler> activityHandler = [AIAdjustFactory activityHandlerWithAppToken:@"123456789012"];

    //  track event with nil token
    [activityHandler trackEvent:nil withParameters:nil];

    //  track event with invalid token
    [activityHandler trackEvent:@"abc1234" withParameters:nil];

    //  track revenue with invalid amount token
    [activityHandler trackRevenue:-0.1 forEvent:nil withParameters:nil];

    //  track revenue with invalid token
    [activityHandler trackRevenue:0 forEvent:@"abc12" withParameters:nil];

    [NSThread sleepForTimeInterval:1];

    //  check missing app token messages
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Missing App Token"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Missing App Token"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Missing App Token"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Missing App Token"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Missing App Token"],  @"%@", self.loggerMock);

    //  check the invalid app token message
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Malformed App Token '12345678901'"],  @"%@", self.loggerMock);

    //  check the nil event token
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Missing Event Token"],  @"%@", self.loggerMock);

    //  check the invalid event token
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Malformed Event Token 'abc1234'"],  @"%@", self.loggerMock);

    //  check the invalid revenue amount token
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Invalid amount -0.1"],  @"%@", self.loggerMock);

    //  check the invalid revenue token
    XCTAssert([self.loggerMock containsMessage:AILogLevelError beginsWith:@"Malformed Event Token 'abc12'"],  @"%@", self.loggerMock);

}

@end

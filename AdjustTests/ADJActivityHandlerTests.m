//
//  ADJActivityHandlerTests.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ADJLoggerMock.h"
#import "ADJPackageHandlerMock.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"
#import "ADJActivityPackage.h"
#import "ADJTestsUtil.h"
#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJAttributionHandlerMock.h"
#import "ADJConfig.h"
#import "ADJDelegateTest.h"

@interface ADJActivityHandlerTests : XCTestCase

@property (atomic,strong) ADJLoggerMock *loggerMock;
@property (atomic,strong) ADJPackageHandlerMock *packageHandlerMock;
@property (atomic,strong) ADJAttributionHandlerMock *attributionHandlerMock;

@end

@implementation ADJActivityHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    [ADJAdjustFactory setPackageHandler:nil];
    [ADJAdjustFactory setLogger:nil];
    [ADJAdjustFactory setSessionInterval:-1];
    [ADJAdjustFactory setSubsessionInterval:-1];
    [ADJAdjustFactory setAttributionHandler:nil];
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[ADJLoggerMock alloc] init];
    [ADJAdjustFactory setLogger:self.loggerMock];

    self.packageHandlerMock = [ADJPackageHandlerMock alloc];
    [ADJAdjustFactory setPackageHandler:self.packageHandlerMock];

    [ADJAdjustFactory setSessionInterval:-1];
    [ADJAdjustFactory setSubsessionInterval:-1];

    self.attributionHandlerMock = [ADJAttributionHandlerMock alloc];
    [ADJAdjustFactory setAttributionHandler:self.attributionHandlerMock];

    // starting from a clean slate
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoAttribution" logger:self.loggerMock], @"%@", self.loggerMock);
}

- (void)testFirstRun
{
    //  reseting to make the test order independent
    [self reset];

    //  deleting the activity state file to simulate a first session
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoAttribution" logger:self.loggerMock], @"%@", self.loggerMock);

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    //  set the delegate that to be called at after sending the package
    ADJDelegateTest * delegateTests = [[ADJDelegateTest alloc] init];
    [config setDelegate:delegateTests];

    //  create handler and start the first session
    [ADJActivityHandler handlerWithConfig:config];

    // it's necessary to sleep the activity for a while after each handler call
    //  to let the internal queue act
    [NSThread sleepForTimeInterval:2.0];

    // check environment level
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelAssert beginsWith:@"SANDBOX: Adjust will run in Sandbox mode. Use this setting for testing. Don't forget to set the environment to ADJEnvironmentProduction before publishing!"],
              @"%@", self.loggerMock);

    // check default log level
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJLogger setLogLevel: 3"],
              @"%@", self.loggerMock);

    //  test that the attribution file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Attribution file not found"],
              @"%@", self.loggerMock);

    //  test that the activity state file did not exist in the first run of the application
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Activity state file not found"],
              @"%@", self.loggerMock);

    // Handler initializations
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler initWithActivityHandler"],
              @"%@", self.loggerMock);

    //  when a session package is being sent the package handler should resume sending
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler resumeSending"],
              @"%@", self.loggerMock);

    //  if the package was build, it was sent to the Package Handler
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler addPackage"], @"%@", self.loggerMock);

    // checking the default values of the first session package
    //  should only have one package
    XCTAssertEqual((NSUInteger)1, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    ADJActivityPackage *activityPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[0];

    //  check the Sdk version is being tested
    XCTAssertEqual(@"ios4.2.4", activityPackage.clientSdk, @"%@", activityPackage.extendedString);

    // check the server url
    XCTAssertEqual(@"https://app.adjust.com", ADJUtil.baseUrl);

    //   package path should be of session
    XCTAssertEqual(@"/session", activityPackage.path, @"%@", activityPackage.extendedString);

    // testing the activity kind is the correct one
    ADJActivityKind sessionActivityKind = activityPackage.activityKind;
    XCTAssertEqual(ADJActivityKindSession, sessionActivityKind, @"%@", activityPackage.extendedString);

    // suffix should be empty
    XCTAssertEqual(@"", activityPackage.suffix, @"%@", activityPackage.extendedString);

    NSDictionary *parameters = activityPackage.parameters;

    // test attributes
    //  app token
    XCTAssertEqual(@"123456789012", parameters[@"app_token"], @"%@", activityPackage.extendedString);

    //   created at
    XCTAssertNotNil((NSString *)parameters[@"created_at"], @"%@", activityPackage.extendedString);

    //   device name
    XCTAssertNotNil((NSString *)parameters[@"device_name"], @"%@", activityPackage.extendedString);

    //   device type
    XCTAssertNotNil((NSString *)parameters[@"device_type"], @"%@", activityPackage.extendedString);

    //  environment
    XCTAssertEqual(@"sandbox", parameters[@"environment"], @"%@", activityPackage.extendedString);

    //   idfa
    XCTAssertNotNil((NSString *)parameters[@"idfa"], @"%@", activityPackage.extendedString);

    //   vendorId
    XCTAssertNotNil((NSString *)parameters[@"idfv"], @"%@", activityPackage.extendedString);

    //  uuid
    XCTAssertNotNil((NSString *)parameters[@"ios_uuid"], @"%@", activityPackage.extendedString);

    //  language
    XCTAssertNotNil((NSString *)parameters[@"language"], @"%@", activityPackage.extendedString);

    //  mac md5
    XCTAssertNotNil((NSString *)parameters[@"mac_md5"], @"%@", activityPackage.extendedString);

    //  mac sha1
    XCTAssertNotNil((NSString *)parameters[@"mac_sha1"], @"%@", activityPackage.extendedString);

    //  has delegate
    XCTAssertEqual(1, [(NSString *)parameters[@"needs_attribution_data"] intValue], @"%@", activityPackage.extendedString);

    //  os name
    XCTAssertEqual(@"ios", parameters[@"os_name"], @"%@", activityPackage.extendedString);

    //  os version
    XCTAssertNotNil((NSString *)parameters[@"os_version"], @"%@", activityPackage.extendedString);

    //  tracking enabled
    XCTAssertNotNil((NSString *)parameters[@"tracking_enabled"], @"%@", activityPackage.extendedString);

    // TODO later check: bundle_id, app_version, country, mobile_country_code, mobile_network_code

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
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendFirstPackage"],
        @"%@", self.loggerMock);

    //  check that the package handler calls back with the json dict response
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJAttributionHandlerMock initWithActivityHandler"],
              @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJAttributionHandlerMock checkAttribution"],
              @"%@", self.loggerMock);

    // check that the activity state is written by the first session or timer
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: "], @"%@", self.loggerMock);
}

- (void)testSessions {

    //  reseting to make the test order independent
    [self reset];

    //  starting from a clean slate
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoActivityState" logger:self.loggerMock], @"%@", self.loggerMock);
    XCTAssert([ADJTestsUtil deleteFile:@"AdjustIoAttribution" logger:self.loggerMock], @"%@", self.loggerMock);

    //  adjust the intervals for testing
    [ADJAdjustFactory setSessionInterval:(2)]; // 2 seconds
    [ADJAdjustFactory setSubsessionInterval:(0.1)]; // 0.1 second

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentProduction];

    //  set the delegate that doesn't implement the optional selector
    ADJTestsUtil * delegateNotImpl = [[ADJTestsUtil alloc] init];
    [config setDelegate:delegateNotImpl];
    
    // set default tracker
    [config setDefaultTracker:@"default1234tracker"];

    // set macMd5 disabled
    [config setMacMd5TrackingEnabled:NO];

    //  create handler and start the first session
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    //  wait enough to be a new subsession, but not a new session
    [NSThread sleepForTimeInterval:1.5];
    [activityHandler trackSubsessionStart];

    //  wait enough to be a new session
    [NSThread sleepForTimeInterval:4];
    [activityHandler trackSubsessionStart];

    //  test the subsession end
    [activityHandler trackSubsessionEnd];
    [NSThread sleepForTimeInterval:1];

    // check environment level
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelAssert beginsWith:@"PRODUCTION: Adjust will run in Production mode. Use this setting only for the build that you want to publish. Set the environment to ADJEnvironmentSandbox if you want to test your app!"], @"%@", self.loggerMock);

    // check error from the delegate that does not implement the optional selector
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Delegate does not implement AdjustDelegate"],
              @"%@", self.loggerMock);

    // check production log level
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJLogger setLogLevel: 6"],
              @"%@", self.loggerMock);

    // check mac md5 was disabled
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Tracking of macMd5 is disabled"],
              @"%@", self.loggerMock);

    // check default tracker
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Default tracker: default1234tracker"],
              @"%@", self.loggerMock);

    //  check that a new subsession was created
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Processed Subsession 2 of Session 1"],
              @"%@", self.loggerMock);

    //  check that the package handler was paused
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler pauseSending"],
              @"%@", self.loggerMock);

    //  check that 2 packages were added to the package handler
    XCTAssertEqual((NSUInteger)2, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    //  get the second session package and its parameters
    ADJActivityPackage *activityPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[1];
    NSDictionary *parameters = activityPackage.parameters;

    //  the session and subsession count should be 2
    //   session_count
    XCTAssertEqual(2, [(NSString *)parameters[@"session_count"] intValue], @"%@", activityPackage.extendedString);

    //   subsession_count
    XCTAssertEqual(2, [(NSString *)parameters[@"subsession_count"] intValue], @"%@", activityPackage.extendedString);

    //   mac md5 was never added
    XCTAssertNil((NSString *)parameters[@"mac_md5"], @"%@", activityPackage.extendedString);
    
    // default_tracker
    XCTAssertEqual((NSString *)parameters[@"default_tracker"], @"default1234tracker");
}

- (void)testEventsBuffered {

    //  reseting to make the test order independent
    [self reset];

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // set event buffering enable
    [config setEventBufferingEnabled:YES];

    // set verbose log level
    [config setLogLevel:ADJLogLevelVerbose];

    //  create handler and start the first session
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    // create the first Event object
    ADJEvent * firstEvent = [ADJEvent eventWithEventToken:@"event1"];

    // add callback parameters
    [firstEvent addCallbackParameter:@"keyCall" value:@"valueCall"];
    [firstEvent addCallbackParameter:@"keyCall" value:@"valueCall2"];
    [firstEvent addCallbackParameter:@"fooCall" value:@"barCall"];

    // add partner paramters
    [firstEvent addPartnerParameter:@"keyPartner" value:@"valuePartner"];
    [firstEvent addPartnerParameter:@"keyPartner" value:@"valuePartner2"];
    [firstEvent addPartnerParameter:@"fooPartner" value:@"barPartner"];

    // add revenue
    [firstEvent setRevenue:0.0001 currency:@"EUR"];

    // set transaction id
    [firstEvent setReceipt:[[NSData alloc] init] transactionId:@"t_id_1"];

    // track the first event
    [activityHandler trackEvent:firstEvent];

    [NSThread sleepForTimeInterval:2];

    // create a second Event object
    ADJEvent * secondEvent = [ADJEvent eventWithEventToken:@"event2"];

    // set the same id
    [secondEvent setTransactionId:@"t_id_1"];

    // track the second event
    [activityHandler trackEvent:secondEvent];

    [NSThread sleepForTimeInterval:2];

    // create a third Event object
    ADJEvent * thirdEvent = [ADJEvent eventWithEventToken:@"event3"];

    // add revenue
    [thirdEvent setRevenue:0 currency:@"USD"];

    // add receipt information
    [thirdEvent setReceipt:[@"{ \"transaction-id\" = \"t_id_2\"; }" dataUsingEncoding:NSUTF8StringEncoding] transactionId:@"t_id_2"];

    // track the third event
    [activityHandler trackEvent:thirdEvent];

    [NSThread sleepForTimeInterval:2];

    // create a forth Event object
    ADJEvent * forthEvent = [ADJEvent eventWithEventToken:@"event4"];

    // track the forth event
    [activityHandler trackEvent:forthEvent];

    // check verbose log level
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJLogger setLogLevel: 1"],
              @"%@", self.loggerMock);

    //  check that event buffering is enabled
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Event buffering is enabled"], @"%@", self.loggerMock);

    // check warning of overwriting callback param
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelWarn beginsWith:@"key keyCall will be overwritten"], @"%@", self.loggerMock);

    // check warning of overwriting callback param
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelWarn beginsWith:@"key keyPartner will be overwritten"], @"%@", self.loggerMock);

    // check transaction ID
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Added transaction ID"], @"%@", self.loggerMock);

    //  check if the event was added to the package handler
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler addPackage"], @"%@", self.loggerMock);

    //  check that it was buffered
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Buffered event (0.0001 EUR, 'event1')"], @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: ec:1"],
              @"%@", self.loggerMock);

    // check transaction ID of the second event was found before
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Skipping duplicate transaction ID 't_id_1'"], @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose beginsWith:@"Found transaction ID in ("], @"%@", self.loggerMock);


    //  check if the third event was added to the package handler
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler addPackage"], @"%@", self.loggerMock);

    //  check that the third event was buffered
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Buffered event (0.0000 USD, 'event3')"], @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: ec:2"],
              @"%@", self.loggerMock);

    //  check if the forth event was added to the package handler
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler addPackage"], @"%@", self.loggerMock);

    //  check that the forth event was buffered
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Buffered event 'event4'"], @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: ec:3"],
              @"%@", self.loggerMock);


    //  check that the package builder added the session and the first package
    XCTAssertEqual((NSUInteger)4, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    //  check the first event
    ADJActivityPackage *firstEventPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[1];

    //   check the event path
    XCTAssert([firstEventPackage.path isEqualToString:@"/event"], @"%@", firstEventPackage.extendedString);

    // testing the activity kind is the correct one
    ADJActivityKind eventActivityKind = firstEventPackage.activityKind;
    XCTAssertEqual(ADJActivityKindEvent, eventActivityKind, @"%@", firstEventPackage.extendedString);

    //   check the event suffix
    XCTAssert([firstEventPackage.suffix isEqualToString:@" (0.0001 EUR, 'event1')"], @"%@", firstEventPackage.extendedString);

    NSDictionary *firstEventPackageParameters = firstEventPackage.parameters;

    //   check the event count in the package parameters
    XCTAssertEqual(1, [(NSString *)firstEventPackageParameters[@"event_count"] intValue], @"%@", firstEventPackage.extendedString);

    //   check the event token
    XCTAssert([(NSString *)firstEventPackageParameters[@"event_token"] isEqualToString:@"event1"], @"%@", firstEventPackage.extendedString);

    //   check the revenue and currency
    XCTAssert([(NSString *)firstEventPackageParameters[@"revenue"] isEqualToString:@"0.0001"], @"%@", firstEventPackage.extendedString);
    XCTAssert([(NSString *)firstEventPackageParameters[@"currency"] isEqualToString:@"EUR"], @"%@", firstEventPackage.extendedString);

    //   check the that the transaction id was not injected
    XCTAssert([(NSString *)firstEventPackageParameters[@"transaction_id"] isEqualToString:@"t_id_1"], @"%@", firstEventPackage.extendedString);

    //   check the injected parameters
    XCTAssert([(NSString *)firstEventPackageParameters[@"callback_params"] isEqualToString:@"{\"keyCall\":\"valueCall2\",\"fooCall\":\"barCall\"}"],
              @"%@", firstEventPackage.extendedString);

    XCTAssert([(NSString *)firstEventPackageParameters[@"partner_params"] isEqualToString:@"{\"keyPartner\":\"valuePartner2\",\"fooPartner\":\"barPartner\"}"],
              @"%@", firstEventPackage.extendedString);

    XCTAssert([(NSString *)firstEventPackageParameters[@"receipt"] isEqualToString:@"empty"], @"%@", firstEventPackage.extendedString);

    //  check the third event
    ADJActivityPackage *thirdEventPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[2];
    NSDictionary *thirdEventPackageParameters = thirdEventPackage.parameters;

    //   check the event suffix
    XCTAssert([thirdEventPackage.suffix isEqualToString:@" (0.0000 USD, 'event3')"], @"%@", thirdEventPackage.extendedString);

    //   check the event count in the package parameters
    XCTAssertEqual(2, [(NSString *)thirdEventPackageParameters[@"event_count"] intValue], @"%@", thirdEventPackage.extendedString);

    //   check the event token
    XCTAssert([(NSString *)thirdEventPackageParameters[@"event_token"] isEqualToString:@"event3"], @"%@", thirdEventPackage.extendedString);

    //   check the revenue and currency
    XCTAssert([(NSString *)thirdEventPackageParameters[@"revenue"] isEqualToString:@"0"], @"%@", thirdEventPackage.extendedString);
    XCTAssert([(NSString *)thirdEventPackageParameters[@"currency"] isEqualToString:@"USD"], @"%@", thirdEventPackage.extendedString);

    //   check the receipt and transaction_id
    XCTAssert([(NSString *)thirdEventPackageParameters[@"receipt"] isEqualToString:@"eyAidHJhbnNhY3Rpb24taWQiID0gInRfaWRfMiI7IH0="], @"%@", thirdEventPackage.extendedString);
    XCTAssert([(NSString *)thirdEventPackageParameters[@"transaction_id"] isEqualToString:@"t_id_2"], @"%@", thirdEventPackage.extendedString);

    //   check the that the parameters were not injected
    XCTAssertNil(thirdEventPackageParameters[@"callback_params"], @"%@", thirdEventPackage.extendedString);
    XCTAssertNil(thirdEventPackageParameters[@"partner_params"], @"%@", thirdEventPackage.extendedString);

    //  check the third event
    ADJActivityPackage *forthEventPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[3];
    NSDictionary *forthEventPackageParameters = forthEventPackage.parameters;

    //   check the event suffix
    XCTAssert([forthEventPackage.suffix isEqualToString:@" 'event4'"], @"%@", forthEventPackage.extendedString);

    //   check the event count in the package parameters
    XCTAssertEqual(3, [(NSString *)forthEventPackageParameters[@"event_count"] intValue], @"%@", forthEventPackage.extendedString);

    //   check the event token
    XCTAssert([(NSString *)forthEventPackageParameters[@"event_token"] isEqualToString:@"event4"], @"%@", forthEventPackage.extendedString);

    //   check the revenue and currency are not included
    XCTAssertNil(forthEventPackageParameters[@"revenue"], @"%@", forthEventPackage.extendedString);
    XCTAssertNil(forthEventPackageParameters[@"currency"], @"%@", forthEventPackage.extendedString);

    //   check the that the parameters were not injected
    XCTAssertNil(forthEventPackageParameters[@"callback_params"], @"%@", forthEventPackage.extendedString);
    XCTAssertNil(forthEventPackageParameters[@"partner_params"], @"%@", forthEventPackage.extendedString);

}

- (void)testEventsNotBuffered {

    //  reseting to make the test order independent
    [self reset];

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    //  create handler and start the first session
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    // test push token
    const char bytes[] = "\xFC\x07\x21\xB6\xDF\xAD\x5E\xE1\x10\x97\x5B\xB2\xA2\x63\xDE\x00\x61\xCC\x70\x5B\x4A\x85\xA8\xAE\x3C\xCF\xBE\x7A\x66\x2F\xB1\xAB";
    [activityHandler setDeviceToken:[NSData dataWithBytes:bytes length:(sizeof(bytes) - 1)]];

    [NSThread sleepForTimeInterval:2];

    // create the first Event object
    ADJEvent * firstEvent = [ADJEvent eventWithEventToken:@"event1"];

    // track the first event
    [activityHandler trackEvent:firstEvent];

    [NSThread sleepForTimeInterval:2];

    //   check that the package handler was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendFirstPackage"],
              @"%@", self.loggerMock);

    //   check the event count in the written activity state
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: ec:1"],
              @"%@", self.loggerMock);

    //  check that the package added the session and event
    XCTAssertEqual((NSUInteger)2, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    //  check the first event
    ADJActivityPackage *eventPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[1];

    //   check the event path
    XCTAssert([eventPackage.path isEqualToString:@"/event"], @"%@", eventPackage.extendedString);

    //   check the event suffix
    XCTAssert([eventPackage.suffix isEqualToString:@" 'event1'"], @"%@", eventPackage.extendedString);

    NSDictionary *eventPackageParameters = eventPackage.parameters;

    //   check the event count in the package parameters
    XCTAssertEqual(1, [(NSString *)eventPackageParameters[@"event_count"] intValue], @"%@", eventPackage.extendedString);

    //   check the event token
    XCTAssert([(NSString *)eventPackageParameters[@"event_token"] isEqualToString:@"event1"], @"%@", eventPackage.extendedString);

    //   check push token was correctly parsed
    XCTAssert([@"fc0721b6dfad5ee110975bb2a263de0061cc705b4a85a8ae3ccfbe7a662fb1ab" isEqualToString:eventPackageParameters[@"push_token"]], @"%@", eventPackage.extendedString);
}

- (void)testChecks {
    //  reseting to make the test order independent
    [self reset];

    // create the config with null app token
    ADJConfig * nilAppTokenConfig = [ADJConfig configWithAppToken:nil environment:ADJEnvironmentSandbox];
    XCTAssertNil(nilAppTokenConfig, @"%@", self.loggerMock);

    // create the config with size diferent than 12
    ADJConfig * sizeAppTokenConfig = [ADJConfig configWithAppToken:@"1234567890123" environment:ADJEnvironmentSandbox];
    XCTAssertNil(sizeAppTokenConfig, @"%@", self.loggerMock);

    // create the config with environment not standart
    ADJConfig * environmentConfig = [ADJConfig configWithAppToken:@"123456789012" environment:@"other"];
    XCTAssertNil(environmentConfig, @"%@", self.loggerMock);

    // activity handler created with a nil config
    id<ADJActivityHandler> nilConfigActivityHandler = [ADJActivityHandler handlerWithConfig:nil];
    XCTAssertNil(nilConfigActivityHandler, @"%@", self.loggerMock);

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    //  create handler and start the first session
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    // event with nil token
    ADJEvent * nilTokenEvent = [ADJEvent eventWithEventToken:nil];
    XCTAssertNil(nilTokenEvent, @"%@", self.loggerMock);

    // event with malformed token
    ADJEvent * malformedTokenEvent = [ADJEvent eventWithEventToken:@"event1x"];
    XCTAssertNil(malformedTokenEvent, @"%@", self.loggerMock);

    // create the first Event object
    ADJEvent * firstEvent = [ADJEvent eventWithEventToken:@"event1"];

    // invalid values
    [firstEvent addCallbackParameter:nil value:@"valueCall"];
    [firstEvent addCallbackParameter:@"" value:@"valueCall"];
    [firstEvent addCallbackParameter:@"keyCall" value:nil];
    [firstEvent addCallbackParameter:@"keyCall" value:@""];

    [firstEvent addPartnerParameter:nil value:@"valuePartner"];
    [firstEvent addPartnerParameter:@"" value:@"valuePartner"];
    [firstEvent addPartnerParameter:@"keyPartner" value:nil];
    [firstEvent addPartnerParameter:@"keyPartner" value:@""];

    [firstEvent setRevenue:0 currency:nil];
    [firstEvent setRevenue:0 currency:@""];
    [firstEvent setRevenue:-0.0001 currency:@"EUR"];

    [firstEvent setReceipt:[@"value" dataUsingEncoding:NSUTF8StringEncoding] transactionId:nil];

    [activityHandler trackEvent:firstEvent];

    [NSThread sleepForTimeInterval:2];

    // check null app token
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Missing App Token"],  @"%@", self.loggerMock);

    // check malformed app token
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Malformed App Token '1234567890123'"],  @"%@", self.loggerMock);

    // check malformed environment
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Malformed environment 'other'"],  @"%@", self.loggerMock);

    // check null config
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"AdjustConfig not initialized correctly"],  @"%@", self.loggerMock);

    // check parameters errors
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Callback parameter key is missing"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Callback parameter key is empty"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Callback parameter value is missing"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Callback parameter value is empty"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Partner parameter key is missing"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Partner parameter key is empty"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Partner parameter value is missing"],  @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Partner parameter value is empty"],  @"%@", self.loggerMock);

    // check currency is null
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Currency must be set with revenue"],  @"%@", self.loggerMock);

    // check currency is empty
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Currency is empty"],  @"%@", self.loggerMock);

    // check revenue is invalid
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Invalid amount -0.0001"],  @"%@", self.loggerMock);

    // check the receipt had a nil transaction id
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Missing transactionId"],  @"%@", self.loggerMock);

    //  check the first parameters
    ADJActivityPackage *firstEventPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[1];
    NSDictionary *firstEventPackageParameters = firstEventPackage.parameters;

    //   check the that none of the attributes were injected
    XCTAssertNil(firstEventPackageParameters[@"callback_params"], @"%@", firstEventPackage.extendedString);
    XCTAssertNil(firstEventPackageParameters[@"partner_params"], @"%@", firstEventPackage.extendedString);
    XCTAssertNil(firstEventPackageParameters[@"revenue"], @"%@", firstEventPackage.extendedString);
    XCTAssertNil(firstEventPackageParameters[@"currency"], @"%@", firstEventPackage.extendedString);
}

- (void)testDisable {

    //  reseting to make the test order independent
    [self reset];

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // set event buffering enable
    [config setEventBufferingEnabled:YES];

    //  create handler and start the first session
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    // verify the default value
    XCTAssert([activityHandler isEnabled], @"%@", self.loggerMock);

    [activityHandler setEnabled:NO];

    // check that the value is changed
    XCTAssertFalse([activityHandler isEnabled], @"%@", self.loggerMock);

    // create the first Event object
    ADJEvent * firstEvent = [ADJEvent eventWithEventToken:@"event1"];

    // track the first event
    [activityHandler trackEvent:firstEvent];

    [activityHandler trackSubsessionEnd];
    [activityHandler trackSubsessionStart];

    [NSThread sleepForTimeInterval:2];

    // verify the changed value after the activity handler is started
    XCTAssertFalse([activityHandler isEnabled], @"%@", self.loggerMock);

    // making sure the first session was sent
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler addPackage"], @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendFirstPackage"],
        @"%@", self.loggerMock);

    // verify that the application was paused
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler pauseSending"],
              @"%@", self.loggerMock);

    // making sure the timer fired did not call the package handler
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendFirstPackage"],
        @"%@", self.loggerMock);

    // test if the event was not triggered
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Buffered event 'event1'"], @"%@", self.loggerMock);

    // verify that the application was paused
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler pauseSending"],
        @"%@", self.loggerMock);

    //   check the event count is still 0 after pausing
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: ec:0"],
              @"%@", self.loggerMock);

    // verify that it was not resumed
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler resumeSending"],
        @"%@", self.loggerMock);

    // enable again
    [activityHandler setEnabled:YES];

    // verify value changed
    XCTAssert([activityHandler isEnabled], @"%@", self.loggerMock);

    [activityHandler trackEvent:firstEvent];
    [activityHandler trackSubsessionEnd];
    [activityHandler trackSubsessionStart];

    [NSThread sleepForTimeInterval:2];

    // check that the application was resumed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler resumeSending"],
              @"%@", self.loggerMock);

    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Processed Subsession 2 of Session 1"],
              @"%@", self.loggerMock);

    // check that the event was triggered
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Buffered event 'event1'"], @"%@", self.loggerMock);

    //   check the event count is increased
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: ec:1"],
              @"%@", self.loggerMock);

    // verify that the application was paused
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler pauseSending"],
        @"%@", self.loggerMock);

    // verify that it was also resumed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler resumeSending"],
        @"%@", self.loggerMock);
}

- (void)testOfflineMode {

    //  reseting to make the test order independent
    [self reset];

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // set event buffering enable
    [config setEventBufferingEnabled:YES];

    //  create handler and start the first session
    id<ADJActivityHandler> activityHandler = [ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    // making sure the first session was sent
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler addPackage"], @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendFirstPackage"],
              @"%@", self.loggerMock);

    // set offline mode on
    [activityHandler setOfflineMode:YES];

    // create the first Event object
    ADJEvent * firstEvent = [ADJEvent eventWithEventToken:@"event1"];

    // track the first event
    [activityHandler trackEvent:firstEvent];

    [NSThread sleepForTimeInterval:2];

    // verify that the application was paused
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler pauseSending"],
              @"%@", self.loggerMock);

    // check that offline mode was set on
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Pausing package handler to put in offline mode"],
              @"%@", self.loggerMock);

    // making sure the event event was added
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler addPackage"],
                   @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Buffered event 'event1'"], @"%@", self.loggerMock);
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Activity state: ec:1"],
              @"%@", self.loggerMock);

    // simulate session
    [activityHandler trackSubsessionEnd];
    [activityHandler trackSubsessionStart];

    [NSThread sleepForTimeInterval:2];

    // check that the package handler didn't resume sending due to the offline mode
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler resumeSending"],
              @"%@", self.loggerMock);

    // set offline mode off
    [activityHandler setOfflineMode:NO];

    [NSThread sleepForTimeInterval:2];

    // verify that the application was paused
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler resumeSending"],
              @"%@", self.loggerMock);

    // check that offline mode was set on
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelInfo beginsWith:@"Resuming package handler to put in online mode"],
              @"%@", self.loggerMock);
}

- (void)testClickPackage {

    // reseting to make the test order independent
    [self reset];

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    //  create handler and start the first session
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    NSString* emptyQueryString = @"AdjustTests://";
    NSString* emptyString = @"";
    NSString* single = @"AdjustTests://example.com/path/inApp?adjust_foo";
    NSString* prefix = @"AdjustTests://example.com/path/inApp?adjust_=bar";
    NSString* incomplete = @"AdjustTests://example.com/path/inApp?adjust_foo=";

    [activityHandler appWillOpenUrl:[NSURL URLWithString:emptyQueryString]];
    [activityHandler appWillOpenUrl:[NSURL URLWithString:emptyString]];
    [activityHandler appWillOpenUrl:[NSURL URLWithString:single]];
    [activityHandler appWillOpenUrl:[NSURL URLWithString:prefix]];
    [activityHandler appWillOpenUrl:[NSURL URLWithString:incomplete]];

    [NSThread sleepForTimeInterval:2];

    // test if the deep link was not triggered
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJAttributionHandlerMock getAttribution"], @"%@", self.loggerMock);
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendClickPackage"], @"%@", self.loggerMock);

    // 1 session
    XCTAssertEqual((NSUInteger)1, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    NSString* normal = @"AdjustTests://example.com/path/inApp?adjust_tracker=trackerValue&other=stuff&adjust_foo=bar&adjust_key=value&adjust_campaign=campaignValue&adjust_adgroup=adgroupValue&adjust_creative=creativeValue";
    [activityHandler appWillOpenUrl:[NSURL URLWithString:normal]];

    NSDate * date = [NSDate date];

    // should be ignored
    [activityHandler setIadDate:nil withPurchaseDate:nil];
    [activityHandler setIadDate:nil withPurchaseDate:date];

    [NSThread sleepForTimeInterval:2];

    // check that the deep link tried to get a new attribution
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJAttributionHandlerMock getAttribution"], @"%@", self.loggerMock);

    // check that the deep link send a click package
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJPackageHandler sendClickPackage"], @"%@", self.loggerMock);

    // 1 session + 1 deep link
    XCTAssertEqual((NSUInteger)2, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    // check that the normal url was parsed and sent
    ADJActivityPackage *deeplinkPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[1];
    NSDictionary *deeplinkParameters = deeplinkPackage.parameters;

    // packageType should be click
    XCTAssertEqual(@"/sdk_click", deeplinkPackage.path, @"%@", deeplinkPackage.extendedString);

    // testing the activity kind is the correct one
    ADJActivityKind activityKind = deeplinkPackage.activityKind;
    XCTAssertEqual(ADJActivityKindClick, activityKind, @"%@", deeplinkPackage.extendedString);

    // suffix should be empty
    XCTAssertEqual(@"", deeplinkPackage.suffix, @"%@", deeplinkPackage.extendedString);

    // check that it contains the source
    XCTAssert([(NSString *)deeplinkParameters[@"source"] isEqualToString:@"deeplink"], @"%@", deeplinkPackage.description);

    // check that deep link parameters contains the 2 keys
    XCTAssert([(NSString *)deeplinkParameters[@"params"] isEqualToString:@"{\"foo\":\"bar\",\"key\":\"value\"}"],
              @"%@", deeplinkPackage.description);

    // check that deep link parameters contains attribution information
    XCTAssert([(NSString *)deeplinkParameters[@"tracker"] isEqualToString:@"trackerValue"], @"%@", deeplinkPackage.description);
    XCTAssert([(NSString *)deeplinkParameters[@"campaign"] isEqualToString:@"campaignValue"], @"%@", deeplinkPackage.description);
    XCTAssert([(NSString *)deeplinkParameters[@"adgroup"] isEqualToString:@"adgroupValue"], @"%@", deeplinkPackage.description);
    XCTAssert([(NSString *)deeplinkParameters[@"creative"] isEqualToString:@"creativeValue"], @"%@", deeplinkPackage.description);

    // check that it contains click time
    XCTAssertNotNil(deeplinkParameters[@"click_time"], @"%@", deeplinkPackage.description);

    // check that it does not contain purchase time
    XCTAssertNil(deeplinkParameters[@"purchase_time"], @"%@", deeplinkPackage.description);

    NSDate * secondDate = [NSDate date];

    [activityHandler setIadDate:date withPurchaseDate:secondDate];
    [activityHandler setIadDate:secondDate withPurchaseDate:nil];

    [NSThread sleepForTimeInterval:2];

    // 1 session + 1 deep link + 2 iad
    XCTAssertEqual((NSUInteger)4, [self.packageHandlerMock.packageQueue count], @"%@", self.loggerMock);

    // first iad package
    ADJActivityPackage *firstIadPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[2];
    NSDictionary *firstIadParameters = firstIadPackage.parameters;

    // check that it contains the source
    XCTAssert([(NSString *)firstIadParameters[@"source"] isEqualToString:@"iad"], @"%@", firstIadPackage.description);

    // test that the click time is the same passed
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z"];
    NSString * firstDateString = [dateFormat stringFromDate:date];
    XCTAssert([firstDateString isEqualToString:firstIadParameters[@"click_time"]], @"%@", firstIadPackage.description);

    // test that the purchase time is the same passed
    NSString * secondDateString = [dateFormat stringFromDate:secondDate];
    XCTAssert([secondDateString isEqualToString:firstIadParameters[@"purchase_time"]], @"%@", firstIadPackage.description);

    // check that it does not contain params or attribution information
    XCTAssertNil(firstIadParameters[@"params"], @"%@", firstIadPackage.description);
    XCTAssertNil(firstIadParameters[@"tracker"], @"%@", firstIadPackage.description);
    XCTAssertNil(firstIadParameters[@"campaign"], @"%@", firstIadPackage.description);
    XCTAssertNil(firstIadParameters[@"adgroup"], @"%@", firstIadPackage.description);
    XCTAssertNil(firstIadParameters[@"creative"], @"%@", firstIadPackage.description);

    // second iad package
    ADJActivityPackage *secondIadPackage = (ADJActivityPackage *) self.packageHandlerMock.packageQueue[3];
    NSDictionary *secondIadParameters = secondIadPackage.parameters;

    // check that it contains the source
    XCTAssert([(NSString *)secondIadParameters[@"source"] isEqualToString:@"iad"], @"%@", secondIadPackage.description);

    // test that the click time is the same passed
    XCTAssert([secondDateString isEqualToString:secondIadParameters[@"click_time"]], @"%@", secondIadPackage.description);

    // check that it does not contain purchase time
    XCTAssertNil(secondIadParameters[@"purchase_time"], @"%@", deeplinkPackage.description);
}

- (void)testConversions {
    // check the logLevel conversions
    XCTAssertEqual(ADJLogLevelVerbose, [ADJLogger LogLevelFromString:@"verbose"]);
    XCTAssertEqual(ADJLogLevelDebug, [ADJLogger LogLevelFromString:@"debug"]);
    XCTAssertEqual(ADJLogLevelInfo, [ADJLogger LogLevelFromString:@"info"]);
    XCTAssertEqual(ADJLogLevelWarn, [ADJLogger LogLevelFromString:@"warn"]);
    XCTAssertEqual(ADJLogLevelError, [ADJLogger LogLevelFromString:@"error"]);
    XCTAssertEqual(ADJLogLevelAssert, [ADJLogger LogLevelFromString:@"assert"]);

    // testing the conversion from activity kind to string
    XCTAssertEqual(@"session", ADJActivityKindToString(ADJActivityKindSession));
    XCTAssertEqual(@"event", ADJActivityKindToString(ADJActivityKindEvent));
    XCTAssertEqual(@"click", ADJActivityKindToString(ADJActivityKindClick));
    XCTAssertEqual(@"unknown", ADJActivityKindToString(ADJActivityKindUnknown));
    XCTAssertEqual(@"unknown", ADJActivityKindToString(3)); // old value for ADJRevenueKindClick

    // testing the conversion from string to activity kind
    XCTAssertEqual(ADJActivityKindSession, ADJActivityKindFromString(@"session"));
    XCTAssertEqual(ADJActivityKindEvent, ADJActivityKindFromString(@"event"));
    XCTAssertEqual(ADJActivityKindClick, ADJActivityKindFromString(@"click"));
    XCTAssertEqual(ADJActivityKindUnknown, ADJActivityKindFromString(@"revenue")); // old value for ADJRevenueKindClick
}

- (void)testfinishedTrackingWithResponse {

    // reseting to make the test order independent
    [self reset];

    // create the config to start the session
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    NSMutableDictionary * jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"testfinishedTrackingWithResponse://" forKey:@"deeplink"];

    [activityHandler finishedTrackingWithResponse:jsonDictionary];

    [NSThread sleepForTimeInterval:2];

    //  check the deep link from the response
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Unable to open deep link (testfinishedTrackingWithResponse://)"],
              @"%@", self.loggerMock);

    //  check that send the dict to the attribution handler
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJAttributionHandlerMock checkAttribution, jsonDict: {\n    deeplink = \"testfinishedTrackingWithResponse://\";\n}"],
              @"%@", self.loggerMock);
}

- (void)testAttribution {

    // reseting to make the test order independent
    [self reset];

    // create the config
    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    // set delegate to see attribution launched
    ADJDelegateTest * delegateTests = [[ADJDelegateTest alloc] init];
    [config setDelegate:delegateTests];

    // start the session
    id<ADJActivityHandler> activityHandler =[ADJActivityHandler handlerWithConfig:config];

    [NSThread sleepForTimeInterval:2];

    [activityHandler setAskingAttribution:YES];

    // check that it wrote setAskingAttribution 1
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Activity state: ec:0 sc:1 ssc:1 ask:1"], @"%@", self.loggerMock);

    // check that shouldGetAttribution is NO after first session
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest
                                    beginsWith:@"ADJAttributionHandlerMock getAttribution"], @"%@", self.loggerMock);

    // try to update nil attribution
    BOOL attributeUpdatedNil = [activityHandler updateAttribution:nil];

    // check nil attribution does not update
    XCTAssertFalse(attributeUpdatedNil, @"%@", self.loggerMock);

    // check that it did not write a new Attribute
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Wrote Attribution"], @"%@", self.loggerMock);

    // build initial json dict
    NSMutableDictionary * jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"trackerNameValue" forKey:@"tracker_name"];
    [jsonDictionary setObject:@"trackerTokenValue" forKey:@"tracker_token"];
    [jsonDictionary setObject:@"networkValue" forKey:@"network"];
    [jsonDictionary setObject:@"campaignValue" forKey:@"campaign"];
    [jsonDictionary setObject:@"adgroupValue" forKey:@"adgroup"];
    [jsonDictionary setObject:@"creativeValue" forKey:@"creative"];
    [jsonDictionary setObject:@"clickLabelValue" forKey:@"click_label"];

    // build, update attribution and launch it to delegate
    ADJAttribution * attribution = [[ADJAttribution alloc] initWithJsonDict:jsonDictionary];
    BOOL attributeUpdatedNew = [activityHandler updateAttribution:attribution];

    // check new attribution updates
    XCTAssert(attributeUpdatedNew, @"%@", self.loggerMock);

    //  check the first attribution is written
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Attribution: tt:trackerTokenValue tn:trackerNameValue net:networkValue cam:campaignValue adg:adgroupValue cre:creativeValue lab:clickLabelValue"], @"%@", self.loggerMock);

    // change values of the same attribution
    attribution.trackerName  = @"trackerNameValueNew";
    attribution.trackerToken = @"trackerTokenValueNew";
    attribution.network      = @"networkValueNew";
    attribution.campaign     = @"campaignValueNew";
    attribution.adgroup      = @"adgroupValueNew";
    attribution.creative     = @"creativeValueNew";
    attribution.clickLabel   = @"clickLabelValueNew";

    // update it and launch delegate
    BOOL attributeUpdatedNewValues = [activityHandler updateAttribution:attribution];

    // check new attribution values updates
    XCTAssert(attributeUpdatedNewValues, @"%@", self.loggerMock);

    //  check the second attribution is written
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Attribution: tt:trackerTokenValueNew tn:trackerNameValueNew net:networkValueNew cam:campaignValueNew adg:adgroupValueNew cre:creativeValueNew lab:clickLabelValueNew"], @"%@", self.loggerMock);

    // build a json dictionary equal to the updated Attribution
    NSMutableDictionary * newJsonDictionary = [[NSMutableDictionary alloc] init];
    [newJsonDictionary setObject:@"trackerNameValueNew" forKey:@"tracker_name"];
    [newJsonDictionary setObject:@"trackerTokenValueNew" forKey:@"tracker_token"];
    [newJsonDictionary setObject:@"networkValueNew" forKey:@"network"];
    [newJsonDictionary setObject:@"campaignValueNew" forKey:@"campaign"];
    [newJsonDictionary setObject:@"adgroupValueNew" forKey:@"adgroup"];
    [newJsonDictionary setObject:@"creativeValueNew" forKey:@"creative"];
    [newJsonDictionary setObject:@"clickLabelValueNew" forKey:@"click_label"];

    // build, update attribution and launch new attribution to delegate
    ADJAttribution * newAttribution = [[ADJAttribution alloc] initWithJsonDict:newJsonDictionary];
    BOOL attributeUpdatedSameNewValues = [activityHandler updateAttribution:newAttribution];

    // check same attribution values does not update
    XCTAssertFalse(attributeUpdatedSameNewValues, @"%@", self.loggerMock);

    //  check the same attribution is not written again
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Attribution: tt:trackerTokenValueNew tn:trackerNameValueNew net:networkValueNew cam:campaignValueNew adg:adgroupValueNew cre:creativeValueNew lab:clickLabelValueNew"], @"%@", self.loggerMock);


    [activityHandler setAskingAttribution:NO];

    // check that it wrote setAskingAttribution 0
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Activity state: ec:0 sc:1 ssc:1 ask:0"], @"%@", self.loggerMock);

    // try to start a new session with
    [activityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2];


    // check that shouldGetAttribution is NO after first session
    // with attribution saved and setAskingAttribution 0
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest
                                         beginsWith:@"ADJAttributionHandlerMock getAttribution"], @"%@", self.loggerMock);

    // start a new session
    [activityHandler trackSubsessionEnd];
    [NSThread sleepForTimeInterval:1];
    id<ADJActivityHandler> newActivityHandler =[ADJActivityHandler handlerWithConfig:config];
    [NSThread sleepForTimeInterval:2];

    // check that setAskingAttribution is 0
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Activity state: ec:0 sc:1 ssc:3 ask:0"], @"%@", self.loggerMock);

    // check that when attribution is set and setAskingAttribution is 0, it doesn't get attribution
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest
                                         beginsWith:@"ADJAttributionHandlerMock getAttribution"], @"%@", self.loggerMock);

    BOOL attributeUpdatedSameNewValuesRestart = [newActivityHandler updateAttribution:newAttribution];

    // check same attribution value after restart
    XCTAssertFalse(attributeUpdatedSameNewValuesRestart, @"%@", self.loggerMock);

    //  check the same attribution is not written again
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelDebug
                                         beginsWith:@"Wrote Attribution"], @"%@", self.loggerMock);

    attribution = [[ADJAttribution alloc] initWithJsonDict:jsonDictionary];

    BOOL attributeUpdatedNewValuesRestart = [newActivityHandler updateAttribution:attribution];

    // check new attribution back after restart
    XCTAssert(attributeUpdatedNewValuesRestart, @"%@", self.loggerMock);

    // check new attribution after restart
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Attribution: tt:trackerTokenValue tn:trackerNameValue net:networkValue cam:campaignValue adg:adgroupValue cre:creativeValue lab:clickLabelValue"], @"%@", self.loggerMock);

    [newActivityHandler setAskingAttribution:YES];

    // check that setAskingAttribution is 1
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug
                                    beginsWith:@"Wrote Activity state: ec:0 sc:1 ssc:3 ask:1"], @"%@", self.loggerMock);

    [newActivityHandler trackSubsessionStart];
    [NSThread sleepForTimeInterval:2];

    // check that when attribution is set and setAskingAttribution is 1,
    // and getAttribution wasn't reset by sending a session, it will try to get an Attribution
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest
                                         beginsWith:@"ADJAttributionHandlerMock getAttribution"], @"%@", self.loggerMock);
}

@end

//
//  ADJAttributionHandlerTests.m
//  adjust
//
//  Created by Pedro Filipe on 12/12/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "ADJAdjustFactory.h"
#import "ADJLoggerMock.h"
#import "NSURLConnection+NSURLConnectionSynchronousLoadingMocking.h"
#import "ADJTestsUtil.h"
#import "ADJActivityHandlerMock.h"
#import "ADJAttributionHandlerMock.h"
#import "ADJAttributionHandler.h"
#import "ADJPackageHandlerMock.h"
#import "ADJUtil.h"

@interface ADJAttributionHandlerTests : XCTestCase

@property (atomic,strong) ADJLoggerMock *loggerMock;
@property (atomic,strong) ADJActivityHandlerMock *activityHandlerMock;
@property (atomic,strong) ADJActivityPackage * attributionPackage;

@end

@implementation ADJAttributionHandlerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    [ADJAdjustFactory setLogger:nil];

    // Put teardown code here; it will be run once, after the last test case.
    [NSURLConnection setConnectionError:NO];
    [ADJAdjustFactory setPackageHandler:nil];
    [ADJAdjustFactory setAttributionHandler:nil];

    [super tearDown];
}

- (void)reset {
    self.loggerMock = [[ADJLoggerMock alloc] init];
    [ADJAdjustFactory setLogger:self.loggerMock];

    ADJConfig * config = [ADJConfig configWithAppToken:@"123456789012" environment:ADJEnvironmentSandbox];

    self.activityHandlerMock = [[ADJActivityHandlerMock alloc] initWithConfig:config];
    self.attributionPackage = [self getAttributionPackage:config];
}

- (ADJActivityPackage *)getAttributionPackage:(ADJConfig *)config {
    ADJAttributionHandlerMock * attributionHandlerMock = [ADJAttributionHandlerMock alloc];

    ADJPackageHandlerMock * packageHandlerMock = [ADJPackageHandlerMock alloc];
    [ADJAdjustFactory setPackageHandler:packageHandlerMock];

    [ADJAdjustFactory setSessionInterval:-1];
    [ADJAdjustFactory setSubsessionInterval:-1];

    [ADJAdjustFactory setAttributionHandler:attributionHandlerMock];

    [ADJActivityHandler handlerWithConfig:config];
    [NSThread sleepForTimeInterval:2.0];

    [self.loggerMock reset];

    return attributionHandlerMock.attributionPackage;
}


- (void) testGetCheckAttributionNoAskInUpdate {
    [self checkGetCheckAttributionNoAskIn:YES];
}

- (void) testGetCheckAttributionNoAskInNoUpdate {
    [self checkGetCheckAttributionNoAskIn:NO];
}

- (void) checkGetCheckAttributionNoAskIn:(BOOL)update {

    //  reseting to make the test order independent
    [self reset];

    if (update) {
        [self.activityHandlerMock setUpdatedAttribution:YES];
    }

    id<ADJAttributionHandler> attributionHandler =
    [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock withMaxDelay:nil withAttributionPackage:self.attributionPackage];

    [NSURLConnection setResponse:0];

    [attributionHandler getAttribution];

    [NSThread sleepForTimeInterval:3.0];

    // TODO check attribution package

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
                                    beginsWith:@"status code 200 for attribution response: {\"attribution\":{\"tracker_token\":\"trackerTokenValue\",\"tracker_name\":\"trackerNameValue\",\"network\":\"networkValue\",\"campaign\":\"campaignValue\",\"adgroup\":\"adgroupValue\",\"creative\":\"creativeValue\",\"click_label\":\"clickLabelValue\"},\"message\":\"response OK\",\"deeplink\":\"testApp://\"}"],
              @"%@", self.loggerMock);

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"response OK"],
              @"%@", self.loggerMock);

    // check that called updateAttribution with Attribution
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler updateAttribution"],
              @"%@", self.loggerMock);

    if (update) {
        // check that did launch delegate
        XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler launchAttributionDelegate"],
                       @"%@", self.loggerMock);

    } else {
        // check that did not launch delegate
        XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler launchAttributionDelegate"],
                       @"%@", self.loggerMock);
    }

    // check the attribution sent to activity handler
    NSMutableDictionary * jsonDictionary = [[NSMutableDictionary alloc] init];
    [jsonDictionary setObject:@"trackerNameValue" forKey:@"tracker_name"];
    [jsonDictionary setObject:@"trackerTokenValue" forKey:@"tracker_token"];
    [jsonDictionary setObject:@"networkValue" forKey:@"network"];
    [jsonDictionary setObject:@"campaignValue" forKey:@"campaign"];
    [jsonDictionary setObject:@"adgroupValue" forKey:@"adgroup"];
    [jsonDictionary setObject:@"creativeValue" forKey:@"creative"];
    [jsonDictionary setObject:@"clickLabelValue" forKey:@"click_label"];

    ADJAttribution * attribution = [[ADJAttribution alloc] initWithJsonDict:jsonDictionary];

    XCTAssert([attribution isEqual:self.activityHandlerMock.attributionUpdated], @"%@", self.activityHandlerMock.attributionUpdated);


    // check that set asking attribution NO
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler setAskingAttribution: 0"],
              @"%@", self.loggerMock);
}

-(void) testAskInConnectionError {
    //  reseting to make the test order independent
    [self reset];

    id<ADJAttributionHandler> attributionHandler =
    [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock withMaxDelay:nil withAttributionPackage:self.attributionPackage];

    [NSURLConnection setConnectionError:YES];

    NSDictionary *jsonDict = [ADJUtil buildJsonDict:@"{\"attribution\":{\"tracker_token\":\"trackerTokenValue\",\"tracker_name\":\"trackerNameValue\",\"network\":\"networkValue\",\"campaign\":\"campaignValue\",\"adgroup\":\"adgroupValue\",\"creative\":\"creativeValue\",\"click_label\":\"clickLabelValue\"},\"ask_in\":0,\"message\":\"response OK\",\"deeplink\":\"testApp://\"}"];

    [attributionHandler checkAttribution:jsonDict];

    [NSThread sleepForTimeInterval:2.0];

    // check that did not call updateAttribution with Attribution
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler updateAttribution"],
              @"%@", self.loggerMock);


    // check that set asking attribution YES
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler setAskingAttribution: 1"],
              @"%@", self.loggerMock);

    // check to see it's going to wait
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Waiting to query attribution in 0 milliseconds"],
              @"%@", self.loggerMock);

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check that the package was successfully sent
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Failed to get attribution. (connection error)"],
              @"%@", self.loggerMock);
}

-(void) testGetResponseError {
    //  reseting to make the test order independent
    [self reset];

    id<ADJAttributionHandler> attributionHandler =
    [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock withMaxDelay:nil withAttributionPackage:self.attributionPackage];

    [NSURLConnection setResponse:1];

    [attributionHandler getAttribution];

    [NSThread sleepForTimeInterval:3.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
                                    beginsWith:@"status code 0 for attribution response: {\"message\":\"response error\"}"],
              @"%@", self.loggerMock);

    //  check that the error message
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"response error"],
              @"%@", self.loggerMock);

    // check that called updateAttribution with Attribution
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler updateAttribution"],
              @"%@", self.loggerMock);

    // check that set asking attribution NO
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler setAskingAttribution: 0"],
              @"%@", self.loggerMock);
}

-(void) testCheckUpdatedAskInResponseNil {

    [self reset];

    id<ADJAttributionHandler> attributionHandler =
    [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock withMaxDelay:nil withAttributionPackage:self.attributionPackage];

    [NSURLConnection setResponse:2];

    [attributionHandler getAttribution];

    [NSThread sleepForTimeInterval:3.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
                                    beginsWith:@"status code 0 for attribution response: server response"],
              @"%@", self.loggerMock);

    //  check the error message
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"Failed to parse json attribution response: server response"],
              @"%@", self.loggerMock);
}

// get with response empty
-(void) testGetResponseEmpty {
    [self reset];

    id<ADJAttributionHandler> attributionHandler =
    [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock withMaxDelay:nil withAttributionPackage:self.attributionPackage];

    [NSURLConnection setResponse:3];

    [attributionHandler getAttribution];

    [NSThread sleepForTimeInterval:3.0];

    //  check the URL Connection was called
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    //  check the response was verbosed
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelVerbose
                                    beginsWith:@"status code 0 for attribution response: {}"],
              @"%@", self.loggerMock);

    //  check the error message
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelError beginsWith:@"No message found"],
              @"%@", self.loggerMock);

    // check that called updateAttribution with Attribution
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler updateAttribution"],
              @"%@", self.loggerMock);

    // check that set asking attribution NO
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler setAskingAttribution: 0"],
              @"%@", self.loggerMock);
}

-(void) testCancelTimer {

    [self reset];

    id<ADJAttributionHandler> attributionHandler =
    [ADJAttributionHandler handlerWithActivityHandler:self.activityHandlerMock withMaxDelay:nil withAttributionPackage:self.attributionPackage];

    [NSURLConnection setConnectionError:YES];

    NSString * jsonString = @"{\"attribution\":{\"tracker_token\":\"trackerTokenValue\",\"tracker_name\":\"trackerNameValue\",\"network\":\"networkValue\",\"campaign\":\"campaignValue\",\"adgroup\":\"adgroupValue\",\"creative\":\"creativeValue\",\"click_label\":\"clickLabelValue\"},\"message\":\"response OK\",\"ask_in\":\"5000\"}";

    NSDictionary * jsonDict = [ADJUtil buildJsonDict:jsonString];

    [attributionHandler checkAttribution:jsonDict];

    [NSThread sleepForTimeInterval:1.0];

    // check that set asking attribution YES
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"ADJActivityHandler setAskingAttribution: 1"],
              @"%@", self.loggerMock);

    // check to see it's going to wait
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelDebug beginsWith:@"Waiting to query attribution in 5000 milliseconds"],
              @"%@", self.loggerMock);

    //  check the URL Connection not was called
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);

    // getAttribution
    [attributionHandler getAttribution];

    [NSThread sleepForTimeInterval:5.0];

    //  check the URL Connection was called only once
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
                   @"%@", self.loggerMock);

    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
                   @"%@", self.loggerMock);

    // check another attribution and get in 5 seconds
    [attributionHandler checkAttribution:jsonDict];

    [NSThread sleepForTimeInterval:4.0];

    //  check the URL Connection was not called after 4 seconds
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
                   @"%@", self.loggerMock);

    // process another attribution and reset to wait 5 more seconds
    [attributionHandler checkAttribution:jsonDict];

    [NSThread sleepForTimeInterval:4.0];

    //  check the URL Connection was not called after 8 seconds
    //  from the first, but only 4 from the second
    XCTAssertFalse([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
                   @"%@", self.loggerMock);

    [NSThread sleepForTimeInterval:2.0];

    //  check the URL Connection was called for the last check
    XCTAssert([self.loggerMock containsMessage:ADJLogLevelTest beginsWith:@"NSURLConnection sendSynchronousRequest"],
              @"%@", self.loggerMock);



}


@end


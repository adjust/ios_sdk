//
//  AIResponseData.h
//  Adjust
//
//  Created by Christian Wellenbrock on 07.02.14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIActivityKind.h"

@class AIActivityPackage;

/*
 * Information about the result of a tracking attempt
 *
 * Will be passed to the delegate function adjustFinishedTrackingWithResponse:
 */
@interface AIResponseData : NSObject

#pragma mark set by SDK

// the kind of activity (AIActivityKindSession etc.)
// see the AIActivityKind definition
@property (nonatomic, assign) AIActivityKind activityKind;

// true when the activity was tracked successfully
// might be true even if response could not be parsed
@property (nonatomic, assign) BOOL success;

// true if the server was not reachable and the request will be tried again later
@property (nonatomic, assign) BOOL willRetry;

#pragma mark set by server or SDK
// nil if activity was tracked successfully and response could be parsed
// might be not nil even when activity was tracked successfully
@property (nonatomic, copy) NSString *error;

#pragma mark returned by server
// the following attributes are only set when error is nil
// (when activity was tracked successfully and response could be parsed)

// tracker token of current device
@property (nonatomic, copy) NSString *trackerToken;

// tracker name of current device
@property (nonatomic, copy) NSString *trackerName;

// tracker network
@property (nonatomic, copy) NSString *network;

// tracker campaign
@property (nonatomic, copy) NSString *campaign;

// tracker adgroup
@property (nonatomic, copy) NSString *adgroup;

// tracker creative
@property (nonatomic, copy) NSString *creative;


// returns human readable version of activityKind
// (session, event, revenue), see above
- (NSString *)activityKindString;

// returns a NSDictonary representation
- (NSDictionary *)dictionary;


#pragma mark internals

+ (AIResponseData *)dataWithJsonDict:(NSDictionary *)jsonDict jsonString:(NSString *)jsonString;
+ (AIResponseData *)dataWithError:(NSString *)error;

- (id)initWithJsonDict:(NSDictionary *)jsonDict jsonString:(NSString *)jsonString;
- (id)initWithError:(NSString *)error;

@end

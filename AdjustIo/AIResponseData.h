//
//  AIResponseData.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 07.02.14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIActivityKind.h"

@class AIActivityPackage;

/*
 * Information about the result of a tracking attempt
 *
 * Will be passed to the delegate function adjustIoFinishedTrackingWithResponse:
 */
@interface AIResponseData : NSObject

#pragma mark set by SDK

// the kind of activity (AIActivityKindSession etc.)
// see the AIActivity definition above
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

+ (AIResponseData *)dataWithJsonString:(NSString *)string;
+ (AIResponseData *)dataWithError:(NSString *)error;

- (id)initWithJsonString:(NSString *)string;
- (id)initWithError:(NSString *)error;

// returns human readable version of activityKind
// (session, event, revenue), see above
- (NSString *)activityKindString;



@end

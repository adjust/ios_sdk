//
//  AIResponseData.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 07.02.14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

typedef enum {
    AIActivityKindUnknown = 0,
    AIActivityKindSession = 1,
    AIActivityKindEvent   = 2,
    AIActivityKindRevenue = 3,

    // only possible when server could be reached because the SDK can't know
    // whether or not a session might be an install or reattribution
    AIActivityKindInstall       = 4,
    AIActivityKindReattribution = 5,
} AIActivityKind;


@class AIActivityPackage;

/*
 * Information about the result of a tracking attempt
 *
 * Will be passed to the delegate function adjustIoTrackedActivityWithResponse
 */
@interface AIResponseData : NSObject

// the kind of activity (install, session, event, etc.)
// see the AIActivity definition above
@property (nonatomic, assign) AIActivityKind activityKind;

// true when the activity was tracked successfully
// might be true even if response could not be parsed
@property (nonatomic, assign) BOOL success;

// true if the server was not reachable and the request will be tried again later
@property (nonatomic, assign) BOOL willRetry;

// nil if activity was tracked successfully and response could be parsed
// might be not nil even when activity was tracked successfully
@property (nonatomic, copy) NSString *error;

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

@end

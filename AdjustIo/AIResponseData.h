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


@interface AIResponseData : NSObject

@property (nonatomic, assign) AIActivityKind activityKind;

@property (nonatomic, copy) NSString *trackerToken;
@property (nonatomic, copy) NSString *trackerName;
@property (nonatomic, copy) NSString *error;

+ (AIResponseData *)dataWithJsonString:(NSString *)string;

- (id)initWithJsonString:(NSString *)string;

@end

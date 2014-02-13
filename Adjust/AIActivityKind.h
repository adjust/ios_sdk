//
//  AIActivityKind.h
//  Adjust
//
//  Created by Christian Wellenbrock on 11.02.14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AIActivityKindUnknown = 0,
    AIActivityKindSession = 1,
    AIActivityKindEvent   = 2,
    AIActivityKindRevenue = 3,
} AIActivityKind;

AIActivityKind AIActivityKindFromString(NSString *string);
NSString* AIActivityKindToString(AIActivityKind activityKind);

//
//  ADJActivityKind.h
//  Adjust
//
//  Created by Christian Wellenbrock on 11.02.14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ADJActivityKindUnknown       = 0,
    ADJActivityKindSession       = 1,
    ADJActivityKindEvent         = 2,
//    ADJActivityKindRevenue       = 3,
    ADJActivityKindClick         = 4,
} ADJActivityKind;

ADJActivityKind ADJActivityKindFromString(NSString *string);
NSString* ADJActivityKindToString(ADJActivityKind activityKind);

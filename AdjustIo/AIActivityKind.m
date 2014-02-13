//
//  AIActivityKind.m
//  Adjust
//
//  Created by Christian Wellenbrock on 11.02.14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIActivityKind.h"

AIActivityKind AIActivityKindFromString(NSString *string) {
    if ([@"session" isEqualToString:string]) {
        return AIActivityKindSession;
    } else if ([@"event" isEqualToString:string]) {
        return AIActivityKindEvent;
    } else if ([@"revenue" isEqualToString:string]) {
        return AIActivityKindRevenue;
    } else {
        return AIActivityKindUnknown;
    }
}

NSString* AIActivityKindToString(AIActivityKind activityKind) {
    switch (activityKind) {
        case AIActivityKindSession: return @"session"; break;
        case AIActivityKindEvent:   return @"event";   break;
        case AIActivityKindRevenue: return @"revenue"; break;
        case AIActivityKindUnknown: return @"unknown"; break;
    }
}

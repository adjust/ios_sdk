//
//  AIActivityKind.m
//  Adjust
//
//  Created by Christian Wellenbrock on 11.02.14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIActivityKind.h"

AIActivityKind AIActivityKindFromString(NSString *string) {
    if ([@"session" isEqualToString:string]) {
        return AIActivityKindSession;
    } else if ([@"event" isEqualToString:string]) {
        return AIActivityKindEvent;
    } else if ([@"revenue" isEqualToString:string]) {
        return AIActivityKindRevenue;
    } else if ([@"reattribution" isEqualToString:string]) {
        return AIActivityKindReattribution;
    } else {
        return AIActivityKindUnknown;
    }
}

NSString* AIActivityKindToString(AIActivityKind activityKind) {
    switch (activityKind) {
        case AIActivityKindSession:       return @"session";
        case AIActivityKindEvent:         return @"event";
        case AIActivityKindRevenue:       return @"revenue";
        case AIActivityKindReattribution: return @"reattribution";
        case AIActivityKindUnknown:       return @"unknown";
    }
}

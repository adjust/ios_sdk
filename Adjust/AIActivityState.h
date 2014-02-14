//
//  AIActivityState.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adeven. All rights reserved.
//
#import <Foundation/Foundation.h>

@class AIPackageBuilder;

@interface AIActivityState : NSObject <NSCoding>

// persistent data
@property (nonatomic, copy) NSString *uuid;

// global counters
@property (nonatomic, assign) int eventCount;
@property (nonatomic, assign) int sessionCount;

// session attributes
@property (nonatomic, assign) int subsessionCount;
@property (nonatomic, assign) double sessionLength; // all durations in seconds
@property (nonatomic, assign) double timeSpent;
@property (nonatomic, assign) double lastActivity;  // all times in seconds since 1970
@property (nonatomic, assign) double createdAt;

// not persisted, only injected
@property (nonatomic, assign) double lastInterval;

- (void)resetSessionAttributes:(double)now;

- (void)injectSessionAttributes:(AIPackageBuilder *)packageBilder;
- (void)injectEventAttributes:(AIPackageBuilder *)packageBilder;

@end

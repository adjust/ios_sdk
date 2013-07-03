//
//  AISessionState.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 02.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AISessionState : NSObject <NSCoding>

// global counters
@property (nonatomic, assign) int eventCount;
@property (nonatomic, assign) int sessionCount;

// session attributes
@property (nonatomic, assign) int subsessionCount;
@property (nonatomic, assign) double sessionLength; // all durations in seconds
@property (nonatomic, assign) double timeSpent;
@property (nonatomic, assign) double createdAt;     // all times in seconds since 1970
@property (nonatomic, assign) double lastActivity;
@property (nonatomic, assign) double lastInterval;  // not persisted because volatile

- (void)startNextSession:(long)now;
// TODO: injectors

@end

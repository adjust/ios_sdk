//
//  AETimer.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 02.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AETimer.h"

@interface AETimer() {
    dispatch_source_t source;
    BOOL suspended;
}

@end

@implementation AETimer

+ (AETimer *)timerWithInterval:(uint64_t)interval
                        leeway:(uint64_t)leeway
                         queue:(dispatch_queue_t)queue
                         block:(dispatch_block_t)block
{
    return [[AETimer alloc] initWithInterval:interval leeway:leeway queue:queue block:block];
}

- (id)initWithInterval:(uint64_t)interval
                leeway:(uint64_t)leeway
                 queue:(dispatch_queue_t)queue
                 block:(dispatch_block_t)block
{
    self = [super init];
    if (self == nil) return nil;

    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (source != nil) {
        dispatch_source_set_timer(source, dispatch_walltime(NULL, 0), interval, leeway);
        dispatch_source_set_event_handler(source, block);
    }
    suspended = YES;

    return self;
}

- (void)resume {
    if (!suspended) return;

    dispatch_resume(source);
    suspended = NO;
}

- (void)suspend {
    if (suspended) return;

    dispatch_suspend(source);
    suspended = YES;
}

@end

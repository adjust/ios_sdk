//
//  ADJTimer.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJTimer.h"

static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second

#pragma mark - private
@interface ADJTimer()

@property (nonatomic) dispatch_source_t source;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic, assign) BOOL suspended;
@property (nonatomic, assign, readonly) dispatch_time_t start;
@property (nonatomic, assign) dispatch_time_t interval;
@property (nonatomic, retain) NSDate * fireDate;
@property (nonatomic, copy) dispatch_block_t block;

@end

#pragma mark -
@implementation ADJTimer

+ (ADJTimer *)timerWithBlock:(dispatch_block_t)block
                       queue:(dispatch_queue_t)queue
                   startTime:(NSTimeInterval)startTime
                intervalTime:(NSTimeInterval)intervalTime
{
    return [[ADJTimer alloc] initBlock:block queue:queue startTime:startTime intervalTime:intervalTime];
}

+ (ADJTimer *)timerWithBlock:(dispatch_block_t)block
                       queue:(dispatch_queue_t)queue
{
    return [[ADJTimer alloc] initBlock:block queue:queue];
}

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
      startTime:(NSTimeInterval)startTime
   intervalTime:(NSTimeInterval)intervalTime
{
    self = [super init];
    if (self == nil) return nil;

    self.block = block;
    self.queue = queue;

    self.startTime = startTime;

    if (intervalTime > 0) {
        self.interval = intervalTime * NSEC_PER_SEC;
    } else {
        self.interval = DISPATCH_TIME_FOREVER;
    }

    [self buildSource];
    self.suspended = YES;

    return self;
}

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
{
    return [self initBlock:block queue:queue startTime:0 intervalTime:0];
}

- (void)resume {
    if (!self.suspended) return;

    [self buildSource];

    if (self.interval == DISPATCH_TIME_FOREVER) {
        self.fireDate = [[NSDate date] initWithTimeIntervalSinceNow:self.startTime];
    }

    dispatch_resume(self.source);
    self.suspended = NO;
}

- (void)suspend {
    if (self.suspended) return;

    if (self.interval == DISPATCH_TIME_FOREVER) {
        self.startTime = [self fireIn];
    }

    dispatch_suspend(self.source);
    self.suspended = YES;
}

- (void)cancel {
    dispatch_source_cancel(self.source);
    self.source = nil;
    self.suspended = YES;
    self.fireDate = nil;
}

- (NSTimeInterval)fireIn {
    if (self.fireDate == nil) {
        return 0;
    }
    return [self.fireDate timeIntervalSinceNow];
}

- (void)setStartTime:(NSTimeInterval)startTime {
    if (startTime < 0) {
        _startTime = 0;
        return;
    }
    _startTime = startTime;
}

- (dispatch_time_t)start {
    return dispatch_walltime(NULL, self.startTime * NSEC_PER_SEC);
}


- (void)buildSource {
    if (self.source != nil) { return; }

    self.source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);

    dispatch_source_set_timer(self.source,
                              self.start,
                              self.interval,
                              kTimerLeeway);

    dispatch_source_set_event_handler(self.source, self.block);
}

@end

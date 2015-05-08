//
//  ADJTimer.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface ADJTimer : NSObject

@property (nonatomic, assign) NSTimeInterval startTime;

+ (ADJTimer *)timerWithBlock:(dispatch_block_t)block
                       queue:(dispatch_queue_t)queue
                   startTime:(NSTimeInterval)startTime
                intervalTime:(NSTimeInterval)intervalTime;

+ (ADJTimer *)timerWithBlock:(dispatch_block_t)block
                       queue:(dispatch_queue_t)queue;

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue
      startTime:(NSTimeInterval)startTime
   intervalTime:(NSTimeInterval)intervalTime;

- (id)initBlock:(dispatch_block_t)block
          queue:(dispatch_queue_t)queue;

- (void)resume;
- (void)suspend;
- (void)cancel;
- (NSTimeInterval)fireIn;
@end

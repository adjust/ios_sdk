//
//  ADJTimer.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface ADJTimer : NSObject

+ (ADJTimer *)timerWithInterval:(uint64_t)interval
                         leeway:(uint64_t)leeway
                          queue:(dispatch_queue_t)queue
                          block:(dispatch_block_t)block;

+ (ADJTimer *)timerWithStart:(uint64_t)start
                      leeway:(uint64_t)leeway
                       queue:(dispatch_queue_t)queue
                       block:(dispatch_block_t)block;

- (id)initWithInterval:(uint64_t)interval
                leeway:(uint64_t)leeway
                 queue:(dispatch_queue_t)queue
                 block:(dispatch_block_t)block;

- (id)initWithStart:(uint64_t)start
             leeway:(uint64_t)leeway
              queue:(dispatch_queue_t)queue
              block:(dispatch_block_t)block;

- (void)resume;
- (void)suspend;
- (void)cancel;

@end

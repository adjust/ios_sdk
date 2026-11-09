//
//  ADJAdjustFactoryTests.m
//  AdjustUnitTests
//
//  Copyright © 2026-Present Adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../../Adjust/ADJLogger.h"
#import "../../Adjust/Internal/ADJAdjustFactory.h"

@interface ADJAdjustFactoryTests : XCTestCase
@end

@implementation ADJAdjustFactoryTests

- (void)setUp {
    [super setUp];
    [ADJAdjustFactory teardown:NO];
}

- (void)tearDown {
    [ADJAdjustFactory teardown:NO];
    [super tearDown];
}

/// Verify that multiple concurrent calls to the logger only create a single instances
///
/// This is testing a thread safety issue that depends on thread timing,
/// running multiple times increases the likelihood of encountering the failure
- (void)testConcurrentLazyInitializationCreatesSingleLogger {
    for (NSUInteger round = 0; round < 100; round++) {
        // Reset the factory's state prior to running the concurrency test
        [ADJAdjustFactory teardown:NO];
        NSMutableSet *loggers = [NSMutableSet set];
        [self runConcurrently:^(NSUInteger iteration) {
            id logger = (id)[ADJAdjustFactory logger] ?: [NSNull null];
            @synchronized (loggers) {
                [loggers addObject:logger];
            }
        }];

        // The logger should return a non-nil instance
        XCTAssertFalse([loggers containsObject:[NSNull null]],
                       @"Round %lu: logger was nil", (unsigned long)round);
        // Only one logger should be created
        XCTAssertEqual(loggers.count, 1u,
                       @"Round %lu: expected a single shared logger, got %lu instances",
                       (unsigned long)round, (unsigned long)loggers.count);
        if (loggers.count != 1) {
            // The test condition failed, so return immediately
            return;
        }
    }
}

- (void)runConcurrently:(void (^)(NSUInteger iteration))block {
    dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
    dispatch_group_t group = dispatch_group_create();
    for (NSUInteger i = 0; i < 64; i++) {
        dispatch_group_async(group, queue, ^{
            block(i);
        });
    }
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

@end

//
//  AIPackageHandler.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 03.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIPackageHandler.h"
#import "AIActivityPackage.h"
#import "AILogger.h"

static NSString * const kPackageQueueFilename = @"PackageQueue1"; // TODO: rename
static const char * const kInternalQueueName = "io.adjust.PackageQueue1"; // TODO: rename

#pragma mark private interface

@interface AIPackageHandler()

@property (nonatomic, retain) dispatch_queue_t internalQueue;
@property (nonatomic, retain) NSMutableArray *packageQueue;

- (void)initInternal;
- (void)addInternal:(AIActivityPackage *)package;
- (void)readPackageQueue;
- (void)writePackageQueue;
- (NSString *)packageQueueFilename;

@end


@implementation AIPackageHandler

#pragma mark public implementation

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    dispatch_async(self.internalQueue, ^{
        [self initInternal];
    });

    return self;
}

- (void)addPackage:(AIActivityPackage *)package {
    dispatch_async(self.internalQueue, ^{
        [self addInternal:package];
    });
}

- (void)sendFirstPackage {
    NSLog(@"sendFirstPackage");
}

- (void)sendNextPackage {
    NSLog(@"sendNextPackage");
}

- (void)closeFirstPackage {
    NSLog(@"closeFirstPackage");
}

- (void)pauseSending {
    NSLog(@"pauseSending");
}

- (void)resumeSending {
    NSLog(@"resumeSending");
}


#pragma marke private implementation

- (void)initInternal {
    [self readPackageQueue];
}

- (void)addInternal:(AIActivityPackage *)newPackage {
    [self.packageQueue addObject:newPackage];
    [AILogger debug:@"Added package %d (%@)", self.packageQueue.count, newPackage];
    [AILogger verbose:@"%@", newPackage.parameterString];

    [self writePackageQueue];
}

- (void)readPackageQueue {
    @try {
        NSString *filename = [self packageQueueFilename];
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if ([object isKindOfClass:[NSArray class]]) {
            // TODO: check class of packages?
            self.packageQueue = object;
            NSLog(@"Package handler read %d packages", self.packageQueue.count);
            return;
        } else {
            NSLog(@"Failed to read package queue");
        }
    } @catch (NSException *ex ) {
        NSLog(@"Failed to read package queue (%@)", ex);
    }

    // start with a fresh package queue in case of any exception
    self.packageQueue = [NSMutableArray array];
}

- (void)writePackageQueue {
    NSString *filename = [self packageQueueFilename];
    BOOL result = [NSKeyedArchiver archiveRootObject:self.packageQueue toFile:filename];
    if (result == YES) {
        NSLog(@"Package handler wrote %d packages", self.packageQueue.count);
    } else {
        NSLog(@"Failed to write package queue");
    }
}

- (NSString *)packageQueueFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:kPackageQueueFilename];
    return filename;
}

@end

//
//  AIPackageHandlerMock.m
//  AdjustIo
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//
#import "AILoggerMock.h"
#import "AIPackageHandlerMock.h"
#import "AIAdjustIoFactory.h"

static NSString * const prefix = @"AIPackageHandler ";

@interface AIPackageHandlerMock()

@property (nonatomic, retain) AILoggerMock *testLogger;
@property (nonatomic, copy) NSMutableArray *packageQueue;

@end

@implementation AIPackageHandlerMock

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    self.testLogger = [[AILoggerMock alloc] init];
    self.packageQueue = [NSMutableArray array];
    
    return self;
}

- (void)addPackage:(AIActivityPackage *)package {
    [self.testLogger test:[prefix stringByAppendingString:@"addPackage"]];
    [self.packageQueue addObject:package];
}

- (void)sendFirstPackage {
    [self.testLogger test:[prefix stringByAppendingString:@"sendFirstPackage"]];
}

- (void)sendNextPackage {
    [self.testLogger test:[prefix stringByAppendingString:@"sendNextPackage"]];
}

- (void)closeFirstPackage {
    [self.testLogger test:[prefix stringByAppendingString:@"closeFirstPackage"]];
}

- (void)pauseSending {
    [self.testLogger test:[prefix stringByAppendingString:@"pauseSending"]];
}

- (void)resumeSending {
    [self.testLogger test:[prefix stringByAppendingString:@"resumeSending"]];
}

@end

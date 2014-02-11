//
//  AIPackageHandlerMock.m
//  AdjustIo
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIPackageHandlerMock.h"
#import "AILoggerMock.h"
#import "AIAdjustIoFactory.h"

static NSString * const prefix = @"AIPackageHandler ";

@interface AIPackageHandlerMock()

@property (nonatomic, strong) AILoggerMock *loggerMock;
@property (nonatomic, copy) NSMutableArray *packageQueue;
@property (nonatomic, assign) id<AIActivityHandler> activityHandler;

@end

@implementation AIPackageHandlerMock

- (id)initWithActivityHandler:(id<AIActivityHandler>)activityHandler {
    self = [super init];
    if (self == nil) return nil;
    
    self.activityHandler = activityHandler;
    
    self.loggerMock = (AILoggerMock *) [AIAdjustIoFactory logger];
    self.packageQueue = [NSMutableArray array];
    
    [self.loggerMock test:[prefix stringByAppendingString:@"initWithActivityHandler"]];
    
    return self;
}

- (void)addPackage:(AIActivityPackage *)package {
    [self.loggerMock test:[prefix stringByAppendingString:@"addPackage"]];
    [self.packageQueue addObject:package];
}

- (void)sendFirstPackage {
    [self.loggerMock test:[prefix stringByAppendingString:@"sendFirstPackage"]];
}

- (void)sendNextPackage {
    [self.loggerMock test:[prefix stringByAppendingString:@"sendNextPackage"]];
}

- (void)closeFirstPackage {
    [self.loggerMock test:[prefix stringByAppendingString:@"closeFirstPackage"]];
}

- (void)pauseSending {
    [self.loggerMock test:[prefix stringByAppendingString:@"pauseSending"]];
}

- (void)resumeSending {
    [self.loggerMock test:[prefix stringByAppendingString:@"resumeSending"]];
}

- (void)finishedTrackingActivity:(AIActivityPackage *)activityPackage withResponse:(AIResponseData *)response {
    [self.loggerMock test:[prefix stringByAppendingString:@"finishedTrackingActivity"]];
}

@end

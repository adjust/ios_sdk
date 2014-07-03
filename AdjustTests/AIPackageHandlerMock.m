//
//  AIPackageHandlerMock.m
//  Adjust
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIPackageHandlerMock.h"
#import "AILoggerMock.h"
#import "AIAdjustFactory.h"
#import "AIActivityHandler.h"
#import "AIResponseData.h"

static NSString * const prefix = @"AIPackageHandler ";

@interface AIPackageHandlerMock()

@property (nonatomic, strong) AILoggerMock *loggerMock;
@property (nonatomic, assign) id<AIActivityHandler> activityHandler;

@end

@implementation AIPackageHandlerMock

- (id)init {
    return [self initWithActivityHandler:nil];
}

- (id)initWithActivityHandler:(id<AIActivityHandler>)activityHandler {
    self = [super init];
    if (self == nil) return nil;

    self.activityHandler = activityHandler;

    self.loggerMock = (AILoggerMock *) AIAdjustFactory.logger;
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
    [self.activityHandler finishedTrackingWithResponse:[[AIResponseData alloc] init]];
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
    self.responseData = response;
}

@end

//
//  AIPackageHandlerMock.m
//  Adjust
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIPackageHandlerMock.h"
#import "AILoggerMock.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityHandler.h"

static NSString * const prefix = @"AIPackageHandler ";

@interface AIPackageHandlerMock()

@property (nonatomic, strong) AILoggerMock *loggerMock;
@property (nonatomic, assign) id<ADJActivityHandler> activityHandler;

@end

@implementation AIPackageHandlerMock

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler {
    self = [super init];
    if (self == nil) return nil;

    self.activityHandler = activityHandler;

    self.loggerMock = (AILoggerMock *) ADJAdjustFactory.logger;
    self.packageQueue = [NSMutableArray array];

    [self.loggerMock test:[prefix stringByAppendingString:@"initWithActivityHandler"]];

    return self;
}

- (void)addPackage:(ADJActivityPackage *)package {
    [self.loggerMock test:[prefix stringByAppendingString:@"addPackage"]];
    [self.packageQueue addObject:package];
}

- (void)sendFirstPackage {
    [self.loggerMock test:[prefix stringByAppendingString:@"sendFirstPackage"]];
    [self.activityHandler finishedTrackingWithResponse:self.jsonDict];
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

- (void)finishedTrackingActivity:(NSDictionary *)jsonDict {
    [self.loggerMock test:[prefix stringByAppendingString:@"finishedTrackingActivity"]];
    self.jsonDict = jsonDict;
}

- (void)sendClickPackage:(ADJActivityPackage *) clickPackage {
    [self.loggerMock test:[prefix stringByAppendingString:@"sendClickPackage"]];
}

@end

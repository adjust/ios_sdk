//
//  ADJTrackingSucceededDelegate.m
//  adjust
//
//  Created by Pedro Filipe on 22/01/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJTrackingSucceededDelegate.h"
#import "ADJLoggerMock.h"
#import "ADJAdjustFactory.h"

static NSString * const prefix = @"ADJTrackingSucceededDelegate ";

@interface ADJTrackingSucceededDelegate()

@property (nonatomic, strong) ADJLoggerMock *loggerMock;

@end

@implementation ADJTrackingSucceededDelegate

- (id) init {
    self = [super init];
    if (self == nil) return nil;

    self.loggerMock = (ADJLoggerMock *) [ADJAdjustFactory logger];

    [self.loggerMock test:[prefix stringByAppendingFormat:@"init"]];

    return self;
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"adjustSessionTrackingSucceeded, %@", sessionSuccessResponseData]];
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"adjustEventTrackingSucceeded, %@", eventSuccessResponseData]];
}
@end

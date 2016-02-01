//
//  ADJTrackingFailedDelegate.m
//  adjust
//
//  Created by Pedro Filipe on 22/01/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJTrackingFailedDelegate.h"
#import "ADJLoggerMock.h"
#import "ADJAdjustFactory.h"

static NSString * const prefix = @"ADJTrackingFailedDelegate ";

@interface ADJTrackingFailedDelegate()

@property (nonatomic, strong) ADJLoggerMock *loggerMock;

@end

@implementation ADJTrackingFailedDelegate

- (id) init {
    self = [super init];
    if (self == nil) return nil;

    self.loggerMock = (ADJLoggerMock *) [ADJAdjustFactory logger];

    [self.loggerMock test:[prefix stringByAppendingFormat:@"init"]];

    return self;
}

- (void)adjustTrackingFailed:(ADJFailureResponseData *)failureResponseData {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"adjustTrackingFailed, %@", failureResponseData]];
}

@end

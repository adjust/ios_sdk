//
//  AIRequestHandlerMock.m
//  Adjust
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIRequestHandlerMock.h"
#import "AILoggerMock.h"
#import "ADJAdjustFactory.h"

static NSString * const prefix = @"AIRequestHandler ";

@interface AIRequestHandlerMock()

@property (nonatomic, assign) id<ADJPackageHandler> packageHandler;
@property (nonatomic, assign) AILoggerMock *loggerMock;

@end

@implementation AIRequestHandlerMock

- (id)initWithPackageHandler:(id<ADJPackageHandler>) packageHandler {
    self = [super init];
    if (self == nil) return nil;

    self.packageHandler = packageHandler;
    self.loggerMock = (AILoggerMock *) [ADJAdjustFactory logger];

    [self.loggerMock test:[prefix stringByAppendingString:@"initWithPackageHandler"]];

    self.connectionError = NO;

    return self;
}

- (void)sendPackage:(ADJActivityPackage *)activityPackage {
    [self.loggerMock test:[prefix stringByAppendingString:@"sendPackage"]];

    NSDictionary *jsonDict;

    if (self.connectionError) {
        jsonDict = nil;
    } else {
        jsonDict = @{@"tracker_token": @"token",@"tracker_name":@"name"};
    }

    [self.packageHandler finishedTrackingActivity:jsonDict];

    if (self.connectionError) {
        [self.packageHandler closeFirstPackage];
    } else {
        [self.packageHandler sendNextPackage];
    }
}

- (void)sendClickPackage:(ADJActivityPackage *)clickPackage {
    [self.loggerMock test:[prefix stringByAppendingString:@"sendClickPackage"]];
}


@end

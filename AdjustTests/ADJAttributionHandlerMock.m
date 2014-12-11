//
//  ADJAttributionHandlerMock.m
//  adjust
//
//  Created by Pedro Filipe on 10/12/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJAttributionHandlerMock.h"
#import "ADJLoggerMock.h"
#import "ADJAdjustFactory.h"

static NSString * const prefix = @"ADJAttributionHandlerMock ";

@interface ADJAttributionHandlerMock()

@property (nonatomic, strong) ADJLoggerMock *loggerMock;

@end


@implementation ADJAttributionHandlerMock

- (id)initWithActivityHandler:(id<ADJActivityHandler>) activityHandler
                 withMaxDelay:(NSNumber*) milliseconds
       withAttributionPackage:(ADJActivityPackage *) attributionPackage
{
    self = [super init];
    if (self == nil) return nil;

    self.loggerMock = (ADJLoggerMock *) [ADJAdjustFactory logger];

    self.attributionPackage = attributionPackage;
    [self.loggerMock test:[prefix stringByAppendingFormat:@"initWithActivityHandler"]];

    return self;
}

- (void)checkAttribution:(NSDictionary *)jsonDict {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"checkAttribution, jsonDict: %@", jsonDict]];
}

- (void)getAttribution {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"getAttribution"]];
}

@end

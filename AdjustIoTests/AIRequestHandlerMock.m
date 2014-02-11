//
//  AIRequestHandlerMock.m
//  AdjustIo
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIRequestHandlerMock.h"
#import "AILoggerMock.h"
#import "AIAdjustIoFactory.h"

static NSString * const prefix = @"AIRequestHandler ";

@interface AIRequestHandlerMock()

@property (nonatomic, assign) id<AIPackageHandler> packageHandler;
@property (nonatomic, assign) AILoggerMock *mockLogger;

@end

@implementation AIRequestHandlerMock

+ (id<AIRequestHandler>) handlerWithPackageHandler:(id<AIPackageHandler>)packageHandler {
    return [[AIRequestHandlerMock alloc] initWithPackageHandler:packageHandler];
}

- (id)initWithPackageHandler:(id<AIPackageHandler>) packageHandler {
    self = [super init];
    if (self == nil) return nil;
    
    self.packageHandler = packageHandler;
    self.mockLogger = (AILoggerMock *) [AIAdjustIoFactory logger];
    
    return self;
}

- (void)sendPackage:(AIActivityPackage *)activityPackage {
    [self.mockLogger test:[prefix stringByAppendingString:@"sendPackage"]];
}

@end

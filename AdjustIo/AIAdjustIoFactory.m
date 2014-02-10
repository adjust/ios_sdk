//
//  AIAdjustIoFactory.m
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIAdjustIoFactory.h"
#import "AIPackageHandler.h"
#import "AIRequestHandler.h"
#import "AILogger.h"

static id<AIPackageHandler> packageHandler = nil;
static id<AIRequestHandler> requestHandler = nil;
static id<AILogger> logger = nil;

@implementation AIAdjustIoFactory

+ (id<AIPackageHandler>)packageHandlerForActivityHandler:(AIActivityHandler *)activityHandler {
    if (packageHandler == nil) {
        return [AIPackageHandler handlerWithActivityHandler:activityHandler];
    }
    return packageHandler;
}

+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler {
    if (requestHandler == nil) {
        return [AIRequestHandler handlerWithPackageHandler:packageHandler];
    }
    return requestHandler;
}

+ (id<AILogger>)logger {
    if (logger == nil) {
        //  same instance of logger
        logger = [[AILogger alloc] init];
    }
    return logger;
}

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler {
    AIAdjustIoFactory.packageHandler = packageHandler;
}

+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler {
    AIAdjustIoFactory.requestHandler = requestHandler;
}

+ (void)setLogger:(id<AILogger>)logger {
    AIAdjustIoFactory.logger = logger;
}


@end

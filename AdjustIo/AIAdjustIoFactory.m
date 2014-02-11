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

static id<AIPackageHandler> internalPackageHandler = nil;
static id<AIRequestHandler> internalRequestHandler = nil;
static id<AILogger> internalLogger = nil;

@implementation AIAdjustIoFactory

+ (id<AIPackageHandler>)packageHandlerForActivityHandler:(AIActivityHandler *)activityHandler {
    if (internalPackageHandler == nil) {
        return [AIPackageHandler handlerWithActivityHandler:activityHandler];
    }
    return internalPackageHandler;
}

+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler {
    if (internalRequestHandler == nil) {
        return [AIRequestHandler handlerWithPackageHandler:packageHandler];
    }
    return internalRequestHandler;
}

+ (id<AILogger>)logger {
    if (internalLogger == nil) {
        //  same instance of logger
        internalLogger = [[AILogger alloc] init];
    }
    return internalLogger;
}

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler {
    internalPackageHandler = packageHandler;
}

+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler {
    internalRequestHandler = requestHandler;
}

+ (void)setLogger:(id<AILogger>)logger {
    internalLogger = logger;
}


@end

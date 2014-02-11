//
//  AIAdjustIoFactory.m
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIAdjustIoFactory.h"
#import "AIRequestHandler.h"
#import "AILogger.h"

static id<AIPackageHandler> internalPackageHandler = NULL;
static id<AIRequestHandler> internalRequestHandler = NULL;
static id<AILogger> internalLogger = NULL;

@implementation AIAdjustIoFactory

+ (id<AIPackageHandler>)packageHandler {
    if (internalPackageHandler == NULL) {
        return [[AIPackageHandler alloc] init];
    }
    return internalPackageHandler;
}

+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler {
    if (internalRequestHandler == NULL) {
        return [AIRequestHandler handlerWithPackageHandler:packageHandler];
    }
    return internalRequestHandler;
}

+ (id<AILogger>)logger {
    if (internalLogger == NULL) {
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

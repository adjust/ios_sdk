//
//  AIAdjustIoFactory.m
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIAdjustIoFactory.h"

static id<AIPackageHandler> packageHandler = NULL;
static id<AIRequestHandler> requestHandler = NULL;
static id<AILogger> logger = NULL;

@implementation AIAdjustIoFactory

+ (id<AIPackageHandler>)packageHandler {
    if (packageHandler == NULL) {
        return [[AIPackageHandler alloc] init];
    }
    return packageHandler;
}

+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler {
    if (requestHandler == NULL) {
        return [AIRequestHandler handlerWithPackageHandler:packageHandler];
    }
    return requestHandler;
}

+ (id<AILogger>)logger {
    if (logger == NULL) {
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

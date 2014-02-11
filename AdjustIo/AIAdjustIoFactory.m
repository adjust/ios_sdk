//
//  AIAdjustIoFactory.m
//  AdjustIo
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIAdjustIoFactory.h"
#import "AIActivityHandler.h"
#import "AIPackageHandler.h"
#import "AIRequestHandler.h"
#import "AILogger.h"

static id<AIPackageHandler> internalPackageHandler = nil;
static id<AIRequestHandler> internalRequestHandler = nil;
static id<AIActivityHandler> internalActivityHandler = nil;
static id<AILogger> internalLogger = nil;

@implementation AIAdjustIoFactory

+ (id<AIPackageHandler>)packageHandlerForActivityHandler:(id<AIActivityHandler>)activityHandler {
    if (internalPackageHandler == nil) {
        return [AIPackageHandler handlerWithActivityHandler:activityHandler];
    }
    
    return [internalPackageHandler initWithActivityHandler:activityHandler];
}

+ (id<AIRequestHandler>)requestHandlerForPackageHandler:(id<AIPackageHandler>)packageHandler {
    if (internalRequestHandler == nil) {
        return [AIRequestHandler handlerWithPackageHandler:packageHandler];
    }
    return [internalRequestHandler initWithPackageHandler:packageHandler];
}

+ (id<AILogger>)logger {
    if (internalLogger == nil) {
        //  same instance of logger
        internalLogger = [[AILogger alloc] init];
    }
    return internalLogger;
}

+ (id<AIActivityHandler>)activityHandlerWithAppToken:(NSString *)appToken {
    if (internalActivityHandler == nil) {
        return [AIActivityHandler handlerWithAppToken:appToken];
    }
    return [internalActivityHandler initWithAppToken:appToken];
}

+ (void)setPackageHandler:(id<AIPackageHandler>)packageHandler {
    internalPackageHandler = packageHandler;
}

+ (void)setRequestHandler:(id<AIRequestHandler>)requestHandler {
    internalRequestHandler = requestHandler;
}

+ (void)setActivityHandler:(id<AIActivityHandler>)activityHandler {
    internalActivityHandler = activityHandler;
}

+ (void)setLogger:(id<AILogger>)logger {
    internalLogger = logger;
}


@end

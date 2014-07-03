//
//  AIAdjustFactory.m
//  Adjust
//
//  Created by Pedro Filipe on 07/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIAdjustFactory.h"
#import "AIActivityHandler.h"
#import "AIPackageHandler.h"
#import "AIRequestHandler.h"
#import "AILogger.h"

static id<AIPackageHandler> internalPackageHandler = nil;
static id<AIRequestHandler> internalRequestHandler = nil;
static id<AIActivityHandler> internalActivityHandler = nil;
static id<AILogger> internalLogger = nil;

static double internalSessionInterval    = -1;
static double intervalSubsessionInterval = -1;

@implementation AIAdjustFactory

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

+ (id<AIActivityHandler>)activityHandlerWithAppToken:(NSString *)appToken {
    if (internalActivityHandler == nil) {
        return [AIActivityHandler handlerWithAppToken:appToken];
    }
    return [internalActivityHandler initWithAppToken:appToken];
}

+ (id<AILogger>)logger {
    if (internalLogger == nil) {
        //  same instance of logger
        internalLogger = [[AILogger alloc] init];
    }
    return internalLogger;
}

+ (double)sessionInterval {
    if (internalSessionInterval == -1) {
        return 30 * 60;           // 30 minutes
    }
    return internalSessionInterval;
}

+ (double)subsessionInterval {
    if (intervalSubsessionInterval == -1) {
        return 1;                // 1 second
    }
    return intervalSubsessionInterval;
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

+ (void)setSessionInterval:(double)sessionInterval {
    internalSessionInterval = sessionInterval;
}

+ (void)setSubsessionInterval:(double)subsessionInterval {
    intervalSubsessionInterval = subsessionInterval;
}

@end

//
//  AIAttributionHandler.h
//  adjust
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIActivityHandler.h"

@protocol AIAttributionHandler

- (id)initWithActivityHandler:(id<AIActivityHandler>) activityHandler withMaxDelay:(NSNumber* )milliseconds;

- (void)checkAttribution:(NSDictionary *)jsonDict;

- (void)getAttribution;

@end

@interface AIAttributionHandler : NSObject <AIAttributionHandler>

+ (id<AIAttributionHandler>)handlerWithActivityHandler:(id<AIActivityHandler>)activityHandler
                                          withMaxDelay:(NSNumber* )milliseconds;

@end

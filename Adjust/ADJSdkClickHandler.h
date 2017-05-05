//
//  ADJSdkClickHandler.h
//  Adjust
//
//  Created by Pedro Filipe on 21/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityPackage.h"
#import "ADJActivityHandler.h"

@protocol ADJSdkClickHandler

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending;

- (void)pauseSending;
- (void)resumeSending;
- (void)sendSdkClick:(ADJActivityPackage *)sdkClickPackage;
- (void)teardown;

@end

@interface ADJSdkClickHandler : NSObject <ADJSdkClickHandler>

+ (id<ADJSdkClickHandler>)handlerWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                                       startsSending:(BOOL)startsSending;

@end

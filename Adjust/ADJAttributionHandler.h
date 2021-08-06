//
//  ADJAttributionHandler.h
//  adjust
//
//  Created by Pedro Filipe on 29/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityHandler.h"
#import "ADJActivityPackage.h"
#import "ADJRequestHandler.h"
#import "ADJUrlStrategy.h"

@interface ADJAttributionHandler : NSObject <ADJResponseCallback>

- (id)initWithActivityHandler:(id<ADJActivityHandler>) activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy;

- (void)checkSessionResponse:(ADJSessionResponseData *)sessionResponseData;

- (void)checkSdkClickResponse:(ADJSdkClickResponseData *)sdkClickResponseData;

- (void)checkAttributionResponse:(ADJAttributionResponseData *)attributionResponseData;

- (void)getAttribution;

- (void)pauseSending;

- (void)resumeSending;

- (void)teardown;

@end

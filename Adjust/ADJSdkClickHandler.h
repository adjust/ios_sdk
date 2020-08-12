//
//  ADJSdkClickHandler.h
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 21st April 2016.
//  Copyright © 2016 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityPackage.h"
#import "ADJActivityHandler.h"
#import "ADJRequestHandler.h"
#import "ADJUrlStrategy.h"

@interface ADJSdkClickHandler : NSObject <ADJResponseCallback>

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy;
- (void)pauseSending;
- (void)resumeSending;
- (void)sendSdkClick:(ADJActivityPackage *)sdkClickPackage;
- (void)teardown;

@end

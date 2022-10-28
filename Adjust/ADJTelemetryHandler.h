//
//  ADJTelemetryHandler.h
//  Adjust SDK
//
//  Created by Ugljesa Erceg (@uerceg) on 28th October 2022.
//  Copyright © 2022-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityPackage.h"
#import "ADJActivityHandler.h"
#import "ADJRequestHandler.h"
#import "ADJUrlStrategy.h"

@interface ADJTelemetryHandler : NSObject <ADJResponseCallback>

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy;

- (void)pauseSending;

- (void)resumeSending;

- (void)sendTelemetryPackage:(ADJActivityPackage *)telemetryPackage;

- (void)teardown;

@end

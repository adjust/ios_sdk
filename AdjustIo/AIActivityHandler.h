//
//  AIActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "Adjust.h"

@protocol AIActivityHandler

@property (nonatomic, copy) NSString *environment;
@property (nonatomic, assign) BOOL bufferEvents;
@property (nonatomic, assign) BOOL trackMacMd5;
@property (nonatomic, assign) NSObject<AdjustDelegate> *delegate;

- (id)initWithAppToken:(NSString *)appToken;
- (void)setSdkPrefix:(NSString *)sdkPrefix;

- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters;

- (void)trackRevenue:(double)amount
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters;

- (void)finishedTrackingWithResponse:(AIResponseData *)response;

@end

@interface AIActivityHandler : NSObject <AIActivityHandler>

+ (id<AIActivityHandler>)handlerWithAppToken:(NSString *)appToken;

@end

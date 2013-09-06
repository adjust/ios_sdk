//
//  AIActivityHandler.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adeven. All rights reserved.
//

@interface AIActivityHandler : NSObject

+ (AIActivityHandler *)handlerWithAppToken:(NSString *)appToken;
- (id)initWithAppToken:(NSString *)appToken;

- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters;

- (void)trackRevenue:(double)amount
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters;

- (void)setEventBufferingEnabled:(BOOL)enabled;

@end

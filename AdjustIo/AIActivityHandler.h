//
//  AIActivityHandler.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 01.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: rename to AIStateHandler
@interface AIActivityHandler : NSObject

+ (AIActivityHandler *)handlerWithAppToken:(NSString *)appToken;
- (id)initWithAppToken:(NSString *)appToken;

- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters;

- (void)trackRevenue:(float)amount
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters;

@end

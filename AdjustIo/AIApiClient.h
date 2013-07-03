//
//  AIApiClient.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 06.08.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@class AILogger;

@interface AIApiClient : AFHTTPClient

+ (AIApiClient *)apiClientWithLogger:(AILogger *)logger;

- (void)postPath:(NSString *)path
      parameters:(NSDictionary *)parameters
  successMessage:(NSString *)successMessage
  failureMessage:(NSString *)failureMessage;

- (void)logSuccess:(NSString *)string;
- (void)logFailure:(NSString *)string response:(NSString *)response error:(NSError *)error;

@end

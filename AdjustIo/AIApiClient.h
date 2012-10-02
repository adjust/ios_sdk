//
//  AIApiClient.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 06.08.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AIApiClient : AFHTTPClient

+ (AIApiClient *)apiClient;

@end

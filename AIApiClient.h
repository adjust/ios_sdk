//
//  AdjustIoApiClient.h
//  Rotate
//
//  Created by Christian Wellenbrock on 06.08.12.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface AIApiClient : AFHTTPClient

+ (AIApiClient *)apiClient;

@end

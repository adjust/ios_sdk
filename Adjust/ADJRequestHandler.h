//
//  ADJRequestHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityPackage.h"

@protocol ADJResponseCallback <NSObject>
- (void)responseCallback:(ADJResponseData *)responseData;
@end

@interface ADJRequestHandler : NSObject

- (id)initWithResponseCallback:(id<ADJResponseCallback>)responseCallback
                     extraPath:(NSString *)extraPath
                       baseUrl:(NSString *)baseUrl
                       gdprUrl:(NSString *)gdprUrl
               subscriptionUrl:(NSString *)subscriptionUrl
                     userAgent:(NSString *)userAgent
                requestTimeout:(double)requestTimeout;

- (void)sendPackageByPOST:(ADJActivityPackage *)activityPackage
        sendingParameters:(NSDictionary *)sendingParameters;

- (void)sendPackageByGET:(ADJActivityPackage *)activityPackage
        sendingParameters:(NSDictionary *)sendingParameters;

@end

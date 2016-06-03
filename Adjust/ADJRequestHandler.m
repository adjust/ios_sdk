//
//  ADJRequestHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJActivityPackage.h"
#import "ADJLogger.h"
#import "ADJUtil.h"
#import "NSString+ADJAdditions.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityKind.h"

static const char * const kInternalQueueName = "io.adjust.RequestQueue";

#pragma mark - private
@interface ADJRequestHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, weak) id<ADJPackageHandler> packageHandler;
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) NSURL *baseUrl;

@end


#pragma mark -
@implementation ADJRequestHandler

+ (ADJRequestHandler *)handlerWithPackageHandler:(id<ADJPackageHandler>)packageHandler {
    return [[ADJRequestHandler alloc] initWithPackageHandler:packageHandler];
}

- (id)initWithPackageHandler:(id<ADJPackageHandler>) packageHandler {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;
    self.logger = ADJAdjustFactory.logger;
    self.baseUrl = [NSURL URLWithString:ADJUtil.baseUrl];

    return self;
}

- (void)sendPackage:(ADJActivityPackage *)activityPackage
          queueSize:(NSUInteger)queueSize
{
    dispatch_async(self.internalQueue, ^{
        [self sendInternal:activityPackage queueSize:queueSize];
    });
}

#pragma mark - internal
- (void)sendInternal:(ADJActivityPackage *)package
           queueSize:(NSUInteger)queueSize
{

    [ADJUtil sendPostRequest:self.baseUrl
                   queueSize:queueSize
          prefixErrorMessage:package.failureMessage
          suffixErrorMessage:@"Will retry later"
             activityPackage:package
         responseDataHandler:^(ADJResponseData * responseData)
    {
        if (responseData.jsonResponse == nil) {
            [self.packageHandler closeFirstPackage:responseData activityPackage:package];
            return;
        }

        [self.packageHandler sendNextPackage:responseData];
     }];
}

@end

//
//  ADJRequestHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-04.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJActivityKind.h"
#import "ADJAdjustFactory.h"
#import "ADJPackageBuilder.h"
#import "ADJActivityPackage.h"
#import "NSString+ADJAdditions.h"

static const char * const kInternalQueueName = "io.adjust.RequestQueue";

@interface ADJRequestHandler()

@property (nonatomic, strong) NSURL *baseUrl;

@property (nonatomic, strong) dispatch_queue_t internalQueue;

@property (nonatomic, weak) id<ADJLogger> logger;

@property (nonatomic, weak) id<ADJPackageHandler> packageHandler;

@end

@implementation ADJRequestHandler

#pragma mark - Public methods

+ (ADJRequestHandler *)handlerWithPackageHandler:(id<ADJPackageHandler>)packageHandler {
    return [[ADJRequestHandler alloc] initWithPackageHandler:packageHandler];
}

- (id)initWithPackageHandler:(id<ADJPackageHandler>)packageHandler {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.packageHandler = packageHandler;
    self.logger = ADJAdjustFactory.logger;
    self.baseUrl = [NSURL URLWithString:ADJUtil.baseUrl];
    
    return self;
}

- (void)sendPackage:(ADJActivityPackage *)activityPackage queueSize:(NSUInteger)queueSize {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJRequestHandler* selfI) {
                         [selfI sendI:selfI activityPackage:activityPackage queueSize:queueSize];
                     }];
}

- (void)teardown {
    [ADJAdjustFactory.logger verbose:@"ADJRequestHandler teardown"];
    
    self.logger = nil;
    self.baseUrl = nil;
    self.internalQueue = nil;
    self.packageHandler = nil;
}

#pragma mark - Private & helper methods

- (void)sendI:(ADJRequestHandler *)selfI activityPackage:(ADJActivityPackage *)activityPackage queueSize:(NSUInteger)queueSize {
    [ADJUtil sendPostRequest:selfI.baseUrl
                   queueSize:queueSize
          prefixErrorMessage:activityPackage.failureMessage
          suffixErrorMessage:@"Will retry later"
             activityPackage:activityPackage
         responseDataHandler:^(ADJResponseData *responseData) {
             if (NO == responseData.validationResult) {
                 NSString *previousValue = [activityPackage.parameters objectForKey:@"tce"];
                 
                 if (nil == previousValue) {
                     [ADJPackageBuilder parameters:activityPackage.parameters setString:@"1" forKey:@"tce"];
                 } else {
                     if ([previousValue isEqualToString:@"0"]) {
                         [ADJPackageBuilder parameters:activityPackage.parameters setString:@"1" forKey:@"tce"];
                     } else {
                         [ADJPackageBuilder parameters:activityPackage.parameters setString:@"0" forKey:@"tce"];
                     }
                 }
                 
                 [self sendPackage:activityPackage queueSize:queueSize];
                 
                 return;
             }
             
             if (responseData.jsonResponse == nil) {
                 [selfI.packageHandler closeFirstPackage:responseData activityPackage:activityPackage];
                 
                 return;
             }
             
             [selfI.packageHandler sendNextPackage:responseData];
         }];
}

@end

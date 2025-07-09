//
//  ADJPurchaseVerificationHandler.m
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on May 25th 2023.
//  Copyright © 2023 Adjust. All rights reserved.
//

#import "ADJPurchaseVerificationHandler.h"
#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJAdjustFactory.h"
#import "ADJUserDefaults.h"
#import "ADJPackageBuilder.h"
#import "ADJPurchaseVerificationResult.h"

static const char * const kInternalQueueName = "com.adjust.PurchaseVerificationQueue";

@interface ADJPurchaseVerificationHandler()

@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADJRequestHandler *requestHandler;

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL isSendingPurchaseVerificationPackage;

@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, weak) id<ADJActivityHandler> activityHandler;

@end

@implementation ADJPurchaseVerificationHandler

#pragma mark - Public instance methods

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                  urlStrategy:(ADJUrlStrategy *)urlStrategy {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.logger = ADJAdjustFactory.logger;

    self.requestHandler = [[ADJRequestHandler alloc] initWithResponseCallback:self
                                                                  urlStrategy:urlStrategy
                                                               requestTimeout:[ADJAdjustFactory requestTimeout]
                                                          adjustConfiguration:activityHandler.adjustConfig];

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPurchaseVerificationHandler *selfI) {
                         [selfI initI:selfI activityHandler:activityHandler startsSending:startsSending];
                     }];
    return self;
}

- (void)pauseSending {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPurchaseVerificationHandler *selfI) {
        selfI.paused = YES;
        selfI.isSendingPurchaseVerificationPackage = NO;
    }];
}

- (void)resumeSending {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPurchaseVerificationHandler *selfI) {
        selfI.paused = NO;
        [selfI sendNextPurchaseVerificationPackage];
    }];
}

- (void)sendPurchaseVerificationPackage:(ADJActivityPackage *)purchaseVerificationPackage {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPurchaseVerificationHandler *selfI) {
                         [selfI sendPurchaseVerificationPackageI:selfI purchaseVerificationPackage:purchaseVerificationPackage];
                     }];
}

- (void)sendNextPurchaseVerificationPackage {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPurchaseVerificationHandler *selfI) {
                         [selfI sendNextPurchaseVerificationPackageI:selfI];
                     }];
}

- (void)updatePackagesWithAttStatus:(int)attStatus {
    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPurchaseVerificationHandler *selfI) {
        [selfI updatePackagesTrackingI:selfI
                             attStatus:attStatus];
    }];
}

- (void)teardown {
    [ADJAdjustFactory.logger verbose:@"ADJPurchaseVerificationHandler teardown"];

    if (self.packageQueue != nil) {
        [self.packageQueue removeAllObjects];
    }

    self.internalQueue = nil;
    self.logger = nil;
    self.packageQueue = nil;
    self.activityHandler = nil;
    self.isSendingPurchaseVerificationPackage = NO;
}

#pragma mark - Private & helper methods

-   (void)initI:(ADJPurchaseVerificationHandler *)selfI
activityHandler:(id<ADJActivityHandler>)activityHandler
  startsSending:(BOOL)startsSending {
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.isSendingPurchaseVerificationPackage = NO;
    selfI.packageQueue = [NSMutableArray array];
}

- (void)sendPurchaseVerificationPackageI:(ADJPurchaseVerificationHandler *)selfI
             purchaseVerificationPackage:(ADJActivityPackage *)purchaseVerificationPackage {
    [selfI.packageQueue addObject:purchaseVerificationPackage];
    [selfI.logger debug:@"Added purchase_verification %d", selfI.packageQueue.count];
    [selfI.logger verbose:@"%@", purchaseVerificationPackage.extendedString];
    [selfI sendNextPurchaseVerificationPackage];
}

- (void)sendNextPurchaseVerificationPackageI:(ADJPurchaseVerificationHandler *)selfI {
    if (selfI.paused) {
        [selfI.logger debug:@"Purchase verification handler is paused"];
        return;
    }
    if (selfI.isSendingPurchaseVerificationPackage) {
        [selfI.logger debug:@"Purchase verification handler is already sending a package"];
        return;
    }
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) {
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"purchase_verification request won't be sent for GDPR forgotten user"];
        return;
    }

    ADJActivityPackage *purchaseVerificationPackage = [self.packageQueue objectAtIndex:0];
    [self.packageQueue removeObjectAtIndex:0];

    if (![purchaseVerificationPackage isKindOfClass:[ADJActivityPackage class]]) {
        [selfI.logger error:@"Failed to read purchase_verification package"];
        selfI.isSendingPurchaseVerificationPackage = NO;
        [selfI sendNextPurchaseVerificationPackage];
        return;
    }

    // Set flag to indicate we're sending a package
    selfI.isSendingPurchaseVerificationPackage = YES;

    dispatch_block_t work = ^{
        [selfI.requestHandler sendPackageByPOST:purchaseVerificationPackage
                              sendingParameters:nil];
    };

    work();
}

- (void)updatePackagesTrackingI:(ADJPurchaseVerificationHandler *)selfI
                      attStatus:(int)attStatus {
    [selfI.logger debug:@"Updating purchase_verification queue with idfa and att_status: %d", attStatus];
    for (ADJActivityPackage *activityPackage in selfI.packageQueue) {
        [ADJPackageBuilder parameters:activityPackage.parameters
                               setInt:attStatus
                               forKey:@"att_status"];

        [ADJPackageBuilder addConsentDataToParameters:activityPackage.parameters
                                      forActivityKind:activityPackage.activityKind
                                        withAttStatus:attStatus
                                        configuration:selfI.activityHandler.adjustConfig
                                        packageParams:selfI.activityHandler.packageParams
                                        activityState:selfI.activityHandler.activityState];
    }
}

- (void)responseCallback:(ADJResponseData *)responseData {
    // check if any package response contains information that user has opted out.
    // if yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADJTrackingStateOptedOut) {
        self.isSendingPurchaseVerificationPackage = NO;
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }

    if (!responseData.jsonResponse) {
        [self.logger error:
            @"Could not get purchase_verification JSON response with message: %@", responseData.message];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 102;
        verificationResult.message = responseData.message;
        ((ADJPurchaseVerificationResponseData *)responseData).error = verificationResult;
    }

    // reset flag to indicate we're done processing this package
    self.isSendingPurchaseVerificationPackage = NO;

    // finish package tracking without retrying / backoff
    [self.activityHandler finishedTracking:responseData];
    
    // process next package in queue if any
    [self sendNextPurchaseVerificationPackage];
}

@end

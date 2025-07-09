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

@property (nonatomic, strong) NSNumber *lastPackageRetryInMilli;

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

    self.requestHandler =
    [[ADJRequestHandler alloc] initWithResponseCallback:self
                                            urlStrategy:urlStrategy
                                         requestTimeout:[ADJAdjustFactory verifyRequestTimeout]
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
        selfI.lastPackageRetryInMilli = nil;
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
    self.lastPackageRetryInMilli = nil;
}

#pragma mark - Private & helper methods

-   (void)initI:(ADJPurchaseVerificationHandler *)selfI
activityHandler:(id<ADJActivityHandler>)activityHandler
  startsSending:(BOOL)startsSending {
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.isSendingPurchaseVerificationPackage = NO;
    selfI.lastPackageRetryInMilli = nil;
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
    if (selfI.packageQueue.count == 0) {
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"purchase_verification request won't be sent for GDPR forgotten user"];
        return;
    }

    // check if we need to wait for backend-requested retry_in delay
    NSNumber *waitTime = [selfI waitTimeTimeInterval];
    if (waitTime != nil) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([waitTime doubleValue] * NSEC_PER_SEC)), 
                       selfI.internalQueue, ^{
            // clear the retry delay after waiting
            selfI.lastPackageRetryInMilli = nil;
            [selfI sendNextPurchaseVerificationPackage];
        });
        return;
    }

    // get the package but keep it in the queue until processing is complete
    ADJActivityPackage *purchaseVerificationPackage = [self.packageQueue objectAtIndex:0];

    if (![purchaseVerificationPackage isKindOfClass:[ADJActivityPackage class]]) {
        [selfI.logger error:@"Failed to read purchase_verification package"];
        // remove the bad package to prevent infinite loop
        [selfI.packageQueue removeObjectAtIndex:0];
        selfI.isSendingPurchaseVerificationPackage = NO;
        [selfI sendNextPurchaseVerificationPackage];
        return;
    }

    // set flag to indicate we're sending a package
    selfI.isSendingPurchaseVerificationPackage = YES;

    [selfI.requestHandler sendPackageByPOST:purchaseVerificationPackage
                          sendingParameters:nil];
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

    // check if backend requested retry_in delay
    if (responseData.retryInMilli != nil) {
        self.lastPackageRetryInMilli = responseData.retryInMilli;
        [self.logger error:@"Retrying purchase_verification package with retry in %d ms",
         [responseData.retryInMilli intValue]];
        
        // package stays in queue - just reset flag and schedule retry
        self.isSendingPurchaseVerificationPackage = NO;
        [self sendNextPurchaseVerificationPackage];
        return;
    }

    // reset retry counter after successful response
    self.lastPackageRetryInMilli = nil;

    if (!responseData.jsonResponse) {
        [self.logger error:
            @"Could not get purchase_verification JSON response with message: %@", responseData.message];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 102;
        verificationResult.message = responseData.message;
        ((ADJPurchaseVerificationResponseData *)responseData).error = verificationResult;
    }

    // processing is complete - remove the package from queue
    if (self.packageQueue.count > 0) {
        [self.packageQueue removeObjectAtIndex:0];
    }

    // reset flag to indicate we're done processing this package
    self.isSendingPurchaseVerificationPackage = NO;

    // finish package tracking without retrying / backoff
    [self.activityHandler finishedTracking:responseData];
    
    // process next package in queue if any
    [self sendNextPurchaseVerificationPackage];
}

- (NSNumber *)waitTimeTimeInterval {
    // handle backend-requested retry_in delay
    if (self.lastPackageRetryInMilli != nil) {
        NSTimeInterval waitTime = [self.lastPackageRetryInMilli intValue] / 1000.0;

        [self.logger verbose:
         @"Waiting for %@ seconds before retrying purchase_verification with retry_in",
         [ADJUtil secondsNumberFormat:waitTime]];

        return @(waitTime);
    }

    return nil;
}

@end

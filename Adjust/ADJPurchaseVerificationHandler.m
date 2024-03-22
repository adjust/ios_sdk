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
#import "ADJBackoffStrategy.h"
#import "ADJUserDefaults.h"
#import "ADJPackageBuilder.h"

static const char * const kInternalQueueName = "com.adjust.PurchaseVerificationQueue";

@interface ADJPurchaseVerificationHandler()

@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) ADJRequestHandler *requestHandler;

@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) ADJBackoffStrategy *backoffStrategy;

@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, weak) id<ADJActivityHandler> activityHandler;

@property (nonatomic, assign) NSInteger lastPackageRetriesCount;

@end

@implementation ADJPurchaseVerificationHandler

#pragma mark - Public instance methods

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.logger = ADJAdjustFactory.logger;
    self.lastPackageRetriesCount = 0;

    self.requestHandler = [[ADJRequestHandler alloc] initWithResponseCallback:self
                                                                  urlStrategy:urlStrategy
                                                                    userAgent:userAgent
                                                               requestTimeout:[ADJAdjustFactory requestTimeout]];

    [ADJUtil launchInQueue:self.internalQueue
                selfInject:self
                     block:^(ADJPurchaseVerificationHandler *selfI) {
                         [selfI initI:selfI activityHandler:activityHandler startsSending:startsSending];
                     }];
    return self;
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
    [self sendNextPurchaseVerificationPackage];
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
    self.backoffStrategy = nil;
    self.packageQueue = nil;
    self.activityHandler = nil;
}

#pragma mark - Private & helper methods

-   (void)initI:(ADJPurchaseVerificationHandler *)selfI
activityHandler:(id<ADJActivityHandler>)activityHandler
  startsSending:(BOOL)startsSending {
    selfI.activityHandler = activityHandler;
    selfI.paused = !startsSending;
    selfI.backoffStrategy = [ADJAdjustFactory sdkClickHandlerBackoffStrategy];
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
        return;
    }
    NSUInteger queueSize = selfI.packageQueue.count;
    if (queueSize == 0) {
        return;
    }
    if ([selfI.activityHandler isGdprForgotten]) {
        [selfI.logger debug:@"purchase_verification request won't be fired for forgotten user"];
        return;
    }

    ADJActivityPackage *purchaseVerificationPackage = [self.packageQueue objectAtIndex:0];
    [self.packageQueue removeObjectAtIndex:0];

    if (![purchaseVerificationPackage isKindOfClass:[ADJActivityPackage class]]) {
        [selfI.logger error:@"Failed to read purchase_verification package"];
        [selfI sendNextPurchaseVerificationPackage];
        return;
    }

    dispatch_block_t work = ^{
        NSDictionary *sendingParameters = @{
            @"sent_at": [ADJUtil formatSeconds1970:[NSDate.date timeIntervalSince1970]]
        };
        [selfI.requestHandler sendPackageByPOST:purchaseVerificationPackage
                              sendingParameters:sendingParameters];
        [selfI sendNextPurchaseVerificationPackage];
    };

    if (selfI.lastPackageRetriesCount <= 0) {
        work();
        return;
    }

    NSTimeInterval waitTime = [ADJUtil waitingTime:selfI.lastPackageRetriesCount backoffStrategy:self.backoffStrategy];
    NSString *waitTimeFormatted = [ADJUtil secondsNumberFormat:waitTime];
    [self.logger verbose:@"Waiting for %@ seconds before retrying purchase_verification for the %d time",
     waitTimeFormatted,
     selfI.lastPackageRetriesCount];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, work);
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
                                        withAttStatus:[activityPackage.parameters objectForKey:@"att_status"]
                                        configuration:selfI.activityHandler.adjustConfig
                                        packageParams:selfI.activityHandler.packageParams];
    }
}

- (void)responseCallback:(ADJResponseData *)responseData {
    if (responseData.jsonResponse) {
        [self.logger debug:
            @"Got purchase_verification JSON response with message: %@", responseData.message];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = responseData.jsonResponse[@"verification_status"];
        verificationResult.code = [(NSNumber *)responseData.jsonResponse[@"code"] intValue];
        verificationResult.message = responseData.jsonResponse[@"message"];
        responseData.purchaseVerificationPackage.purchaseVerificationCallback(verificationResult);
    } else {
        [self.logger error:
            @"Could not get purchase_verification JSON response with message: %@", responseData.message];
        ADJPurchaseVerificationResult *verificationResult = [[ADJPurchaseVerificationResult alloc] init];
        verificationResult.verificationStatus = @"not_verified";
        verificationResult.code = 102;
        verificationResult.message = responseData.message;
        responseData.purchaseVerificationPackage.purchaseVerificationCallback(verificationResult);
    }
    // Check if any package response contains information that user has opted out.
    // If yes, disable SDK and flush any potentially stored packages that happened afterwards.
    if (responseData.trackingState == ADJTrackingStateOptedOut) {
        self.lastPackageRetriesCount = 0;
        [self.activityHandler setTrackingStateOptedOut];
        return;
    }
    if (responseData.jsonResponse == nil) {
        self.lastPackageRetriesCount++;
        [self.logger error:@"Retrying purchase_verification package for the %d time", self.lastPackageRetriesCount];
        [self sendPurchaseVerificationPackage:responseData.purchaseVerificationPackage];
        return;
    }
    self.lastPackageRetriesCount = 0;
    [self.activityHandler finishedTracking:responseData];
}

@end

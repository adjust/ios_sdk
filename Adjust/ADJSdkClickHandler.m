//
//  ADJSdkClickHandler.m
//  Adjust
//
//  Created by Pedro Filipe on 21/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJSdkClickHandler.h"
#import "ADJLogger.h"
#import "ADJAdjustFactory.h"
#import "ADJBackoffStrategy.h"
#import "ADJUtil.h"

static const char * const kInternalQueueName    = "com.adjust.SdkClickQueue";

#pragma mark - private
@interface ADJSdkClickHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) ADJBackoffStrategy * backoffStrategy;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, strong) NSMutableArray *packageQueue;
@property (nonatomic, strong) NSURL *baseUrl;

@end

@implementation ADJSdkClickHandler

+ (id<ADJSdkClickHandler>)handlerWithStartsSending:(BOOL)startsSending
{
    return [[ADJSdkClickHandler alloc] initWithStartsSending:startsSending];
}

- (id)initWithStartsSending:(BOOL)startsSending
{
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    dispatch_async(self.internalQueue, ^{
        [self initInternal:startsSending];
    });

    return self;
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;

    [self sendNextSdkClick];
}

- (void)sendSdkClick:(ADJActivityPackage *)sdkClickPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendSdkClickInternal:sdkClickPackage];
    });
}

- (void)sendNextSdkClick {
    dispatch_async(self.internalQueue, ^{
        [self sendNextSdkClickInternal];
    });
}

#pragma mark - internal
- (void)initInternal:(BOOL)startsSending
{
    self.paused = !startsSending;
    self.logger = ADJAdjustFactory.logger;
    self.backoffStrategy = [ADJAdjustFactory sdkClickHandlerBackoffStrategy];
    self.packageQueue = [NSMutableArray array];
    self.baseUrl = [NSURL URLWithString:ADJUtil.baseUrl];
}

- (void)sendSdkClickInternal:(ADJActivityPackage *)sdkClickPackage {
    [self.packageQueue addObject:sdkClickPackage];

    [self.logger debug:@"Added sdk_click %d", self.packageQueue.count];
    [self.logger verbose:@"%@", sdkClickPackage.extendedString];

    [self sendNextSdkClick];
}

- (void)sendNextSdkClickInternal {
    if (self.paused) return;
    NSUInteger queueSize = self.packageQueue.count;
    if (queueSize == 0) return;

    ADJActivityPackage *sdkClickPackage = [self.packageQueue objectAtIndex:0];
    [self.packageQueue removeObjectAtIndex:0];

    if (![sdkClickPackage isKindOfClass:[ADJActivityPackage class]]) {
        [self.logger error:@"Failed to read sdk_click package"];

        [self sendNextSdkClick];

        return;
    }

    dispatch_block_t work = ^{
        [ADJUtil sendPostRequest:self.baseUrl
                       queueSize:queueSize - 1
              prefixErrorMessage:sdkClickPackage.failureMessage
              suffixErrorMessage:@"Will retry later"
                 activityPackage:sdkClickPackage
             responseDataHandler:^(ADJResponseData * responseData)
         {
             if (responseData.jsonResponse == nil) {
                 NSInteger retries = [sdkClickPackage increaseRetries];
                 [self.logger error:@"Retrying sdk_click package for the %d time", retries];

                 [self sendSdkClick:sdkClickPackage];
             }
         }];

        [self sendNextSdkClick];
    };

    NSInteger retries = [sdkClickPackage retries];

    if (retries <= 0) {
        work();
        return;
    }

    NSTimeInterval waitTime = [ADJUtil waitingTime:retries backoffStrategy:self.backoffStrategy];
    NSString * waitTimeFormatted = [ADJUtil secondsNumberFormat:waitTime];

    [self.logger verbose:@"Waiting for %@ seconds before retrying sdk_click for the %d time", waitTimeFormatted, retries];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(waitTime * NSEC_PER_SEC)), self.internalQueue, work);
}

@end

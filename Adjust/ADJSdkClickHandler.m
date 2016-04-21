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

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, retain) id<ADJLogger> logger;
@property (nonatomic, retain) ADJBackoffStrategy * backoffStrategy;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, retain) NSMutableArray *packageQueue;
@property (nonatomic, retain) NSURL *baseUrl;

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
    if (self.packageQueue.count == 0) return;

    ADJActivityPackage *sdkClickPackage = [self.packageQueue objectAtIndex:0];

    if (![sdkClickPackage isKindOfClass:[ADJActivityPackage class]]) {
        [self.logger error:@"Failed to read sdk_click package"];

        [self.packageQueue removeObjectAtIndex:0];
        [self sendNextSdkClick];

        return;
    }

    NSInteger retries = [sdkClickPackage retries];
    if (retries > 0) {
        NSTimeInterval waitTime = [ADJUtil waitingTime:retries backoffStrategy:self.backoffStrategy];
        NSString * waitTimeFormatted = [ADJUtil secondsNumberFormat:waitTime];

        [self.logger verbose:@"Sleeping for %@ seconds before retrying sdk_click for the %d time", waitTimeFormatted, retries];

        [NSThread sleepForTimeInterval:waitTime];
    }

    [ADJUtil sendPostRequest:self.baseUrl
          prefixErrorMessage:@"Failed to send sdk_click"
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

    [self.packageQueue removeObjectAtIndex:0];
    [self sendNextSdkClick];
}

@end

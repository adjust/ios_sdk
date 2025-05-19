//
//  ADJOdmManager.m
//  Adjust
//
//  Created by Genady Buchatsky on 14.03.25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import "ADJOdmManager.h"
#import "ADJUserDefaults.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"

static const char * const kInternalQueueName = "io.adjust.OdmQueue";

@interface ADJOdmManager ()
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, assign) BOOL odmPluginAvailable;
@property (nonatomic, assign) BOOL odmInfoFetched;
@property (nonatomic, assign) BOOL odmInfoSendingInProcess;
@property (nonatomic, assign) BOOL odmInfoHasBeenProcessed;
@property (nonatomic, strong) NSString *odmInfo;
@property (nonatomic, strong) NSError *odmInfoFetchError;
@property (nonatomic, strong) ADJFetchGoogleOdmInfoBlock fetchOdmInfoBlock;
@end

@implementation ADJOdmManager
- (id _Nullable)init {

    self = [super init];
    if (self == nil) return nil;

    _logger = [ADJAdjustFactory logger];
    _internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    _odmPluginAvailable = [ADJOdmManager isOdmPluginAvailable];
    _odmInfoHasBeenProcessed = [ADJUserDefaults getGoogleOdmInfoProcessed];

    if (!_odmPluginAvailable) {
        [_logger verbose:@"Adjust Plugin for Google ODM SDK is not found. Skipping ODM initialization..."];
    }

    if (_odmInfoHasBeenProcessed) {
        [_logger verbose:@"Google ODM Info has been already processed. Skipping ODM initialization..."];
    }

    if (_odmPluginAvailable && !_odmInfoHasBeenProcessed) {
        // set App Launch Timestamp to ODM SDK and save it for a future check.
        // we should call it only once in an app lifetime.

        if ([ADJUserDefaults getGoogleOdmInitTimestamp] == nil) {
            [_logger verbose:@"Calling Google ODM's setFirstLaunchTime: method..."];

            NSDate *firstAppLaunch = [ADJUserDefaults getAppFirstLaunchTimestamp];
            if (firstAppLaunch == nil) {
                firstAppLaunch = [NSDate date];
                [ADJUserDefaults saveAppFirstLaunchTimestamp:firstAppLaunch];
            }

            [ADJOdmManager setOdmAppFirstLaunchTimestamp:firstAppLaunch];
            [ADJUserDefaults saveGoogleOdmInitTimestamp:[NSDate date]];
        }

        // fetch odm Info only in case it hasn't been already fetched and stored.
        if (![ADJUserDefaults getGoogleOdmInfo]) {
            [ADJOdmManager fetchOdmInfoWithCompletion:^(NSString * _Nullable odmInfo, NSError * _Nullable error) {
                dispatch_async(self.internalQueue, ^{
                    self.odmInfoFetched = YES;
                    self.odmInfo = odmInfo;
                    self.odmInfoFetchError = error;

                    // Stor ODM Info only in case it's not nil and error is nill.
                    if (odmInfo != nil && error == nil) {
                        [ADJUserDefaults setGoogleOdmInfo:odmInfo];
                    } else {
                        [self.logger verbose:@"Google ODM's fetchAggregateConversionInfoForInteraction:completion: failed. Conversion Info: %@, Error: %@",
                         odmInfo, error];
                        if (error == nil) {
                            self.odmInfoFetchError = [NSError errorWithDomain:@"com.adjust.sdk.googleOdm"
                                                                         code:100
                                                                     userInfo:@{@"Error reason": @"Odm Info and Error are nil"}];
                        }
                    }
                    // if a block for handling odm info already set
                    // (while ODM SDK has been processing fetch request),
                    // invoke it and reset after the invocation.
                    if (self.fetchOdmInfoBlock) {
                        self.fetchOdmInfoBlock(self.odmInfo, self.odmInfoFetchError);
                        self.fetchOdmInfoBlock = nil;
                        self.odmInfoSendingInProcess = YES;
                    }
                });
            }];
        }
    }
    return self;
}

- (void)fetchGoogleOdmInfoWithCompletionHandler:(ADJFetchGoogleOdmInfoBlock)completion {
    if (!self.odmPluginAvailable) {
        return;
    }

    dispatch_async(self.internalQueue, ^{
        if(self.odmInfoHasBeenProcessed) {
            [self.logger verbose:@"Fetch Google ODM Info: it has been already processed. Skipping..."];
            return;
        }

        // Handle the case when a one fetch call is already received and is being executed now
        // and second call to this method is done.
        if (self.odmInfoSendingInProcess) {
            [self.logger verbose:@"Fetch Google ODM Info: sending is already in process. Skipping..."];
            return;
        }

        if (completion == nil) {
            [self.logger verbose:@"Fetch Google ODM Info: completion block parameter is nil. Skipping..."];
            return;
        }

        // Handle the case when a one fetch call is already received
        // and the second call to this method is done.
        if (self.fetchOdmInfoBlock){
            [self.logger verbose:@"Fetch Google ODM Info: completion block is already set. Skipping..."];
            return;
        }

        if (self.odmInfoFetched) {
            self.odmInfoSendingInProcess = YES;
            completion(self.odmInfo, self.odmInfoFetchError);
        } else {
            // Store completion object if odmInfo is still not available.
            // It will be called after odmInfo fetch is completed.
            self.fetchOdmInfoBlock = completion;
        }
    });
}

- (void)onBackendProcessedGoogleOdmInfoWithSuccess:(BOOL)success {
    if (!self.odmPluginAvailable) {
        return;
    }

    dispatch_async(self.internalQueue, ^{
        self.odmInfoSendingInProcess = NO;

        if(self.odmInfoHasBeenProcessed) {
            [self.logger verbose:@"Set Google ODM Info Processed: it has been already set. Skipping..."];
            return;
        }

        self.odmInfoHasBeenProcessed = success;
        // Update UserDefaults in case odmInfo was processed successfully.
        if (success) {
            [ADJUserDefaults setGoogleOdmInfoProcessed];
        }
    });
}

#pragma mark Internal

+ (BOOL)isOdmPluginAvailable {
    Class odmPluginClass = NSClassFromString(@"ADJOdmPlugin");
    if (odmPluginClass == nil) {
        return NO;
    }

    SEL selSetLaunchTime = NSSelectorFromString(@"setOdmAppFirstLaunchTimestamp:");
    if (![odmPluginClass respondsToSelector:selSetLaunchTime]) {
        [[ADJAdjustFactory logger] error:@"Method 'setOdmAppFirstLaunchTimestamp:' is not found in ADJOdmPlugin class."];
        return NO;
    }

    SEL selFetchInfo = NSSelectorFromString(@"fetchOdmInfoWithCompletion:");
    if (![odmPluginClass respondsToSelector:selFetchInfo]) {
        [[ADJAdjustFactory logger] error:@"Method 'fetchOdmInfoWithCompletion' is not found in ADJOdmPlugin class."];
        return NO;
    }

    return YES;
}

+ (void)setOdmAppFirstLaunchTimestamp:(NSDate *)time {
    Class odmClass = NSClassFromString(@"ADJOdmPlugin");
    SEL selSetLaunchTime = NSSelectorFromString(@"setOdmAppFirstLaunchTimestamp:");
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [odmClass methodSignatureForSelector:selSetLaunchTime]];
    [inv setSelector:selSetLaunchTime];
    [inv setTarget:odmClass];
    [inv setArgument:&time atIndex:2];
    [inv invoke];
}

+ (void)fetchOdmInfoWithCompletion:(void (^)(NSString * _Nullable odmInfo, NSError * _Nullable error))completion {

    Class odmClass = NSClassFromString(@"ADJOdmPlugin");
    SEL selFetchInfo = NSSelectorFromString(@"fetchOdmInfoWithCompletion:");
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [odmClass methodSignatureForSelector:selFetchInfo]];
    [inv setSelector:selFetchInfo];
    [inv setTarget:odmClass];
    [inv setArgument:&completion atIndex:2];
    [inv invoke];
}

@end

//
//  ADJOdmPlugin.m
//  Adjust
//
//  Created by Genady Buchatsky on 14.03.25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import "ADJOdmPlugin.h"
#import "ADJUserDefaults.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"

static const char * const kInternalQueueName = "io.adjust.OdmQueue";

@interface ADJOdmPlugin ()
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, assign) BOOL odmFrameworkAvailable;
@property (nonatomic, assign) BOOL odmInfoFetched;
@property (nonatomic, assign) BOOL odmInfoSendingInProcess;
@property (nonatomic, assign) BOOL odmInfoHasBeenProcessed;
@property (nonatomic, strong) NSString *odmInfo;
@property (nonatomic, strong) NSError *odmInfoFetchError;
@property (nonatomic, strong) ADJFetchGoogleOdmInfoBlock fetchOdmInfoBlock;
@end

@implementation ADJOdmPlugin
- (id _Nullable)initWithAppLaunchTimestamp:(NSDate * _Nonnull)launchTimestamp {

    self = [super init];
    if (self == nil) return nil;

    _logger = [ADJAdjustFactory logger];
    _internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);

    _odmFrameworkAvailable = [ADJOdmPlugin isFrameworkAvailable];
    _odmInfoHasBeenProcessed = [ADJUserDefaults getGoogleOdmInfoProcessed];

    if (_odmInfoHasBeenProcessed) {
        [_logger verbose:@"Google ODM Info has been already processed. Skipping ODM initialization..."];
    }

    if (!_odmFrameworkAvailable) {
        [_logger verbose:@"Google ODM framework is not available. Skipping ODM initialization..."];
    }

    if (_odmFrameworkAvailable && !_odmInfoHasBeenProcessed) {
        // set App Launch Timestamp to ODM SDK and save it for a future check.
        // we should call it only once in an app lifetime.

        if ([ADJUserDefaults getGoogleOdmInitTimestamp] == nil) {
            [_logger verbose:@"Calling Google ODM's setFirstLaunchTime: method..."];
            [ADJOdmPlugin setOdmLaunchTimestamp:launchTimestamp];
            [ADJUserDefaults saveGoogleOdmInitTimestamp:launchTimestamp];
        }

        // fetch odm Info only in case it hasn't been already fetched and stored.
        if (![ADJUserDefaults getGoogleOdmInfo]) {
            [ADJOdmPlugin fetchOdmInfoWithCompletion:^(NSString * _Nullable odmInfo, NSError * _Nullable error) {
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
    if (!self.odmFrameworkAvailable) {
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
    if (!self.odmFrameworkAvailable) {
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

+ (BOOL)isFrameworkAvailable {

    Class odmClass = NSClassFromString(@"ODCConversionManager");
    if (odmClass == nil) {
        [[ADJAdjustFactory logger] verbose:@"Google ODM error: ODCConversionManager class is not found."];
        return NO;
    }

    SEL selSharedInstance = NSSelectorFromString(@"sharedInstance");
    if (![odmClass respondsToSelector:selSharedInstance]) {
        [[ADJAdjustFactory logger] verbose:@"Google ODM error: 'sharedInstance' method is not found in ODCConversionManager class."];
        return NO;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id sharedInstance = [odmClass performSelector:selSharedInstance];
#pragma clang diagnostic pop

    SEL selSetLaunchTime = NSSelectorFromString(@"setFirstLaunchTime:");
    if (![sharedInstance respondsToSelector:selSetLaunchTime]) {
        [[ADJAdjustFactory logger] verbose:@"Google ODM error: 'setFirstLaunchTime:' method is not found in ODCConversionManager's sharedInstance."];
        return NO;
    }

    SEL selFetchConversionInfo = NSSelectorFromString(@"fetchAggregateConversionInfoForInteraction:completion:");
    if (![sharedInstance respondsToSelector:selFetchConversionInfo]) {
        [[ADJAdjustFactory logger] verbose:@"Google ODM error: 'fetchAggregateConversionInfoForInteraction:completion:' method is not found in ODCConversionManager's sharedInstance."];
        return NO;
    }

    return YES;
}

+ (void)setOdmLaunchTimestamp:(NSDate *)time {
    Class odmClass = NSClassFromString(@"ODCConversionManager");
    SEL selSharedInstance = NSSelectorFromString(@"sharedInstance");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id sharedInstance = [odmClass performSelector:selSharedInstance];
#pragma clang diagnostic pop

    SEL selSetLaunchTime = NSSelectorFromString(@"setFirstLaunchTime:");
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [sharedInstance methodSignatureForSelector:selSetLaunchTime]];
    [inv setSelector:selSetLaunchTime];
    [inv setTarget:sharedInstance];
    [inv setArgument:&time atIndex:2];
    [inv invoke];
}


+ (void)fetchOdmInfoWithCompletion:(void (^)(NSString * _Nullable odmInfo, NSError * _Nullable error))completion {
    Class odmClass = NSClassFromString(@"ODCConversionManager");
    SEL selSharedInstance = NSSelectorFromString(@"sharedInstance");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id sharedInstance = [odmClass performSelector:selSharedInstance];
#pragma clang diagnostic pop

    SEL selFetchConversionInfo = NSSelectorFromString(@"fetchAggregateConversionInfoForInteraction:completion:");

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [sharedInstance methodSignatureForSelector:selFetchConversionInfo]];
    NSInteger interactionType = 0; // ODCInteractionTypeInstallation of ODCInteractionType
    [inv setSelector:selFetchConversionInfo];
    [inv setTarget:sharedInstance];
    [inv setArgument:&interactionType atIndex:2];
    [inv setArgument:&completion atIndex:3];
    [inv invoke];
}

@end

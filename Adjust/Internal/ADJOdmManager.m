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
static const NSString * const kSupportedOdmVersion = @"2.0.0";

@interface ADJOdmManager ()
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, assign) BOOL isOdmAvailable;
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
    _isOdmAvailable = NO;

    if ([ADJOdmManager isOdmPluginAvailable]) {
        NSString *error = nil;
        if ([ADJOdmManager isOdmFrameworkAvailableWithError:&error]) {
            NSString *odmVersion = [ADJOdmManager odmFrameworkVersion];
            if ([kSupportedOdmVersion isEqualToString:odmVersion]) {
                _isOdmAvailable = YES;
            } else {
                [_logger warn:@"Google ODM Framework version %@ is not supported. Skipping ODM initialization...", odmVersion];
            }
        } else {
            [_logger warn:@"Google ODM Framework error - %@. Skipping ODM initialization...", error];
        }
    } else {
        [_logger warn:@"Adjust Plugin for Google ODM SDK is not found. Skipping ODM initialization..."];
    }

    _odmInfoHasBeenProcessed = [ADJUserDefaults getGoogleOdmInfoProcessed];
    if (_odmInfoHasBeenProcessed) {
        [_logger info:@"Google ODM Info has been already processed. Skipping ODM initialization..."];
    }

    if (_isOdmAvailable && !_odmInfoHasBeenProcessed) {
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
    if (!self.isOdmAvailable) {
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
    if (!self.isOdmAvailable) {
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

    SEL selIsFrameworkAvailable = NSSelectorFromString(@"isOdmFrameworkAvailableWithError:");
    if (![odmPluginClass respondsToSelector:selIsFrameworkAvailable]) {
        [[ADJAdjustFactory logger] error:@"ODM Plugin error - method 'isOdmFrameworkAvailableWithError:' is not found in ADJOdmPlugin class."];
        return NO;
    }

    SEL selOdmFrameworkVersion = NSSelectorFromString(@"odmFrameworkVersion");
    if (![odmPluginClass respondsToSelector:selOdmFrameworkVersion]) {
        [[ADJAdjustFactory logger] error:@"ODM Plugin error - method 'odmFrameworkVersion' is not found in ADJOdmPlugin class."];
        return NO;
    }

    SEL selSetLaunchTime = NSSelectorFromString(@"setOdmAppFirstLaunchTimestamp:");
    if (![odmPluginClass respondsToSelector:selSetLaunchTime]) {
        [[ADJAdjustFactory logger] error:@"ODM Plugin error - method 'setOdmAppFirstLaunchTimestamp:' is not found in ADJOdmPlugin class."];
        return NO;
    }

    SEL selFetchInfo = NSSelectorFromString(@"fetchOdmInfoWithCompletion:");
    if (![odmPluginClass respondsToSelector:selFetchInfo]) {
        [[ADJAdjustFactory logger] error:@"ODM Plugin error - method 'fetchOdmInfoWithCompletion' is not found in ADJOdmPlugin class."];
        return NO;
    }

    return YES;
}

+ (BOOL)isOdmFrameworkAvailableWithError:(NSString **)error {
    Class odmClass = NSClassFromString(@"ADJOdmPlugin");
    SEL sel = NSSelectorFromString(@"isOdmFrameworkAvailableWithError:");
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [odmClass methodSignatureForSelector:sel]];
    __autoreleasing NSString **errorPointer = error;
    [inv setSelector:sel];
    [inv setTarget:odmClass];
    [inv setArgument:&errorPointer atIndex:2];
    [inv invoke];
    BOOL bResult = NO;
    [inv getReturnValue:&bResult];
    return bResult;
}

+ (nullable NSString *)odmFrameworkVersion {
    Class odmClass = NSClassFromString(@"ADJOdmPlugin");
    SEL sel = NSSelectorFromString(@"odmFrameworkVersion");
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [odmClass methodSignatureForSelector:sel]];
    [inv setSelector:sel];
    [inv setTarget:odmClass];
    [inv invoke];
    NSString * __unsafe_unretained tmpVersion = nil;
    [inv getReturnValue:&tmpVersion];
    NSString *version = tmpVersion;
    return version;
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

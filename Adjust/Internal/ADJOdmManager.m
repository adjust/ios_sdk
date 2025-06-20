//
//  ADJOdmManager.m
//  Adjust
//
//  Created by Genady Buchatsky on 14.03.25.
//  Copyright © 2025-Present Adjust GmbH. All rights reserved.
//

#import "ADJOdmManager.h"
#import "ADJUserDefaults.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"

static const char * const kInternalQueueName = "io.adjust.OdmQueue";

@interface ADJOdmManager ()

@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, assign) BOOL odmInfoFetched;
@property (nonatomic, assign) BOOL odmInfoSendingInProcess;
@property (nonatomic, assign) BOOL odmInfoHasBeenProcessed;
@property (nonatomic, strong) NSString *odmInfo;
@property (nonatomic, strong) NSError *odmInfoFetchError;
@property (nonatomic, strong) ADJFetchGoogleOdmInfoBlock fetchOdmInfoBlock;

@end

@implementation ADJOdmManager

- (id _Nullable)initIfPluginAvailbleAndFetchOdmData {
    self = [super init];
    if (self == nil) return nil;

    _logger = [ADJAdjustFactory logger];
    BOOL isOdmAvailable = NO;

    if ([ADJOdmManager isOdmPluginAvailable]) {
        NSString *error = nil;
        if ([ADJOdmManager isOdmFrameworkAvailableWithError:&error]) {
            [_logger verbose:@"GoogleAdsOnDeviceConversion framework version %@ successfully found in the app", [ADJOdmManager odmFrameworkVersion]];
            isOdmAvailable = YES;
        } else {
            [_logger warn:@"%@", error];
            [_logger warn:@"ADJOdmPlugin can not be initialized"];
        }
    } else {
        [_logger warn:@"ADJOdmPlugin can not be initialized"];
    }

    if (!isOdmAvailable) {
        return nil;
    }

    _internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    _odmInfoHasBeenProcessed = [ADJUserDefaults getGoogleOdmInfoProcessed];
    if (_odmInfoHasBeenProcessed) {
        [_logger info:@"GoogleAdsOnDeviceConversion info has been already processed for this app"];
    } else {
        // Set App Launch Timestamp to ODM SDK and save it for a future check.
        // we should call this ODM method only once in an app lifetime.
        if ([ADJUserDefaults getAppFirstLaunchTimestamp] == nil) {
            [_logger verbose:@"Calling GoogleAdsOnDeviceConversion's setFirstLaunchTime: method"];
            NSDate *firstAppLaunch = [NSDate date];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'Z";
            NSString *formattedDate = [formatter stringFromDate:firstAppLaunch];
            [_logger verbose:[NSString stringWithFormat:@"Calling GoogleAdsOnDeviceConversion setFirstLaunchTime: method with timestamp: %@", formattedDate]];
            [ADJUserDefaults saveAppFirstLaunchTimestamp:firstAppLaunch];
            [ADJOdmManager setOdmAppFirstLaunchTimestamp:firstAppLaunch];
        }

        // fetch odm Info only in case it hasn't been already fetched and stored.
        if (![ADJUserDefaults getGoogleOdmInfo]) {
            [_logger verbose:@"Calling GoogleAdsOnDeviceConversion fetchAggregateConversionInfoForInteraction:completion: method"];
            [ADJOdmManager fetchOdmInfoWithCompletion:^(NSString * _Nullable odmInfo, NSError * _Nullable error) {
                dispatch_async(self.internalQueue, ^{
                    self.odmInfoFetched = YES;
                    self.odmInfo = odmInfo;
                    self.odmInfoFetchError = error;

                    // Store ODM Info only in case it's not nil and error is nill.
                    if (odmInfo != nil && error == nil) {
                        [self.logger verbose:@"GoogleAdsOnDeviceConversion fetchAggregateConversionInfoForInteraction:completion: succeeded"];
                        [ADJUserDefaults setGoogleOdmInfo:odmInfo];
                    } else {
                        NSString *strErr = [NSString stringWithFormat:@"GoogleAdsOnDeviceConversion fetchAggregateConversionInfoForInteraction:completion: failed with error: %@ and ODM info: %@", error, odmInfo];
                        [self.logger error:strErr];
                        if (error == nil) {
                            self.odmInfoFetchError = [NSError errorWithDomain:@"com.adjust.sdk.googleOdm"
                                                                         code:100
                                                                     userInfo:@{@"Error reason": strErr}];
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

- (void)handleFetchedOdmInfoWithCompletionHandler:(ADJFetchGoogleOdmInfoBlock)completion {
    [self.logger verbose:@"Processing fetched GoogleAdsOnDeviceConversion info"];
    // Since odmInfoHasBeenProcessed can change from false to true only,
    // we are checking here in a not-synchronised way - in order to avoid
    // the unnecessary dispatch_async below, when the value is already `YES`.
    // All that in addition to the same check (synchronised) below when the value here is NO.
    if (self.odmInfoHasBeenProcessed) {
        [self.logger verbose:@"GoogleAdsOnDeviceConversion info has already been processed for this app"];
        return;
    }

    dispatch_async(self.internalQueue, ^{
        if(self.odmInfoHasBeenProcessed) {
            [self.logger verbose:@"GoogleAdsOnDeviceConversion info has already been processed for this app"];
            return;
        }

        // Handle the case when a one fetch call is already received and is being executed now
        // and second call to this method is done.
        if (self.odmInfoSendingInProcess) {
            [self.logger verbose:@"GoogleAdsOnDeviceConversion is being sent"];
            return;
        }

        // Handle the case when a one fetch call is already received
        // and the second call to this method is done.
        if (self.fetchOdmInfoBlock){
            [self.logger warn:@"Completion block has already been set"];
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

- (void)completeProcessingOdmInfoWithSuccess:(BOOL)success {
    [self.logger verbose:@"Finishing processing of GoogleAdsOnDeviceConversion info"];
    // Since odmInfoHasBeenProcessed can change from false to true only,
    // we are checking here in a not-synchronised way - in order to avoid
    // the unnecessary dispatch_async below, when the value is already `YES`.
    // All that in addition to the same check (synchronised) below when the value here is NO.
    if (self.odmInfoHasBeenProcessed) {
        [self.logger warn:@"Skipped because GoogleAdsOnDeviceConversion has already been processed for this app"];
        return;
    }

    dispatch_async(self.internalQueue, ^{
        if(self.odmInfoHasBeenProcessed) {
            [self.logger warn:@"Skipped because GoogleAdsOnDeviceConversion has already been processed for this app"];
            return;
        }
        self.odmInfoSendingInProcess = NO;
        self.odmInfoHasBeenProcessed = success;
        // Update UserDefaults in case odmInfo was processed successfully.
        if (success) {
            [ADJUserDefaults setGoogleOdmInfoProcessed];
            [self.logger warn:@"GoogleAdsOnDeviceConversion info has been processed"];
        }
    });
}

#pragma mark Internal

+ (BOOL)isOdmPluginAvailable {
    Class odmPluginClass = NSClassFromString(@"ADJOdmPlugin");
    if (odmPluginClass == nil) {
        [[ADJAdjustFactory logger] error:@"ADJOdmPlugin class not found"];
        return NO;
    }

    SEL selIsFrameworkAvailable = NSSelectorFromString(@"isOdmFrameworkAvailableWithError:");
    if (![odmPluginClass respondsToSelector:selIsFrameworkAvailable]) {
        [[ADJAdjustFactory logger] error:@"isOdmFrameworkAvailableWithError: method not found in ADJOdmPlugin class"];
        return NO;
    }

    SEL selOdmFrameworkVersion = NSSelectorFromString(@"odmFrameworkVersion");
    if (![odmPluginClass respondsToSelector:selOdmFrameworkVersion]) {
        [[ADJAdjustFactory logger] error:@"odmFrameworkVersion method not found in ADJOdmPlugin class"];
        return NO;
    }

    SEL selSetLaunchTime = NSSelectorFromString(@"setOdmAppFirstLaunchTimestamp:");
    if (![odmPluginClass respondsToSelector:selSetLaunchTime]) {
        [[ADJAdjustFactory logger] error:@"setOdmAppFirstLaunchTimestamp: method not found in ADJOdmPlugin class"];
        return NO;
    }

    SEL selFetchInfo = NSSelectorFromString(@"fetchOdmInfoWithCompletion:");
    if (![odmPluginClass respondsToSelector:selFetchInfo]) {
        [[ADJAdjustFactory logger] error:@"fetchOdmInfoWithCompletion: method not found in ADJOdmPlugin class"];
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

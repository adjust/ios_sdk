//
//  ADJAsaAttributionController.m
//  Adjust
//
//  Created by Aditi Agrawal on 20/09/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJAsaAttributionController.h"

#import "ADJUtilSys.h"
#import "ADJAsaAttributionStateStorageAction.h"
#import "ADJClickPackageData.h"
#import "ADJConstantsParam.h"
#import "ADJUtilMap.h"
#import "ADJUtilR.h"
#import "ADJValueWO.h"
#import "ADJUtilObj.h"
#import "ADJAdjustLogMessageData.h"

#pragma mark Fields

@interface ADJAsaAttributionController ()
#pragma mark - Injected dependencies
@property (nullable, readonly, weak, nonatomic) ADJLogQueueController *logQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJMainQueueController *mainQueueControllerWeak;
@property (nullable, readonly, weak, nonatomic) ADJSdkPackageBuilder *sdkPackageBuilderWeak;
@property (nullable, readonly, weak, nonatomic) ADJAsaAttributionStateStorage *storageWeak;
@property (nullable, readonly, weak, nonatomic) ADJClock *clockWeak;
@property (nonnull, readonly, strong, nonatomic) ADJExternalConfigData *asaAttributionConfig;

#pragma mark - Internal variables
@property (nonnull, readonly, strong, nonatomic) ADJSingleThreadExecutor *executor;
@property (assign, readwrite, nonatomic) BOOL canReadToken;
@property (assign, readwrite, nonatomic) BOOL isFinishedReading;
@property (assign, readwrite, nonatomic) BOOL isInDelay;
@property (assign, readwrite, nonatomic) BOOL mainQueueContainsAsaClickPackage;

@end

@implementation ADJAsaAttributionController
- (nonnull instancetype)
    initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageBuilder:(nonnull ADJSdkPackageBuilder *)sdkPackageBuilder
    asaAttributionStateStorage:(nonnull ADJAsaAttributionStateStorage *)asaAttributionStateStorage
    clock:(nonnull ADJClock *)clock
    clientConfigData:(nonnull ADJClientConfigData *)clientConfigData
    asaAttributionConfig:(nonnull ADJExternalConfigData *)asaAttributionConfig
    logQueueController:(nonnull ADJLogQueueController *)logQueueController
    mainQueueController:(nonnull ADJMainQueueController *)mainQueueController
    adjustAttributionStateStorage:
        (nonnull ADJAttributionStateStorage *)adjustAttributionStateStorage
{
    self = [super initWithLoggerFactory:loggerFactory source:@"AsaAttributionController"];
    _sdkPackageBuilderWeak = sdkPackageBuilder;
    _logQueueControllerWeak = logQueueController;
    _mainQueueControllerWeak = mainQueueController;
    _storageWeak = asaAttributionStateStorage;
    _clockWeak = clock;
    _storageWeak = asaAttributionStateStorage;
    _clockWeak = clock;
    _asaAttributionConfig = asaAttributionConfig;

    _executor = [threadExecutorFactory createSingleThreadExecutorWithLoggerFactory:loggerFactory
                                                                 sourceDescription:self.source];

    _canReadToken = [ADJAsaAttributionController
                     initialCanReadTokenWithClientConfig:clientConfigData
                     asaAttributionConfig:asaAttributionConfig
                     logger:self.logger];

    _isFinishedReading = NO;

    _isInDelay = NO;

    _mainQueueContainsAsaClickPackage = [mainQueueController containsAsaClickPackage];

    [ADJAsaAttributionController
     updateAdjustAttributionWithStateData:[adjustAttributionStateStorage readOnlyStoredDataValue]
     storage:asaAttributionStateStorage
     executor:self.executor];

    return self;
}

+ (BOOL)initialCanReadTokenWithClientConfig:(ADJClientConfigData *)clientConfigData
                       asaAttributionConfig:(nonnull ADJExternalConfigData *)asaAttributionConfig
                                     logger:(nonnull ADJLogger *)logger {
    BOOL canReadTokenFromClient = ! clientConfigData.doNotReadAsaAttribution;

    BOOL canTryToReadAtLeastOnce =
    asaAttributionConfig.libraryMaxReadAttempts != nil
    && ! [asaAttributionConfig.libraryMaxReadAttempts isZero];

    BOOL hasTimeoutToRead =
    asaAttributionConfig.timeoutPerAttempt != nil
    && ! [asaAttributionConfig.timeoutPerAttempt isZero];

    BOOL canReadTokenFromConfig = canTryToReadAtLeastOnce && hasTimeoutToRead;

    BOOL hasMininumOsVersion;
    if (@available(iOS 14.3, tvOS 14.3, macOS 11.1, macCatalyst 14.3, *)) {
        hasMininumOsVersion = YES;
    } else {
        hasMininumOsVersion = NO;
    }

    [logger debug:@"canReadTokenFromClient: %@, canReadTokenFromConfig: %@, hasMininumOsVersion: %@",
     @(canReadTokenFromClient), @(canReadTokenFromConfig), @(hasMininumOsVersion)];

    return canReadTokenFromClient && canReadTokenFromConfig && hasMininumOsVersion;
}

+ (void)updateAdjustAttributionWithStateData:(nonnull ADJAttributionStateData *)adjustAttributionStateData
                                     storage:(nonnull ADJAsaAttributionStateStorage *)storage
                                    executor:(nonnull ADJSingleThreadExecutor *)executor {
    ADJAsaAttributionStateData *_Nonnull stateData = [storage readOnlyStoredDataValue];

    // no need to update, since it already received a final adjust attribution previously
    if (stateData.hasReceivedAdjustAttribution) {
        return;
    }

    [executor executeInSequenceWithBlock:^{
        // read again, since it could, in theory, been updated betwwen threads
        ADJAsaAttributionStateData *_Nonnull currentStateData = [storage readOnlyStoredDataValue];

        if (currentStateData.hasReceivedAdjustAttribution) {
            return;
        }

        if (! ([adjustAttributionStateData unavailableStatus]
               || [adjustAttributionStateData hasAttributionStatus]))
        {
            return;
        }

        [storage updateWithNewDataValue:
         [[ADJAsaAttributionStateData alloc]
          initWithHasReceivedValidAsaClickResponse:
              currentStateData.hasReceivedValidAsaClickResponse
          hasReceivedAdjustAttribution:YES
          cachedToken:currentStateData.cachedToken
          cacheReadTimestamp:currentStateData.cacheReadTimestamp
          errorReason:currentStateData.errorReason]];
    }];
}

#pragma mark Public API
#pragma mark - Subscriptions
- (void)ccSubscribeToPublishersWithKeepAlivePublisher:(nonnull ADJKeepAlivePublisher *)keepAlivePublisher
                     preFirstMeasurementSessionStartPublisher:
(nonnull ADJPreFirstMeasurementSessionStartPublisher *)preFirstMeasurementSessionStartPublisher
                                 sdkResponsePublisher:(nonnull ADJSdkResponsePublisher *)sdkResponsePublisher
                                 attributionPublisher:(nonnull ADJAttributionPublisher *)attributionPublisher
                           sdkPackageSendingPublisher:(nonnull ADJSdkPackageSendingPublisher *)sdkPackageSendingPublisher {

    [keepAlivePublisher addSubscriber:self];
    [preFirstMeasurementSessionStartPublisher addSubscriber:self];
    [sdkResponsePublisher addSubscriber:self];
    [attributionPublisher addSubscriber:self];
    [sdkPackageSendingPublisher addSubscriber:self];
}

#pragma mark - ADJKeepAliveSubscriber
- (void)didKeepAlivePing {
    if (! self.canReadToken || self.isFinishedReading) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         strongSelf.asaAttributionConfig.libraryMaxReadAttempts];
    }];
}

#pragma mark - ADJPreFirstMeasurementSessionStartSubscriber
- (void)ccPreFirstMeasurementSessionStart:(BOOL)hasFirstSessionHappened {
    if (! self.canReadToken || self.isFinishedReading) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         strongSelf.asaAttributionConfig.libraryMaxReadAttempts];
    }];
}

#pragma mark - ADJSdkResponseSubscriber
- (void)didReceiveSdkResponseWithData:(nonnull id<ADJSdkResponseData>)sdkResponseData {
    if (sdkResponseData.shouldRetry) {
        return;
    }

    if (! [self isAsaClickPackageWithData:sdkResponseData.sourcePackage]) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleAsaClickPackage];
    }];
}

#pragma mark - ADJAttributionSubscriber
- (void)didAttributionWithData:(nullable ADJAttributionData *)attributionData
             attributionStatus:(nonnull NSString *)attributionStatus {
    ADJAsaAttributionStateStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot check if it has received adjust attribution"
         " without a reference to storage"];
        return;
    }

    ADJAsaAttributionStateData *_Nonnull stateData = [storage readOnlyStoredDataValue];

    // no need to update, since it already received a final adjust attribution previously
    if (stateData.hasReceivedAdjustAttribution) {
        return;
    }

    __typeof(self) __weak weakSelf = self;
    [self.executor executeInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        [strongSelf handleAdjustAttributionWithStatus:attributionStatus
                                              storage:storage];
    }];
}

#pragma mark - ADJSdkPackageSendingSubscriber
- (void)willSendSdkPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData
                   parametersToAdd:(nonnull ADJStringMapBuilder *)parametersToAdd
                      headersToAdd:(nonnull ADJStringMapBuilder *)headersToAdd {
    if (! [self isAsaClickPackageWithData:sdkPackageData]) {
        return;
    }

    ADJAsaAttributionStateStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot update sending asa attribution token"
         " without a reference to storage"];
        return;
    }

    ADJAsaAttributionStateData *_Nonnull stateData = [storage readOnlyStoredDataValue];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersToAdd
     key:ADJParamAsaAttributionTokenKey
     packageParamValueSerializable:stateData.cachedToken];

    [ADJUtilMap
     injectIntoPackageParametersWithBuilder:parametersToAdd
     key:ADJParamAsaAttributionReadAtKey
     packageParamValueSerializable:stateData.cacheReadTimestamp];
}

#pragma mark Internal Methods
- (BOOL)isAsaClickPackageWithData:(nonnull id<ADJSdkPackageData>)sdkPackageData {
    if (! [sdkPackageData.path isEqualToString:ADJClickPackageDataPath]) {
        return NO;
    }

    ADJNonEmptyString *_Nullable clickSourceValue =
    [sdkPackageData.parameters pairValueWithKey:ADJParamClickSourceKey];
    if (clickSourceValue == nil) {
        return NO;
    }

    return [clickSourceValue.stringValue isEqualToString:ADJParamAsaAttributionClickSourceValue];
}

- (void)handleAsaClickPackage {
    self.mainQueueContainsAsaClickPackage = NO;

    ADJAsaAttributionStateStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot check if it has received asa click"
         " without a reference to storage"];
        return;
    }

    ADJAsaAttributionStateData *_Nonnull currentStateData = [storage readOnlyStoredDataValue];

    // no need to update, since it already received a asa click previously
    if (currentStateData.hasReceivedValidAsaClickResponse) {
        return;
    }

    [storage updateWithNewDataValue:
     [[ADJAsaAttributionStateData alloc]
      initWithHasReceivedValidAsaClickResponse:YES
      hasReceivedAdjustAttribution:currentStateData.hasReceivedAdjustAttribution
      cachedToken:currentStateData.cachedToken
      cacheReadTimestamp:currentStateData.cacheReadTimestamp
      errorReason:currentStateData.errorReason]];
}

- (void)handleAdjustAttributionWithStatus:(nonnull NSString *)adjustAttributionStatus
                                  storage:(nonnull ADJAsaAttributionStateStorage *)storage {
    ADJAsaAttributionStateData *_Nonnull currentStateData = [storage readOnlyStoredDataValue];

    if (currentStateData.hasReceivedAdjustAttribution) {
        return;
    }

    BOOL attributionCreated = [adjustAttributionStatus isEqualToString:ADJAttributionStatusCreated];
    BOOL attributionUpdated = [adjustAttributionStatus isEqualToString:ADJAttributionStatusUpdated];
    BOOL attributionRead = [adjustAttributionStatus isEqualToString:ADJAttributionStatusRead];
    BOOL attributionNotAvailableFromBackend =
    [adjustAttributionStatus isEqualToString:ADJAttributionStatusNotAvailableFromBackend];

    if (! (attributionCreated
           || attributionUpdated
           || attributionRead
           || attributionNotAvailableFromBackend))
    {
        return;
    }

    [storage updateWithNewDataValue:
     [[ADJAsaAttributionStateData alloc]
      initWithHasReceivedValidAsaClickResponse:currentStateData.hasReceivedValidAsaClickResponse
      hasReceivedAdjustAttribution:YES
      cachedToken:currentStateData.cachedToken
      cacheReadTimestamp:currentStateData.cacheReadTimestamp
      errorReason:currentStateData.errorReason]];
}

- (void)processAsaAttibutionWithAttemptsLeft:(nullable ADJNonNegativeInt *)attemptsLeft {
    if (self.isInDelay || ! self.canReadToken) {
        return;
    }

    ADJAsaAttributionStateStorage *_Nullable storage = self.storageWeak;
    if (storage == nil) {
        [self.logger error:@"Cannot check Asa Attribution before sending"
         " without a reference to storage"];
        return;
    }

    ADJAsaAttributionStateData *_Nonnull stateData = [storage readOnlyStoredDataValue];

    BOOL hasFinishedReadingAsaAttribution =
    stateData.hasReceivedAdjustAttribution && stateData.hasReceivedValidAsaClickResponse;

    [self.logger debug:@"hasFinishedReadingAsaAttribution:"
     " hasReceivedAdjustAttribution (%@) && hasReceivedValidAsaClickResponse (%@)",
     @(stateData.hasReceivedAdjustAttribution), @(stateData.hasReceivedValidAsaClickResponse)];

    if (hasFinishedReadingAsaAttribution) {
        self.isFinishedReading = YES;
        return;
    }

    BOOL stateDataUpdated =
    [self refreshTokenWithStorage:storage
                     attemptsLeft:attemptsLeft];

    if (stateDataUpdated) {
        stateData = [storage readOnlyStoredDataValue];
    }

    [self trackAsaClickWithStateData:stateData];
}

- (BOOL)refreshTokenWithStorage:(nonnull ADJAsaAttributionStateStorage *)storage
                   attemptsLeft:(nullable ADJNonNegativeInt *)attemptsLeft {
    if (attemptsLeft == nil) {
        [self.logger info:@"Cannot refresh token with invalid number of attempts left"];
        return NO;
    }

    if (attemptsLeft.uIntegerValue == 0) {
        [self.logger debug:@"No more attempts left to refresh token"];
        return NO;
    }

    ADJAsaAttributionStateData *_Nonnull currentStateData = [storage readOnlyStoredDataValue];

    ADJValueWO<NSString *> *_Nonnull readAsaAttributionTokenWO = [[ADJValueWO alloc] init];

    NSString *_Nullable errorMessageString =
    [self readAsaAttributionTokenWithWO:readAsaAttributionTokenWO];

    ADJNonEmptyString *_Nullable readAsaAttributionToken =
    [ADJNonEmptyString instanceFromOptionalString:readAsaAttributionTokenWO.changedValue
                                sourceDescription:@"read Asa Attribution Token"
                                           logger:self.logger];

    if (readAsaAttributionToken == nil) {
        [self retryWithAttemptsLeft:attemptsLeft];
    }

    ADJNonEmptyString *_Nullable errorMessage =
    [ADJNonEmptyString instanceFromOptionalString:errorMessageString
                                sourceDescription:@"read Asa Attribution error message"
                                           logger:self.logger];

    BOOL tokenUpdated = NO;
    BOOL errorMessageUpdated = NO;

    ADJNonEmptyString *_Nullable tokenToWrite;
    ADJTimestampMilli *_Nullable timestampToWrite;

    if (readAsaAttributionToken != nil
        && ! [ADJUtilObj objectEquals:readAsaAttributionToken other:currentStateData.cachedToken])
    {
        tokenToWrite = readAsaAttributionToken;
        timestampToWrite = [self nowTimestamp];

        tokenUpdated = YES;
    } else {
        tokenToWrite = currentStateData.cachedToken;
        timestampToWrite = currentStateData.cacheReadTimestamp;
    }

    ADJNonEmptyString *_Nullable errorReasonToWrite;

    if (errorMessage != nil) {
        [self.logger error:@"Tryng to read token: %@", errorMessage];

        if (! [ADJUtilObj objectEquals:errorMessage other:currentStateData.errorReason]) {
            errorReasonToWrite = errorMessage;

            errorMessageUpdated = YES;

            [self trackNewErrorReason:errorMessage];
        } else {
            errorReasonToWrite = currentStateData.errorReason;
        }
    } else {
        errorReasonToWrite = currentStateData.errorReason;
    }

    if (! (tokenUpdated || errorMessageUpdated)) {
        return NO;
    }

    ADJAsaAttributionStateData *_Nonnull updatedStateData =
    [[ADJAsaAttributionStateData alloc]
     initWithHasReceivedValidAsaClickResponse:currentStateData.hasReceivedValidAsaClickResponse
     hasReceivedAdjustAttribution:currentStateData.hasReceivedAdjustAttribution
     cachedToken:tokenToWrite
     cacheReadTimestamp:timestampToWrite
     errorReason:errorReasonToWrite];

    [storage updateWithNewDataValue:updatedStateData];

    return YES;
}

- (nullable NSString *)readAsaAttributionTokenWithWO:(nonnull ADJValueWO<NSString *> *)asaAttributionTokenWO {
    // any error that happens before trying to read the Asa Attribution Token
    //  won't change during the current app execution,
    //  so it can be assumed that the token can't be read
    if (self.asaAttributionConfig.timeoutPerAttempt == nil) {
        self.canReadToken = NO;
        return @"Cannot attempt to read token without a timeout";
    }

    Class _Nullable classFromName = NSClassFromString(@"AAAttribution");
    if (classFromName == nil) {
        self.canReadToken = NO;
        return @"Could not detect AAAttribution class";
    }

    SEL _Nullable methodSelector = NSSelectorFromString(@"attributionTokenWithError:");
    if (! [classFromName respondsToSelector:methodSelector]) {
        self.canReadToken = NO;
        return @"Could not detect attributionTokenWithError: method";
    }

    IMP _Nullable methodImplementation = [classFromName methodForSelector:methodSelector];

    if (! methodImplementation) {
        self.canReadToken = NO;
        return @"Could not detect attributionTokenWithError: method implementation";
    }

    __block NSString* (*func)(id, SEL, NSError **) = (void *)methodImplementation;

    __block NSError *error = nil;

    __block NSString *_Nullable asaAttributionToken;

    BOOL readAsaAttributionTokenFinishedSuccessfully =
        [self.executor
            executeSynchronouslyWithTimeout:self.asaAttributionConfig.timeoutPerAttempt
            blockToExecute:^{
                // TODO cache in a dispatch_once: methodImplementation, classFromName and methodSelector
                asaAttributionToken = func(classFromName, methodSelector, &error);
            }];

    if (! readAsaAttributionTokenFinishedSuccessfully) {
        return @"Could not make or finish the [AAAttribution attributionTokenWithError:] call";
    }

    if (error) {
        /** typedef NS_ERROR_ENUM(AAAttributionErrorDomain, AAAttributionErrorCode)
         {
         AAAttributionErrorCodeNetworkError = 1,
         AAAttributionErrorCodeInternalError = 2,
         AAAttributionErrorCodePlatformNotSupported = 3
         } API_AVAILABLE(ios(14.3), macosx(11.1), tvos(14.3));
         */
        // AAAttributionError.platformNotSupported == 3 implies that it won't change
        if (error.code == 3) {
            self.canReadToken = NO;
        }
        return [ADJLogger formatNSError:error
                                message:
                @"[AAAttribution attributionTokenWithError:] call"];
    }

    if (asaAttributionToken == nil) {
        return @"Returned asa attribution token is nil";
    }

    [asaAttributionTokenWO setNewValue:asaAttributionToken];
    return nil;
}

- (nullable ADJTimestampMilli *)nowTimestamp {
    ADJClock *_Nullable clock = self.clockWeak;
    if (clock == nil) {
        return nil;
    }

    ADJTimestampMilli *_Nullable nowTimestamp =
    [clock nonMonotonicNowTimestampMilliWithLogger:self.logger];
    if (nowTimestamp == nil) {
        return nil;
    }

    return nowTimestamp;
}

- (void)retryWithAttemptsLeft:(nonnull ADJNonNegativeInt *)attemptsLeft {
    if ([attemptsLeft isZero]) {
        [self.logger debug:@"Cannot attempt to retry with zero attempts left"];
        return;
    }

    NSUInteger nextNumberOfAttemptsLeft = attemptsLeft.uIntegerValue - 1;
    if (nextNumberOfAttemptsLeft == 0) {
        [self.logger debug:@"Cannot attempt to retry after it was left with zero attempts"];
        return;
    }

    if (! self.canReadToken) {
        return;
    }

    if (self.asaAttributionConfig.delayBetweenAttempts == nil) {
        return;
    }

    self.isInDelay = YES;

    __typeof(self) __weak weakSelf = self;
    [self.executor scheduleInSequenceWithBlock:^{
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (strongSelf == nil) { return; }

        strongSelf.isInDelay = NO;

        [strongSelf processAsaAttibutionWithAttemptsLeft:
         [[ADJNonNegativeInt alloc] initWithUIntegerValue:nextNumberOfAttemptsLeft]];
    } delayTimeMilli:self.asaAttributionConfig.delayBetweenAttempts];
}

- (void)trackAsaClickWithStateData:(nonnull ADJAsaAttributionStateData *)stateData {
    if (self.mainQueueContainsAsaClickPackage) {
        [self.logger debug:@"Does not need to track asa click package"
         " since the main queue already contains one"];
        return;
    }

    if (stateData.cachedToken == nil) {
        [self.logger debug:@"Cannot track asa click without a read token"];
        return;
    }

    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger error:@"Cannot track asa click"
         " without a reference to package builder"];
        return;
    }

    ADJMainQueueController *_Nullable mainQueueController = self.mainQueueControllerWeak;
    if (mainQueueController == nil) {
        [self.logger error:@"Cannot track asa click"
         " without a reference to main queue controller"];
        return;
    }

    ADJClickPackageData *_Nonnull clickPackage =
    [sdkPackageBuilder buildAsaAttributionClickWithToken:stateData.cachedToken
                             asaAttributionReadTimestamp:stateData.cacheReadTimestamp];

    [mainQueueController addClickPackageToSendWithData:clickPackage
                                   sqliteStorageAction:nil];

    self.mainQueueContainsAsaClickPackage = YES;
}

- (void)trackNewErrorReason:(nonnull ADJNonEmptyString *)errorMessage {
    ADJSdkPackageBuilder *_Nullable sdkPackageBuilder = self.sdkPackageBuilderWeak;
    if (sdkPackageBuilder == nil) {
        [self.logger error:@"Cannot track new error reason"
         " without a reference to package builder"];
        return;
    }

    ADJLogQueueController *_Nullable logQueueController = self.logQueueControllerWeak;
    if (logQueueController == nil) {
        [self.logger error:@"Cannot track new error reason"
         " without a reference to log queue controller"];
        return;
    }

    ADJLogPackageData *_Nonnull logPackage =
    [sdkPackageBuilder buildLogPackageWithMessage:errorMessage
                                         logLevel:ADJAdjustLogLevelError
                                        logSource:self.source];

    [logQueueController addLogPackageDataToSendWithData:logPackage];
}

@end


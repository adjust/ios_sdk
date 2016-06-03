//
//  ADJActivityHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJActivityPackage.h"
#import "ADJActivityHandler.h"
#import "ADJActivityState.h"
#import "ADJPackageBuilder.h"
#import "ADJPackageHandler.h"
#import "ADJLogger.h"
#import "ADJTimerCycle.h"
#import "ADJTimerOnce.h"
#import "ADJUtil.h"
#import "UIDevice+ADJAdditions.h"
#import "ADJAdjustFactory.h"
#import "ADJAttributionHandler.h"
#import "NSString+ADJAdditions.h"
#import "ADJSdkClickHandler.h"
#import "ADJSessionParameters.h"

static NSString   * const kActivityStateFilename = @"AdjustIoActivityState";
static NSString   * const kAttributionFilename   = @"AdjustIoAttribution";
static NSString   * const kSessionParametersFilename   = @"AdjustSessionParameters";
static NSString   * const kSessionCallbackParametersFilename   = @"AdjustSessionCallbackParameters";
static NSString   * const kSessionPartnerParametersFilename    = @"AdjustSessionPartnerParameters";
static NSString   * const kAdjustPrefix          = @"adjust_";
static const char * const kInternalQueueName     = "io.adjust.ActivityQueue";
static NSString   * const kForegroundTimerName   = @"Foreground timer";
static NSString   * const kBackgroundTimerName   = @"Background timer";
static NSString   * const kDelayStartTimerName   = @"Delay Start timer";

static NSTimeInterval kForegroundTimerInterval;
static NSTimeInterval kForegroundTimerStart;
static NSTimeInterval kBackgroundTimerInterval;
static double kSessionInterval;
static double kSubSessionInterval;

// number of tries
static const int kTryIadV3                       = 2;
static const uint64_t kDelayRetryIad   =  2 * NSEC_PER_SEC; // 1 second

@implementation ADJInternalState

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    return self;
}

- (BOOL)isEnabled { return self.enabled; }
- (BOOL)isDisabled { return !self.enabled; }
- (BOOL)isOffline { return self.offline; }
- (BOOL)isOnline { return !self.offline; }
- (BOOL)isBackground { return self.background; }
- (BOOL)isForeground { return !self.background; }
- (BOOL)isDelayStart { return self.delayStart; }
- (BOOL)isToStartNow { return !self.delayStart; }
- (BOOL)isEventPreStart { return self.eventPreStart; }
- (BOOL)isRegularStart { return !self.eventPreStart; }
- (BOOL)isToUpdatePackages { return self.updatePackages; }

@end

#pragma mark -
@interface ADJActivityHandler()

@property (nonatomic, strong) dispatch_queue_t internalQueue;
@property (nonatomic, strong) id<ADJPackageHandler> packageHandler;
@property (nonatomic, strong) id<ADJAttributionHandler> attributionHandler;
@property (nonatomic, strong) id<ADJSdkClickHandler> sdkClickHandler;
@property (nonatomic, strong) ADJActivityState *activityState;
@property (nonatomic, strong) ADJTimerCycle *foregroundTimer;
@property (nonatomic, strong) ADJTimerOnce *backgroundTimer;
@property (nonatomic, strong) ADJInternalState *internalState;
@property (nonatomic, strong) ADJDeviceInfo *deviceInfo;
@property (nonatomic, strong) ADJTimerOnce *delayStartTimer;
@property (nonatomic, strong) ADJSessionParameters *sessionParameters;
// weak for object that Activity Handler does not "own"
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, weak) NSObject<AdjustDelegate> *adjustDelegate;
// copy for objects shared with the user
@property (nonatomic, copy) ADJAttribution *attribution;
@property (nonatomic, copy) ADJConfig *adjustConfig;

@end

// copy from ADClientError
typedef NS_ENUM(NSInteger, AdjADClientError) {
    AdjADClientErrorUnknown = 0,
    AdjADClientErrorLimitAdTracking = 1,
};

#pragma mark -
@implementation ADJActivityHandler

+ (id<ADJActivityHandler>)handlerWithConfig:(ADJConfig *)adjustConfig
             sessionParametersActionsArray:(NSArray*)sessionParametersActionsArray
{
    return [[ADJActivityHandler alloc] initWithConfig:adjustConfig
                       sessionParametersActionsArray:sessionParametersActionsArray];
}

- (id)initWithConfig:(ADJConfig *)adjustConfig
sessionParametersActionsArray:(NSArray*)sessionParametersActionsArray
{
    self = [super init];
    if (self == nil) return nil;

    if (adjustConfig == nil) {
        [ADJAdjustFactory.logger error:@"AdjustConfig missing"];
        return nil;
    }

    if (![adjustConfig isValid]) {
        [ADJAdjustFactory.logger error:@"AdjustConfig not initialized correctly"];
        return nil;
    }

    self.adjustConfig = adjustConfig;
    self.adjustDelegate = adjustConfig.delegate;

    // init logger to be available everywhere
    self.logger = ADJAdjustFactory.logger;

    if ([self.adjustConfig.environment isEqualToString:ADJEnvironmentProduction]) {
        [self.logger setLogLevel:ADJLogLevelAssert];
    } else {
        [self.logger setLogLevel:self.adjustConfig.logLevel];
    }

    // read files to have sync values available
    [self readAttribution];
    [self readActivityState];

    self.internalState = [[ADJInternalState alloc] init];

    // enabled by default
    if (self.activityState == nil) {
        self.internalState.enabled = YES;
    } else {
        self.internalState.enabled = self.activityState.enabled;
    }

    // online by default
    self.internalState.offline = NO;
    // in the background by default
    self.internalState.background = YES;
    // delay start not configured by default
    self.internalState.delayStart = NO;
    // event pre-start does not occur by default
    self.internalState.eventPreStart = NO;
    // does not need to update packages by default
    if (self.activityState == nil) {
        self.internalState.updatePackages = NO;
    } else {
        self.internalState.updatePackages = self.activityState.updatePackages;
    }

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.internalQueue, ^{
        [self initInternal:sessionParametersActionsArray];
    });

    [self addNotificationObserver];

    return self;
}

- (void)applicationDidBecomeActive {
    self.internalState.background = NO;

    dispatch_async(self.internalQueue, ^{
        [self delayStartInternal];

        // marks regular start
        self.internalState.eventPreStart = NO;

        [self stopBackgroundTimer];

        [self startForegroundTimer];

        [self.logger verbose:@"Subsession start"];

        [self startInternal];
    });
}

- (void)applicationWillResignActive {
    self.internalState.background = YES;

    dispatch_async(self.internalQueue, ^{
        [self stopForegroundTimer];

        [self startBackgroundTimer];

        [self.logger verbose:@"Subsession end"];

        [self endInternal];
    });
}

- (void)trackEvent:(ADJEvent *)event {
    dispatch_async(self.internalQueue, ^{
        // track event called before app started
        if (self.activityState == nil) {
            // not the regular start
            self.internalState.eventPreStart = YES;
            [self startInternal];
        }
        [self eventInternal:event];
    });
}

- (void)finishedTracking:(ADJResponseData *)responseData {
    // redirect session responses to attribution handler to check for attribution information
    if ([responseData isKindOfClass:[ADJSessionResponseData class]]) {
        [self.attributionHandler checkSessionResponse:(ADJSessionResponseData*)responseData];
        return;
    }

    // check if it's an event response
    if ([responseData isKindOfClass:[ADJEventResponseData class]]) {
        [self launchEventResponseTasks:(ADJEventResponseData*)responseData];
        return;
    }
}

- (void)launchEventResponseTasks:(ADJEventResponseData *)eventResponseData {
    dispatch_async(self.internalQueue, ^{
        [self launchEventResponseTasksInternal:eventResponseData];
    });
}

- (void)launchSessionResponseTasks:(ADJSessionResponseData *)sessionResponseData {
    dispatch_async(self.internalQueue, ^{
        [self launchSessionResponseTasksInternal:sessionResponseData];
    });
}

- (void)launchAttributionResponseTasks:(ADJAttributionResponseData *)attributionResponseData {
    dispatch_async(self.internalQueue, ^{
        [self launchAttributionResponseTasksInternal:attributionResponseData];
    });
}

- (void)setEnabled:(BOOL)enabled {
    // compare with the saved or internal state
    if (![self hasChangedState:[self isEnabled]
                     nextState:enabled
                   trueMessage:@"Adjust already enabled"
                  falseMessage:@"Adjust already disabled"])
    {
        return;
    }

    // save new enabled state in internal state
    self.internalState.enabled = enabled;

    if (self.activityState == nil) {
        [self updateState:!enabled
           pausingMessage:@"Handlers will start as paused due to the SDK being disabled"
     remainsPausedMessage:@"Handlers will still start as paused"
         unPausingMessage:@"Handlers will start as active due to the SDK being enabled"];
        return;
    }

    // save new enabled state in activity state
    self.activityState.enabled = enabled;
    [self writeActivityState];

    [self updateState:!enabled
       pausingMessage:@"Pausing handlers due to SDK being disabled"
 remainsPausedMessage:@"Handlers remain paused"
     unPausingMessage:@"Resuming handlers due to SDK being enabled"];
}

- (void)setOfflineMode:(BOOL)offline {
    // compare with the internal state
    if (![self hasChangedState:[self.internalState isOffline]
                     nextState:offline
                   trueMessage:@"Adjust already in offline mode"
                  falseMessage:@"Adjust already in online mode"])
    {
        return;
    }

    // save new offline state in internal state
    self.internalState.offline = offline;

    if (self.activityState == nil) {
        [self updateState:offline
           pausingMessage:@"Handlers will start paused due to SDK being offline"
     remainsPausedMessage:@"Handlers will still start as paused"
         unPausingMessage:@"Handlers will start as active due to SDK being online"];
        return;
    }

    [self updateState:offline
       pausingMessage:@"Pausing handlers to put SDK offline mode"
 remainsPausedMessage:@"Handlers remain paused"
     unPausingMessage:@"Resuming handlers to put SDK in online mode"];
}

- (BOOL)isEnabled {
    if (self.activityState != nil) {
        return self.activityState.enabled;
    } else {
        return [self.internalState isEnabled];
    }
}

- (BOOL)isToUpdatePackages {
    if (self.activityState != nil) {
        return self.activityState.updatePackages;
    } else {
        return [self.internalState isToUpdatePackages];
    }
}

- (BOOL)hasChangedState:(BOOL)previousState
              nextState:(BOOL)nextState
            trueMessage:(NSString *)trueMessage
           falseMessage:(NSString *)falseMessage
{
    if (previousState != nextState) {
        return YES;
    }

    if (previousState) {
        [self.logger debug:trueMessage];
    } else {
        [self.logger debug:falseMessage];
    }

    return NO;
}

- (void)updateState:(BOOL)pausingState
     pausingMessage:(NSString *)pausingMessage
remainsPausedMessage:(NSString *)remainsPausedMessage
   unPausingMessage:(NSString *)unPausingMessage
{
    // it is changing from an active state to a pause state
    if (pausingState) {
        [self.logger info:pausingMessage];
    }
    // check if it's remaining in a pause state
    else if ([self paused:NO]) {
        // including the sdk click handler
        if ([self paused:YES]) {
            [self.logger info:remainsPausedMessage];
        } else {
            // or except it
            [self.logger info:[remainsPausedMessage stringByAppendingString:@", except the Sdk Click Handler"]];
        }
    } else {
        // it is changing from a pause state to an active state
        [self.logger info:unPausingMessage];
    }

    [self updateHandlersStatusAndSend];
}

- (void)appWillOpenUrl:(NSURL*)url {
    dispatch_async(self.internalQueue, ^{
        [self appWillOpenUrlInternal:url];
    });
}

- (void)setDeviceToken:(NSData *)deviceToken {
    dispatch_async(self.internalQueue, ^{
        [self setDeviceTokenInternal:deviceToken];
    });
}

- (void)setIadDate:(NSDate *)iAdImpressionDate withPurchaseDate:(NSDate *)appPurchaseDate {
    if (iAdImpressionDate == nil) {
        [self.logger debug:@"iAdImpressionDate not received"];
        return;
    }

    [self.logger debug:@"iAdImpressionDate received: %@", iAdImpressionDate];


    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder *clickBuilder = [[ADJPackageBuilder alloc]
                                       initWithDeviceInfo:self.deviceInfo
                                       activityState:self.activityState
                                       config:self.adjustConfig
                                       createdAt:now];

    clickBuilder.purchaseTime = appPurchaseDate;
    clickBuilder.clickTime = iAdImpressionDate;

    ADJActivityPackage *clickPackage = [clickBuilder buildClickPackage:@"iad"];
    [self.sdkClickHandler sendSdkClick:clickPackage];
}

- (void)setIadDetails:(NSDictionary *)attributionDetails
                error:(NSError *)error
          retriesLeft:(int)retriesLeft
{
    if (![ADJUtil isNull:error]) {
        [self.logger warn:@"Unable to read iAd details"];

        if (retriesLeft < 0) {
            [self.logger warn:@"Limit number of retry for iAd v3 surpassed"];
            return;
        }

        if (error.code == AdjADClientErrorUnknown) {
            dispatch_time_t retryTime = dispatch_time(DISPATCH_TIME_NOW, kDelayRetryIad);
            dispatch_after(retryTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[UIDevice currentDevice] adjSetIad:self triesV3Left:retriesLeft];
            });
        }
        return;
    }

    if ([ADJUtil isNull:attributionDetails]) {
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder *clickBuilder = [[ADJPackageBuilder alloc]
                                       initWithDeviceInfo:self.deviceInfo
                                       activityState:self.activityState
                                       config:self.adjustConfig
                                       createdAt:now];

    clickBuilder.iadDetails = attributionDetails;

    ADJActivityPackage *clickPackage = [clickBuilder buildClickPackage:@"iad3"];
    [self.sdkClickHandler sendSdkClick:clickPackage];
}

- (void)setAskingAttribution:(BOOL)askingAttribution {
    self.activityState.askingAttribution = askingAttribution;
    [self writeActivityState];
}

- (void)updateHandlersStatusAndSend {
    dispatch_async(self.internalQueue, ^{
        [self updateHandlersStatusAndSendInternal];
    });
}

- (void)foregroundTimerFired {
    dispatch_async(self.internalQueue, ^{
        [self foregroundTimerFiredInternal];
    });
}

- (void)backgroundTimerFired {
    dispatch_async(self.internalQueue, ^{
        [self backgroundTimerFiredInternal];
    });
}

- (void)sendFirstPackages {
    dispatch_async(self.internalQueue, ^{
        [self sendFirstPackagesInternal];
    });
}

- (void)addCustomUserId:(NSString *)customUserId {
    dispatch_async(self.internalQueue, ^{
        [self addCustomUserIdInternal:customUserId];
    });
}

- (void)addSessionCallbackParameter:(NSString *)key
                              value:(NSString *)value {
    dispatch_async(self.internalQueue, ^{
        [self addSessionCallbackParameterInternal:key value:value];
    });
}

- (void)addSessionPartnerParameter:(NSString *)key
                             value:(NSString *)value {
    dispatch_async(self.internalQueue, ^{
        [self addSessionPartnerParameterInternal:key value:value];
    });
}

- (void)removeSessionCallbackParameter:(NSString *)key {
    dispatch_async(self.internalQueue, ^{
        [self removeSessionCallbackParameterInternal:key];
    });
}

- (void)removeSessionPartnerParameter:(NSString *)key {
    dispatch_async(self.internalQueue, ^{
        [self removeSessionPartnerParameterInternal:key];
    });
}

- (void)resetCustomUserId {
    dispatch_async(self.internalQueue, ^{
        [self resetCustomUserIdInternal];
    });
}

- (void)resetSessionCallbackParameters {
    dispatch_async(self.internalQueue, ^{
        [self resetSessionCallbackParametersInternal];
    });
}

- (void)resetSessionPartnerParameters {
    dispatch_async(self.internalQueue, ^{
        [self resetSessionPartnerParametersInternal];
    });
}


#pragma mark - internal
- (void)initInternal:(NSArray*)sessionParametersActionsArray
{
    // get session values
    kSessionInterval = ADJAdjustFactory.sessionInterval;
    kSubSessionInterval = ADJAdjustFactory.subsessionInterval;
    // get timer values
    kForegroundTimerStart = ADJAdjustFactory.timerStart;
    kForegroundTimerInterval = ADJAdjustFactory.timerInterval;
    kBackgroundTimerInterval = ADJAdjustFactory.timerInterval;

    self.deviceInfo = [ADJDeviceInfo deviceInfoWithSdkPrefix:self.adjustConfig.sdkPrefix];

    // read files that are accessed only in Internal sections
    [self readSessionParameters];
    if (self.sessionParameters == nil) {
        self.sessionParameters = [[ADJSessionParameters alloc] init];
    }
    [self readSessionCallbackParameters];
    [self readSessionPartnerParameters];

    if (self.adjustConfig.eventBufferingEnabled)  {
        [self.logger info:@"Event buffering is enabled"];
    }

    if (self.adjustConfig.defaultTracker != nil) {
        [self.logger info:@"Default tracker: '%@'", self.adjustConfig.defaultTracker];
    }

    self.foregroundTimer = [ADJTimerCycle timerWithBlock:^{ [self foregroundTimerFired]; }
                                                   queue:self.internalQueue
                                               startTime:kForegroundTimerStart
                                            intervalTime:kForegroundTimerInterval
                                                    name:kForegroundTimerName];

    if (self.adjustConfig.sendInBackground) {
        [self.logger info:@"Send in background configured"];
        self.backgroundTimer = [ADJTimerOnce timerWithBlock:^{ [self backgroundTimerFired]; }
                                                      queue:self.internalQueue
                                                       name:kBackgroundTimerName];
    }

    if (self.activityState == nil &&
        self.adjustConfig.delayStart > 0)
    {
        [self.logger info:@"Delay start configured"];
        self.internalState.delayStart = YES;
        self.delayStartTimer = [ADJTimerOnce timerWithBlock:^{ [self sendFirstPackages]; }
                                                      queue:self.internalQueue
                                                       name:kDelayStartTimerName];

    }

    self.packageHandler = [ADJAdjustFactory packageHandlerForActivityHandler:self
                                                               startsSending:[self toSend:NO]];

    // update session parameters in package queue
    if ([self isToUpdatePackages]) {
        [self updatePackagesInternal];
     }

    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder *attributionBuilder = [[ADJPackageBuilder alloc]
                                             initWithDeviceInfo:self.deviceInfo
                                             activityState:self.activityState
                                             config:self.adjustConfig
                                             createdAt:now];
    ADJActivityPackage *attributionPackage = [attributionBuilder buildAttributionPackage];
    self.attributionHandler = [ADJAdjustFactory attributionHandlerForActivityHandler:self
                                                              withAttributionPackage:attributionPackage
                                                                       startsSending:[self toSend:NO]
                                                       hasAttributionChangedDelegate:self.adjustConfig.hasAttributionChangedDelegate];

    self.sdkClickHandler = [ADJAdjustFactory sdkClickHandlerWithStartsPaused:[self toSend:YES]];

    [[UIDevice currentDevice] adjSetIad:self triesV3Left:kTryIadV3];

    [self sessionParametersActionsInternal:sessionParametersActionsArray];

    [self startInternal];
}

- (void)startInternal {
    // it shouldn't start if it was disabled after a first session
    if (self.activityState != nil
        && !self.activityState.enabled) {
        return;
    }

    [self updateHandlersStatusAndSendInternal];

    [self processSession];

    [self checkAttributionState];
}

- (void)processSession {
    double now = [NSDate.date timeIntervalSince1970];

    // very first session
    if (self.activityState == nil) {
        self.activityState = [[ADJActivityState alloc] init];
        self.activityState.sessionCount = 1; // this is the first session

        [self transferSessionPackage:now];
        [self.activityState resetSessionAttributes:now];
        self.activityState.enabled = [self.internalState isEnabled];
        self.activityState.updatePackages = [self.internalState isToUpdatePackages];
        [self writeActivityState];
        return;
    }

    double lastInterval = now - self.activityState.lastActivity;
    if (lastInterval < 0) {
        [self.logger error:@"Time travel!"];
        self.activityState.lastActivity = now;
        [self writeActivityState];
        return;
    }

    // new session
    if (lastInterval > kSessionInterval) {
        self.activityState.sessionCount++;
        self.activityState.lastInterval = lastInterval;

        [self transferSessionPackage:now];
        [self.activityState resetSessionAttributes:now];
        [self writeActivityState];
        return;
    }

    // new subsession
    if (lastInterval > kSubSessionInterval) {
        self.activityState.subsessionCount++;
        self.activityState.sessionLength += lastInterval;
        self.activityState.lastActivity = now;
        [self.logger verbose:@"Started subsession %d of session %d",
         self.activityState.subsessionCount,
         self.activityState.sessionCount];
        [self writeActivityState];
        return;
    }

    [self.logger verbose:@"Time span since last activity too short for a new subsession"];
}

- (void)transferSessionPackage:(double)now {
    ADJPackageBuilder *sessionBuilder = [[ADJPackageBuilder alloc]
                                         initWithDeviceInfo:self.deviceInfo
                                         activityState:self.activityState
                                         config:self.adjustConfig
                                         createdAt:now];
    ADJActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage:self.sessionParameters isInDelay:[self.internalState delayStart]];
    [self.packageHandler addPackage:sessionPackage];
    [self.packageHandler sendFirstPackage];
}

- (void)checkAttributionState {
    if (![self checkActivityState]) return;

    // if it' a new session
    if (self.activityState.subsessionCount <= 1) {
        return;
    }

    // if there is already an attribution saved and there was no attribution being asked
    if (self.attribution != nil && !self.activityState.askingAttribution) {
        return;
    }

    [self.attributionHandler getAttribution];
}

- (void)endInternal {
    // pause sending if it's not allowed to send
    if (![self toSend]) {
        [self pauseSending];
    }

    double now = [NSDate.date timeIntervalSince1970];
    if ([self updateActivityState:now]) {
        [self writeActivityState];
    }
}

- (void)eventInternal:(ADJEvent *)event {
    if (![self isEnabled]) return;
    if (![self checkEvent:event]) return;
    if (![self checkTransactionId:event.transactionId]) return;

    double now = [NSDate.date timeIntervalSince1970];

    self.activityState.eventCount++;
    [self updateActivityState:now];

    // create and populate event package
    ADJPackageBuilder *eventBuilder = [[ADJPackageBuilder alloc]
                                       initWithDeviceInfo:self.deviceInfo
                                       activityState:self.activityState
                                       config:self.adjustConfig
                                       createdAt:now];
    ADJActivityPackage *eventPackage = [eventBuilder buildEventPackage:event sessionParameters:self.sessionParameters isInDelay:[self.internalState delayStart]];
    [self.packageHandler addPackage:eventPackage];

    if (self.adjustConfig.eventBufferingEnabled) {
        [self.logger info:@"Buffered event %@", eventPackage.suffix];
    } else {
        [self.packageHandler sendFirstPackage];
    }

    // if it is in the background and it can send, start the background timer
    if (self.adjustConfig.sendInBackground && [self.internalState isBackground]) {
        [self startBackgroundTimer];
    }

    [self writeActivityState];
}

- (void) launchEventResponseTasksInternal:(ADJEventResponseData *)eventResponseData {
    // event success callback
    if (eventResponseData.success
        && [self.adjustDelegate respondsToSelector:@selector(adjustEventTrackingSucceeded:)])
    {
        [self.logger debug:@"Launching success event tracking delegate"];
        [ADJUtil launchInMainThread:self.adjustDelegate
                           selector:@selector(adjustEventTrackingSucceeded:)
                         withObject:[eventResponseData successResponseData]];
        return;
    }
    // event failure callback
    if (!eventResponseData.success
        && [self.adjustDelegate respondsToSelector:@selector(adjustEventTrackingFailed:)])
    {
        [self.logger debug:@"Launching failed event tracking delegate"];
        [ADJUtil launchInMainThread:self.adjustDelegate
                           selector:@selector(adjustEventTrackingFailed:)
                         withObject:[eventResponseData failureResponseData]];
        return;
    }
}

- (void) launchSessionResponseTasksInternal:(ADJSessionResponseData *)sessionResponseData {
    BOOL toLaunchAttributionDelegate = [self updateAttribution:sessionResponseData.attribution];

    // session success callback
    if (sessionResponseData.success
        && [self.adjustDelegate respondsToSelector:@selector(adjustSessionTrackingSucceeded:)])
    {
        [self.logger debug:@"Launching success session tracking delegate"];
        [ADJUtil launchInMainThread:self.adjustDelegate
                           selector:@selector(adjustSessionTrackingSucceeded:)
                         withObject:[sessionResponseData successResponseData]];
    }
    // session failure callback
    if (!sessionResponseData.success
        && [self.adjustDelegate respondsToSelector:@selector(adjustSessionTrackingFailed:)])
    {
        [self.logger debug:@"Launching failed session tracking delegate"];
        [ADJUtil launchInMainThread:self.adjustDelegate
                           selector:@selector(adjustSessionTrackingFailed:)
                         withObject:[sessionResponseData failureResponseData]];
    }

    // try to update and launch the attribution changed delegate
    if (toLaunchAttributionDelegate) {
        [self.logger debug:@"Launching attribution changed delegate"];
        [ADJUtil launchInMainThread:self.adjustDelegate
                           selector:@selector(adjustAttributionChanged:)
                         withObject:sessionResponseData.attribution];
    }
}

- (void)prepareDeeplink:(ADJResponseData *)responseData {
    if (responseData == nil) {
        return;
    }

    NSString *deepLink = [responseData.jsonResponse objectForKey:@"deeplink"];
    if (deepLink == nil) {
        return;
    }

    NSURL* deepLinkUrl = [NSURL URLWithString:deepLink];

    [self.logger info:@"Open deep link (%@)", deepLink];

    [ADJUtil launchInMainThread:^{
        BOOL toLaunchDeeplink = YES;

        if ([self.adjustDelegate respondsToSelector:@selector(adjustDeeplinkResponse:)]) {
            toLaunchDeeplink = [self.adjustDelegate adjustDeeplinkResponse:deepLinkUrl];
        }

        if (toLaunchDeeplink) {
            [self launchDeepLinkMain:deepLinkUrl];
        }
    }];
}

- (void)launchDeepLinkMain:(NSURL *) deepLinkUrl{
    BOOL success = [[UIApplication sharedApplication] openURL:deepLinkUrl];

    if (!success) {
        [self.logger error:@"Unable to open deep link (%@)", deepLinkUrl];
    }
}

- (void) launchAttributionResponseTasksInternal:(ADJAttributionResponseData *)attributionResponseData {
    BOOL toLaunchAttributionDelegate = [self updateAttribution:attributionResponseData.attribution];

    // try to update and launch the attribution changed delegate non-blocking
    if (toLaunchAttributionDelegate) {
        [self.logger debug:@"Launching attribution changed delegate"];
        [ADJUtil launchInMainThread:self.adjustDelegate
                           selector:@selector(adjustAttributionChanged:)
                         withObject:attributionResponseData.attribution];
    }

    [self prepareDeeplink:attributionResponseData];
}

- (BOOL)updateAttribution:(ADJAttribution *)attribution {
    if (attribution == nil) {
        return NO;
    }
    if ([attribution isEqual:self.attribution]) {
        return NO;
    }
    self.attribution = attribution;
    [self writeAttribution];

    if (self.adjustDelegate == nil) {
        return NO;
    }

    if (![self.adjustConfig hasAttributionChangedDelegate]) {
        return NO;
    }

    if (![self.adjustDelegate respondsToSelector:@selector(adjustAttributionChanged:)]) {
        return NO;
    }

    return YES;
}

- (void) appWillOpenUrlInternal:(NSURL *)url {
    if ([ADJUtil isNull:url]) {
        return;
    }

    if ([[url absoluteString] length] == 0) {
        return;
    }

    NSArray* queryArray = [url.query componentsSeparatedByString:@"&"];
    if (queryArray == nil) {
        queryArray = @[];
    }

    NSMutableDictionary* adjustDeepLinks = [NSMutableDictionary dictionary];
    ADJAttribution *deeplinkAttribution = [[ADJAttribution alloc] init];

    for (NSString* fieldValuePair in queryArray) {
        [self readDeeplinkQueryString:fieldValuePair adjustDeepLinks:adjustDeepLinks attribution:deeplinkAttribution];
    }

    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder *clickBuilder = [[ADJPackageBuilder alloc]
                                       initWithDeviceInfo:self.deviceInfo
                                       activityState:self.activityState
                                       config:self.adjustConfig
                                       createdAt:now];
    clickBuilder.deeplinkParameters = adjustDeepLinks;
    clickBuilder.attribution = deeplinkAttribution;
    clickBuilder.clickTime = [NSDate date];
    clickBuilder.deeplink = [url absoluteString];

    ADJActivityPackage *clickPackage = [clickBuilder buildClickPackage:@"deeplink"];
    [self.sdkClickHandler sendSdkClick:clickPackage];
}

- (BOOL) readDeeplinkQueryString:(NSString *)queryString
                 adjustDeepLinks:(NSMutableDictionary*)adjustDeepLinks
                     attribution:(ADJAttribution *)deeplinkAttribution
{
    NSArray* pairComponents = [queryString componentsSeparatedByString:@"="];
    if (pairComponents.count != 2) return NO;

    NSString* key = [pairComponents objectAtIndex:0];
    if (![key hasPrefix:kAdjustPrefix]) return NO;

    NSString* keyDecoded = [key adjUrlDecode];

    NSString* value = [pairComponents objectAtIndex:1];
    if (value.length == 0) return NO;

    NSString* valueDecoded = [value adjUrlDecode];

    NSString* keyWOutPrefix = [keyDecoded substringFromIndex:kAdjustPrefix.length];
    if (keyWOutPrefix.length == 0) return NO;

    if (![self trySetAttributionDeeplink:deeplinkAttribution withKey:keyWOutPrefix withValue:valueDecoded]) {
        [adjustDeepLinks setObject:valueDecoded forKey:keyWOutPrefix];
    }

    return YES;
}

- (BOOL) trySetAttributionDeeplink:(ADJAttribution *)deeplinkAttribution
                           withKey:(NSString *)key
                         withValue:(NSString*)value {

    if ([key isEqualToString:@"tracker"]) {
        deeplinkAttribution.trackerName = value;
        return YES;
    }

    if ([key isEqualToString:@"campaign"]) {
        deeplinkAttribution.campaign = value;
        return YES;
    }

    if ([key isEqualToString:@"adgroup"]) {
        deeplinkAttribution.adgroup = value;
        return YES;
    }

    if ([key isEqualToString:@"creative"]) {
        deeplinkAttribution.creative = value;
        return YES;
    }

    return NO;
}

- (void)setDeviceTokenInternal:(NSData *)deviceToken {
    if (deviceToken == nil) {
        return;
    }

    NSString *deviceTokenString = [deviceToken.description stringByTrimmingCharactersInSet:
                       [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];

    if (![self updateDeviceToken:deviceTokenString]) {
        return;
    }

    double now = [NSDate.date timeIntervalSince1970];
    ADJPackageBuilder * clickBuilder = [[ADJPackageBuilder alloc]
                                        initWithDeviceInfo:self.deviceInfo
                                        activityState:self.activityState
                                        config:self.adjustConfig
                                        createdAt:now];

    clickBuilder.deviceToken = deviceTokenString;

    ADJActivityPackage * clickPackage = [clickBuilder buildClickPackage:@"push"];

    [self.sdkClickHandler sendSdkClick:clickPackage];
}

- (BOOL)updateDeviceToken:(NSString *)deviceToken {
    if (deviceToken == nil) {
        return NO;
    }

    if ([deviceToken isEqualToString:self.activityState.deviceToken]) {
        return NO;
    }

    return YES;
}

#pragma mark - private

// returns whether or not the activity state should be written
- (BOOL)updateActivityState:(double)now {
    if (![self checkActivityState]) return NO;

    double lastInterval = now - self.activityState.lastActivity;

    // ignore late updates
    if (lastInterval > kSessionInterval) return NO;

    self.activityState.lastActivity = now;

    if (lastInterval < 0) {
        [self.logger error:@"Time travel!"];
        return YES;
    } else {
        self.activityState.sessionLength += lastInterval;
        self.activityState.timeSpent += lastInterval;
    }

    return YES;
}

- (void)writeActivityState {
    [ADJUtil writeObject:self.activityState filename:kActivityStateFilename objectName:@"Activity state"];
}

- (void)writeAttribution {
    [ADJUtil writeObject:self.attribution filename:kAttributionFilename objectName:@"Attribution"];
}

- (void)writeSessionParameters {
    [ADJUtil writeObject:self.sessionParameters
                filename:kSessionParametersFilename
              objectName:@"Session parameters"];
}

- (void)writeSessionCallbackParameters {
    [ADJUtil writeObject:self.sessionParameters.callbackParameters
                filename:kSessionCallbackParametersFilename
              objectName:@"Session Callback parameters"];
}

- (void)writeSessionPartnerParameters {
    [ADJUtil writeObject:self.sessionParameters.partnerParameters
                filename:kSessionPartnerParametersFilename
              objectName:@"Session Partner parameters"];
}

- (void)readActivityState {
    [NSKeyedUnarchiver setClass:[ADJActivityState class] forClassName:@"AIActivityState"];
    self.activityState = [ADJUtil readObject:kActivityStateFilename
                                  objectName:@"Activity state"
                                       class:[ADJActivityState class]];
}

- (void)readAttribution {
    self.attribution = [ADJUtil readObject:kAttributionFilename
                                objectName:@"Attribution"
                                     class:[ADJAttribution class]];
}

- (void)readSessionParameters {
    self.sessionParameters = [ADJUtil readObject:kSessionParametersFilename
                                      objectName:@"Session parameters"
                                           class:[ADJSessionParameters class]];
}
- (void)readSessionCallbackParameters {
    self.sessionParameters.callbackParameters = [ADJUtil readObject:kSessionCallbackParametersFilename
                                                         objectName:@"Session Callback parameters"
                                                              class:[NSDictionary class]];
}

- (void)readSessionPartnerParameters {
    self.sessionParameters.partnerParameters = [ADJUtil readObject:kSessionPartnerParametersFilename
                                                        objectName:@"Session Partner parameters"
                                                             class:[NSDictionary class]];
}

# pragma mark - handlers status
- (void)updateHandlersStatusAndSendInternal {
    // check if it should stop sending
    if (![self toSend]) {
        [self pauseSending];
        return;
    }

    [self resumeSending];

    // try to send
    if (!self.adjustConfig.eventBufferingEnabled) {
        [self.packageHandler sendFirstPackage];
    }
}

- (void)pauseSending {
    [self.attributionHandler pauseSending];
    [self.packageHandler pauseSending];
    // the conditions to pause the sdk click handler are less restrictive
    // it's possible for the sdk click handler to be active while others are paused
    if (![self toSend:YES]) {
        [self.sdkClickHandler pauseSending];
    }
}

- (void)resumeSending {
    [self.attributionHandler resumeSending];
    [self.packageHandler resumeSending];
    [self.sdkClickHandler resumeSending];
}

- (BOOL)paused {
    return [self paused:NO];
}

- (BOOL)paused:(BOOL)sdkClickHandlerOnly {
    if (sdkClickHandlerOnly) {
        // sdk click handler is paused if either:
        return [self.internalState isOffline] ||    // it's offline
                ![self isEnabled];                  // is disabled
    }
    // other handlers are paused if either:
    return [self.internalState isOffline] ||        // it's offline
            ![self isEnabled] ||                    // is disabled
            [self.internalState isDelayStart] ||    // is in delayed start
            [self.internalState isEventPreStart];   // an pre-start event has occurred before the regular start
}

- (BOOL)toSend {
    return [self toSend:NO];
}

- (BOOL)toSend:(BOOL)sdkClickHandlerOnly {
    // don't send when it's paused
    if ([self paused:sdkClickHandlerOnly]) {
        return NO;
    }

    // has the option to send in the background -> is to send
    if (self.adjustConfig.sendInBackground) {
        return YES;
    }

    // doesn't have the option -> depends on being on the background/foreground
    return [self.internalState isForeground];
}

# pragma mark - timer
- (void)startForegroundTimer {
    // don't start the timer when it's paused
    if ([self paused]) {
        return;
    }

    [self.foregroundTimer resume];
}

- (void)stopForegroundTimer {
    [self.foregroundTimer suspend];
}

- (void)foregroundTimerFiredInternal {
    // stop the timer cycle when it's paused
    if ([self paused]) {
        [self stopForegroundTimer];
        return;
    }
    [self.packageHandler sendFirstPackage];
    double now = [NSDate.date timeIntervalSince1970];
    if ([self updateActivityState:now]) {
        [self writeActivityState];
    }
}

- (void)startBackgroundTimer {
    if (self.backgroundTimer == nil) {
        return;
    }

    // check if it can send in the background
    if (![self toSend]) {
        return;
    }

    // background timer already started
    if ([self.backgroundTimer fireIn] > 0) {
        return;
    }

    [self.backgroundTimer startIn:kBackgroundTimerInterval];
}

- (void)stopBackgroundTimer {
    if (self.backgroundTimer == nil) {
        return;
    }

    [self.backgroundTimer cancel];
}

- (void)backgroundTimerFiredInternal {
    [self.packageHandler sendFirstPackage];
}

#pragma mark - delay
- (void)delayStartInternal {
    // it's not configured to start delayed or already finished
    if ([self.internalState isToStartNow]) {
        return;
    }

    // the delay has already started
    if ([self isToUpdatePackages]) {
        return;
    }

    // first regular session has occurred
    if (self.activityState != nil &&
        [self.internalState isRegularStart]) {
        return;
    }

    // check against max start delay
    double delayStart = self.adjustConfig.delayStart;
    double maxDelayStart = [ADJAdjustFactory maxDelayStart];

    if (delayStart > maxDelayStart) {
        NSString * delayStartFormatted = [ADJUtil secondsNumberFormat:delayStart];
        NSString * maxDelayStartFormatted = [ADJUtil secondsNumberFormat:maxDelayStart];

        [self.logger warn:@"Delay start of %@ seconds bigger than max allowed value of %@ seconds", delayStartFormatted, maxDelayStartFormatted];
        delayStart = maxDelayStart;
    }

    NSString * delayStartFormatted = [ADJUtil secondsNumberFormat:delayStart];
    [self.logger info:@"Waiting %@ seconds before starting first session", delayStartFormatted];

    [self.delayStartTimer startIn:delayStart];

    self.internalState.updatePackages = YES;

    if (self.activityState != nil) {
        self.activityState.updatePackages = YES;
        [self writeActivityState];
    }
}

- (void)sendFirstPackagesInternal {
    if ([self.internalState isToStartNow]) {
        [self.logger info:@"Start delay expired or never configured"];
        return;
    }
    // update packages in queue
    [self updatePackagesInternal];
    // no longer is in delay start
    self.internalState.delayStart = NO;
    // cancel possible still running timer if it was called by user
    [self.delayStartTimer cancel];
    // and release timer
    self.delayStartTimer = nil;
    // update the status and try to send first package
    [self updateHandlersStatusAndSendInternal];
}

- (void)updatePackagesInternal {
    // update activity packages
    [self.packageHandler updatePackages:self.sessionParameters];
    // no longer needs to update packages
    self.internalState.updatePackages = NO;
    if (self.activityState != nil) {
        self.activityState.updatePackages = NO;
        [self writeActivityState];
    }
}

#pragma mark - session parameters
- (void)addCustomUserIdInternal:(NSString *)customUserId {
    if (![ADJUtil isValidParameter:customUserId
                     attributeType:@"value"
                     parameterName:@"Custom User Id"]) return;

    if (self.sessionParameters.customUserId != nil) {
        [self.logger warn:@"Custom User Id %@ will be overwritten", self.sessionParameters.customUserId];
    }

    self.sessionParameters.customUserId = customUserId;

    [self writeSessionParameters];
}
- (void)addSessionCallbackParameterInternal:(NSString *)key
                              value:(NSString *)value
{
    if (![ADJUtil isValidParameter:key
                  attributeType:@"key"
                  parameterName:@"Session Callback"]) return;

    if (![ADJUtil isValidParameter:value
                  attributeType:@"value"
                  parameterName:@"Session Callback"]) return;

    if (self.sessionParameters.callbackParameters == nil) {
        self.sessionParameters.callbackParameters = [NSMutableDictionary dictionary];
    }

    NSString * oldValue = [self.sessionParameters.callbackParameters objectForKey:key];

    if (oldValue != nil) {
        if ([oldValue isEqualToString:value]) {
            [self.logger verbose:@"Key %@ already present with the same value", key];
            return;
        }
        [self.logger warn:@"Key %@ will be overwritten", key];
    }

    [self.sessionParameters.callbackParameters setObject:value forKey:key];

    [self writeSessionCallbackParameters];
}

- (void)addSessionPartnerParameterInternal:(NSString *)key
                             value:(NSString *)value
{
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Session Partner"]) return;

    if (![ADJUtil isValidParameter:value
                     attributeType:@"value"
                     parameterName:@"Session Partner"]) return;

    if (self.sessionParameters.partnerParameters == nil) {
        self.sessionParameters.partnerParameters = [NSMutableDictionary dictionary];
    }

    NSString * oldValue = [self.sessionParameters.partnerParameters objectForKey:key];

    if (oldValue != nil) {
        if ([oldValue isEqualToString:value]) {
            [self.logger verbose:@"Key %@ already present with the same value", key];
            return;
        }
        [self.logger warn:@"Key %@ will be overwritten", key];
    }


    [self.sessionParameters.partnerParameters setObject:value forKey:key];

    [self writeSessionPartnerParameters];
}

- (void)removeSessionCallbackParameterInternal:(NSString *)key {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Session Callback"]) return;

    if (self.sessionParameters.callbackParameters == nil) {
        [self.logger warn:@"Key %@ does not exist", key];
        return;
    }

    NSString * oldValue = [self.sessionParameters.callbackParameters objectForKey:key];
    if (oldValue == nil) {
        [self.logger warn:@"Key %@ does not exist", key];
        return;
    }

    [self.logger debug:@"Key %@ eliminated", key];
    [self.sessionParameters.callbackParameters removeObjectForKey:key];
    [self writeSessionCallbackParameters];
}

- (void)removeSessionPartnerParameterInternal:(NSString *)key {
    if (![ADJUtil isValidParameter:key
                     attributeType:@"key"
                     parameterName:@"Session Partner"]) return;

    if (self.sessionParameters.partnerParameters == nil) {
        [self.logger warn:@"Key %@ does not exist", key];
        return;
    }

    NSString * oldValue = [self.sessionParameters.partnerParameters objectForKey:key];
    if (oldValue == nil) {
        [self.logger warn:@"Key %@ does not exist", key];
        return;
    }

    [self.logger debug:@"key %@ eliminated", key];
    [self.sessionParameters.partnerParameters removeObjectForKey:key];
    [self writeSessionPartnerParameters];
}

- (void)resetCustomUserIdInternal {
    if (self.sessionParameters.customUserId == nil) {
        [self.logger warn:@"Custom User Id already reset"];
        return;
    }
    self.sessionParameters.customUserId = nil;
    [self writeSessionParameters];
}

- (void)resetSessionCallbackParametersInternal {
    if (self.sessionParameters.callbackParameters == nil) {
        [self.logger warn:@"Session Callback parameters already reset"];
        return;
    }
    self.sessionParameters.callbackParameters = nil;
    [self writeSessionCallbackParameters];
}

- (void)resetSessionPartnerParametersInternal {
    if (self.sessionParameters.partnerParameters == nil) {
        [self.logger warn:@"Session Partner parameters already reset"];
        return;
    }
    self.sessionParameters.partnerParameters = nil;
    [self writeSessionPartnerParameters];
}

- (void)sessionParametersActionsInternal:(NSArray*)sessionParametersActionsArray {
    if (sessionParametersActionsArray == nil) {
        return;
    }
    for (NSArray* actionArray in sessionParametersActionsArray) {
        NSString * action = actionArray[0];
        NSString * parameterType = actionArray[1];
        if ([@"callback" isEqualToString:parameterType]) {
            if ([@"add" isEqualToString:action]) {
                [self addSessionCallbackParameterInternal:actionArray[2] value:actionArray[3]];
            }
            if ([@"remove" isEqualToString:action]) {
                [self removeSessionCallbackParameterInternal:actionArray[2]];
            }
            if ([@"reset" isEqualToString:action]) {
                [self resetSessionCallbackParametersInternal];
            }
        }
        if ([@"partner" isEqualToString:parameterType]) {
            if ([@"add" isEqualToString:action]) {
                [self addSessionPartnerParameterInternal:actionArray[2] value:actionArray[3]];
            }
            if ([@"remove" isEqualToString:action]) {
                [self removeSessionPartnerParameterInternal:actionArray[2]];
            }
            if ([@"reset" isEqualToString:action]) {
                [self resetSessionPartnerParametersInternal];
            }
        }
        if ([@"customUserId" isEqualToString:parameterType]) {
            if ([@"add" isEqualToString:action]) {
                [self addCustomUserIdInternal:actionArray[2]];
            }
            if ([@"reset" isEqualToString:action]) {
                [self resetCustomUserId];
            }
        }
    }
}

#pragma mark - notifications
- (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center removeObserver:self];
    [center addObserver:self
               selector:@selector(applicationDidBecomeActive)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(applicationWillResignActive)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(removeNotificationObserver)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
}

- (void)removeNotificationObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - checks

- (BOOL)checkTransactionId:(NSString *)transactionId {
    if (transactionId == nil || transactionId.length == 0) {
        return YES; // no transaction ID given
    }

    if ([self.activityState findTransactionId:transactionId]) {
        [self.logger info:@"Skipping duplicate transaction ID '%@'", transactionId];
        [self.logger verbose:@"Found transaction ID in %@", self.activityState.transactionIds];
        return NO; // transaction ID found -> used already
    }
    
    [self.activityState addTransactionId:transactionId];
    [self.logger verbose:@"Added transaction ID %@", self.activityState.transactionIds];
    // activity state will get written by caller
    return YES;
}

- (BOOL)checkEvent:(ADJEvent *)event {
    if (event == nil) {
        [self.logger error:@"Event missing"];
        return NO;
    }

    if (![event isValid]) {
        [self.logger error:@"Event not initialized correctly"];
        return NO;
    }

    return YES;
}

- (BOOL)checkActivityState {
    if (self.activityState == nil) {
        [self.logger error:@"Missing activity state"];
        return NO;
    }
    return YES;
}
@end

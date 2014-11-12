//
//  AIActivityHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "AIActivityPackage.h"
#import "AIActivityHandler.h"
#import "AIActivityState.h"
#import "AIPackageBuilder.h"
#import "AIPackageHandler.h"
#import "AILogger.h"
#import "AITimer.h"
#import "AIUtil.h"
#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"
#import "AIAdjustFactory.h"
#import "AIAttributionHandler.h"

static NSString   * const kActivityStateFilename = @"AdjustIoActivityState";
static NSString   * const kAttributionFilename   = @"AdjustIoAttribution";
static NSString   * const kActivityStateName     = @"activity state";
static NSString   * const kAttributionName       = @"attributionlo";
static NSString   * const kAdjustPrefix          = @"adjust_";
static const char * const kInternalQueueName     = "io.adjust.ActivityQueue";

static const uint64_t kTimerInterval = 60 * NSEC_PER_SEC; // 1 minute
static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second


#pragma mark -
@interface AIActivityHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, retain) id<AIPackageHandler> packageHandler;
@property (nonatomic, retain) id<AIAttributionHandler> attributionHandler;
@property (nonatomic, retain) AIActivityState *activityState;
@property (nonatomic, retain) AITimer *timer;
@property (nonatomic, retain) id<AILogger> logger;
@property (nonatomic, retain) NSObject<AdjustDelegate> *delegate;
@property (nonatomic, retain) AIAttribution *attribution;
@property (nonatomic, copy) AdjustConfig *adjustConfig;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, copy) AIDeviceInfo* deviceInfo;

@end


#pragma mark -
@implementation AIActivityHandler

+ (id<AIActivityHandler>)handlerWithConfig:(AdjustConfig *)adjustConfig {
    return [[AIActivityHandler alloc] initWithConfig:adjustConfig];
}


- (id)initWithConfig:(AdjustConfig *)adjustConfig {
    self = [super init];
    if (self == nil) return nil;

    if (adjustConfig == nil) {
        [AIAdjustFactory.logger error:@"AdjustConfig not initialized correctly"];
        return nil;
    }

    self.logger        = AIAdjustFactory.logger;
    [self addNotificationObserver];
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.logger        = AIAdjustFactory.logger;
    _enabled = YES;

    dispatch_async(self.internalQueue, ^{
        [self initInternal:adjustConfig];
    });

    return self;
}

- (void)trackSubsessionStart {
    dispatch_async(self.internalQueue, ^{
        [self startInternal];
    });
}

- (void)trackSubsessionEnd {
    dispatch_async(self.internalQueue, ^{
        [self endInternal];
    });
}

- (void)trackEvent:(AIEvent *)event
{
    dispatch_async(self.internalQueue, ^{
        [self eventInternal:event];
    });
}

- (void)finishedTrackingWithResponse:(NSDictionary *)jsonDict{
    [self launchDeepLink:jsonDict];
    [self.attributionHandler checkAttribution:jsonDict];
}

- (void)launchDeepLink:(NSDictionary *)jsonDict{
    if (jsonDict == nil) return;

    NSString * deepLink = [jsonDict objectForKey:@"deeplink"];
    if (deepLink == nil) return;

    NSURL* deepLinkUrl = [NSURL URLWithString:deepLink];

    if (![[UIApplication sharedApplication]
          canOpenURL:deepLinkUrl]) {
        [self.logger error:@"Unable to open deep link (%@)", deepLink];
        return;
    }

    [self.logger info:@"Open deep link (%@)", deepLink];

    [[UIApplication sharedApplication] openURL:deepLinkUrl];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if ([self checkActivityState:self.activityState]) {
        self.activityState.enabled = enabled;
        [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
    }
    if (enabled) {
        [self trackSubsessionStart];
    } else {
        [self trackSubsessionEnd];
    }
}

- (BOOL)isEnabled {
    if ([self checkActivityState:self.activityState]) {
        return self.activityState.enabled;
    } else {
        return _enabled;
    }
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

- (void)setIsIad:(BOOL)isIad {
    self.deviceInfo.isIad = isIad;
    if (isIad) {
        AIPackageBuilder *clickBuilder = [[AIPackageBuilder alloc] initWithDeviceInfo:self.deviceInfo
                                                                     andActivityState:self.activityState
                                                                            andConfig:self.adjustConfig];

        AIActivityPackage *reattributionPackage = [clickBuilder buildClickPackage];
        [self.packageHandler sendClickPackage:reattributionPackage];
    }
}

- (void)updateAttribution:(AIAttribution *)attribution {
    if (attribution == nil) {
        return;
    }
    if ([attribution isEqual:self.attribution]) {
        return;
    }
    self.attribution = attribution;
    [AIUtil writeObject:self.attribution filename:kAttributionFilename objectName:kAttributionName];
}

- (void)launchAttributionDelegate{
    if (![self.delegate respondsToSelector:@selector(adjustAttributionCallback:)]) {
        return;
    }
    [self.delegate performSelectorOnMainThread:@selector(adjustAttributionCallback:)
                                    withObject:self.attribution waitUntilDone:NO];
}

- (void)setOfflineMode:(BOOL)enabled {
    if (enabled) {
        [self endInternal];
    } else {
        [self.packageHandler resumeSending];
        [self startTimer];
    }
}

- (void) addPermanentCallbackParameter:(NSString *)key
                              andValue:(NSString *)value {
    [self.adjustConfig addPermanentCallbackParameter:key andValue:value];
}

- (void) addPermanentPartnerParameter:(NSString *)key
                             andValue:(NSString *)value {
    [self.adjustConfig addPermanentPartnerParameter:key andValue:value];
}

#pragma mark - internal
- (void)initInternal:(AdjustConfig *)adjustConfig {
    self.adjustConfig = adjustConfig;
    self.deviceInfo = [[AIDeviceInfo alloc] init];

    if ([adjustConfig.environment isEqualToString:AIEnvironmentProduction]) {
        [self.logger setLogLevel:AILogLevelAssert];
    } else {
        [self.logger setLogLevel:adjustConfig.logLevel];
    }

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;
    NSString *macShort = macAddress.aiRemoveColons;

    self.deviceInfo.macSha1          = macAddress.aiSha1;
    self.deviceInfo.macShortMd5      = macShort.aiMd5;
    self.deviceInfo.trackingEnabled  = UIDevice.currentDevice.aiTrackingEnabled;
    self.deviceInfo.idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    self.deviceInfo.fbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;
    self.deviceInfo.userAgent        = AIUtil.userAgent;
    self.deviceInfo.vendorId         = UIDevice.currentDevice.aiVendorId;

    if (adjustConfig.sdkPrefix == nil) {
        self.deviceInfo.clientSdk        = AIUtil.clientSdk;
    } else {
        self.deviceInfo.clientSdk = [NSString stringWithFormat:@"%@@%@", adjustConfig.sdkPrefix, AIUtil.clientSdk];
    }

    [self.logger info:@"Tracking of macMd5 is %@", adjustConfig.macMd5TrackingEnabled ? @"enabled" : @"disabled"];

    if (adjustConfig.eventBufferingEnabled)  {
        [self.logger info:@"Event buffering is enabled"];
    }

    self.delegate = adjustConfig.delegate;

    [[UIDevice currentDevice] aiSetIad:self];

    self.packageHandler = [AIAdjustFactory packageHandlerForActivityHandler:self];
    self.attributionHandler = [AIAdjustFactory attributionHandlerForActivityHandler:self withMaxDelay:adjustConfig.attributionMaxTimeMilliseconds];

    self.activityState = [AIUtil readObject:kActivityStateFilename objectName:kActivityStateName];
    self.attribution = [AIUtil readObject:kAttributionFilename objectName:kAttributionName];

    [self startInternal];
}

- (void)startInternal {
    if (![self checkAppTokenNotNil:self.adjustConfig.appToken]) return;

    if (self.activityState != nil
        && !self.activityState.enabled) {
        return;
    }

    [self.packageHandler resumeSending];
    [self startTimer];

    double now = [NSDate.date timeIntervalSince1970];

    // very first session
    if (self.activityState == nil) {
        self.activityState = [[AIActivityState alloc] init];
        self.activityState.sessionCount = 1; // this is the first session
        self.activityState.createdAt = now;  // starting now

        [self transferSessionPackage];
        [self.activityState resetSessionAttributes:now];
        self.activityState.enabled = _enabled;
        [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
        return;
    }

    double lastInterval = now - self.activityState.lastActivity;
    if (lastInterval < 0) {
        [self.logger error:@"Time travel!"];
        self.activityState.lastActivity = now;
        [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
        return;
    }

    // new session
    if (lastInterval > AIAdjustFactory.sessionInterval) {
        self.activityState.sessionCount++;
        self.activityState.createdAt = now;
        self.activityState.lastInterval = lastInterval;

        [self transferSessionPackage];
        [self.activityState resetSessionAttributes:now];
        [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
        return;
    }

    // new subsession
    if (lastInterval > AIAdjustFactory.subsessionInterval) {
        self.activityState.subsessionCount++;
        self.activityState.sessionLength += lastInterval;
        self.activityState.lastActivity = now;
        [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
        [self.logger info:@"Processed Subsession %d of Session %d",
            self.activityState.subsessionCount,
            self.activityState.sessionCount];
    }
}

- (void)endInternal {
    if (![self checkAppTokenNotNil:self.adjustConfig.appToken]) return;

    [self.packageHandler pauseSending];
    [self stopTimer];
    double now = [NSDate.date timeIntervalSince1970];
    [self updateActivityState:now];
    [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
}

- (void)eventInternal:(AIEvent *)event
{
    // check consistency
    if (![self checkAppTokenNotNil:self.adjustConfig.appToken]) return;
    if (![self checkActivityState:self.activityState]) return;
    if (![self checkEventTokenNotNil:event.eventToken]) return;
    if (![self checkEventTokenLength:event.eventToken]) return;
    if (![self checkAmount:event.revenue]) return;
    if (![self checkTransactionId:event.transactionId]) return;

    if (!self.activityState.enabled) {
        return;
    }

    // update activity state
    double now = [NSDate.date timeIntervalSince1970];
    [self updateActivityState:now];
    self.activityState.createdAt = now;
    self.activityState.eventCount++;

    // create and populate event package
    AIPackageBuilder *eventBuilder = [[AIPackageBuilder alloc] initWithDeviceInfo:self.deviceInfo
                                                                 andActivityState:self.activityState
                                                                        andConfig:self.adjustConfig];
    eventBuilder.event = event;

    AIActivityPackage *eventPackage = [eventBuilder buildEventPackage];
    [self.packageHandler addPackage:eventPackage];

    if (self.adjustConfig.eventBufferingEnabled) {
        [self.logger info:@"Buffered event%@", eventPackage.suffix];
    } else {
        [self.packageHandler sendFirstPackage];
    }

    [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
}

- (void) appWillOpenUrlInternal:(NSURL *)url {
    NSArray* queryArray = [url.query componentsSeparatedByString:@"&"];
    NSMutableDictionary* adjustDeepLinks = [NSMutableDictionary dictionary];

    for (NSString* fieldValuePair in queryArray) {
        NSArray* pairComponents = [fieldValuePair componentsSeparatedByString:@"="];
        if (pairComponents.count != 2) continue;

        NSString* key = [pairComponents objectAtIndex:0];
        if (![key hasPrefix:kAdjustPrefix]) continue;

        NSString* value = [pairComponents objectAtIndex:1];
        if (value.length == 0) continue;

        NSString* keyWOutPrefix = [key substringFromIndex:kAdjustPrefix.length];
        if (keyWOutPrefix.length == 0) continue;

        [adjustDeepLinks setObject:value forKey:keyWOutPrefix];
    }

    [self.attributionHandler getAttribution];

    if (adjustDeepLinks.count == 0) {
        return;
    }

    AIPackageBuilder *ClickBuilder = [[AIPackageBuilder alloc] initWithDeviceInfo:self.deviceInfo
                                                                 andActivityState:self.activityState
                                                                        andConfig:self.adjustConfig];
    ClickBuilder.deeplinkParameters = adjustDeepLinks;

    AIActivityPackage *reattributionPackage = [ClickBuilder buildClickPackage];
    [self.packageHandler sendClickPackage:reattributionPackage];
}

- (void) setDeviceTokenInternal:(NSData *)deviceToken {
    if (deviceToken == nil) {
        return;
    }

    NSString *token = [deviceToken.description stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];

    self.deviceInfo.pushToken = token;
}

#pragma mark - private

// returns whether or not the activity state should be written
- (BOOL)updateActivityState:(double)now {
    if (![self checkActivityState:self.activityState]) return NO;

    double lastInterval = now - self.activityState.lastActivity;
    if (lastInterval < 0) {
        [self.logger error:@"Time travel!"];
        self.activityState.lastActivity = now;
        return YES;
    }

    // ignore late updates
    if (lastInterval > AIAdjustFactory.sessionInterval) return NO;

    self.activityState.sessionLength += lastInterval;
    self.activityState.timeSpent += lastInterval;
    self.activityState.lastActivity = now;

    return (lastInterval > AIAdjustFactory.subsessionInterval);
}

- (void)transferSessionPackage {
    AIPackageBuilder *sessionBuilder = [[AIPackageBuilder alloc] initWithDeviceInfo:self.deviceInfo
                                                                   andActivityState:self.activityState
                                                                          andConfig:self.adjustConfig];
    AIActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage];
    [self.packageHandler addPackage:sessionPackage];
    [self.packageHandler sendFirstPackage];
}

# pragma mark - timer
- (void)startTimer {
    if (self.timer == nil) {
        self.timer = [AITimer timerWithInterval:kTimerInterval
                                         leeway:kTimerLeeway
                                          queue:self.internalQueue
                                          block:^{ [self timerFired]; }];
    }
    [self.timer resume];
}

- (void)stopTimer {
    [self.timer suspend];
}

- (void)timerFired {
    if (self.activityState != nil
        && !self.activityState.enabled) {
        return;
    }
    [self.packageHandler sendFirstPackage];
    double now = [NSDate.date timeIntervalSince1970];
    if ([self updateActivityState:now]) {
        [AIUtil writeObject:self.activityState filename:kActivityStateFilename objectName:kActivityStateName];
    }
}

#pragma mark - notifications
- (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center removeObserver:self];
    [center addObserver:self
               selector:@selector(trackSubsessionStart)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(trackSubsessionEnd)
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
- (BOOL)checkActivityState:(AIActivityState *)activityState {
    if (activityState == nil) {
        [self.logger error:@"Missing activity state"];
        return NO;
    }
    return YES;
}

- (BOOL)checkAppTokenNotNil:(NSString *)appToken {
    if (appToken == nil) {
        [self.logger error:@"Missing App Token"];
        return NO;
    }
    return YES;
}

- (BOOL)checkEventTokenNotNil:(NSString *)eventToken {
    if (eventToken == nil) {
        [self.logger error:@"Missing Event Token"];
        return NO;
    }
    return YES;
}

- (BOOL)checkEventTokenLength:(NSString *)eventToken {
    if (eventToken == nil) {
        return YES;
    }
    if (eventToken.length != 6) {
        [self.logger error:@"Malformed Event Token '%@'", eventToken];
        return NO;
    }
    return YES;
}

- (BOOL)checkAmount:(NSNumber *)amount {
    if (amount != nil && [amount doubleValue] < 0.0) {
        [self.logger error:@"Invalid amount %.1f", [amount doubleValue]];
        return NO;
    }
    return YES;
}

- (BOOL) checkTransactionId:(NSString *)transactionId {
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

@end

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


static NSString   * const kActivityStateFilename = @"AdjustIoActivityState";
static NSString   * const kAdjustPrefix          = @"adjust_";
static const char * const kInternalQueueName     = "io.adjust.ActivityQueue";

static const uint64_t kTimerInterval = 60 * NSEC_PER_SEC; // 1 minute
static const uint64_t kTimerLeeway   =  1 * NSEC_PER_SEC; // 1 second


#pragma mark -
@interface AIActivityHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic, retain) id<AIPackageHandler> packageHandler;
@property (nonatomic, retain) AIActivityState *activityState;
@property (nonatomic, retain) AITimer *timer;
@property (nonatomic, retain) id<AILogger> logger;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL bufferEvents;
@property (nonatomic, assign) BOOL trackMacMd5;
@property (nonatomic, retain) NSObject<AdjustDelegate> *delegate;

@property (nonatomic, copy) AIDeviceInfo* deviceInfo;

@end


#pragma mark -
@implementation AIActivityHandler

+ (id<AIActivityHandler>)handlerWithAppToken:(NSString *)appToken {
    return [[AIActivityHandler alloc] initWithAppToken:appToken];
}

- (id)initWithAppToken:(NSString *)yourAppToken {
    self = [super init];
    if (self == nil) return nil;

    [self addNotificationObserver];
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.deviceInfo = [[AIDeviceInfo alloc] init];

    self.deviceInfo.clientSdk = AIUtil.clientSdk;
    self.logger        = AIAdjustFactory.logger;

    // default values
    self.deviceInfo.environment = @"unknown";
    _trackMacMd5 = YES;
    _enabled = YES;

    dispatch_async(self.internalQueue, ^{
        [self initInternal:yourAppToken];
    });

    return self;
}

- (void)setSdkPrefix:(NSString *)sdkPrefix {
    self.deviceInfo.clientSdk = [NSString stringWithFormat:@"%@@%@", sdkPrefix, AIUtil.clientSdk];
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

- (void)finishedTrackingWithResponse:(AIResponseData *)response deepLink:(NSString *)deepLink{
    [self runDelegate:response];
    [self launchDeepLink:deepLink];
}

- (void)runDelegate:(AIResponseData *)response {
    if (![self.delegate respondsToSelector:@selector(adjustFinishedTrackingWithResponse:)]) {
        return;
    }
    if (response == nil) {
        return;
    }
    [self.delegate performSelectorOnMainThread:@selector(adjustFinishedTrackingWithResponse:)
                                    withObject:response waitUntilDone:NO];

}

- (void)launchDeepLink:(NSString *) deepLink{
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

- (void)readOpenUrl:(NSURL*)url {
    dispatch_async(self.internalQueue, ^{
        [self readOpenUrlInternal:url];
    });
}

- (void)savePushToken:(NSData *)pushToken {
    dispatch_async(self.internalQueue, ^{
        [self savePushTokenInternal:pushToken];
    });
}

- (void)setEnvironment:(NSString *)environment {
    self.deviceInfo.environment = environment;
}

- (void)setBufferEvents:(BOOL)bufferEvents {
    _bufferEvents = bufferEvents;
}

- (void)setTrackMacMd5:(BOOL)trackMacMd5 {
    _trackMacMd5 = trackMacMd5;
}

- (void)setDelegate:(NSObject<AdjustDelegate> *) delegate {
    _delegate = delegate;
}

- (void)setIsIad:(BOOL)isIad {
    self.deviceInfo.isIad = isIad;
}


#pragma mark - internal
- (void)initInternal:(NSString *)yourAppToken {
    if (![self checkAppTokenNotNil:yourAppToken]) return;
    if (![self checkAppTokenLength:yourAppToken]) return;

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;
    NSString *macShort = macAddress.aiRemoveColons;

    self.deviceInfo.appToken         = yourAppToken;
    self.deviceInfo.macSha1          = macAddress.aiSha1;
    self.deviceInfo.macShortMd5      = macShort.aiMd5;
    self.deviceInfo.trackingEnabled  = UIDevice.currentDevice.aiTrackingEnabled;
    self.deviceInfo.idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    self.deviceInfo.fbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;
    self.deviceInfo.userAgent        = AIUtil.userAgent;
    self.deviceInfo.vendorId         = UIDevice.currentDevice.aiVendorId;

    [[UIDevice currentDevice] aiSetIad:self];

    self.packageHandler = [AIAdjustFactory packageHandlerForActivityHandler:self];
    [self readActivityState];

    [self startInternal];
}

- (void)startInternal {
    if (![self checkAppTokenNotNil:self.deviceInfo.appToken]) return;

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
        [self writeActivityState];
        [self.logger info:@"First session"];
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
    if (lastInterval > AIAdjustFactory.sessionInterval) {
        self.activityState.sessionCount++;
        self.activityState.createdAt = now;
        self.activityState.lastInterval = lastInterval;

        [self transferSessionPackage];
        [self.activityState resetSessionAttributes:now];
        [self writeActivityState];
        [self.logger debug:@"Session %d", self.activityState.sessionCount];
        return;
    }

    // new subsession
    if (lastInterval > AIAdjustFactory.subsessionInterval) {
        self.activityState.subsessionCount++;
        self.activityState.sessionLength += lastInterval;
        self.activityState.lastActivity = now;
        [self writeActivityState];
        [self.logger info:@"Processed Subsession %d of Session %d",
            self.activityState.subsessionCount,
            self.activityState.sessionCount];
    }
}

- (void)endInternal {
    if (![self checkAppTokenNotNil:self.deviceInfo.appToken]) return;

    [self.packageHandler pauseSending];
    [self stopTimer];
    double now = [NSDate.date timeIntervalSince1970];
    [self updateActivityState:now];
    [self writeActivityState];
}

- (void)eventInternal:(AIEvent *)event
{
    // check consistency
    if (![self checkAppTokenNotNil:self.deviceInfo.appToken]) return;
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
    AIPackageBuilder *eventBuilder = [[AIPackageBuilder alloc] init];
    eventBuilder.event = event;

    //[self injectGeneralAttributes:eventBuilder];
    eventBuilder.deviceInfo = self.deviceInfo;
    eventBuilder.trackMd5 = _trackMacMd5;
    [self.activityState injectEventAttributes:eventBuilder];
    AIActivityPackage *eventPackage = [eventBuilder buildEventPackage];
    [self.packageHandler addPackage:eventPackage];

    if (_bufferEvents) {
        [self.logger info:@"Buffered event%@", eventPackage.suffix];
    } else {
        [self.packageHandler sendFirstPackage];
    }

    [self writeActivityState];
    [self.logger debug:@"Event %d", self.activityState.eventCount];
}

- (void) readOpenUrlInternal:(NSURL *)url {
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

    if (adjustDeepLinks.count == 0) {
        return;
    }

    AIPackageBuilder *reattributionBuilder = [[AIPackageBuilder alloc] init];
    reattributionBuilder.deeplinkParameters = adjustDeepLinks;
    //[self injectGeneralAttributes:reattributionBuilder];
    reattributionBuilder.deviceInfo = self.deviceInfo;
    reattributionBuilder.trackMd5 = _trackMacMd5;
    AIActivityPackage *reattributionPackage = [reattributionBuilder buildReattributionPackage];
    [self.packageHandler addPackage:reattributionPackage];
    [self.packageHandler sendFirstPackage];

    [self.logger debug:@"Reattribution %@", adjustDeepLinks];
}

- (void) savePushTokenInternal:(NSData *)pushToken {
    if (pushToken == nil) {
        return;
    }

    NSString *token = [pushToken.description stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
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

- (void)readActivityState {
    @try {
        NSString *filename = self.activityStateFilename;
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if ([object isKindOfClass:[AIActivityState class]]) {
            self.activityState = object;
            [self.logger debug:@"Read activity state:  %@ uuid:%@", self.activityState, self.activityState.uuid];
            return;
        } else if (object == nil) {
            [self.logger verbose:@"Activity state file not found"];
        } else {
            [self.logger error:@"Failed to read activity state"];
        }
    } @catch (NSException *ex ) {
        [self.logger error:@"Failed to read activity state (%@)", ex];
    }

    // start with a fresh activity state in case of any exception
    self.activityState = nil;
}

- (void)writeActivityState {
    NSString *filename = self.activityStateFilename;
    BOOL result = [NSKeyedArchiver archiveRootObject:self.activityState toFile:filename];
    if (result == YES) {
        [AIUtil excludeFromBackup:filename];
        [self.logger debug:@"Wrote activity state: %@", self.activityState];
    } else {
        [self.logger error:@"Failed to write activity state"];
    }
}

- (NSString *)activityStateFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:kActivityStateFilename];
    return filename;
}

- (void)transferSessionPackage {
    AIPackageBuilder *sessionBuilder = [[AIPackageBuilder alloc] init];
    //[self injectGeneralAttributes:sessionBuilder];
    sessionBuilder.deviceInfo = self.deviceInfo;
    sessionBuilder.trackMd5 = _trackMacMd5;
    [self.activityState injectSessionAttributes:sessionBuilder];
    AIActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage];
    [self.packageHandler addPackage:sessionPackage];
    [self.packageHandler sendFirstPackage];
}

/*
- (void)injectGeneralAttributes:(AIPackageBuilder *)builder {
    builder.userAgent        = self.userAgent;
    builder.clientSdk        = self.clientSdk;
    builder.appToken         = self.appToken;
    builder.macSha1          = self.macSha1;
    builder.trackingEnabled  = self.trackingEnabled;
    builder.idForAdvertisers = self.idForAdvertisers;
    builder.fbAttributionId  = self.fbAttributionId;
    builder.environment      = self.environment;
    builder.isIad            = self.isIad;
    builder.vendorId         = self.vendorId;
    builder.pushToken        = self.pushToken;

    if (self.trackMacMd5) {
        builder.macShortMd5 = self.macShortMd5;
    }
}
*/
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
        [self writeActivityState];
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

- (BOOL)checkAppTokenLength:(NSString *)appToken {
    if (appToken.length != 12) {
        [self.logger error:@"Malformed App Token '%@'", appToken];
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

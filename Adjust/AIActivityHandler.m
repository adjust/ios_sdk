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
#if !ADJUST_NO_IDA
#import <iAd/iAd.h>
#endif

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

@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, copy) NSString *macSha1;
@property (nonatomic, copy) NSString *macShortMd5;
@property (nonatomic, copy) NSString *idForAdvertisers;
@property (nonatomic, copy) NSString *fbAttributionId;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *clientSdk;
@property (nonatomic, assign) BOOL trackingEnabled;
@property (nonatomic, assign) BOOL internalEnabled;
@property (nonatomic, assign) BOOL isIad;
@property (nonatomic, copy) NSString *vendorId;

@end


#pragma mark -
@implementation AIActivityHandler

@synthesize environment;
@synthesize bufferEvents;
@synthesize trackMacMd5;
@synthesize delegate;

+ (id<AIActivityHandler>)handlerWithAppToken:(NSString *)appToken {
    return [[AIActivityHandler alloc] initWithAppToken:appToken];
}

- (id)initWithAppToken:(NSString *)yourAppToken {
    self = [super init];
    if (self == nil) return nil;

    [self addNotificationObserver];
    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.clientSdk     = AIUtil.clientSdk;
    self.logger        = AIAdjustFactory.logger;

    // default values
    self.environment = @"unknown";
    self.trackMacMd5 = YES;
    self.internalEnabled = YES;

    dispatch_async(self.internalQueue, ^{
        [self initInternal:yourAppToken];
    });

    return self;
}

- (void)setSdkPrefix:(NSString *)sdkPrefix {
    self.clientSdk = [NSString stringWithFormat:@"%@@%@", sdkPrefix, self.clientSdk];
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

- (void)trackEvent:(NSString *)eventToken
    withParameters:(NSDictionary *)parameters
{
    dispatch_async(self.internalQueue, ^{
        [self eventInternal:eventToken parameters:parameters];
    });
}

- (void)trackRevenue:(double)amount
       transactionId:(NSString *)transactionId
            forEvent:(NSString *)eventToken
      withParameters:(NSDictionary *)parameters
{
    dispatch_async(self.internalQueue, ^{
        [self revenueInternal:amount transactionId:transactionId event:eventToken parameters:parameters];
    });
}

- (void)finishedTrackingWithResponse:(AIResponseData *)response {
    if ([self.delegate respondsToSelector:@selector(adjustFinishedTrackingWithResponse:)]) {
        [self.delegate performSelectorOnMainThread:@selector(adjustFinishedTrackingWithResponse:)
                                        withObject:response waitUntilDone:NO];
    }
}

- (void)setEnabled:(BOOL)enabled {
    self.internalEnabled = enabled;
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
        return self.internalEnabled;
    }
}

- (void)readOpenUrl:(NSURL*)url {
    dispatch_async(self.internalQueue, ^{
        [self readOpenUrlInternal:url];
    });
}

#pragma mark - internal
- (void)initInternal:(NSString *)yourAppToken {
    if (![self checkAppTokenNotNil:yourAppToken]) return;
    if (![self checkAppTokenLength:yourAppToken]) return;

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;
    NSString *macShort = macAddress.aiRemoveColons;

    self.appToken         = yourAppToken;
    self.macSha1          = macAddress.aiSha1;
    self.macShortMd5      = macShort.aiMd5;
    self.trackingEnabled  = UIDevice.currentDevice.aiTrackingEnabled;
    self.idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    self.fbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;
    self.userAgent        = AIUtil.userAgent;
    self.vendorId         = UIDevice.currentDevice.aiVendorId;

#if !ADJUST_NO_IDA
    if (NSClassFromString(@"ADClient")) {
        [ADClient.sharedClient determineAppInstallationAttributionWithCompletionHandler:^(BOOL appInstallationWasAttributedToiAd) {
            self.isIad = appInstallationWasAttributedToiAd;
        }];
    }
#endif

    self.packageHandler = [AIAdjustFactory packageHandlerForActivityHandler:self];
    [self readActivityState];

    [self startInternal];
}

- (void)startInternal {
    if (![self checkAppTokenNotNil:self.appToken]) return;

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
        self.activityState.enabled = self.internalEnabled;
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
    if (![self checkAppTokenNotNil:self.appToken]) return;

    [self.packageHandler pauseSending];
    [self stopTimer];
    double now = [NSDate.date timeIntervalSince1970];
    [self updateActivityState:now];
    [self writeActivityState];
}

- (void)eventInternal:(NSString *)eventToken
           parameters:(NSDictionary *)parameters
{
    if (![self checkAppTokenNotNil:self.appToken]) return;
    if (![self checkActivityState:self.activityState]) return;
    if (![self checkEventTokenNotNil:eventToken]) return;
    if (![self checkEventTokenLength:eventToken]) return;

    if (!self.activityState.enabled) {
        return;
    }

    AIPackageBuilder *eventBuilder = [[AIPackageBuilder alloc] init];
    eventBuilder.eventToken = eventToken;
    eventBuilder.callbackParameters = parameters;

    double now = [NSDate.date timeIntervalSince1970];
    [self updateActivityState:now];
    self.activityState.createdAt = now;
    self.activityState.eventCount++;

    [self injectGeneralAttributes:eventBuilder];
    [self.activityState injectEventAttributes:eventBuilder];
    AIActivityPackage *eventPackage = [eventBuilder buildEventPackage];
    [self.packageHandler addPackage:eventPackage];

    if (self.bufferEvents) {
        [self.logger info:@"Buffered event%@", eventPackage.suffix];
    } else {
        [self.packageHandler sendFirstPackage];
    }

    [self writeActivityState];
    [self.logger debug:@"Event %d", self.activityState.eventCount];
}

- (void)revenueInternal:(double)amount
          transactionId:(NSString *)transactionId
                  event:(NSString *)eventToken
             parameters:(NSDictionary *)parameters
{
    if (![self checkAppTokenNotNil:self.appToken]) return;
    if (![self checkActivityState:self.activityState]) return;
    if (![self checkAmount:amount]) return;
    if (![self checkEventTokenLength:eventToken]) return;
    if (![self checkTransactionId:transactionId]) return;

    if (!self.activityState.enabled) {
        return;
    }

    AIPackageBuilder *revenueBuilder = [[AIPackageBuilder alloc] init];
    revenueBuilder.amountInCents = amount;
    revenueBuilder.eventToken = eventToken;
    revenueBuilder.callbackParameters = parameters;

    double now = [NSDate.date timeIntervalSince1970];
    [self updateActivityState:now];
    self.activityState.createdAt = now;
    self.activityState.eventCount++;

    [self injectGeneralAttributes:revenueBuilder];
    [self.activityState injectEventAttributes:revenueBuilder];
    AIActivityPackage *revenuePackage = [revenueBuilder buildRevenuePackage];
    [self.packageHandler addPackage:revenuePackage];

    if (self.bufferEvents) {
        [self.logger info:@"Buffered revenue%@", revenuePackage.suffix];
    } else {
        [self.packageHandler sendFirstPackage];
    }

    [self writeActivityState];
    [self.logger debug:@"Event %d (revenue)", self.activityState.eventCount];
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
    [self injectGeneralAttributes:reattributionBuilder];
    AIActivityPackage *reattributionPackage = [reattributionBuilder buildReattributionPackage];
    [self.packageHandler addPackage:reattributionPackage];
    [self.packageHandler sendFirstPackage];

    [self.logger debug:@"Reattribution %@", adjustDeepLinks];
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
    [self injectGeneralAttributes:sessionBuilder];
    [self.activityState injectSessionAttributes:sessionBuilder];
    AIActivityPackage *sessionPackage = [sessionBuilder buildSessionPackage];
    [self.packageHandler addPackage:sessionPackage];
    [self.packageHandler sendFirstPackage];
}

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

    if (self.trackMacMd5) {
        builder.macShortMd5 = self.macShortMd5;
    }
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

- (BOOL)checkAmount:(double)amount {
    if (amount < 0.0) {
        [self.logger error:@"Invalid amount %.1f", amount];
        return NO;
    }
    return YES;
}

- (BOOL) checkTransactionId:(NSString *)transactionId {
    if (transactionId.length == 0) {
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

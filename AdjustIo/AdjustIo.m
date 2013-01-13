//
//  AdjustIo.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AdjustIo.h"
#import "AELogger.h"
#import "AIApiClient.h"

#import "UIDevice+AIAdditions.h"
#import "NSData+AIAdditions.h"
#import "NSString+AIAdditions.h"

static NSString * const kKeySessionDate = @"AdjustIo.sessionDate";
static NSString * const kKeySessionId   = @"AdjustIo.sessionId";

static AdjustIo *defaultInstance;


#pragma mark private interface
@interface AdjustIo()

+ (AdjustIo *)defaultInstance;

- (void)appDidLaunch:(NSString *)appId;
- (void)appWillTerminate;

- (void)trackSessionStart;
- (void)trackSessionEnd;
- (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters;
- (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters;

- (NSNumber *)nextSessionId;
- (NSNumber *)lastSessionId;
- (NSNumber *)lastInterval;

@property (copy) NSString *appId;
@property (copy) NSString *macAddress;
@property (copy) NSString *idForAdvertisers;
@property (copy) NSString *fbAttributionId;

@property (retain) AELogger *logger;
@property (retain) AIApiClient *apiClient;

@end


#pragma mark AdjustIo
@implementation AdjustIo

#pragma mark public

// class methods get forwarded to defaultInstance

+ (void)appDidLaunch:(NSString *)appId {
    [self.defaultInstance appDidLaunch:appId];
}

+ (void)trackEvent:(NSString *)eventId {
    [self trackEvent:eventId withParameters:nil];
}

+ (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters {
    [self.defaultInstance trackEvent:eventId withParameters:parameters];
}

+ (void)userGeneratedRevenue:(float)amountInCents {
    [self userGeneratedRevenue:amountInCents forEvent:nil];
}

+ (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId {
    [self userGeneratedRevenue:amountInCents forEvent:eventId withParameters:nil];
}

+ (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters {
    [self.defaultInstance userGeneratedRevenue:amountInCents forEvent:eventId withParameters:parameters];
}

+ (void)setLoggingEnabled:(BOOL)loggingEnabled {
    self.defaultInstance.logger.loggingEnabled = loggingEnabled;
}

#pragma mark deprecated

+ (void)trackDeviceId __attribute__((deprecated)) {
    NSLog(@"[AdjustIo trackDeviceId] is deprecated.");
}

#pragma mark private

+ (AdjustIo *)defaultInstance {
    if (defaultInstance == nil) {
        defaultInstance = [[AdjustIo alloc] init];
    }

    return defaultInstance;
}

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    self.logger = [AELogger loggerWithTag:@"AdjustIo" enabled:NO];
    self.apiClient = [AIApiClient apiClientWithLogger:self.logger];

    return self;
}

- (void)appDidLaunch:(NSString *)theAppId {
    if (theAppId.length == 0) {
        [self.logger log:@"Error: Missing appId"];
        return;
    }

    // these must not be nil
    self.appId = theAppId;
    self.macAddress = UIDevice.currentDevice.aiMacAddress;
    self.idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    self.fbAttributionId = UIDevice.currentDevice.aiFbAttributionId;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(trackSessionStart) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(trackSessionEnd) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)appWillTerminate {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)trackSessionStart {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appId,            @"app_id",
                                       self.macAddress,       @"mac",
                                       self.idForAdvertisers, @"idfa",
                                       self.nextSessionId,    @"session_id",
                                       self.lastInterval,     @"last_interval",
                                       self.fbAttributionId,  @"fb_id",
                                       nil];

    [self.apiClient postPath:@"/startup"
                     success:@"Tracked session start."
                     failure:@"Failed to track session start."
                  parameters:parameters];
}

- (void)trackSessionEnd {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appId,            @"app_id",
                                       self.macAddress,       @"mac",
                                       self.idForAdvertisers, @"idfa",
                                       self.lastSessionId,    @"session_id",
                                       self.lastInterval,     @"last_interval",
                                       nil];

    [self.apiClient postPath:@"/shutdown"
                     success:@"Tracked session end."
                     failure:@"Failed to track session end."
                  parameters:parameters];
}

- (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)callbackParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       eventId,               @"id",
                                       self.appId,            @"app_id",
                                       self.macAddress,       @"mac",
                                       self.idForAdvertisers, @"idfa",
                                       nil];

    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    [self.apiClient postPath:@"/event"
                     success:[NSString stringWithFormat:@"Tracked event %@.", eventId]
                     failure:[NSString stringWithFormat:@"Failed to track event %@.", eventId]
                  parameters:parameters];
}

- (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)callbackParameters {
    NSString *amountInMillis = [NSNumber numberWithInt:roundf(10 * amountInCents)].stringValue;

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appId,            @"app_id",
                                       self.macAddress,       @"mac",
                                       self.idForAdvertisers, @"idfa",
                                       amountInMillis,        @"amount",
                                       nil];

    if (eventId != nil) {
        [parameters setObject:eventId forKey:@"event_id"];
    }

    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    [self.apiClient postPath:@"/revenue"
                     success:[NSString stringWithFormat:@"Tracked revenue (%.1f Cents).", amountInCents]
                     failure:[NSString stringWithFormat:@"Failed to track revenue (%.1f Cents).", amountInCents]
                  parameters:parameters];
}

- (NSNumber *)nextSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionId] + 1;
    [NSUserDefaults.standardUserDefaults setInteger:sessionId forKey:kKeySessionId];
    return [NSNumber numberWithInt:sessionId];
}

- (NSNumber *)lastSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionId];
    return [NSNumber numberWithInt:sessionId];
}

- (NSNumber *)lastInterval {
    NSDate *now = [NSDate date];
    NSDate *last = [NSUserDefaults.standardUserDefaults objectForKey:kKeySessionDate];
    [NSUserDefaults.standardUserDefaults setObject:now forKey:kKeySessionDate];

    NSTimeInterval interval = [now timeIntervalSinceDate:last];
    return [NSNumber numberWithInt:roundf(interval)];
}

@synthesize appId;
@synthesize macAddress;
@synthesize idForAdvertisers;
@synthesize fbAttributionId;
@synthesize apiClient;
@synthesize logger;

@end

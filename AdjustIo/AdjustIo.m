//
//  AdjustIo.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AdjustIo.h"
#import "AIApiClient.h"

#import "UIDevice+AIAdditions.h"
#import "NSString+AIAdditions.h"
#import "NSData+AIAdditions.h"

// We currently only track online sessions: If the server couldn't be reached when a session starts,
// that session is considered an offline session and won't be tracked at the moment.

typedef enum {
    kSessionStateAwaitingStart,
    kSessionStateAwaitingEnd,
    kSessionStateMissedEnd,
} SessionState;

// the current sessionState, the session tracking behavior depends on this state
static NSString * const kKeySessionState = @"AdjustIo.sessionState";

// sessionId of the current session
static NSString * const kKeySessionId = @"AdjustIo.sessionId";

// sessionId of last online session (might be the current one)
static NSString * const kKeySessionLastId = @"AdjustIo.sessionLastId";

// length of last online session
static NSString * const kKeySessionLength = @"AdjustIo.sessionLength";

// date of last online session start or end
static NSString * const kKeySessionDate = @"AdjustIo.sessionDate";

static AdjustIo *defaultInstance;


#pragma mark private interface
@interface AdjustIo()

+ (AdjustIo *)defaultInstance;

- (void)appDidLaunch:(NSString *)appToken;
- (void)appWillTerminate;

- (void)trackSessionStart;
- (void)trackSessionEnd;
- (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;
- (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters;

// save a new sessionState to sessionState
- (void)setSessionState:(SessionState)sessionState;

// return sessionState
- (SessionState)sessionState;

// increment sessionId, save and return it (first returned value: 1)
- (NSNumber *)nextSessionId;

// save the sessionId to sessionLastId (marks current session as online)
- (void)setLastSessionId;

// return sessionLastId (id of last online session)
// or -1 if there is no last online session
- (NSNumber *)lastSessionId;

// save the current date to sessionDate
- (void)setSessionDate;

// return the time interval in seconds between sessionDate and now
- (int)sessionDateInterval;

// at session start: the time interval in seconds between the last online session end and now
// or -1 if we don't know when the last online session ended
- (NSNumber *)lastSessionInterval;

// save sessionDateInterval to sessionLength
// at session end: save length of current online session
- (void)setSessionLength;

// return sessionLength (length of last online session)
// or -1 if we don't know when the last online session ended
- (NSNumber *)lastSessionLength;

@property (copy) NSString *appToken;
@property (copy) NSString *macSha1;
@property (copy) NSString *macShortMd5;
@property (copy) NSString *idForAdvertisers;
@property (copy) NSString *fbAttributionId;

@property (retain) AELogger *logger;
@property (retain) AIApiClient *apiClient;

@end


#pragma mark AdjustIo
@implementation AdjustIo

#pragma mark public

// class methods get forwarded to defaultInstance

+ (void)appDidLaunch:(NSString *)appToken {
    [self.defaultInstance appDidLaunch:appToken];
}

+ (void)trackEvent:(NSString *)eventToken {
    [self trackEvent:eventToken withParameters:nil];
}

+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters {
    [self.defaultInstance trackEvent:eventToken withParameters:parameters];
}

+ (void)trackRevenue:(float)amountInCents {
    [self trackRevenue:amountInCents forEvent:nil];
}

+ (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken {
    [self trackRevenue:amountInCents forEvent:eventToken withParameters:nil];
}

+ (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)parameters {
    [self.defaultInstance trackRevenue:amountInCents forEvent:eventToken withParameters:parameters];
}

+ (void)setLogLevel:(AELogLevel)logLevel {
    self.defaultInstance.logger.logLevel = logLevel;
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

    self.logger = [AELogger loggerWithTag:@"AdjustIo"];
    self.apiClient = [AIApiClient apiClientWithLogger:self.logger];

    return self;
}

- (void)appDidLaunch:(NSString *)yourAppToken {
    if (yourAppToken.length == 0) {
        [self.logger error:@"Missing App Token."];
        return;
    }

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;

    // these must not be nil
    appToken = yourAppToken;
    macSha1 = [macAddress aiSha1];
    macShortMd5 = [[macAddress aiRemoveColons] aiMd5];
    idForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    fbAttributionId = UIDevice.currentDevice.aiFbAttributionId;

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(trackSessionStart) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(trackSessionEnd) name:UIApplicationWillResignActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)appWillTerminate {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)trackSessionStart {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appToken,            @"app_token",
                                       self.macShortMd5,         @"mac",
                                       self.macSha1,             @"mac_sha1",
                                       self.idForAdvertisers,    @"idfa",
                                       self.fbAttributionId,     @"fb_id",
                                       self.nextSessionId,       @"session_id",
                                       self.lastSessionId,       @"last_session_id",
                                       self.lastSessionInterval, @"last_interval",
                                       self.lastSessionLength,   @"last_length",
                                       nil];

    [self.apiClient postPath:@"/startup"
                  parameters:parameters
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         [self.apiClient logSuccess:@"Tracked session."];
                         [self setSessionState:kSessionStateAwaitingEnd];
                         [self setLastSessionId];
                         [self setSessionDate];
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self.apiClient logFailure:@"Failed to track session." response:operation.responseString error:error];
                         if (self.sessionState == kSessionStateAwaitingEnd)
                             [self setSessionState:kSessionStateMissedEnd];
                     }];
}

- (void)trackSessionEnd {
    if (self.sessionState == kSessionStateAwaitingEnd) {
        [self setSessionState:kSessionStateAwaitingStart];
        [self setSessionLength];
        [self setSessionDate];
    }
}

- (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)callbackParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appToken,         @"app_token",
                                       self.macShortMd5,      @"mac",
                                       self.idForAdvertisers, @"idfa",
                                       eventToken,            @"event_id",
                                       nil];

    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    [self.apiClient postPath:@"/event" parameters:parameters
              successMessage:[NSString stringWithFormat:@"Tracked event %@.", eventToken]
              failureMessage:[NSString stringWithFormat:@"Failed to track event %@.", eventToken]];
}

- (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)callbackParameters {
    NSString *amountInMillis = [NSNumber numberWithInt:roundf(10 * amountInCents)].stringValue;

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appToken,         @"app_token",
                                       self.macShortMd5,      @"mac",
                                       self.idForAdvertisers, @"idfa",
                                       amountInMillis,        @"amount",
                                       nil];

    if (eventToken != nil) {
        [parameters setObject:eventToken forKey:@"event_id"];
    }

    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    [self.apiClient postPath:@"/revenue" parameters:parameters
              successMessage:[NSString stringWithFormat:@"Tracked revenue (%.1f Cents).", amountInCents]
              failureMessage:[NSString stringWithFormat:@"Failed to track revenue (%.1f Cents).", amountInCents]];
}

#pragma mark NSUserDefault interface

- (void)setSessionState:(SessionState)sessionState {
    [NSUserDefaults.standardUserDefaults setInteger:sessionState forKey:kKeySessionState];
}

- (SessionState)sessionState {
    int sessionState = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionState];
    return sessionState;
}

- (NSNumber *)nextSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionId] + 1;
    [NSUserDefaults.standardUserDefaults setInteger:sessionId forKey:kKeySessionId];
    return [NSNumber numberWithInt:sessionId];
}

- (void)setLastSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionId];
    [NSUserDefaults.standardUserDefaults setInteger:sessionId forKey:kKeySessionLastId];
}

- (NSNumber *)lastSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionLastId];
    if (sessionId == 0) {
        sessionId = -1;
    }
    return [NSNumber numberWithInt:sessionId];
}

- (void)setSessionDate {
    [NSUserDefaults.standardUserDefaults setObject:[NSDate date] forKey:kKeySessionDate];
}

- (int)sessionDateInterval {
    int interval = -1;
    NSDate *last = [NSUserDefaults.standardUserDefaults objectForKey:kKeySessionDate];
    if (last != nil) {
        interval = roundf([[NSDate date] timeIntervalSinceDate:last]);
    }
    return interval;
}

- (NSNumber *)lastSessionInterval {
    int interval = -1;
    if (self.sessionState == kSessionStateAwaitingStart) {
        interval = self.sessionDateInterval;
    }
    return [NSNumber numberWithInt:interval];
}

- (void)setSessionLength {
    int length = self.sessionDateInterval;
    [NSUserDefaults.standardUserDefaults setInteger:length forKey:kKeySessionLength];
}

- (NSNumber *)lastSessionLength {
    int length = -1;
    if (self.sessionState == kSessionStateAwaitingStart) {
        NSNumber *number = [NSUserDefaults.standardUserDefaults objectForKey:kKeySessionLength];
        if (number != nil) {
            length = number.intValue;
        }
    }
    return [NSNumber numberWithInt:length];
}

@synthesize appToken;
@synthesize macSha1;
@synthesize macShortMd5;
@synthesize idForAdvertisers;
@synthesize fbAttributionId;
@synthesize apiClient;
@synthesize logger;

@end

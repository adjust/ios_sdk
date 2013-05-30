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


static AELogger    *aiLogger    = nil;
static AIApiClient *aiApiClient = nil;

static NSString *aiAppToken         = nil;
static NSString *aiMacSha1          = nil;
static NSString *aiMacShortMd5      = nil;
static NSString *aiIdForAdvertisers = nil;
static NSString *aiFbAttributionId  = nil;


#pragma mark private interface
@interface AdjustIo()

+ (void)addNotificationObserver;
+ (void)removeNotificationObserver;
+ (void)trackSessionStart;
+ (void)trackSessionEnd;

// save a new sessionState to sessionState
+ (void)setSessionState:(SessionState)sessionState;

// return sessionState
+ (SessionState)sessionState;

// increment sessionId, save and return it (first returned value: 1)
+ (NSNumber *)nextSessionId;

// save the sessionId to sessionLastId (marks current session as online)
+ (void)setLastSessionId;

// return sessionLastId (id of last online session)
// or -1 if there is no last online session
+ (NSNumber *)lastSessionId;

// save the current date to sessionDate
+ (void)setSessionDate;

// return the time interval in seconds between sessionDate and now
+ (int)sessionDateInterval;

// at session start: the time interval in seconds between the last online session end and now
// or -1 if we don't know when the last online session ended
+ (NSNumber *)lastSessionInterval;

// save sessionDateInterval to sessionLength
// at session end: save length of current online session
+ (void)setSessionLength;

// return sessionLength (length of last online session)
// or -1 if we don't know when the last online session ended
+ (NSNumber *)lastSessionLength;

@end


#pragma mark AdjustIo
@implementation AdjustIo

#pragma mark public

+ (void)appDidLaunch:(NSString *)yourAppToken {
    if (yourAppToken.length == 0) {
        [aiLogger error:@"Missing App Token."];
        return;
    }

    NSString *macAddress = UIDevice.currentDevice.aiMacAddress;

    aiAppToken         = yourAppToken;
    aiMacSha1          = macAddress.aiSha1;
    aiMacShortMd5      = macAddress.aiRemoveColons.aiMd5;
    aiIdForAdvertisers = UIDevice.currentDevice.aiIdForAdvertisers;
    aiFbAttributionId  = UIDevice.currentDevice.aiFbAttributionId;

    [self addNotificationObserver];
}

+ (void)trackEvent:(NSString *)eventToken {
    [self trackEvent:eventToken withParameters:nil];
}

+ (void)trackEvent:(NSString *)eventToken withParameters:(NSDictionary *)callbackParameters {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       aiAppToken,         @"app_token",
                                       aiMacShortMd5,      @"mac",
                                       aiIdForAdvertisers, @"idfa",
                                       eventToken,         @"event_id",
                                       nil];

    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    [aiApiClient postPath:@"/event" parameters:parameters
           successMessage:[NSString stringWithFormat:@"Tracked event %@.", eventToken]
           failureMessage:[NSString stringWithFormat:@"Failed to track event %@.", eventToken]];
}

+ (void)trackRevenue:(float)amountInCents {
    [self trackRevenue:amountInCents forEvent:nil];
}

+ (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken {
    [self trackRevenue:amountInCents forEvent:eventToken withParameters:nil];
}

+ (void)trackRevenue:(float)amountInCents forEvent:(NSString *)eventToken withParameters:(NSDictionary *)callbackParameters {
    NSString *amountInMillis = [NSNumber numberWithInt:roundf(10 * amountInCents)].stringValue;

    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       aiAppToken,         @"app_token",
                                       aiMacShortMd5,      @"mac",
                                       aiIdForAdvertisers, @"idfa",
                                       amountInMillis,     @"amount",
                                       nil];

    if (eventToken != nil) {
        [parameters setObject:eventToken forKey:@"event_id"];
    }

    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }

    [aiApiClient postPath:@"/revenue" parameters:parameters
           successMessage:[NSString stringWithFormat:@"Tracked revenue (%.1f Cents).", amountInCents]
           failureMessage:[NSString stringWithFormat:@"Failed to track revenue (%.1f Cents).", amountInCents]];
}

+ (void)setLogLevel:(AELogLevel)logLevel {
    aiLogger.logLevel = logLevel;
}

#pragma mark private

+ (void)initialize {
    if (aiLogger == nil) {
        aiLogger = [AELogger loggerWithTag:@"AdjustIo"];
    }
    if (aiApiClient == nil) {
        aiApiClient = [AIApiClient apiClientWithLogger:aiLogger];
    }
}

+ (void)addNotificationObserver {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center addObserver:self
               selector:@selector(trackSessionStart)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(trackSessionEnd)
                   name:UIApplicationWillResignActiveNotification
                 object:nil];

    [center addObserver:self
               selector:@selector(removeNotificationObserver)
                   name:UIApplicationWillTerminateNotification
                 object:nil];
}

+ (void)removeNotificationObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

+ (void)trackSessionStart {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       aiAppToken,                 @"app_token",
                                       aiMacShortMd5,              @"mac",
                                       aiMacSha1,                  @"mac_sha1",
                                       aiIdForAdvertisers,         @"idfa",
                                       aiFbAttributionId,          @"fb_id",
                                       [self nextSessionId],       @"session_id",
                                       [self lastSessionId],       @"last_session_id",
                                       [self lastSessionInterval], @"last_interval",
                                       [self lastSessionLength],   @"last_length",
                                       nil];

    [aiApiClient postPath:@"/startup"
               parameters:parameters
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      [aiApiClient logSuccess:@"Tracked session."];
                      [self setSessionState:kSessionStateAwaitingEnd];
                      [self setLastSessionId];
                      [self setSessionDate];
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      [aiApiClient logFailure:@"Failed to track session." response:operation.responseString error:error];
                      if ([self sessionState] == kSessionStateAwaitingEnd)
                          [self setSessionState:kSessionStateMissedEnd];
                  }];
}

+ (void)trackSessionEnd {
    if ([self sessionState] == kSessionStateAwaitingEnd) {
        [self setSessionState:kSessionStateAwaitingStart];
        [self setSessionLength];
        [self setSessionDate];
    }
}


#pragma mark NSUserDefault interface

+ (void)setSessionState:(SessionState)sessionState {
    [NSUserDefaults.standardUserDefaults setInteger:sessionState forKey:kKeySessionState];
}

+ (SessionState)sessionState {
    int sessionState = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionState];
    return sessionState;
}

+ (NSNumber *)nextSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionId] + 1;
    [NSUserDefaults.standardUserDefaults setInteger:sessionId forKey:kKeySessionId];
    return [NSNumber numberWithInt:sessionId];
}

+ (void)setLastSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionId];
    [NSUserDefaults.standardUserDefaults setInteger:sessionId forKey:kKeySessionLastId];
}

+ (NSNumber *)lastSessionId {
    int sessionId = [NSUserDefaults.standardUserDefaults integerForKey:kKeySessionLastId];
    if (sessionId == 0) {
        sessionId = -1;
    }
    return [NSNumber numberWithInt:sessionId];
}

+ (void)setSessionDate {
    [NSUserDefaults.standardUserDefaults setObject:[NSDate date] forKey:kKeySessionDate];
}

+ (int)sessionDateInterval {
    int interval = -1;
    NSDate *last = [NSUserDefaults.standardUserDefaults objectForKey:kKeySessionDate];
    if (last != nil) {
        interval = roundf([[NSDate date] timeIntervalSinceDate:last]);
    }
    return interval;
}

+ (NSNumber *)lastSessionInterval {
    int interval = -1;
    if ([self sessionState] == kSessionStateAwaitingStart) {
        interval = [self sessionDateInterval];
    }
    return [NSNumber numberWithInt:interval];
}

+ (void)setSessionLength {
    int length = [self sessionDateInterval];
    [NSUserDefaults.standardUserDefaults setInteger:length forKey:kKeySessionLength];
}

+ (NSNumber *)lastSessionLength {
    int length = -1;
    if ([self sessionState] == kSessionStateAwaitingStart) {
        NSNumber *number = [NSUserDefaults.standardUserDefaults objectForKey:kKeySessionLength];
        if (number != nil) {
            length = number.intValue;
        }
    }
    return [NSNumber numberWithInt:length];
}

@end

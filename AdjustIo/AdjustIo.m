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
#import "NSData+AIAdditions.h"
#import "NSString+AIAdditions.h"

static AdjustIo *defaultInstance;


#pragma mark private interface
@interface AdjustIo()

+ (AdjustIo *)defaultInstance;

- (void)appDidLaunch:(NSString *)appId;
- (void)appWillTerminate;
- (void)trackDeviceId;

- (void)trackSessionStart;
- (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters;
- (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters;

- (void)log:(NSString *)format, ...;

@property (copy) NSString *appId;
@property (copy) NSString *macAddress;
@property (copy) NSString *deviceId;
@property (assign) BOOL loggingEnabled;

@property (retain) AIApiClient *apiClient;

@end


#pragma mark
@implementation AdjustIo

#pragma mark public

// class methods get forwarded to defaultInstance

+ (void)appDidLaunch:(NSString *)appId {
    [self.defaultInstance appDidLaunch:appId];
}

+ (void)trackDeviceId {
    [self.defaultInstance trackDeviceId];
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
    self.defaultInstance.loggingEnabled = loggingEnabled;
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
    
    self.apiClient = [AIApiClient apiClient];
    
    return self;
}

- (void)appDidLaunch:(NSString *)theAppId {
    if (theAppId.length == 0) {
        [self log:@"Error: Missing appId"];
        return;
    }
    
    self.appId = theAppId;
    self.macAddress = [UIDevice.currentDevice aiMacAddress];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(trackSessionStart) name:UIApplicationDidBecomeActiveNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)appWillTerminate {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)trackDeviceId {
    // uniqueIdentifier is deprecated at the time of writing (July 2012)
    // this code will still work and set the deviceId to nil when it won't be available anymore
    @try {
        self.deviceId = [UIDevice.currentDevice performSelector:@selector(uniqueIdentifier)];
    } @catch (NSException *e) {
        self.deviceId = nil;
    }
}

- (void)trackSessionStart {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appId,		@"app_id",
                                       self.macAddress,	@"mac",
                                       nil];
    
    if (self.deviceId != nil) {
        [parameters setValue:self.deviceId forKey:@"udid"];
    }
    
    [self.apiClient postPath:@"startup"
                  parameters:parameters
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         [self log:@"Tracked session start"];
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self log:@"Failed to track session start. (%@)", operation.responseString.aiTrim];
                     }];
}

- (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)callbackParameters {
    NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                eventId,			@"id",
                                self.appId,			@"app_id",
                                self.macAddress,	@"mac",
                                nil];
    
    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }
    
    [self.apiClient postPath:@"event"
                  parameters:parameters
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         [self log:@"Tracked event %@", eventId];
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self log:@"Failed to track event %@. (%@)", eventId, operation.responseString.aiTrim];
                     }];
}

- (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)callbackParameters {
    NSString *amountInMillis = [NSNumber numberWithInt:roundf(10 * amountInCents)].stringValue;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       self.appId,		@"app_id",
                                       self.macAddress,	@"mac",
                                       amountInMillis,	@"amount",
                                       nil];
    
    if (eventId != nil) {
        [parameters setObject:eventId forKey:@"event_id"];
    }
    
    
    if (callbackParameters != nil) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
        NSString *paramString = jsonData.aiEncodeBase64;
        [parameters setValue:paramString forKey:@"params"];
    }
    
    [self.apiClient postPath:@"revenue"
                  parameters:parameters
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         [self log:@"Tracked revenue"];
                     }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self log:@"Failed to tracke revenue. (%@)", operation.responseString.aiTrim];
                     }];
}

- (void)log:(NSString *)format, ... {
    if (loggingEnabled) {
        va_list ap;
        va_start(ap,format);
        NSLog(@"[AdjustIo] %@", [[NSString alloc] initWithFormat:format arguments:ap]);
        va_end(ap);
    }
}

@synthesize appId;
@synthesize macAddress;
@synthesize deviceId;
@synthesize loggingEnabled;
@synthesize apiClient;

@end

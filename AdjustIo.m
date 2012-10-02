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

static AdjustIo *defaultInstance;


#pragma mark private interface
@interface AdjustIo()

+ (AdjustIo *)defaultInstance;

- (void)appDidLaunch:(NSString *)appId;
- (void)trackDeviceId;
- (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters;
- (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters;

- (void)appWillTerminate;
- (void)trackSessionStart;

@property (copy) NSString *appId;
@property (copy) NSString *macAddress;
@property (copy) NSString *deviceId;

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

+ (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters {
	[self.defaultInstance trackEvent:eventId withParameters:parameters];
}

+ (void)trackEvent:(NSString *)eventId {
	[self trackEvent:eventId withParameters:nil];
}

+ (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)parameters {
	[self.defaultInstance userGeneratedRevenue:amountInCents forEvent:eventId withParameters:parameters];
}

+ (void)userGeneratedRevenue:(float)amountInCents {
	[self userGeneratedRevenue:amountInCents forEvent:nil withParameters:nil];
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
		NSLog(@"appId missing");
		return;
	}
	
	self.appId = theAppId;
	self.macAddress = [UIDevice.currentDevice aiMacAddress];
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(trackSessionStart) name:UIApplicationDidBecomeActiveNotification object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(appWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
}

- (void)trackDeviceId {
	// uniqueIdentifier is deprecated at the time of writing (July 2012)
	// this code will still work and set the udid to nil when it won't be available anymore
	@try {
		self.deviceId = [UIDevice.currentDevice performSelector:@selector(uniqueIdentifier)];
	} @catch (NSException *e) {
		self.deviceId = nil;
	}
}

- (void)trackEvent:(NSString *)eventId withParameters:(NSDictionary *)callbackParameters {
	NSDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								eventId,			@"id",
								self.appId,			@"app_id",
								self.macAddress,	@"mac",
								nil];
	
	if (callbackParameters != nil) {
		NSData *jsonData = [NSJSONSerialization dataWithJSONObject:callbackParameters options:0 error:nil];
		NSString *paramString = [jsonData aiEncodeBase64];
		[parameters setValue:paramString forKey:@"params"];
	}
	
	[self.apiClient postPath:@"event"
				  parameters:parameters
					 success:^(AFHTTPRequestOperation *operation, id responseObject) {
						 NSLog(@"request finished: %@", operation.request.URL.absoluteString);
					 }
					 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
						 NSLog(@"request failed: %@ (%@)", operation.request.URL.absoluteString, operation.responseString);
					 }];
}

- (void)userGeneratedRevenue:(float)amountInCents forEvent:(NSString *)eventId withParameters:(NSDictionary *)callbackParameters {
	NSNumber *amountInDeciCents = [NSNumber numberWithInt:roundf(10 * amountInCents)];
	NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObject:amountInDeciCents forKey:@"amount"];
	
	if (eventId == nil) {
		eventId = @"1";
	}
	
	if (callbackParameters != nil) {
		[parameters addEntriesFromDictionary:callbackParameters];
	}
	
	[self trackEvent:eventId withParameters:parameters];
}

- (void)appWillTerminate {
	[NSNotificationCenter.defaultCenter removeObserver:self];
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
//						 NSLog(@"request finished: %@", operation.request.URL.absoluteString);
					 }
					 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//						 NSLog(@"request failed: %@ (%@)", operation.request.URL.absoluteString, operation.responseString);
					 }];
}

@synthesize appId;
@synthesize macAddress;
@synthesize deviceId;
@synthesize apiClient;

@end

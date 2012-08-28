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

static AdjustIo *defaultInstance;


#pragma mark private interface
@interface AdjustIo()

+ (AdjustIo *)defaultInstance;

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

// static methods get forwarded to defaultInstance
+ (void)appDidLaunch:(NSString *)appId {
	[self.defaultInstance appDidLaunch:appId];
}

+ (void)userGeneratedRevenue:(float)amountInCents {
	[self.defaultInstance userGeneratedRevenue:amountInCents];
}

+ (void)trackDeviceId {
	[self.defaultInstance trackDeviceId];
}


// instance methods do the 'heavy' lifting

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

- (void)userGeneratedRevenue:(float)amountInCents {
	// amount in deci cents
	NSNumber *amount = [NSNumber numberWithInt:roundf(10 * amountInCents)];
	
	NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
								self.appId,			@"app_id",
								self.macAddress,	@"mac",
								amount,				@"amount",
								nil];
	
	[self.apiClient postPath:@"revenue"
				  parameters:parameters
					 success:^(AFHTTPRequestOperation *operation, id responseObject) {
						 NSLog(@"request finished: %@", operation.request.URL.absoluteString);
					 }
					 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
						 NSLog(@"request failed: %@ (%@)", operation.request.URL.absoluteString, operation.responseString);
					 }];
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


#pragma mark private

+ (AdjustIo *)defaultInstance {
	if (defaultInstance == nil) {
		defaultInstance = [[AdjustIo alloc] init];
	}
	
	return defaultInstance;
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
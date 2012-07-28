//
//  AdjustIo.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AdjustIo.h"
#import "UIDevice+AIAdditions.h"
#import "ASIFormDataRequest.h"


static NSString * const kBaseUrl = @"http://app.adjust.io"; 

static AdjustIo *defaultInstance;


#pragma mark private interface
@interface AdjustIo()

+ (AdjustIo *)defaultInstance;

- (void)appWillTerminate;
- (void)trackSessionStart;

// generic request handlers
- (void)requestFinished:(ASIHTTPRequest *)reqest;
- (void)requestFailed:(ASIHTTPRequest *)request;

@property (copy) NSString *appId;
@property (copy) NSString *macAddress;
@property (copy) NSString *deviceId;

@end


#pragma mark
@implementation AdjustIo

#pragma mark public

// static methods get forwarded to defaultInstance
+ (void)appDidLaunch:(NSString *)appId {
	[self.defaultInstance appDidLaunch:appId];
}

+ (void)trackDeviceId {
	[self.defaultInstance trackDeviceId];
}


// instance methods do the 'heavy' lifting

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
	NSString *url = [NSString stringWithFormat:@"%@/startup", kBaseUrl];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
	
	[request addPostValue:self.appId forKey:@"app_id"];
	[request addPostValue:self.macAddress forKey:@"mac"];
	
	// track deviceId only if enabled by calling trackDeviceId
	if (self.deviceId != nil) {
		[request addPostValue:self.deviceId forKey:@"udid"];
	}
	
	[request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"request finished %d: %@\n%@", request.responseStatusCode, request.url.absoluteString, request.responseString);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"request failed: %@", request.url.absoluteString);
}

@synthesize appId;
@synthesize macAddress;
@synthesize deviceId;

@end
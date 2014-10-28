//
//  AIActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "Adjust.h"

@protocol AIActivityHandler

- (id)initWithAppToken:(NSString *)appToken;
- (void)setSdkPrefix:(NSString *)sdkPrefix;

- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;

- (void)trackEvent:(AIEvent *)event;

- (void)finishedTrackingWithResponse:(AIResponseData *)response deepLink:(NSString *)deepLink;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (void)readOpenUrl:(NSURL*)url;
- (void)savePushToken:(NSData *)pushToken;

- (void)setEnvironment:(NSString *)environment;
- (void)setBufferEvents:(BOOL)bufferEvents;
- (void)setTrackMacMd5:(BOOL)trackMacMd5;
- (void)setDelegate:(NSObject<AdjustDelegate> *) delegate;
- (void)setIsIad:(BOOL)isIad;

@end

@interface AIActivityHandler : NSObject <AIActivityHandler>

+ (id<AIActivityHandler>)handlerWithAppToken:(NSString *)appToken;

@end

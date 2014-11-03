//
//  AIActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "AIAttribution.h"

@protocol AIActivityHandler <NSObject>

- (id)initWithConfig:(AdjustConfig *)adjustConfig;

- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;

- (void)trackEvent:(AIEvent *)event;

- (void)finishedTrackingWithResponse:(NSString *)deepLink;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (void)readOpenUrl:(NSURL*)url;
- (void)savePushToken:(NSData *)pushToken;

- (AIAttribution*) attribution;
- (void) setAttribution:(AIAttribution*)attribution;

- (void) changedAttributionDelegate:(AIAttribution*) attribution;

- (void) setOfflineMode:(BOOL)enabled;

@end

@interface AIActivityHandler : NSObject <AIActivityHandler>

+ (id<AIActivityHandler>)handlerWithConfig:(AdjustConfig *)adjustConfig;

@end

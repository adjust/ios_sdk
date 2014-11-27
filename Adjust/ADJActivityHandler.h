//
//  ADJActivityHandler.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-01.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJAttribution.h"

@protocol ADJActivityHandler <NSObject>

- (id)initWithConfig:(ADJConfig *)adjustConfig;

- (void)trackSubsessionStart;
- (void)trackSubsessionEnd;

- (void)trackEvent:(ADJEvent *)event;

- (void)finishedTrackingWithResponse:(NSDictionary *)jsonDict;
- (void)setEnabled:(BOOL)enabled;
- (BOOL)isEnabled;
- (void)appWillOpenUrl:(NSURL*)url;
- (void)setDeviceToken:(NSData *)deviceToken;

- (ADJAttribution*) attribution;
- (void) setAttribution:(ADJAttribution*)attribution;

- (void) updateAttribution:(ADJAttribution*) attribution;
- (void) setIadDate:(NSDate*)iAdImpressionDate withPurchaseDate:(NSDate*)appPurchaseDate;

- (void) launchAttributionDelegate;

- (void) setOfflineMode:(BOOL)enabled;

- (void)addPermanentCallbackParameter:(NSString *)key
                             andValue:(NSString *)value;

- (void)addPermanentPartnerParameter:(NSString *)key
                            andValue:(NSString *)value;

@end

@interface ADJActivityHandler : NSObject <ADJActivityHandler>

+ (id<ADJActivityHandler>)handlerWithConfig:(ADJConfig *)adjustConfig;

@end

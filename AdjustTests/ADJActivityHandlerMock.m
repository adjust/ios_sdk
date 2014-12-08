//
//  ADJActivityHandlerMock.m
//  Adjust
//
//  Created by Pedro Filipe on 11/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJActivityHandlerMock.h"
#import "ADJLoggerMock.h"
#import "ADJAdjustFactory.h"

static NSString * const prefix = @"ADJActivityHandler ";

@interface ADJActivityHandlerMock()

@property (nonatomic, strong) ADJLoggerMock *loggerMock;

@end

@implementation ADJActivityHandlerMock

- (id)initWithConfig:(ADJConfig *)adjustConfig {
    self = [super init];
    if (self == nil) return nil;

    self.loggerMock = (ADJLoggerMock *) [ADJAdjustFactory logger];

    [self.loggerMock test:[prefix stringByAppendingFormat:@"initWithConfig"]];

    return self;
}

- (void)trackSubsessionStart {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"trackSubsessionStart"]];
}
- (void)trackSubsessionEnd {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"trackSubsessionEnd"]];
}

- (void)trackEvent:(ADJEvent *)event {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"trackEvent"]];

}

- (void)finishedTrackingWithResponse:(NSDictionary *)jsonDict {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"finishedTrackingWithResponse response:%@", jsonDict]];
}

- (void)setEnabled:(BOOL)enabled {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"setEnabled enabled:%d", enabled]];
}

- (BOOL)isEnabled {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"isEnabled"]];
    return YES;
}

- (void)appWillOpenUrl:(NSURL *)url {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"readOpenUrl"]];
}

- (void)setDeviceToken:(NSData *)pushToken {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"savePushToken"]];
}

- (ADJAttribution*) attribution {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"attribution"]];
    return (ADJAttribution *)[NSNull null];
}

- (void) setAttribution:(ADJAttribution*)attribution {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"setAttribution"]];
}

- (void) setAskingAttribution:(BOOL)askingAttribution {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"setAskingAttribution"]];
}

- (BOOL) updateAttribution:(ADJAttribution*) attribution {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"updateAttribution"]];
    return NO;
}

- (void) setIadDate:(NSDate*)iAdImpressionDate withPurchaseDate:(NSDate*)appPurchaseDate {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"setIadDate"]];
}

- (void) launchAttributionDelegate {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"launchAttributionDelegate"]];
}

- (void) setOfflineMode:(BOOL)enabled {
    [self.loggerMock test:[prefix stringByAppendingFormat:@"setOfflineMode"]];
}

@end

//
//  ADJThirdPartySharing.m
//  AdjustSdk
//
//  Created by Pedro S. on 02.12.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharing.h"

@interface ADJThirdPartySharing () @end

@implementation ADJThirdPartySharing

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _granularOptions = [[NSMutableDictionary alloc] init];
    _enable = nil;

    return self;
}

- (void)addGranularOption:(NSString *)partnerName
                      key:(NSString *)key
                      value:(NSString *)value
{
    NSMutableDictionary *partnerOptions = [granularOptions objectForKey:partnerName];
    if (partnerOptions == nil) {
        partnerOptions = [[NSMutableDictionary alloc] init];
        [granularOptions setObject:partnerOptions forKey:partnerName];
    }

    [partnerOptions setObject:value forKey:key];
}

- (void)enableThirdPartySharing {
    self.enable = [NSNumber numberWithBool:YES];
}

- (void)diableThirdPartySharing {
    self.enable = [NSNumber numberWithBool:NO];
}

@end

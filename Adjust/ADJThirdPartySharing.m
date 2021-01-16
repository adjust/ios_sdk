//
//  ADJThirdPartySharing.m
//  AdjustSdk
//
//  Created by Pedro S. on 02.12.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharing.h"
#import "ADJAdjustFactory.h"

@implementation ADJThirdPartySharing

- (nullable id)initWithIsEnabledNumberBool:(nullable NSNumber *)isEnabledNumberBool {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _granularOptions = [[NSMutableDictionary alloc] init];
    _enabled = isEnabledNumberBool;

    return self;
}

- (void)addGranularOption:(nonnull NSString *)partnerName
                      key:(nonnull NSString *)key
                    value:(nonnull NSString *)value
{
    if (partnerName == nil || key == nil || value == nil) {
        [ADJAdjustFactory.logger error:@"Cannot add granular option with any nil value"];
        return;
    }

    NSMutableDictionary *partnerOptions = [self.granularOptions objectForKey:partnerName];
    if (partnerOptions == nil) {
        partnerOptions = [[NSMutableDictionary alloc] init];
        [self.granularOptions setObject:partnerOptions forKey:partnerName];
    }

    [partnerOptions setObject:value forKey:key];
}

@end

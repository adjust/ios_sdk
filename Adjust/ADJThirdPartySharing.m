//
//  ADJThirdPartySharing.m
//  AdjustSdk
//
//  Created by Pedro S. on 02.12.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import "ADJThirdPartySharing.h"
#import "ADJAdjustFactory.h"
#import "ADJUtil.h"

@implementation ADJThirdPartySharing

- (nullable id)initWithIsEnabledNumberBool:(nullable NSNumber *)isEnabledNumberBool {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _enabled = isEnabledNumberBool;
    _granularOptions = [[NSMutableDictionary alloc] init];
    _partnerSharingSettings = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)addGranularOption:(nonnull NSString *)partnerName
                      key:(nonnull NSString *)key
                    value:(nonnull NSString *)value {
    if ([ADJUtil isNull:partnerName] || [ADJUtil isNull:key] || [ADJUtil isNull:value]) {
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

- (void)addPartnerSharingSetting:(nonnull NSString *)partnerName
                             key:(nonnull NSString *)key
                           value:(BOOL)value {
    if ([ADJUtil isNull:partnerName] || [ADJUtil isNull:key]) {
        [ADJAdjustFactory.logger error:@"Cannot add partner sharing setting with any nil value"];
        return;
    }

    NSMutableDictionary *partnerSharingSetting = [self.partnerSharingSettings objectForKey:partnerName];
    if (partnerSharingSetting == nil) {
        partnerSharingSetting = [[NSMutableDictionary alloc] init];
        [self.partnerSharingSettings setObject:partnerSharingSetting forKey:partnerName];
    }
    
    [partnerSharingSetting setObject:[NSNumber numberWithBool:value] forKey:key];
}

@end

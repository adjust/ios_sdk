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

static NSMutableDictionary *ADJDeepMutableCopyTwoLevelDictionary(NSDictionary *dictionary) {
    NSMutableDictionary *copy = [[NSMutableDictionary alloc] init];
    if (dictionary == nil) {
        return copy;
    }

    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL * _Nonnull stop) {
        if (key == nil || value == nil || value == [NSNull null]) {
            return;
        }

        id keyCopy = [key conformsToProtocol:@protocol(NSCopying)] ? [key copy] : [key description];
        if (keyCopy == nil) {
            return;
        }

        if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *innerCopy = [[NSMutableDictionary alloc] init];
            [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id innerKey, id innerValue, BOOL * _Nonnull stop) {
                if (innerKey == nil || innerValue == nil || innerValue == [NSNull null]) {
                    return;
                }
                id innerKeyCopy =
                    [innerKey conformsToProtocol:@protocol(NSCopying)] ? [innerKey copy] : [innerKey description];
                id innerValueCopy =
                    [innerValue conformsToProtocol:@protocol(NSCopying)] ? [innerValue copy] : [innerValue description];
                if (innerKeyCopy == nil || innerValueCopy == nil) {
                    return;
                }
                [innerCopy setObject:innerValueCopy forKey:innerKeyCopy];
            }];
            [copy setObject:innerCopy forKey:keyCopy];
            return;
        }

        id valueCopy = [value conformsToProtocol:@protocol(NSCopying)] ? [value copy] : [value description];
        if (valueCopy == nil) {
            return;
        }
        [copy setObject:valueCopy forKey:keyCopy];
    }];

    return copy;
}

@implementation ADJThirdPartySharing

- (nullable id)initWithIsEnabled:(nullable NSNumber *)isEnabled {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _enabled = isEnabled;
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

- (id)copyWithZone:(NSZone *)zone {
    ADJThirdPartySharing *copy =
        [[[self class] allocWithZone:zone] initWithIsEnabled:[self.enabled copyWithZone:zone]];

    if (copy == nil) {
        return nil;
    }

    copy->_granularOptions = ADJDeepMutableCopyTwoLevelDictionary(self.granularOptions);
    copy->_partnerSharingSettings = ADJDeepMutableCopyTwoLevelDictionary(self.partnerSharingSettings);

    return copy;
}

@end

//
//  ADJDeeplink.m
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on 18th July 2024.
//  Copyright © 2024-Present Adjust. All rights reserved.
//

#import "ADJDeeplink.h"

@implementation ADJDeeplink

- (id)initWithDeeplink:(NSURL *)deeplink {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _deeplink = [deeplink copy];

    return self;
}

- (void)setReferrer:(nonnull NSURL *)referrer {
    @synchronized (self) {
        _referrer = [referrer copy];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    ADJDeeplink *copy = [[[self class] allocWithZone:zone] initWithDeeplink:[self.deeplink copyWithZone:zone]];
    if (copy == nil) {
        return nil;
    }

    NSURL *referrerSnapshot = nil;
    @synchronized (self) {
        referrerSnapshot = [self.referrer copyWithZone:zone];
    }
    if (referrerSnapshot != nil) {
        [copy setReferrer:referrerSnapshot];
    }

    return copy;
}

@end

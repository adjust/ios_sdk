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

@end

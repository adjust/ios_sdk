//
//  ADJStoreInfo.m
//  Adjust
//
//  Created by Aditi Agrawal on 06/03/25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import "ADJStoreInfo.h"

@implementation ADJStoreInfo

#pragma mark - Public methods

- (nullable id)initWithStoreName:(nonnull NSString *)storeName {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _storeName = [storeName copy];

    return self;
}

- (void)setStoreAppId:(NSString *)storeAppId {
    @synchronized (self) {
        _storeAppId = [storeAppId copy];
    }
}

- (id)copyWithZone:(NSZone *)zone {
    ADJStoreInfo *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_storeName = [self.storeName copyWithZone:zone];
        copy->_storeAppId = [self.storeAppId copyWithZone:zone];
    }

    return copy;
}

@end

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

- (nullable id)initWithStoreInfoType:(nonnull NSString *)storeType
                      storeInfoAppId:(nonnull NSString *)appId {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _storeType = [storeType copy];
    _appId = [appId copy];

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ADJStoreInfo *copy = [[[self class] allocWithZone:zone] init];

    if (copy) {
        copy->_storeType = [self.storeType copyWithZone:zone];
        copy->_appId = [self.appId copyWithZone:zone];
    }

    return copy;
}

@end

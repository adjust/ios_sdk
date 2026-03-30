//
//  ADJRemoteTrigger.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on December 3rd 2025.
//  Copyright © 2025-present Adjust. All rights reserved.
//

#import "ADJRemoteTrigger.h"

@implementation ADJRemoteTrigger

- (nonnull instancetype)initWithLabel:(nonnull NSString *)label
                               payload:(nonnull NSDictionary<NSString *, id> *)payload {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    _label = [label copy];
    _payload = [payload copy];
    
    return self;
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    ADJRemoteTrigger *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_label = [self.label copyWithZone:zone];
        copy->_payload = [self.payload copyWithZone:zone];
    }
    
    return copy;
}

#pragma mark - NSObject protocol methods

- (NSString *)description {
    return [NSString stringWithFormat:@"Remote Trigger label:%@ payload:%@",
            self.label,
            self.payload];
}

@end

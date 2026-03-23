//
//  ADJGlobalParameters.m
//  Adjust
//
//  Created by Pedro Filipe on 27/05/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJGlobalParameters.h"
#import "ADJUtil.h"

@implementation ADJGlobalParameters

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    return self;
}

- (ADJGlobalParameters *)deepCopy {
    ADJGlobalParameters *copy = [[ADJGlobalParameters alloc] init];
    copy.callbackParameters = self.callbackParameters != nil
        ? [[ADJUtil dictionaryDeepCopy:self.callbackParameters] mutableCopy]
        : nil;
    copy.partnerParameters = self.partnerParameters != nil
        ? [[ADJUtil dictionaryDeepCopy:self.partnerParameters] mutableCopy]
        : nil;
    return copy;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    
    ADJGlobalParameters* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.callbackParameters = [self.callbackParameters copyWithZone:zone];
        copy.partnerParameters  = [self.partnerParameters copyWithZone:zone];
    }

    return copy;
}

@end

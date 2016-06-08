//
//  ADJSessionParameters.m
//  Adjust
//
//  Created by Pedro Filipe on 27/05/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJSessionParameters.h"

@implementation ADJSessionParameters

#pragma mark NSCoding
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return self;

    self.externalDeviceId = [decoder decodeObjectForKey:@"externalDeviceId"];
    // does not read dictionary parameters
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.externalDeviceId forKey:@"externalDeviceId"];
    // does not save dictionary parameters
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    ADJSessionParameters* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.externalDeviceId       = [self.externalDeviceId copyWithZone:zone];
        copy.callbackParameters = [self.callbackParameters copyWithZone:zone];
        copy.partnerParameters  = [self.partnerParameters copyWithZone:zone];
    }

    return copy;
}

@end

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

    self.customUserId = [decoder decodeObjectForKey:@"customUserId"];
    // does not read dictionary parameters
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.customUserId forKey:@"customUserId"];
    // does not save dictionary parameters
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    ADJSessionParameters* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.customUserId       = [self.customUserId copyWithZone:zone];
        copy.callbackParameters = [self.callbackParameters copyWithZone:zone];
        copy.partnerParameters  = [self.partnerParameters copyWithZone:zone];
    }

    return copy;
}

@end

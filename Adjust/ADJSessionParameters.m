//
//  ADJSessionParameters.m
//  Adjust
//
//  Created by Pedro Filipe on 27/05/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJSessionParameters.h"

@implementation ADJSessionParameters

#pragma mark - NSCoding protocol methods
- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.externalDeviceId = [decoder decodeObjectForKey:@"externalDeviceId"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {

    [encoder encodeObject:self.externalDeviceId     forKey:@"externalDeviceId"];
}

#pragma mark - NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    ADJSessionParameters* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.callbackParameters = [self.callbackParameters copyWithZone:zone];
        copy.partnerParameters  = [self.partnerParameters copyWithZone:zone];
    }

    return copy;
}

@end

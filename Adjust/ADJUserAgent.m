//
//  ADJUserAgent.m
//  adjust
//
//  Created by Pedro Filipe on 28/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJUserAgent.h"

@implementation ADJUserAgent

-(id)copyWithZone:(NSZone *)zone
{
    ADJUserAgent * copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.bundeIdentifier = [self.bundeIdentifier copyWithZone:zone];
        copy.bundleVersion = [self.bundleVersion copyWithZone:zone];
        copy.deviceType = [self.deviceType copyWithZone:zone];
        copy.deviceName = [self.deviceName copyWithZone:zone];
        copy.osName = [self.osName copyWithZone:zone];
        copy.systemVersion = [self.systemVersion copyWithZone:zone];
        copy.languageCode = [self.languageCode copyWithZone:zone];
        copy.countryCode = [self.countryCode copyWithZone:zone];
    }

    return copy;
}

@end

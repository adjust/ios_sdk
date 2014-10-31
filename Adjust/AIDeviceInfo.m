//
//  AIDeviceInfo.m
//  adjust
//
//  Created by Pedro Filipe on 17/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "AIDeviceInfo.h"

@implementation AIDeviceInfo

-(id)copyWithZone:(NSZone *)zone
{
    AIDeviceInfo* copy = [[[self class] allocWithZone:zone] init];
    if (copy) {
        copy.macSha1 = [self.macSha1 copyWithZone:zone];
        copy.macShortMd5 = [self.macShortMd5 copyWithZone:zone];
        copy.idForAdvertisers = [self.idForAdvertisers copyWithZone:zone];
        copy.fbAttributionId = [self.fbAttributionId copyWithZone:zone];
        copy.trackingEnabled = self.trackingEnabled;
        copy.isIad = self.isIad;
        copy.vendorId = [self.vendorId copyWithZone:zone];
        copy.pushToken = [self.pushToken copyWithZone:zone];
        copy.clientSdk = [self.clientSdk copyWithZone:zone];
        copy.userAgent = [self.userAgent copyWithZone:zone];
        copy.adjustConfig = [self.adjustConfig copyWithZone:zone];
    }

    return copy;
}

@end

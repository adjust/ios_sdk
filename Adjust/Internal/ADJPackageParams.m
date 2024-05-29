//
//  ADJPackageParams.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 17th November 2014.
//  Copyright (c) 2014-2021 adjust GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ADJPackageParams.h"
#import "ADJUtil.h"

@implementation ADJPackageParams

+ (ADJPackageParams *) packageParamsWithSdkPrefix:(NSString *)sdkPrefix {
    return [[ADJPackageParams alloc] initWithSdkPrefix:sdkPrefix];
}

- (id)initWithSdkPrefix:(NSString *)sdkPrefix {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.osName = @"ios";
    self.idfv = [ADJUtil idfv];
    self.fbAnonymousId = [ADJUtil fbAnonymousId];
    self.bundleIdentifier = [ADJUtil bundleIdentifier];
    self.buildNumber = [ADJUtil buildNumber];
    self.versionNumber = [ADJUtil versionNumber];
    self.deviceType = [ADJUtil deviceType];
    self.deviceName = [ADJUtil deviceName];
    self.osVersion = [ADJUtil osVersion];
    self.installedAt = [ADJUtil installedAt];
    self.startedAt = [ADJUtil startedAt];
    if (sdkPrefix == nil) {
        self.clientSdk = ADJUtil.clientSdk;
    } else {
        self.clientSdk = [NSString stringWithFormat:@"%@@%@", sdkPrefix, ADJUtil.clientSdk];
    }

    return self;
}

@end

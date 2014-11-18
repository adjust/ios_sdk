//
//  ADJUserAgent.m
//  adjust
//
//  Created by Pedro Filipe on 28/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJUserAgent.h"
#import "UIDevice+ADJAdditions.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>


static NSString * const kWiFi   = @"WIFI";
static NSString * const kWWAN   = @"WWAN";


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
        copy.networkType = [self.networkType copyWithZone:zone];
        copy.mobileCountryCode = [self.mobileCountryCode copyWithZone:zone];
        copy.mobileNetworkCode = [self.mobileNetworkCode copyWithZone:zone];
    }

    return copy;
}

+ (ADJUserAgent *)userAgent {

    ADJUserAgent * userAgent = [[ADJUserAgent alloc] init];

    UIDevice *device = UIDevice.currentDevice;
    NSLocale *locale = NSLocale.currentLocale;
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];

    userAgent.bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    userAgent.bundleVersion   = [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey];
    userAgent.languageCode    = [locale objectForKey:NSLocaleLanguageCode];
    userAgent.countryCode     = [locale objectForKey:NSLocaleCountryCode];
    userAgent.osName          = @"ios";

    userAgent.deviceType      = device.adjDeviceType;
    userAgent.deviceName      = device.adjDeviceName;
    userAgent.systemVersion   = device.systemVersion;
    userAgent.networkType     = [ADJUserAgent getNetworkStatus];

    userAgent.mobileCountryCode = [carrier mobileCountryCode];
    userAgent.mobileNetworkCode = [carrier mobileNetworkCode];

    return userAgent;
}

// from https://developer.apple.com/library/ios/samplecode/Reachability/
+ (NSString *)getNetworkStatus {
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;

    const struct sockaddr_in * hostAddress = &zeroAddress;
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *) hostAddress);

    SCNetworkReachabilityFlags flags;
    if(!SCNetworkReachabilityGetFlags(reachability, &flags)) {
        return nil;
    }

    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        return nil;
    }

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        /*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
        return kWiFi;
    }

    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */

        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            /*
             ... and no [user] intervention is needed...
             */
            return kWiFi;
        }
    }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        /*
         ... but WWAN connections are OK if the calling application is using the CFNetwork APIs.
         */
        return kWWAN;
    }

    return nil;
}

@end

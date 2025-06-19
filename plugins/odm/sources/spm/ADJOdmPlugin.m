//
//  ADJOdmPlugin.m
//  Adjust
//
//  Created by Genady Buchatsky on 13.05.25.
//  Copyright © 2025-Present Adjust GmbH. All rights reserved.
//

#import "ADJOdmPlugin.h"

#if __has_feature(modules)
@import GoogleAdsOnDeviceConversion;
#else
#import <GoogleAdsOnDeviceConversion/GoogleAdsOnDeviceConversion.h>
#endif


@implementation ADJOdmPlugin

+ (BOOL)isOdmFrameworkAvailableWithError:(NSString **)error {
    return YES;
}

+ (nullable NSString *)odmFrameworkVersion {
    return [[ODCConversionManager sharedInstance] versionString];
}

+ (void)setOdmAppFirstLaunchTimestamp:(NSDate *_Nonnull)time {
    [[ODCConversionManager sharedInstance] setFirstLaunchTime:time];
}

+ (void)fetchOdmInfoWithCompletion:(void (^_Nonnull)(NSString * _Nullable odmInfo, NSError * _Nullable error))completion {
    [[ODCConversionManager sharedInstance] fetchAggregateConversionInfoForInteraction:ODCInteractionTypeInstallation
                                                                           completion:completion];
}

@end

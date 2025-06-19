//
//  ADJOdmPlugin.m
//  Adjust
//
//  Created by Genady Buchatsky on 13.05.25.
//  Copyright © 2025-Present Adjust GmbH. All rights reserved.
//

#import "ADJOdmPlugin.h"

@implementation ADJOdmPlugin

+ (BOOL)isOdmFrameworkAvailableWithError:(NSString **)error {
    Class odmClass = NSClassFromString(@"ODCConversionManager");
    if (odmClass == nil) {
        *error = @"ODCConversionManager class not found";
        return NO;
    }

    SEL selSharedInstance = NSSelectorFromString(@"sharedInstance");
    if (![odmClass respondsToSelector:selSharedInstance]) {
        *error = @"sharedInstance method not found in ODCConversionManager class";
        return NO;
    }

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id sharedInstance = [odmClass performSelector:selSharedInstance];
#pragma clang diagnostic pop

    SEL selVersionString = NSSelectorFromString(@"versionString");
    if (![sharedInstance respondsToSelector:selVersionString]) {
        *error = @"versionString: method not found in ODCConversionManager class";
        return NO;
    }

    SEL selSetLaunchTime = NSSelectorFromString(@"setFirstLaunchTime:");
    if (![sharedInstance respondsToSelector:selSetLaunchTime]) {
        *error = @"setFirstLaunchTime: method not found in ODCConversionManager class";
        return NO;
    }

    SEL selFetchConversionInfo = NSSelectorFromString(@"fetchAggregateConversionInfoForInteraction:completion:");
    if (![sharedInstance respondsToSelector:selFetchConversionInfo]) {
        *error = @"fetchAggregateConversionInfoForInteraction:completion: method not found in ODCConversionManager class";
        return NO;
    }

    return YES;
}

+ (nullable NSString *)odmFrameworkVersion {
    Class class = NSClassFromString(@"ODCConversionManager");
    if (class == nil) {
        return nil;
    }
    SEL selSharedInstance = NSSelectorFromString(@"sharedInstance");
    if (![class respondsToSelector:selSharedInstance]) {
        return nil;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id sharedInstance = [class performSelector:selSharedInstance];
#pragma clang diagnostic pop
    SEL selVersionString = NSSelectorFromString(@"versionString");
    if (![sharedInstance respondsToSelector:selVersionString]) {
        return nil;
    }

    NSMethodSignature *msVersionString = [sharedInstance methodSignatureForSelector:selVersionString];
    NSInvocation *inVersionString = [NSInvocation invocationWithMethodSignature:msVersionString];
    [inVersionString setSelector:selVersionString];
    [inVersionString setTarget:sharedInstance];
    [inVersionString invoke];
    NSString *version = nil;
    [inVersionString getReturnValue:&version];
    return version;
}

+ (void)setOdmAppFirstLaunchTimestamp:(NSDate *)time {
    Class odmClass = NSClassFromString(@"ODCConversionManager");
    SEL selSharedInstance = NSSelectorFromString(@"sharedInstance");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id sharedInstance = [odmClass performSelector:selSharedInstance];
#pragma clang diagnostic pop

    SEL selSetLaunchTime = NSSelectorFromString(@"setFirstLaunchTime:");
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [sharedInstance methodSignatureForSelector:selSetLaunchTime]];
    [inv setSelector:selSetLaunchTime];
    [inv setTarget:sharedInstance];
    [inv setArgument:&time atIndex:2];
    [inv invoke];
}

+ (void)fetchOdmInfoWithCompletion:(void (^_Nonnull)(NSString * _Nullable odmInfo, NSError * _Nullable error))completion {
    Class odmClass = NSClassFromString(@"ODCConversionManager");
    SEL selSharedInstance = NSSelectorFromString(@"sharedInstance");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id sharedInstance = [odmClass performSelector:selSharedInstance];
#pragma clang diagnostic pop

    SEL selFetchConversionInfo = NSSelectorFromString(@"fetchAggregateConversionInfoForInteraction:completion:");

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:
                         [sharedInstance methodSignatureForSelector:selFetchConversionInfo]];
    NSInteger interactionType = 0; // ODCInteractionTypeInstallation of ODCInteractionType
    [inv setSelector:selFetchConversionInfo];
    [inv setTarget:sharedInstance];
    [inv setArgument:&interactionType atIndex:2];
    [inv setArgument:&completion atIndex:3];
    [inv invoke];
}

@end

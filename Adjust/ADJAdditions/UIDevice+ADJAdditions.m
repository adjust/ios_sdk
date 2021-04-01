//
//  UIDevice+ADJAdditions.m
//  Adjust
//
//  Created by Christian Wellenbrock (@wellle) on 23rd July 2012.
//  Copyright © 2012-2018 Adjust GmbH. All rights reserved.
//

#import "UIDevice+ADJAdditions.h"
#import "NSString+ADJAdditions.h"

#import <sys/sysctl.h>

#if !ADJUST_NO_IDFA
#import <AdSupport/ASIdentifierManager.h>
#endif

#if !ADJUST_NO_IAD && !TARGET_OS_TV
#import <iAd/iAd.h>
#endif

#import "ADJUtil.h"
#import "ADJSystemProfile.h"
#import "ADJAdjustFactory.h"

@implementation UIDevice(ADJAdditions)

- (Class)adSupportManager {
    NSString *className = [NSString adjJoin:@"A", @"S", @"identifier", @"manager", nil];
    Class class = NSClassFromString(className);
    
    return class;
}

- (Class)appTrackingManager {
    NSString *className = [NSString adjJoin:@"A", @"T", @"tracking", @"manager", nil];
    Class class = NSClassFromString(className);
    
    return class;
}

- (int)adjATTStatus {
    Class appTrackingClass = [self appTrackingManager];
    if (appTrackingClass != nil) {
        NSString *keyAuthorization = [NSString adjJoin:@"tracking", @"authorization", @"status", nil];
        SEL selAuthorization = NSSelectorFromString(keyAuthorization);
        if ([appTrackingClass respondsToSelector:selAuthorization]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return (int)[appTrackingClass performSelector:selAuthorization];
#pragma clang diagnostic pop
        }
    }
    
    return -1;
}

- (void)requestTrackingAuthorizationWithCompletionHandler:(void (^)(NSUInteger status))completion
{
    Class appTrackingClass = [self appTrackingManager];
    if (appTrackingClass == nil) {
        return;
    }
    NSString *requestAuthorization = [NSString adjJoin:
                                      @"request",
                                      @"tracking",
                                      @"authorization",
                                      @"with",
                                      @"completion",
                                      @"handler:", nil];
    SEL selRequestAuthorization = NSSelectorFromString(requestAuthorization);
    if (![appTrackingClass respondsToSelector:selRequestAuthorization]) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [appTrackingClass performSelector:selRequestAuthorization withObject:completion];
#pragma clang diagnostic pop
}

- (BOOL)adjTrackingEnabled {
#if ADJUST_NO_IDFA
    return NO;
#else
    
//     return [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    Class adSupportClass = [self adSupportManager];
    if (adSupportClass == nil) {
        return NO;
    }

    NSString *keyManager = [NSString adjJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return NO;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id manager = [adSupportClass performSelector:selManager];
    
    NSString *keyEnabled = [NSString adjJoin:@"is", @"advertising", @"tracking", @"enabled", nil];
    SEL selEnabled = NSSelectorFromString(keyEnabled);
    if (![manager respondsToSelector:selEnabled]) {
        return NO;
    }
    BOOL enabled = (BOOL)[manager performSelector:selEnabled];
    return enabled;
#pragma clang diagnostic pop
#endif
}

- (NSString *)adjIdForAdvertisers {
#if ADJUST_NO_IDFA
    return @"";
#else
    // return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    Class adSupportClass = [self adSupportManager];
    if (adSupportClass == nil) {
        return @"";
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    NSString *keyManager = [NSString adjJoin:@"shared", @"manager", nil];
    SEL selManager = NSSelectorFromString(keyManager);
    if (![adSupportClass respondsToSelector:selManager]) {
        return @"";
    }
    id manager = [adSupportClass performSelector:selManager];

    NSString *keyIdentifier = [NSString adjJoin:@"advertising", @"identifier", nil];
    SEL selIdentifier = NSSelectorFromString(keyIdentifier);
    if (![manager respondsToSelector:selIdentifier]) {
        return @"";
    }
    id identifier = [manager performSelector:selIdentifier];

    NSString *keyString = [NSString adjJoin:@"UUID", @"string", nil];
    SEL selString = NSSelectorFromString(keyString);
    if (![identifier respondsToSelector:selString]) {
        return @"";
    }
    NSString *string = [identifier performSelector:selString];
    return string;

#pragma clang diagnostic pop
#endif
}

- (NSString *)adjFbAnonymousId {
#if TARGET_OS_TV
    return @"";
#else
    // pre FB SDK v6.0.0
    // return [FBSDKAppEventsUtility retrievePersistedAnonymousID];
    // post FB SDK v6.0.0
    // return [FBSDKBasicUtility retrievePersistedAnonymousID];
    Class class = nil;
    SEL selGetId = NSSelectorFromString(@"retrievePersistedAnonymousID");
    class = NSClassFromString(@"FBSDKBasicUtility");
    if (class != nil) {
        if ([class respondsToSelector:selGetId]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *fbAnonymousId = (NSString *)[class performSelector:selGetId];
            return fbAnonymousId;
#pragma clang diagnostic pop
        }
    }
    class = NSClassFromString(@"FBSDKAppEventsUtility");
    if (class != nil) {
        if ([class respondsToSelector:selGetId]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            NSString *fbAnonymousId = (NSString *)[class performSelector:selGetId];
            return fbAnonymousId;
#pragma clang diagnostic pop
        }
    }
    return @"";
#endif
}

- (NSString *)adjDeviceType {
    NSString *type = [self.model stringByReplacingOccurrencesOfString:@" " withString:@""];
    return type;
}

- (NSString *)adjDeviceName {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *name = calloc(1, size);
    sysctlbyname("hw.machine", name, &size, NULL, 0);
    NSString *machine = [NSString stringWithUTF8String:name];
    free(name);
    return machine;
}

- (NSString *)adjCreateUuid {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef stringRef = CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    NSString *uuidString = (__bridge_transfer NSString*)stringRef;
    NSString *lowerUuid = [uuidString lowercaseString];
    CFRelease(newUniqueId);
    return lowerUuid;
}

- (NSString *)adjVendorId {
    if ([UIDevice.currentDevice respondsToSelector:@selector(identifierForVendor)]) {
        return [UIDevice.currentDevice.identifierForVendor UUIDString];
    }
    return @"";
}

- (void)adjCheckForiAd:(ADJActivityHandler *)activityHandler queue:(dispatch_queue_t)queue {
    // if no tries for iad v3 left, stop trying
    id<ADJLogger> logger = [ADJAdjustFactory logger];

#if ADJUST_NO_IAD || TARGET_OS_TV
    [logger debug:@"ADJUST_NO_IAD or TARGET_OS_TV set"];
    return;
#else
    [logger debug:@"ADJUST_NO_IAD or TARGET_OS_TV not set"];

    // [[ADClient sharedClient] ...]
    Class ADClientClass = NSClassFromString(@"ADClient");
    if (ADClientClass == nil) {
        [logger warn:@"iAd framework not found in user's app (ADClientClass not found)"];
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sharedClientSelector = NSSelectorFromString(@"sharedClient");
    if (![ADClientClass respondsToSelector:sharedClientSelector]) {
        [logger warn:@"iAd framework not found in user's app (sharedClient method not found)"];
        return;
    }
    id ADClientSharedClientInstance = [ADClientClass performSelector:sharedClientSelector];
    if (ADClientSharedClientInstance == nil) {
        [logger warn:@"iAd framework not found in user's app (ADClientSharedClientInstance is nil)"];
        return;
    }

    [logger debug:@"iAd framework successfully found in user's app"];
    
    BOOL iAdInformationAvailable = [self setiAdWithDetails:activityHandler
                                   adcClientSharedInstance:ADClientSharedClientInstance
                                    queue:queue];

    if (!iAdInformationAvailable) {
        [logger warn:@"iAd information not available"];
        return;
    }
#pragma clang diagnostic pop
#endif
}

- (NSString *)adjFetchAdServicesAttribution:(NSError **)errorPtr {
    id<ADJLogger> logger = [ADJAdjustFactory logger];
    
    // [AAAttribution attributionTokenWithError:...]
    Class attributionClass = NSClassFromString(@"AAAttribution");
    if (attributionClass == nil) {
        [logger warn:@"AdServices framework not found in user's app (AAAttribution not found)"];
        
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:@"com.adjust.sdk.adServices"
                                            code:100
                                        userInfo:@{@"Error reason": @"AdServices framework not found"}];
        }
        return nil;
    }
    
    SEL attributionTokenSelector = NSSelectorFromString(@"attributionTokenWithError:");
    if (![attributionClass respondsToSelector:attributionTokenSelector]) {
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:@"com.adjust.sdk.adServices"
                                            code:100
                                        userInfo:@{@"Error reason": @"AdServices framework not found"}];
        }
        return nil;
    }
    
    NSMethodSignature *attributionTokenMethodSignature = [attributionClass methodSignatureForSelector:attributionTokenSelector];
    NSInvocation *tokenInvocation = [NSInvocation invocationWithMethodSignature:attributionTokenMethodSignature];
    [tokenInvocation setSelector:attributionTokenSelector];
    [tokenInvocation setTarget:attributionClass];
    
    __autoreleasing NSError *error;
    __autoreleasing NSError **errorPointer = &error;
    [tokenInvocation setArgument:&errorPointer atIndex:2];
    [tokenInvocation invoke];
    
    if (error) {
        [logger error:@"Error while retrieving AdServices attribution token: %@", error];
        if (errorPtr) {
            *errorPtr = error;
        }
        return nil;
    }
    
    NSString * __unsafe_unretained tmpToken = nil;
    [tokenInvocation getReturnValue:&tmpToken];
    
    NSString *token = tmpToken;
    return token;
}

- (BOOL)setiAdWithDetails:(ADJActivityHandler *)activityHandler
  adcClientSharedInstance:(id)ADClientSharedClientInstance
                    queue:(dispatch_queue_t)queue {
    SEL iAdDetailsSelector = NSSelectorFromString(@"requestAttributionDetailsWithBlock:");
    if (![ADClientSharedClientInstance respondsToSelector:iAdDetailsSelector]) {
        return NO;
    }
    
    __block Class lock = [ADJActivityHandler class];
    __block BOOL completed = NO;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [ADClientSharedClientInstance performSelector:iAdDetailsSelector
                                       withObject:^(NSDictionary *attributionDetails, NSError *error) {
        
        @synchronized (lock) {
            if (completed) {
                return;
            } else {
                completed = YES;
            }
        }
        
        [activityHandler setAttributionDetails:attributionDetails
                                         error:error];
    }];
#pragma clang diagnostic pop
    
    // 5 seconds of timeout
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), queue, ^{
        @synchronized (lock) {
            if (completed) {
                return;
            } else {
                completed = YES;
            }
        }
        
        [activityHandler setAttributionDetails:nil
                                         error:[NSError errorWithDomain:@"com.adjust.sdk.iAd"
                                                                   code:100
                                                               userInfo:@{@"Error reason": @"iAd request timed out"}]];
    });
    
    return YES;
}

@end

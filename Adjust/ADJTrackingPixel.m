//
//  ADJTrackingPixel.m
//  Adjust
//
//  Created by Uglješa Erceg on 28/06/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJUtil.h"
#import "ADJLogger.h"
#import "ADJAdjustFactory.h"
#import "ADJTrackingPixel.h"
#import "UIDevice+ADJAdditions.h"

#if !TARGET_OS_TV
#import <SafariServices/SafariServices.h>
#endif

#if !TARGET_OS_TV
static const int kTrackingPixelMaxAttempts  = 2;
static const int kTrackingPixelTimeout[]    = { 10, 100 };
#endif

#if !TARGET_OS_TV
@interface ADJTrackingPixel () <SFSafariViewControllerDelegate>
#else
@interface ADJTrackingPixel ()
#endif

@end

@implementation ADJTrackingPixel {
    NSUInteger numberOfAttempts;
    UIWindow *window;
}

+ (id)getInstance {
    static ADJTrackingPixel *defaultInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultInstance = [[self alloc] init];
    });

    return defaultInstance;
}

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    numberOfAttempts = 0;

    return self;
}

+ (void)present {
    // If SFSafariViewController is present, use it.
    // SFSafariViewController is supported starting from iOS 9.
    if (NSClassFromString(@"SFSafariViewController")) {
        [[ADJTrackingPixel getInstance] present];
    } else {
        [[ADJAdjustFactory logger] warn:@"AdWords request can't be sent with this iOS version"];
    }
}

- (void)present {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self tryToLoadTrackingPixel];
    });
}

- (void)tryToLoadTrackingPixel {
#if !TARGET_OS_TV
    [[ADJAdjustFactory logger] verbose:@"Trying to initialise tracking pixel for Google AdWords"];

    NSBundle *appBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundleIdentifier = appBundle.bundleIdentifier;
    NSString *sdkVersion = [NSString stringWithFormat:@"adjust-sdk-i-v%@", [[[ADJUtil clientSdk] componentsSeparatedByString:@"s"] lastObject]];
    NSString * const urlStringFormat = @"%@"
    @"/%@/?app_event_type=web_bridge"
    @"&idtype=idfa"
    @"&lat=%d"
    @"&rdid=%@"
    @"&sdkversion=%@";

    NSString *urlString = [[NSString alloc] initWithFormat:urlStringFormat,
                           @"https://www.googleadservices.com/pagead/conversion/app/connect",
                           bundleIdentifier,
                           [[UIDevice currentDevice] adjTrackingEnabled] ? 1 : 0,
                           [[UIDevice currentDevice] adjIdForAdvertisers],
                           sdkVersion];

    NSURL *url = [NSURL URLWithString:urlString];

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UIViewController *topViewController = [self topViewController];

        if (!topViewController) {
            return;
        }

        SFSafariViewController *safariViewController = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:NO];
        safariViewController.delegate = self;
        safariViewController.view.userInteractionEnabled = NO;
        safariViewController.view.alpha = 0.05;
        safariViewController.view.translatesAutoresizingMaskIntoConstraints = NO;

        [topViewController addChildViewController:safariViewController];
        [topViewController.view addSubview:safariViewController.view];
        
        safariViewController.view.frame = CGRectMake(0, 0, 1, 1);
    });
#endif
}

#if !TARGET_OS_TV
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    window = nil;

    if (didLoadSuccessfully) {
        [[ADJAdjustFactory logger] verbose:@"AdWords request completed successfully"];

        // Remove the tracking pixel from the view hierarchy.
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    } else {
        if (numberOfAttempts < kTrackingPixelMaxAttempts) {
            dispatch_time_t retryTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * kTrackingPixelTimeout[numberOfAttempts++]);
            dispatch_after(retryTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self tryToLoadTrackingPixel];
            });
        } else {
            numberOfAttempts = 0;
            [[ADJAdjustFactory logger] verbose:@"AdWords request failed"];
        }
    }
}

- (UIWindow *)mainWindow {
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    UIWindow *mainWindow = sharedApplication.keyWindow;

    if (!mainWindow && [sharedApplication.delegate respondsToSelector:@selector(window)]) {
        mainWindow = [sharedApplication.delegate window];
    }

    return mainWindow;
}

- (UIViewController *)topViewController {
    UIWindow *mainWindow = [self mainWindow];
    UIViewController *topViewController = nil;
    UIViewController *presentedViewController = mainWindow.rootViewController;

    while (presentedViewController) {
        topViewController = presentedViewController;

        if ([topViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)topViewController;
            presentedViewController = navController.topViewController;
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = (UITabBarController *)topViewController;
            presentedViewController = tabBarController.selectedViewController;
        } else {
            presentedViewController = topViewController.presentedViewController;
        }
    }
    
    return topViewController;
}
#endif

@end

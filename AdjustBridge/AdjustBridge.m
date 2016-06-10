//
//  AdjustBridge.m
//  Adjust
//
//  Created by Pedro Filipe on 27/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
// In case of erroneous import statement try with:
// #import <AdjustSdk/Adjust.h>
// (depends how you import the adjust SDK to your app)

#import "AdjustBridge.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "AdjustBridgeRegister.h"

#define KEY_APP_TOKEN                   @"appToken"
#define KEY_ENVIRONMENT                 @"environment"
#define KEY_LOG_LEVEL                   @"logLevel"
#define KEY_SDK_PREFIX                  @"sdkPrefix"
#define KEY_DEFAULT_TRACKER             @"defaultTracker"
#define KEY_SEND_IN_BACKGROUND          @"sendInBackground"
#define KEY_OPEN_DEFERRED_DEEPLINK      @"openDeferredDeeplink"
#define KEY_EVENT_BUFFERING_ENABLED     @"eventBufferingEnabled"
#define KEY_EVENT_TOKEN                 @"eventToken"
#define KEY_REVENUE                     @"revenue"
#define KEY_CURRENCY                    @"currency"
#define KEY_TRANSACTION_ID              @"transactionId"
#define KEY_CALLBACK_PARAMETERS         @"callbackParameters"
#define KEY_PARTNER_PARAMETERS          @"partnerParameters"

@interface AdjustBridge() <AdjustDelegate>

@property BOOL openDeferredDeeplink;

@property (nonatomic, strong) id<AdjustBridgeRegister> bridgeRegister;

@property WVJBResponseCallback deeplinkCallback;
@property WVJBResponseCallback attributionCallback;
@property WVJBResponseCallback eventSuccessCallback;
@property WVJBResponseCallback eventFailureCallback;
@property WVJBResponseCallback sessionSuccessCallback;
@property WVJBResponseCallback sessionFailureCallback;
@property WVJBResponseCallback deferredDeeplinkCallback;

@end

@implementation AdjustBridge

#pragma mark - Object lifecycle

- (id)init {
    self = [super init];

    self.openDeferredDeeplink = YES;

    self.attributionCallback = nil;
    self.eventSuccessCallback = nil;
    self.eventFailureCallback = nil;
    self.sessionSuccessCallback = nil;
    self.sessionFailureCallback = nil;

    return self;
}

#pragma mark - AdjustDelegate methods

- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    if (self.attributionCallback) {
        self.attributionCallback([attribution dictionary]);
    }
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    if (self.eventSuccessCallback) {
        self.eventSuccessCallback([eventSuccessResponseData jsonResponse]);
    }
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    if (self.eventFailureCallback) {
        self.eventFailureCallback([eventFailureResponseData jsonResponse]);
    }
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    if (self.sessionSuccessCallback) {
        self.sessionSuccessCallback([sessionSuccessResponseData jsonResponse]);
    }
}

- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    if (self.sessionFailureCallback) {
        self.sessionFailureCallback([sessionFailureResponseData jsonResponse]);
    }
}

- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    if (self.deferredDeeplinkCallback) {
        self.deferredDeeplinkCallback([deeplink absoluteString]);

        return self.openDeferredDeeplink;
    }

    return YES;
}

#pragma mark - Public methods

- (void)loadUIWebViewBridge:(UIWebView *)uiWebView {
    if (self.bridgeRegister != nil) {
        // WebViewBridge already loaded.
        return;
    }

    // Enable WebViewJavaScriptBridge logging.
    [WebViewJavascriptBridge enableLogging];

    self.bridgeRegister = [AdjustUIBridgeRegister bridgeRegisterWithUIWebView:uiWebView];

    [self loadWebViewBridge];
}

- (void)loadWKWebViewBridge:(WKWebView *)wkWebView {
    if (self.bridgeRegister != nil) {
        // WebViewBridge already loaded.
        return;
    }

    // Enable WebViewJavaScriptBridge logging.
    [WebViewJavascriptBridge enableLogging];

    self.bridgeRegister = [AdjustWKBridgeRegister bridgeRegisterWithWKWebView:wkWebView];

    [self loadWebViewBridge];
}

- (void)loadWebViewBridge {
    // Register for setting attribution callback method.
    [self.bridgeRegister registerHandler:@"adjust_setAttributionCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        self.attributionCallback = responseCallback;
    }];

    // Register for setting event tracking success callback method.
    [self.bridgeRegister registerHandler:@"adjust_setEventSuccessCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        self.eventSuccessCallback = responseCallback;
    }];

    // Register for setting event tracking failure method.
    [self.bridgeRegister registerHandler:@"adjust_setEventFailureCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        self.eventFailureCallback = responseCallback;
    }];

    // Register for setting session tracking success method.
    [self.bridgeRegister registerHandler:@"adjust_setSessionSuccessCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        self.sessionSuccessCallback = responseCallback;
    }];

    // Register for setting session tracking failure method.
    [self.bridgeRegister registerHandler:@"adjust_setSessionFailureCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        self.sessionFailureCallback = responseCallback;
    }];

    // Register for setting direct deeplink handler method.
    [self.bridgeRegister registerHandler:@"adjust_setDeferredDeeplinkCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        self.deferredDeeplinkCallback = responseCallback;
    }];

    // Register for appDidLaunch method.
    [self.bridgeRegister registerHandler:@"adjust_appDidLaunch" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *appToken = [data objectForKey:KEY_APP_TOKEN];
        NSString *environment = [data objectForKey:KEY_ENVIRONMENT];
        NSString *logLevel = [data objectForKey:KEY_LOG_LEVEL];
        NSString *sdkPrefix = [data objectForKey:KEY_SDK_PREFIX];
        NSString *defaultTracker = [data objectForKey:KEY_DEFAULT_TRACKER];
        NSNumber *sendInBackground = [data objectForKey:KEY_SEND_IN_BACKGROUND];
        NSNumber *eventBufferingEnabled = [data objectForKey:KEY_EVENT_BUFFERING_ENABLED];
        NSNumber *shouldOpenDeferredDeeplink = [data objectForKey:KEY_OPEN_DEFERRED_DEEPLINK];

        ADJConfig *adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];

        if ([adjustConfig isValid]) {
            // Log level
            if ([self isFieldValid:logLevel]) {
                [adjustConfig setLogLevel:[ADJLogger LogLevelFromString:[logLevel lowercaseString]]];
            }

            // Sending in background
            if ([self isFieldValid:sendInBackground]) {
                [adjustConfig setSendInBackground:[sendInBackground boolValue]];
            }

            // Event buffering
            if ([self isFieldValid:eventBufferingEnabled]) {
                [adjustConfig setEventBufferingEnabled:[eventBufferingEnabled boolValue]];
            }

            // Deferred deeplink opening
            if ([self isFieldValid:shouldOpenDeferredDeeplink]) {
                self.openDeferredDeeplink = [shouldOpenDeferredDeeplink boolValue];
            }

            // SDK prefix
            if ([self isFieldValid:sdkPrefix]) {
                [adjustConfig setSdkPrefix:sdkPrefix];
            }

            // Default tracker
            if ([self isFieldValid:defaultTracker]) {
                [adjustConfig setDefaultTracker:defaultTracker];
            }

            // Attribution delegate
            if (self.attributionCallback != nil || self.eventSuccessCallback != nil ||
                self.eventFailureCallback != nil || self.sessionSuccessCallback != nil ||
                self.sessionFailureCallback != nil || self.deferredDeeplinkCallback != nil) {
                [adjustConfig setDelegate:self];
            }

            [Adjust appDidLaunch:adjustConfig];
            [Adjust trackSubsessionStart];
        }
    }];

    // Register for trackEvent method.
    [self.bridgeRegister registerHandler:@"adjust_trackEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *eventToken = [data objectForKey:KEY_EVENT_TOKEN];
        NSString *revenue = [data objectForKey:KEY_REVENUE];
        NSString *currency = [data objectForKey:KEY_CURRENCY];
        NSString *transactionId = [data objectForKey:KEY_TRANSACTION_ID];

        NSMutableArray *callbackParameters = [[NSMutableArray alloc] init];
        NSMutableArray *partnerParameters = [[NSMutableArray alloc] init];

        for (id item in [data objectForKey:KEY_CALLBACK_PARAMETERS]) {
            [callbackParameters addObject:item];
        }

        for (id item in [data objectForKey:KEY_PARTNER_PARAMETERS]) {
            [partnerParameters addObject:item];
        }

        ADJEvent *adjustEvent = [ADJEvent eventWithEventToken:eventToken];

        if ([adjustEvent isValid]) {
            // Revenue and currency
            if ([self isFieldValid:revenue] || [self isFieldValid:currency]) {
                double revenueValue = [revenue doubleValue];

                [adjustEvent setRevenue:revenueValue currency:currency];
            }

            // Callback parameters
            for (int i = 0; i < [callbackParameters count]; i += 2) {
                NSString *key = [callbackParameters objectAtIndex:i];
                NSString *value = [callbackParameters objectAtIndex:(i+1)];

                [adjustEvent addCallbackParameter:key value:value];
            }

            // Partner parameters
            for (int i = 0; i < [partnerParameters count]; i += 2) {
                NSString *key = [partnerParameters objectAtIndex:i];
                NSString *value = [partnerParameters objectAtIndex:(i+1)];

                [adjustEvent addPartnerParameter:key value:value];
            }

            // Transaction ID
            if ([self isFieldValid:transactionId]) {
                [adjustEvent setTransactionId:transactionId];
            }

            [Adjust trackEvent:adjustEvent];
        }
    }];

    // Register for setOfflineMode method.
    [self.bridgeRegister registerHandler:@"adjust_setOfflineMode" handler:^(NSNumber * data, WVJBResponseCallback responseCallback) {
        [Adjust setOfflineMode:[data boolValue]];
    }];

    // Register for setEnabled method.
    [self.bridgeRegister registerHandler:@"adjust_setEnabled" handler:^(NSNumber * data, WVJBResponseCallback responseCallback) {
        [Adjust setEnabled:[data boolValue]];
    }];

    // Register for isEnabled method.
    [self.bridgeRegister registerHandler:@"adjust_isEnabled" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        responseCallback([Adjust isEnabled] ? @"Yes" : @"No");
    }];

    // Register for IDFA method.
    [self.bridgeRegister registerHandler:@"adjust_idfa" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        responseCallback([Adjust idfa]);
    }];

    // Register for appWillOpenUrl method.
    [self.bridgeRegister registerHandler:@"adjust_appWillOpenUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust appWillOpenUrl:[NSURL URLWithString:data]];
    }];

    // Register for setDeviceToken method.
    [self.bridgeRegister registerHandler:@"adjust_setDeviceToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust setDeviceToken:[data dataUsingEncoding:NSUTF8StringEncoding]];
    }];
}

- (void)sendDeeplinkToWebView:(NSURL *)deeplink {
    [self.bridgeRegister callHandler:@"adjust_deeplink" data:[deeplink absoluteString]];
}

#pragma mark - Private & helper methods

- (BOOL)isFieldValid:(NSObject *)field {
    if (field == nil) {
        return NO;
    }

    if ([field isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    return YES;
}

@end

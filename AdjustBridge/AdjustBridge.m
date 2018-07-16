//
//  AdjustBridge.m
//  Adjust
//
//  Created by Pedro Filipe on 27/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "Adjust.h"
// #import <AdjustSdk/Adjust.h>
// In case of erroneous import statement try with:
// #import <AdjustSdk/Adjust.h>
// (depends how you import the adjust SDK to your app)

#import "AdjustBridge.h"
#import "WebViewJavascriptBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "ADJAdjustFactory.h"

@interface AdjustBridge() <AdjustDelegate>

@property BOOL openDeferredDeeplink;

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

    if (self == nil) {
        return nil;
    }

    _bridgeRegister = nil;

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
    if (self.attributionCallback == nil) {
        return;
    }

    self.attributionCallback([attribution dictionary]);
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    if (self.eventSuccessCallback == nil) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [dictionary setValue:eventSuccessResponseData.message forKey:@"message"];
    [dictionary setValue:eventSuccessResponseData.timeStamp forKey:@"timestamp"];
    [dictionary setValue:eventSuccessResponseData.adid forKey:@"adid"];
    [dictionary setValue:eventSuccessResponseData.eventToken forKey:@"eventToken"];
    [dictionary setValue:eventSuccessResponseData.jsonResponse forKey:@"jsonResponse"];

    self.eventSuccessCallback(dictionary);
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    if (self.eventFailureCallback == nil) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [dictionary setValue:eventFailureResponseData.message forKey:@"message"];
    [dictionary setValue:eventFailureResponseData.timeStamp forKey:@"timestamp"];
    [dictionary setValue:eventFailureResponseData.adid forKey:@"adid"];
    [dictionary setValue:eventFailureResponseData.eventToken forKey:@"eventToken"];
    [dictionary setValue:[NSNumber numberWithBool:eventFailureResponseData.willRetry] forKey:@"willRetry"];
    [dictionary setValue:eventFailureResponseData.jsonResponse forKey:@"jsonResponse"];

    self.eventFailureCallback(dictionary);
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    if (self.sessionSuccessCallback == nil) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [dictionary setValue:sessionSuccessResponseData.message forKey:@"message"];
    [dictionary setValue:sessionSuccessResponseData.timeStamp forKey:@"timestamp"];
    [dictionary setValue:sessionSuccessResponseData.adid forKey:@"adid"];
    [dictionary setValue:sessionSuccessResponseData.jsonResponse forKey:@"jsonResponse"];

    self.sessionSuccessCallback(dictionary);
}

- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    if (self.sessionFailureCallback == nil) {
        return;
    }

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [dictionary setValue:sessionFailureResponseData.message forKey:@"message"];
    [dictionary setValue:sessionFailureResponseData.timeStamp forKey:@"timestamp"];
    [dictionary setValue:sessionFailureResponseData.adid forKey:@"adid"];
    [dictionary setValue:[NSNumber numberWithBool:sessionFailureResponseData.willRetry] forKey:@"willRetry"];
    [dictionary setValue:sessionFailureResponseData.jsonResponse forKey:@"jsonResponse"];

    self.sessionFailureCallback(dictionary);
}

- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    if (self.deferredDeeplinkCallback) {
        self.deferredDeeplinkCallback([deeplink absoluteString]);
    }

    return self.openDeferredDeeplink;
}

#pragma mark - Public methods

- (void)loadUIWebViewBridge:(WVJB_WEBVIEW_TYPE *)webView {
    [self loadUIWebViewBridge:webView webViewDelegate:nil];
}

- (void)loadWKWebViewBridge:(WKWebView *)wkWebView {
    [self loadWKWebViewBridge:wkWebView wkWebViewDelegate:nil];
}

- (void)loadUIWebViewBridge:(WVJB_WEBVIEW_TYPE *)webView
            webViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate {
    if (self.bridgeRegister != nil) {
        // WebViewBridge already loaded.
        return;
    }

    AdjustUIBridgeRegister *uiBridgeRegister = [AdjustUIBridgeRegister bridgeRegisterWithUIWebView:webView];
    [uiBridgeRegister setWebViewDelegate:webViewDelegate];
    
    _bridgeRegister = uiBridgeRegister;
    [self loadWebViewBridge];
}

- (void)loadWKWebViewBridge:(WKWebView *)wkWebView
          wkWebViewDelegate:(id<WKNavigationDelegate>)wkWebViewDelegate {
    if (self.bridgeRegister != nil) {
        // WebViewBridge already loaded.
        return;
    }

    AdjustWKBridgeRegister *wkBridgeRegister = [AdjustWKBridgeRegister bridgeRegisterWithWKWebView:wkWebView];
    [wkBridgeRegister setWebViewDelegate:wkWebViewDelegate];
    
    _bridgeRegister = wkBridgeRegister;
    [self loadWebViewBridge];
}

- (void)loadWebViewBridge {
    // Register setCallback method to save callbacks before appDidLaunch
    [self.bridgeRegister registerHandler:@"adjust_setCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        if ([data isEqualToString:@"attributionCallback"]) {
            self.attributionCallback = responseCallback;
        } else if ([data isEqualToString:@"eventSuccessCallback"]) {
            self.eventSuccessCallback = responseCallback;
        } else if ([data isEqualToString:@"eventFailureCallback"]) {
            self.eventFailureCallback = responseCallback;
        } else if ([data isEqualToString:@"sessionSuccessCallback"]) {
            self.sessionSuccessCallback = responseCallback;
        } else if ([data isEqualToString:@"sessionFailureCallback"]) {
            self.sessionFailureCallback = responseCallback;
        } else if ([data isEqualToString:@"deferredDeeplinkCallback"]) {
            self.deferredDeeplinkCallback = responseCallback;
        }
    }];

    // Register for appDidLaunch method.
    [self.bridgeRegister registerHandler:@"adjust_appDidLaunch" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *appToken = [data objectForKey:@"appToken"];
        NSString *environment = [data objectForKey:@"environment"];
        NSString *allowSuppressLogLevel = [data objectForKey:@"allowSuppressLogLevel"];
        NSString *sdkPrefix = [data objectForKey:@"sdkPrefix"];
        NSString *defaultTracker = [data objectForKey:@"defaultTracker"];
        NSString *logLevel = [data objectForKey:@"logLevel"];
        NSNumber *eventBufferingEnabled = [data objectForKey:@"eventBufferingEnabled"];
        NSNumber *openDeferredDeeplink = [data objectForKey:@"openDeferredDeeplink"];

        ADJConfig *adjustConfig;
        if ([self isFieldValid:allowSuppressLogLevel]) {
            adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment allowSuppressLogLevel:[allowSuppressLogLevel boolValue]];
        } else {
            adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];
        }

        // no need to continue if adjust config is not valid
        if (![adjustConfig isValid]) {
            return;
        }

        if ([self isFieldValid:sdkPrefix]) {
            [adjustConfig setSdkPrefix:sdkPrefix];
        }
        if ([self isFieldValid:defaultTracker]) {
            [adjustConfig setDefaultTracker:defaultTracker];
        }
        if ([self isFieldValid:logLevel]) {
            [adjustConfig setLogLevel:[ADJLogger logLevelFromString:[logLevel lowercaseString]]];
        }
        if ([self isFieldValid:eventBufferingEnabled]) {
            [adjustConfig setEventBufferingEnabled:[eventBufferingEnabled boolValue]];
        }
        if ([self isFieldValid:openDeferredDeeplink]) {
            self.openDeferredDeeplink = [openDeferredDeeplink boolValue];
        }
        // Set self as delegate if any callback is configured
        // Change to swifle the methods in the future
        if (self.attributionCallback != nil || self.eventSuccessCallback != nil ||
            self.eventFailureCallback != nil || self.sessionSuccessCallback != nil ||
            self.sessionFailureCallback != nil || self.deferredDeeplinkCallback != nil) {
            [adjustConfig setDelegate:self];
        }

        [Adjust appDidLaunch:adjustConfig];
        [Adjust trackSubsessionStart];
    }];
    [self.bridgeRegister registerHandler:@"adjust_trackEvent" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSString *eventToken = [data objectForKey:@"eventToken"];
        NSString *revenue = [data objectForKey:@"revenue"];
        NSString *currency = [data objectForKey:@"currency"];
        NSString *transactionId = [data objectForKey:@"transactionId"];
        id callbackParameters = [data objectForKey:@"callbackParameters"];
        id partnerParameters = [data objectForKey:@"partnerParameters"];

        ADJEvent *adjustEvent = [ADJEvent eventWithEventToken:eventToken];

        // no need to continue if adjust event is not valid
        if (![adjustEvent isValid]) {
            return;
        }
        if ([self isFieldValid:revenue] && [self isFieldValid:currency]) {
            double revenueValue = [revenue doubleValue];
            [adjustEvent setRevenue:revenueValue currency:currency];
        }
        if ([self isFieldValid:transactionId]) {
            [adjustEvent setTransactionId:transactionId];
        }
        for (int i = 0; i < [callbackParameters count]; i += 2) {
            [adjustEvent addCallbackParameter:[callbackParameters objectAtIndex:i]
                                        value:[callbackParameters objectAtIndex:(i+1)]];
        }
        for (int i = 0; i < [partnerParameters count]; i += 2) {
            [adjustEvent addPartnerParameter:[partnerParameters objectAtIndex:i]
                                       value:[partnerParameters objectAtIndex:(i+1)]];
        }

        [Adjust trackEvent:adjustEvent];
    }];
    [self.bridgeRegister registerHandler:@"adjust_setEnabled" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSNumber class]]) {
            return;
        }
        [Adjust setEnabled:[(NSNumber *)data boolValue]];
    }];

    // Register for isEnabled method.
    [self.bridgeRegister registerHandler:@"adjust_isEnabled" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        responseCallback([NSNumber numberWithBool:[Adjust isEnabled]]);
    }];
    [self.bridgeRegister registerHandler:@"adjust_appWillOpenUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust appWillOpenUrl:[NSURL URLWithString:data]];
    }];
    [self.bridgeRegister registerHandler:@"adjust_setPushToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSString class]]) {
            return;
        }
        [Adjust setPushToken:(NSString *)data];
    }];
    [self.bridgeRegister registerHandler:@"adjust_setOfflineMode" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSNumber class]]) {
            return;
        }
        [Adjust setOfflineMode:[(NSNumber *)data boolValue]];
    }];
    [self.bridgeRegister registerHandler:@"adjust_idfa" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        responseCallback([Adjust idfa]);
    }];


    // Method replaced by setPushToken
    [self.bridgeRegister registerHandler:@"adjust_setDeviceToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[ADJAdjustFactory logger] warn:@"Function setDeviceToken has been replaced by setPushToken in web bridge"];
    }];
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

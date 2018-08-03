//
//  AdjustBridgeRegister.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 10th June 2016.
//  Copyright © 2016-2018 Adjust GmbH. All rights reserved.
//

#import "AdjustBridgeRegister.h"

static NSString * const kHandlerPrefix = @"adjust_";

@interface AdjustBridgeRegister()

@property (nonatomic, strong) WebViewJavascriptBridge *wvjb;
@property BOOL isToAugmentHybridWebView;

@end

@implementation AdjustBridgeRegister

- (id)initWithWebView:(id)webView {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.wvjb = [WebViewJavascriptBridge bridgeForWebView:webView];
    self.isToAugmentHybridWebView = NO;
    return self;
}

- (void)setWebViewDelegate:(id)webViewDelegate {
    [self.wvjb setWebViewDelegate:webViewDelegate];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self.wvjb callHandler:handlerName data:data];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    [self.wvjb registerHandler:handlerName handler:handler];
}

+ (NSString *)AdjustBridge_js {
#define __adj_wvjb_js_func__(x) #x
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode =
    @__adj_wvjb_js_func__(;(function() {
        if (window.Adjust) {
            return;
        }

        // copied from adjust.js
        window.Adjust = {
        appDidLaunch: function (adjustConfig) {
            if (WebViewJavascriptBridge) {
                if (adjustConfig) {
                    adjustConfig.iterateConfiguredCallbacks(
                                                            function(callbackName, callback) {
                                                                WebViewJavascriptBridge.callHandler('adjust_setCallback', callbackName, callback);
                                                            }
                                                            );
                    WebViewJavascriptBridge.callHandler('adjust_appDidLaunch', adjustConfig, null);
                }
            }
        },
        trackEvent: function (adjustEvent) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_trackEvent', adjustEvent, null);
            }
        },
        trackSubsessionStart: function() {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_trackSubsessionStart', null, null);
            }
        },
        trackSubsessionEnd: function() {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_trackSubsessionEnd', null, null);
            }
        },
        setEnabled: function (enabled) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_setEnabled', enabled, null);
            }
        },
        isEnabled: function (callback) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_isEnabled', null,
                                                    function(response) {
                                                        callback(new Boolean(response));
                                                    }
                                                    );
            }
        },
        appWillOpenUrl: function (url) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_appWillOpenUrl', url, null);
            }
        },
        setDeviceToken: function (deviceToken) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_setDeviceToken', deviceToken, null);
            }
        },
        setOfflineMode: function(isOffline) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_setOfflineMode', isOffline, null);
            }
        },
        getIdfa: function (callback) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_idfa', null, callback);
            }
        },
        getAdid: function (callback) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_adid', null, callback);
            }
        },
        getAttribution: function (callback) {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_attribution', null, callback);
            }
        },
        sendFirstPackages: function () {
            if (WebViewJavascriptBridge) {
                WebViewJavascriptBridge.callHandler('adjust_sendFirstPackages', null, null);
            }
        },
        addSessionCallbackParameter: function (key, value) {
            if (WebViewJavascriptBridge != null) {
                WebViewJavascriptBridge.callHandler('adjust_addSessionCallbackParameter', {key: key, value: value}, null);
            }
        },
        addSessionPartnerParameter: function (key, value) {
            if (WebViewJavascriptBridge != null) {
                WebViewJavascriptBridge.callHandler('adjust_addSessionPartnerParameter', {key: key, value: value}, null);
            }
        },
        removeSessionCallbackParameter: function (key) {
            if (WebViewJavascriptBridge != null) {
                WebViewJavascriptBridge.callHandler('adjust_removeSessionCallbackParameter', key, null);
            }
        },
        removeSessionPartnerParameter: function (key) {
            if (WebViewJavascriptBridge != null) {
                WebViewJavascriptBridge.callHandler('adjust_removeSessionPartnerParameter', key, null);
            }
        },
        resetSessionCallbackParameters: function () {
            if (WebViewJavascriptBridge != null) {
                WebViewJavascriptBridge.callHandler('adjust_resetSessionCallbackParameters', null, null);
            }
        },
        resetSessionPartnerParameters: function () {
            if (WebViewJavascriptBridge != null) {
                WebViewJavascriptBridge.callHandler('adjust_resetSessionPartnerParameters', null, null);
            }
        },
        gdprForgetMe: function () {
            if (WebViewJavascriptBridge != null) {
                WebViewJavascriptBridge.callHandler('adjust_gdprForgetMe', null, null);
            }
        }
        };

        // copied from adjust_event.js
        window.AdjustEvent = function (eventToken) {
            this.eventToken = eventToken;

            this.revenue = null;
            this.currency = null;
            this.transactionId = null;

            this.callbackParameters = [];
            this.partnerParameters = [];
        };

        AdjustEvent.prototype.addCallbackParameter = function(key, value) {
            this.callbackParameters.push(key);
            this.callbackParameters.push(value);
        };

        AdjustEvent.prototype.addPartnerParameter = function(key, value) {
            this.partnerParameters.push(key);
            this.partnerParameters.push(value);
        };

        AdjustEvent.prototype.setRevenue = function(revenue, currency) {
            this.revenue = revenue;
            this.currency = currency;
        };

        AdjustEvent.prototype.setTransactionId = function(transactionId) {
            this.transactionId = transactionId;
        };

        // copied from adjust_config.js
        window.AdjustConfig = function (appToken, environment, legacy) {

            if (arguments.length === 2) {
                // New format does not require bridge as first parameter.
                this.appToken = appToken;
                this.environment = environment;
            } else if (arguments.length === 3) {
                // New format with allowSuppressLogLevel.
                if (typeof(legacy) == typeof(true)) {
                    this.appToken = appToken;
                    this.environment = environment;
                    this.allowSuppressLogLevel = legacy;
                } else {
                    // Old format with first argument being the bridge instance.
                    this.bridge = appToken;
                    this.appToken = environment;
                    this.environment = legacy;
                }
            }

            this.sdkPrefix = 'web-bridge4.14.0';
            this.defaultTracker = null;
            this.logLevel = null;
            this.eventBufferingEnabled = null;
            this.sendInBackground = null;
            this.delayStart = null;
            this.userAgent = null;
            this.isDeviceKnown = null;
            this.secretId = null;
            this.info1 = null;
            this.info2 = null;
            this.info3 = null;
            this.info4 = null;
            this.openDeferredDeeplink = null;
            this.callbacksMap = {};
            this.test = null;
        };
        AdjustConfig.EnvironmentSandbox     = 'sandbox';
        AdjustConfig.EnvironmentProduction  = 'production';

        AdjustConfig.LogLevelVerbose        = 'VERBOSE';
        AdjustConfig.LogLevelDebug          = 'DEBUG';
        AdjustConfig.LogLevelInfo           = 'INFO';
        AdjustConfig.LogLevelWarn           = 'WARN';
        AdjustConfig.LogLevelError          = 'ERROR';
        AdjustConfig.LogLevelAssert         = 'ASSERT';
        AdjustConfig.LogLevelSuppress       = 'SUPPRESS';

        AdjustConfig.prototype.iterateConfiguredCallbacks = function(handleCallbackWithName) {
            if (!this.callbacksMap) {
                return;
            }
            var keysArray = Object.keys(this.callbacksMap);
            for (var idx in keysArray) {
                var key = keysArray[idx];
                handleCallbackWithName(key, this.callbacksMap[key]);
            }
        };

        AdjustConfig.prototype.setSdkPrefix = function(sdkPrefix) {
            this.sdkPrefix = sdkPrefix;
        };
        AdjustConfig.prototype.setDefaultTracker = function(defaultTracker) {
            this.defaultTracker = defaultTracker;
        };
        AdjustConfig.prototype.setLogLevel = function(logLevel) {
            this.logLevel = logLevel;
        };
        AdjustConfig.prototype.setEventBufferingEnabled = function(isEnabled) {
            this.eventBufferingEnabled = isEnabled;
        };
        AdjustConfig.prototype.setSendInBackground = function(isEnabled) {
            this.sendInBackground = isEnabled;
        };
        AdjustConfig.prototype.setDelayStart = function(delayStartInSeconds) {
            this.delayStart = delayStartInSeconds;
        };
        AdjustConfig.prototype.setUserAgent = function(userAgent) {
            this.userAgent = userAgent;
        };
        AdjustConfig.prototype.setIsDeviceKnown = function(isDeviceKnown) {
            this.isDeviceKnown = isDeviceKnown;
        };
        AdjustConfig.prototype.setAppSecret = function(secretId, info1, info2, info3, info4) {
            this.secretId = secretId;
            this.info1 = info1;
            this.info2 = info2;
            this.info3 = info3;
            this.info4 = info4;
        };

        AdjustConfig.prototype.setOpenDeferredDeeplink = function(shouldOpen) {
            this.openDeferredDeeplink = shouldOpen;
        };

        AdjustConfig.prototype.setAttributionCallback = function(callback) {
            this.callbacksMap['attributionCallback'] = callback;
        };

        AdjustConfig.prototype.setEventSuccessCallback = function(callback) {
            this.callbacksMap['eventSuccessCallback'] = callback;
        };

        AdjustConfig.prototype.setEventFailureCallback = function(callback) {
            this.callbacksMap['eventFailureCallback'] = callback;
        };

        AdjustConfig.prototype.setSessionSuccessCallback = function(callback) {
            this.callbacksMap['sessionSuccessCallback'] = callback;
        };

        AdjustConfig.prototype.setSessionFailureCallback = function(callback) {
            this.callbacksMap['sessionFailureCallback'] = callback;
        };

        AdjustConfig.prototype.setDeferredDeeplinkCallback = function(callback) {
            this.callbacksMap['deferredDeeplinkCallback'] = callback;
        };

        AdjustConfig.prototype.setTest = function() {
            this.test = true;
        };

    })();); // END preprocessorJSCode

#undef __adj_wvjb_js_func__
    return preprocessorJSCode;
}

@end
/*

@interface AdjustUIBridgeRegister()

@property (nonatomic, strong) WebViewJavascriptBridge *uiBridge;

@end

@implementation AdjustUIBridgeRegister

+ (id<AdjustBridgeRegister>)bridgeRegisterWithUIWebView:(WVJB_WEBVIEW_TYPE *)uiWebView {
    return [[AdjustUIBridgeRegister alloc] initWithUIWebView:uiWebView];
}

- (id)initWithUIWebView:(WVJB_WEBVIEW_TYPE *)uiWebView {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.uiBridge = [WebViewJavascriptBridge bridgeForWebView:uiWebView];
    return self;
}

- (void)setWebViewDelegate:(WVJB_WEBVIEW_DELEGATE_TYPE *)webViewDelegate {
    [self.uiBridge setWebViewDelegate:webViewDelegate];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.uiBridge registerHandler:handlerName handler:handler];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.uiBridge callHandler:handlerName data:data];
}

@end

@interface AdjustWKBridgeRegister()

@property (nonatomic, strong) WebViewJavascriptBridge *wkBridge;

@end

@implementation AdjustWKBridgeRegister

+ (id<AdjustBridgeRegister>)bridgeRegisterWithWKWebView:(WKWebView *)wkWebView {
    return [[AdjustWKBridgeRegister alloc] initWithWKWebView:wkWebView];
}

- (id)initWithWKWebView:(WKWebView *)wkWebView {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.wkBridge = [WebViewJavascriptBridge bridgeForWebView:wkWebView];
    return self;
}

- (void)setWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    [self.wkBridge setWebViewDelegate:webViewDelegate];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.wkBridge registerHandler:handlerName handler:handler];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    if ([handlerName hasPrefix:kHandlerPrefix] == NO) {
        return;
    }
    [self.wkBridge callHandler:handlerName data:data];
}

@end
*/

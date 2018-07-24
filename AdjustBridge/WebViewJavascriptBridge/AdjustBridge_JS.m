//
//  AdjustBridge_JS.m
//  AdjustBridge
//
//  Created by Pedro on 20.07.18.
//  Copyright © 2018 adjust GmbH. All rights reserved.
//

// This file including the header and format is copied with adaptions from
// WebViewJavascriptBridge_JS.m

// This file contains the source for the Javascript side of the
// Adjust Webview bridge. It is plaintext, but converted to an NSString
// via some preprocessor tricks.

// Previous implementations of Adjust Webview bridge loaded the javascript source
// from a resource. This worked fine for app developers, but library developers who
// included the bridge into their library, awkwardly had to ask consumers of their
// library to include the resource, violating their encapsulation. By including the
// Javascript as a string resource, the encapsulation of the library is maintained.

#import "AdjustBridge_JS.h"

NSString * AdjustBridge_js() {
    #define __adj_wvjb_js_func__(x) #x
    // BEGIN preprocessorJSCode
    static NSString * preprocessorJSCode = @__adj_wvjb_js_func__(
;(function() {
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

    })();
    ); // END preprocessorJSCode

#undef __adj_wvjb_js_func__
    return preprocessorJSCode;
};

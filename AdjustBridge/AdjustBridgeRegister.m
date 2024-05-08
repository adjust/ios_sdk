//
//  AdjustBridgeRegister.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 10th June 2016.
//  Copyright © 2016-2018 Adjust GmbH. All rights reserved.
//

#import "AdjustBridgeRegister.h"

static NSString * const kHandlerPrefix = @"adjust_";
static NSString * fbAppIdStatic = nil;

@interface AdjustBridgeRegister()

@property (nonatomic, strong) WKWebViewJavascriptBridge *wkwvjb;

@end

@implementation AdjustBridgeRegister

- (id)initWithWKWebView:(WKWebView*)webView {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.wkwvjb = [WKWebViewJavascriptBridge bridgeForWebView:webView];
    return self;
}

- (void)setWKWebViewDelegate:(id<WKNavigationDelegate>)webViewDelegate {
    [self.wkwvjb setWebViewDelegate:webViewDelegate];
}

- (void)callHandler:(NSString *)handlerName data:(id)data {
    [self.wkwvjb callHandler:handlerName data:data];
}

- (void)registerHandler:(NSString *)handlerName handler:(WVJBHandler)handler {
    [self.wkwvjb registerHandler:handlerName handler:handler];
}

- (void)augmentHybridWebView:(NSString *)fbAppId {
    fbAppIdStatic = fbAppId;
}

+ (NSString *)AdjustBridge_js {
    if (fbAppIdStatic != nil) {
        return [NSString stringWithFormat:@"%@%@",
                [AdjustBridgeRegister adjust_js],
                [AdjustBridgeRegister augmented_js]];
    } else {
        return [AdjustBridgeRegister adjust_js];
    }
}

#define __adj_js_func__(x) #x
// BEGIN preprocessorJSCode

+ (NSString *)augmented_js {
    return [NSString stringWithFormat:
        @__adj_js_func__(;(function() {
            window['fbmq_%@'] = {
                'getProtocol' : function() {
                    return 'fbmq-0.1';
                },
                'sendEvent': function(pixelID, evtName, customData) {
                    Adjust.fbPixelEvent(pixelID, evtName, customData);
                }
            };
        })();) // END preprocessorJSCode
     , fbAppIdStatic];
}

+ (NSString *)adjust_js {
    static NSString *preprocessorJSCode = @__adj_js_func__(;(function() {
        if (window.Adjust) {
            return;
        }

        // Copied from adjust.js
        window.Adjust = {
            appDidLaunch: function(adjustConfig) {
                if (WebViewJavascriptBridge) {
                    if (adjustConfig) {
                        if (!adjustConfig.getSdkPrefix()) {
                            adjustConfig.setSdkPrefix(this.getSdkPrefix());
                        }
                        this.sdkPrefix = adjustConfig.getSdkPrefix();
                        adjustConfig.registerCallbackHandlers();
                        WebViewJavascriptBridge.callHandler('adjust_appDidLaunch', adjustConfig, null);
                    }
                }
            },
            trackEvent: function(adjustEvent) {
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
            setEnabled: function(enabled) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_setEnabled', enabled, null);
                }
            },
            isEnabled: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_isEnabled', null,
                                                        function(response) {
                                                            callback(new Boolean(response));
                                                        });
                }
            },
            appWillOpenUrl: function(url) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_appWillOpenUrl', url, null);
                }
            },
            setDeviceToken: function(deviceToken) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_setDeviceToken', deviceToken, null);
                }
            },
            setOfflineMode: function(isOffline) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_setOfflineMode', isOffline, null);
                }
            },
            getIdfa: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_idfa', null, callback);
                }
            },
            getIdfv: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_idfv', null, callback);
                }
            },
            requestAppTrackingAuthorizationWithCompletionHandler: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_requestAppTrackingAuthorizationWithCompletionHandler', null, callback);
                }
            },
            getAppTrackingAuthorizationStatus: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_appTrackingAuthorizationStatus', null, callback);
                }
            },
            updateConversionValue: function(conversionValue) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_updateConversionValue', conversionValue, null);
                }
            },
            updateConversionValueWithCallback: function(conversionValue, callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_updateConversionValueCompletionHandler', conversionValue, callback);
                }
            },
            updateConversionValueWithCoarseValueAndCallback: function(conversionValue, coarseValue, callback) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_updateConversionValueCoarseValueCompletionHandler',
                                                        {conversionValue: conversionValue, coarseValue: coarseValue},
                                                        callback);
                }
            },
            updateConversionValueWithCoarseValueLockWindowAndCallback: function(conversionValue, coarseValue, lockWindow, callback) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_updateConversionValueCoarseValueLockWindowCompletionHandler',
                                                        {conversionValue: conversionValue, coarseValue: coarseValue},
                                                        callback);
                }
            },
            getAdid: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_adid', null, callback);
                }
            },
            getAttribution: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_attribution', null, callback);
                }
            },
            sendFirstPackages: function() {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_sendFirstPackages', null, null);
                }
            },
            addGlobalCallbackParameter: function(key, value) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_addGlobalCallbackParameter', {key: key, value: value}, null);
                }
            },
            addGlobalPartnerParameter: function(key, value) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_addGlobalPartnerParameter', {key: key, value: value}, null);
                }
            },
            removeGlobalCallbackParameter: function(key) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_removeGlobalCallbackParameter', key, null);
                }
            },
            removeGlobalPartnerParameter: function(key) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_removeGlobalPartnerParameter', key, null);
                }
            },
            removeGlobalCallbackParameters: function() {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_removeGlobalCallbackParameters', null, null);
                }
            },
            removeGlobalPartnerParameters: function() {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_removeGlobalPartnerParameters', null, null);
                }
            },
            gdprForgetMe: function() {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_gdprForgetMe', null, null);
                }
            },
            trackThirdPartySharing: function(adjustThirdPartySharing) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_trackThirdPartySharing', adjustThirdPartySharing, null);
                }
            },
            trackMeasurementConsent: function(consentMeasurement) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_trackMeasurementConsent', consentMeasurement, null);
                }
            },
            checkForNewAttStatus: function() {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_checkForNewAttStatus', null, null);
                }
            },
            getLastDeeplink: function(callback) {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_lastDeeplink', null, callback);
                }
            },
            fbPixelEvent: function(pixelID, evtName, customData) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_fbPixelEvent',
                                                        {
                                                            pixelID: pixelID,
                                                            evtName:evtName,
                                                            customData: customData
                                                        },
                                                        null);
                }
            },
            getSdkVersion: function(callback) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_sdkVersion', this.getSdkPrefix(), callback);
                }
            },
            getSdkPrefix: function() {
                if (this.sdkPrefix) {
                    return this.sdkPrefix;
                } else {
                    return 'web-bridge5.0.0';
                }
            },
            setTestOptions: function(testOptions) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_setTestOptions', testOptions, null);
                }
            }
        };

        // Copied from adjust_event.js
        window.AdjustEvent = function(eventToken) {
            this.eventToken = eventToken;
            this.revenue = null;
            this.currency = null;
            this.transactionId = null;
            this.deduplicationId = null;
            this.callbackId = null;
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
        AdjustEvent.prototype.setDeduplicationId = function(deduplicationId) {
            this.deduplicationId = deduplicationId;
        };
        AdjustEvent.prototype.setCallbackId = function(callbackId) {
            this.callbackId = callbackId;
        };

        // Adjust Third Party Sharing
        window.AdjustThirdPartySharing = function(isEnabled) {
            this.isEnabled = isEnabled;
            this.granularOptions = [];
            this.partnerSharingSettings = [];
        };
        AdjustThirdPartySharing.prototype.addGranularOption = function(partnerName, key, value) {
            this.granularOptions.push(partnerName);
            this.granularOptions.push(key);
            this.granularOptions.push(value);
        };
        AdjustThirdPartySharing.prototype.addPartnerSharingSetting = function(partnerName, key, value) {
            this.partnerSharingSettings.push(partnerName);
            this.partnerSharingSettings.push(key);
            this.partnerSharingSettings.push(value);
        };

        // Copied from adjust_config.js
        window.AdjustConfig = function(appToken, environment, legacy) {
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

            this.sdkPrefix = null;
            this.defaultTracker = null;
            this.externalDeviceId = null;
            this.logLevel = null;
            this.coppaCompliantEnabled = null;
            this.sendInBackground = null;
            this.delayStart = null;
            this.needsCost = null;
            this.allowAdServicesInfoReading = null;
            this.isIdfaReadingAllowed = null;
            this.allowSkAdNetworkHandling = null;
            this.openDeferredDeeplink = null;
            this.fbPixelDefaultEventToken = null;
            this.fbPixelMapping = [];
            this.attributionCallback = null;
            this.eventSuccessCallback = null;
            this.eventFailureCallback = null;
            this.sessionSuccessCallback = null;
            this.sessionFailureCallback = null;
            this.deferredDeeplinkCallback = null;
            this.urlStrategy = null;
            this.readDeviceInfoOnceEnabled = null;
            this.attConsentWaitingSeconds = null;
            this.eventDeduplicationIdsMaxSize = null;
        };

        AdjustConfig.EnvironmentSandbox = 'sandbox';
        AdjustConfig.EnvironmentProduction = 'production';

        AdjustConfig.LogLevelVerbose = 'VERBOSE';
        AdjustConfig.LogLevelDebug = 'DEBUG';
        AdjustConfig.LogLevelInfo = 'INFO';
        AdjustConfig.LogLevelWarn = 'WARN';
        AdjustConfig.LogLevelError = 'ERROR';
        AdjustConfig.LogLevelAssert = 'ASSERT';
        AdjustConfig.LogLevelSuppress = 'SUPPRESS';

        AdjustConfig.UrlStrategyIndia = 'UrlStrategyIndia';
        AdjustConfig.UrlStrategyChina = 'UrlStrategyChina';
        AdjustConfig.UrlStrategyCn = 'UrlStrategyCn';
        AdjustConfig.UrlStrategyCnOnly = 'UrlStrategyCnOnly';
        AdjustConfig.DataResidencyEU = 'DataResidencyEU';
        AdjustConfig.DataResidencyTR = 'DataResidencyTR';
        AdjustConfig.DataResidencyUS = 'DataResidencyUS';

        AdjustConfig.prototype.registerCallbackHandlers = function() {
            var registerCallbackHandler = function(callbackName) {
                var callback = this[callbackName];
                if (!callback) {
                    return;
                }
                var regiteredCallbackName = 'adjustJS_' + callbackName;
                WebViewJavascriptBridge.registerHandler(regiteredCallbackName, callback);
                this[callbackName] = regiteredCallbackName;
            };
            registerCallbackHandler.call(this, 'attributionCallback');
            registerCallbackHandler.call(this, 'eventSuccessCallback');
            registerCallbackHandler.call(this, 'eventFailureCallback');
            registerCallbackHandler.call(this, 'sessionSuccessCallback');
            registerCallbackHandler.call(this, 'sessionFailureCallback');
            registerCallbackHandler.call(this, 'deferredDeeplinkCallback');
        };
        AdjustConfig.prototype.getSdkPrefix = function() {
            return this.sdkPrefix;
        };
        AdjustConfig.prototype.setSdkPrefix = function(sdkPrefix) {
            this.sdkPrefix = sdkPrefix;
        };
        AdjustConfig.prototype.setDefaultTracker = function(defaultTracker) {
            this.defaultTracker = defaultTracker;
        };
        AdjustConfig.prototype.setExternalDeviceId = function(externalDeviceId) {
            this.externalDeviceId = externalDeviceId;
        };
        AdjustConfig.prototype.setLogLevel = function(logLevel) {
            this.logLevel = logLevel;
        };
        AdjustConfig.prototype.setCoppaCompliantEnabled = function(isEnabled) {
            this.coppaCompliantEnabled = isEnabled;
        };
        AdjustConfig.prototype.setSendInBackground = function(isEnabled) {
            this.sendInBackground = isEnabled;
        };
        AdjustConfig.prototype.setDelayStart = function(delayStartInSeconds) {
            this.delayStart = delayStartInSeconds;
        };
        AdjustConfig.prototype.setNeedsCost = function(needsCost) {
            this.needsCost = needsCost;
        };
        AdjustConfig.prototype.setAllowAdServicesInfoReading = function(allowAdServicesInfoReading) {
            this.allowAdServicesInfoReading = allowAdServicesInfoReading;
        };
        AdjustConfig.prototype.disableIdfaReading = function() {
            this.isIdfaReadingAllowed = false;
        };
        AdjustConfig.prototype.deactivateSkAdNetworkHandling = function() {
            this.allowSkAdNetworkHandling = false;
        };
        AdjustConfig.prototype.setOpenDeferredDeeplink = function(shouldOpen) {
            this.openDeferredDeeplink = shouldOpen;
        };
        AdjustConfig.prototype.setAttributionCallback = function(callback) {
            this.attributionCallback = callback;
        };
        AdjustConfig.prototype.setEventSuccessCallback = function(callback) {
            this.eventSuccessCallback = callback;
        };
        AdjustConfig.prototype.setEventFailureCallback = function(callback) {
            this.eventFailureCallback = callback;
        };
        AdjustConfig.prototype.setSessionSuccessCallback = function(callback) {
            this.sessionSuccessCallback = callback;
        };
        AdjustConfig.prototype.setSessionFailureCallback = function(callback) {
            this.sessionFailureCallback = callback;
        };
        AdjustConfig.prototype.setDeferredDeeplinkCallback = function(callback) {
            this.deferredDeeplinkCallback = callback;
        };
        AdjustConfig.prototype.setFbPixelDefaultEventToken = function(fbPixelDefaultEventToken) {
            this.fbPixelDefaultEventToken = fbPixelDefaultEventToken;
        };
        AdjustConfig.prototype.addFbPixelMapping = function(fbEventNameKey, adjEventTokenValue) {
            this.fbPixelMapping.push(fbEventNameKey);
            this.fbPixelMapping.push(adjEventTokenValue);
        };
        AdjustConfig.prototype.setUrlStrategy = function(urlStrategy) {
            this.urlStrategy = urlStrategy;
        };
        AdjustConfig.prototype.setReadDeviceInfoOnceEnabled = function(readDeviceInfoOnceEnabled) {
            this.readDeviceInfoOnceEnabled = readDeviceInfoOnceEnabled;
        };
        AdjustConfig.prototype.setAttConsentWaitingInterval = function(attConsentWaitingSeconds) {
            this.attConsentWaitingSeconds = attConsentWaitingSeconds;
        };
        AdjustConfig.prototype.setEventDeduplicationIdsMaxSize = function(eventDeduplicationIdsMaxSize) {
            this.eventDeduplicationIdsMaxSize = eventDeduplicationIdsMaxSize;
        };
    })();); // END preprocessorJSCode
    //, augmentedSection];
#undef __adj_js_func__
    return preprocessorJSCode;
}

@end

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

        // Adjust
        window.Adjust = {
            initSdk: function(adjustConfig) {
                if (WebViewJavascriptBridge) {
                    if (adjustConfig) {
                        if (!adjustConfig.getSdkPrefix()) {
                            adjustConfig.setSdkPrefix(this.getSdkPrefix());
                        }
                        this.sdkPrefix = adjustConfig.getSdkPrefix();
                        adjustConfig.registerCallbackHandlers();
                        WebViewJavascriptBridge.callHandler('adjust_initSdk', adjustConfig, null);
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
            enable: function() {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_enable', null, null);
                }
            },
            disable: function() {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_disable', null, null);
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
            switchToOfflineMode: function() {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_switchToOfflineMode', null, null);
                }
            },
            switchBackToOnlineMode: function() {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_switchBackToOnlineMode', null, null);
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
            updateSkanConversionValueWithCoarseValueLockWindowAndCallback: function(conversionValue, coarseValue, lockWindow, callback) {
                if (WebViewJavascriptBridge != null) {
                    WebViewJavascriptBridge.callHandler('adjust_updateSkanConversionValueCoarseValueLockWindowCompletionHandler',
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
            enableCoppaCompliance: function() {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_enableCoppaCompliance', null, null);
                }
            },
            disableCoppaCompliance: function() {
                if (WebViewJavascriptBridge) {
                    WebViewJavascriptBridge.callHandler('adjust_disableCoppaCompliance', null, null);
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

        // AdjustEvent
        window.AdjustEvent = function(eventToken) {
            this.eventToken = eventToken;
            this.revenue = null;
            this.currency = null;
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
        AdjustEvent.prototype.setDeduplicationId = function(deduplicationId) {
            this.deduplicationId = deduplicationId;
        };
        AdjustEvent.prototype.setCallbackId = function(callbackId) {
            this.callbackId = callbackId;
        };

        // AdjustThirdPartySharing
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

        // AdjustConfig
        window.AdjustConfig = function(appToken, environment, legacy) {
            if (arguments.length === 2) {
                // new format does not require bridge as first parameter
                this.appToken = appToken;
                this.environment = environment;
            } else if (arguments.length === 3) {
                // new format with allowSuppressLogLevel
                if (typeof(legacy) == typeof(true)) {
                    this.appToken = appToken;
                    this.environment = environment;
                    this.allowSuppressLogLevel = legacy;
                } else {
                    // old format with first argument being the bridge instance
                    this.bridge = appToken;
                    this.appToken = environment;
                    this.environment = legacy;
                }
            }

            this.sdkPrefix = null;
            this.defaultTracker = null;
            this.externalDeviceId = null;
            this.logLevel = null;
            this.sendInBackground = null;
            this.isCostDataInAttributionEnabled = null;
            this.urlStrategyDomains = [];
            this.useSubdomains = null;
            this.isDataResidency = null;
            this.isAdServicesEnabled = null;
            this.isIdfaReadingAllowed = null;
            this.isSkanAttributionHandlingEnabled = null;
            this.openDeferredDeeplink = null;
            this.fbPixelDefaultEventToken = null;
            this.fbPixelMapping = [];
            this.attributionCallback = null;
            this.eventSuccessCallback = null;
            this.eventFailureCallback = null;
            this.sessionSuccessCallback = null;
            this.sessionFailureCallback = null;
            this.deferredDeeplinkCallback = null;
            this.shouldReadDeviceInfoOnce = null;
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
        AdjustConfig.prototype.setSendInBackground = function(isEnabled) {
            this.sendInBackground = isEnabled;
        };
        AdjustConfig.prototype.enableCostDataInAttribution = function() {
            this.isCostDataInAttributionEnabled = false;
        };
        AdjustConfig.prototype.disableAdServices = function() {
            this.isAdServicesEnabled = false;
        };
        AdjustConfig.prototype.disableIdfaReading = function() {
            this.isIdfaReadingAllowed = false;
        };
        AdjustConfig.prototype.disableSkanAttributionHandling = function() {
            this.isSkanAttributionHandlingEnabled = false;
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
        AdjustConfig.prototype.readDeviceInfoOnce = function() {
            this.shouldReadDeviceInfoOnce = true;
        };
        AdjustConfig.prototype.setAttConsentWaitingInterval = function(attConsentWaitingSeconds) {
            this.attConsentWaitingSeconds = attConsentWaitingSeconds;
        };
        AdjustConfig.prototype.setEventDeduplicationIdsMaxSize = function(eventDeduplicationIdsMaxSize) {
            this.eventDeduplicationIdsMaxSize = eventDeduplicationIdsMaxSize;
        };
        AdjustConfig.prototype.setUrlStrategy = function(urlStrategyDomains, useSubdomains, isDataResidency) {
            this.urlStrategyDomains = urlStrategyDomains;
            this.useSubdomains = useSubdomains;
            this.isDataResidency = isDataResidency;
        };
    })();); // END preprocessorJSCode
    //, augmentedSection];
#undef __adj_js_func__
    return preprocessorJSCode;
}

@end

//
//  AdjustBridgeRegister.m
//  Adjust
//
//  Created by Pedro Filipe (@nonelse) on 27th April 2016.
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import "AdjustBridgeRegister.h"

static NSString * fbAppIdStatic = nil;

@implementation AdjustBridgeRegister

+ (NSString *)AdjustBridge_js {
    if (fbAppIdStatic != nil) {
        return [NSString stringWithFormat:@"%@%@",
                [AdjustBridgeRegister adjust_js],
                [AdjustBridgeRegister augmented_js]];
    } else {
        return [AdjustBridgeRegister adjust_js];
    }
}

+ (void)augmentHybridWebView:(NSString *)fbAppId {
    fbAppIdStatic = fbAppId;
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
            _postMessage(methodName, parameters = {}, callbackId = "") {
                if (!this._adjustMessageHandler) {
                    function canSend(okCheck, errReason) {
                        if (!okCheck) {
                            if (errSubscriber) {
                                errSubscriber("Cannot send message to native sdk ".concat(errReason));
                            }
                        }
                        return okCheck;
                    }
                    const canSendSendToNative =
                    canSend(window, "without valid: 'window'") &&
                    canSend(window.webkit, "without valid: 'window.webkit'") &&
                    canSend(window.webkit.messageHandlers,
                            "without valid: 'window.webkit.messageHandlers'") &&
                    canSend(window.webkit.messageHandlers.adjust,
                            "without valid: 'window.webkit.messageHandlers.adjust'") &&
                    canSend(window.webkit.messageHandlers.adjust.postMessage,
                            "without valid: 'window.webkit.messageHandlers.adjust.postMessage'") &&
                    canSend(typeof window.webkit.messageHandlers.adjust.postMessage === "function",
                            "when 'window.webkit.messageHandlers.adjust.postMessage' is not a function");

                    if (!canSendSendToNative) { return; }

                    this._adjustMessageHandler = window.webkit.messageHandlers.adjust;
                }

                this._adjustMessageHandler.postMessage({
                _methodName: methodName,
                _parameters: parameters,
                _callbackId: callbackId
                });
            },

            _handleGetterFromObjC: function(callback, callbackId) {
                window[callbackId] = function(value) {
                    if(callbackId.includes("adjust_getAttribution")) {
                        const parsedValue = JSON.parse(value);
                        callback(parsedValue);
                    } else {
                        callback(value);
                    }
                    delete window[callbackId];
                };
            },

            _handleCallbackFromObjC: function(callback, callbackId) {
                window[callbackId] = function(value) {
                    if(callbackId.includes("adjust_deferredDeeplinkCallback")) {
                        callback(value);
                    } else {
                        const parsedValue = JSON.parse(value);
                        callback(parsedValue);
                    }
                };
            },

            initSdk: function(adjustConfig) {
                if (adjustConfig) {
                    if (!adjustConfig.getSdkPrefix()) {
                        adjustConfig.setSdkPrefix(this.getSdkPrefix());
                    }
                    adjustConfig.setSdkPrefix(this.getSdkPrefix());
                    this._postMessage("adjust_initSdk", adjustConfig);
                }
            },

            setTestOptions: function(testOptions) {
                this._postMessage("adjust_setTestOptions", testOptions);
            },

            requestAppTrackingAuthorizationWithCompletionHandler: function(attStatusCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_attStatusCallback");
                this._handleGetterFromObjC(attStatusCallback, callbackId);
                this._postMessage("adjust_requestAppTrackingAuthorizationWithCompletionHandler", null, callbackId);
            },

            getAppTrackingAuthorizationStatus: function(getAppTrackingAuthorizationStatusCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_appTrackingAuthorizationStatus") ;
                this._handleGetterFromObjC(getAppTrackingAuthorizationStatusCallback, callbackId);
                this._postMessage("adjust_appTrackingAuthorizationStatus", null, callbackId);
            },

            getSdkVersion: function(getSdkVersionCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_getSdkVersion") ;
                this._handleGetterFromObjC(getSdkVersionCallback, callbackId);
                this._postMessage("adjust_getSdkVersion", {sdkPrefix: this.getSdkPrefix()}, callbackId);
            },

            getIdfa: function(getIdfaCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_getIdfa") ;
                this._handleGetterFromObjC(getIdfaCallback, callbackId);
                this._postMessage("adjust_getIdfa", null, callbackId);
            },

            getIdfv: function(getIdfvCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_getIdfv") ;
                this._handleGetterFromObjC(getIdfvCallback, callbackId);
                this._postMessage("adjust_getIdfv", null, callbackId);
            },

            getAdid: function(getAdidCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_getAdid") ;
                this._handleGetterFromObjC(getAdidCallback, callbackId);
                this._postMessage("adjust_getAdid", null, callbackId);
            },

            isEnabled: function(isEnabledCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_isEnabled") ;
                this._handleGetterFromObjC(isEnabledCallback, callbackId);
                this._postMessage("adjust_isEnabled", null, callbackId);
            },

            getAttribution: function(getAttributionCallback) {
                const callbackId = window.randomCallbackIdWithPrefix("adjust_getAttribution") ;
                this._handleGetterFromObjC(getAttributionCallback, callbackId);
                this._postMessage("adjust_getAttribution", null, callbackId);
            },

            getSdkPrefix: function() {
                if (this.sdkPrefix) {
                    return this.sdkPrefix;
                } else {
                    return 'web-bridge5.4.2';
                }
            },

            trackEvent: function(adjustEvent) {
                this._postMessage("adjust_trackEvent", adjustEvent);
            },

            trackThirdPartySharing: function(adjustThirdPartySharing) {
                this._postMessage("adjust_trackThirdPartySharing", adjustThirdPartySharing);
            },

            gdprForgetMe: function() {
                this._postMessage("adjust_gdprForgetMe");
            },

            enable: function() {
                this._postMessage("adjust_enable");
            },

            disable: function() {
                this._postMessage("adjust_disable");
            },

            switchToOfflineMode: function() {
                this._postMessage("adjust_switchToOfflineMode");
            },

            switchBackToOnlineMode: function() {
                this._postMessage("adjust_switchBackToOnlineMode");
            },

            trackSubsessionStart: function() {
                this._postMessage("adjust_trackSubsessionStart");
            },

            trackSubsessionEnd: function() {
                this._postMessage("adjust_trackSubsessionEnd");
            },

            trackMeasurementConsent: function(consentMeasurement) {
                this._postMessage("adjust_trackMeasurementConsent", consentMeasurement);
            },

            fbPixelEvent: function(pixelID, evtName, customData) {
                this._postMessage("adjust_fbPixelEvent", {
                    pixelID: pixelID,
                    evtName: evtName,
                    customData: customData
                });
            },

            addGlobalCallbackParameter: function(key, value) {
                if (typeof key !== 'string' || typeof value !== 'string') {
                    console.log('Passed key or value is not of string type');
                    return;
                }
                this._postMessage("adjust_addGlobalCallbackParameter", {
                    _key: key, _keyType: typeof key,
                    _value: value, _valueType: typeof value
                });
            },

            removeGlobalCallbackParameter: function(key) {
                if (typeof key !== 'string') {
                    console.log('Passed key is not of string type');
                    return;
                }
                this._postMessage("adjust_removeGlobalCallbackParameter", { _key: key, _keyType: typeof key });
            },

            removeGlobalCallbackParameters: function() {
                this._postMessage("adjust_removeGlobalCallbackParameters");
            },

            addGlobalPartnerParameter: function(key, value) {
                if (typeof key !== 'string' || typeof value !== 'string') {
                    console.log('Passed key or value is not of string type');
                    return;
                }
                this._postMessage("adjust_addGlobalPartnerParameter", {
                    _key: key, _keyType: typeof key,
                    _value: value, _valueType: typeof value
                });
            },

            removeGlobalPartnerParameter: function(key) {
                if (typeof key !== 'string') {
                    console.log('Passed key is not of string type');
                    return;
                }
                this._postMessage("adjust_removeGlobalPartnerParameter", { _key: key, _keyType: typeof key });
            },

            removeGlobalPartnerParameters: function() {
                this._postMessage("adjust_removeGlobalPartnerParameters");
            },

            endFirstSessionDelay: function() {
                this._postMessage("adjust_endFirstSessionDelay");
            },

            enableCoppaComplianceInDelay: function() {
                this._postMessage("adjust_enableCoppaComplianceInDelay");
            },

            disableCoppaComplianceInDelay: function() {
                this._postMessage("adjust_disableCoppaComplianceInDelay");
            },

            setExternalDeviceIdInDelay: function(externalDeviceId) {
                this._postMessage("adjust_setExternalDeviceIdInDelay", { "externalDeviceId" : externalDeviceId });
            },
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

        AdjustEvent.prototype.setRevenue = function(revenue, currency) {
            if (revenue != null) {
                this.revenue = revenue.toString();
                this.currency = currency;
            }
        };

        AdjustEvent.prototype.addCallbackParameter = function(key, value) {
            if (typeof key !== 'string' || typeof value !== 'string') {
                console.log('Passed key or value is not of string type');
                return;
            }
            this.callbackParameters.push(key);
            this.callbackParameters.push(value);
        };

        AdjustEvent.prototype.addPartnerParameter = function(key, value) {
            if (typeof key !== 'string' || typeof value !== 'string') {
                console.log('Passed key or value is not of string type');
                return;
            }
            this.partnerParameters.push(key);
            this.partnerParameters.push(value);
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
            if (typeof partnerName !== 'string' || typeof key !== 'string' || typeof value !== 'string') {
                console.log('Passed partnerName, key or value is not of string type');
                return;
            }
            this.granularOptions.push(partnerName);
            this.granularOptions.push(key);
            this.granularOptions.push(value);
        };

        AdjustThirdPartySharing.prototype.addPartnerSharingSetting = function(partnerName, key, value) {
            if (typeof partnerName !== 'string' || typeof key !== 'string' || typeof value !== 'boolean') {
                console.log('Passed partnerName or key is not of string type or value is not of boolean type');
                return;
            }
            this.partnerSharingSettings.push(partnerName);
            this.partnerSharingSettings.push(key);
            this.partnerSharingSettings.push(value);
        };

        // AdjustConfig
        window.AdjustConfig = function(appToken, environment) {
            //config parameters
            this.appToken = appToken;
            this.environment = environment;
            this.logLevel = null;
            this.sdkPrefix = null;
            this.defaultTracker = null;
            this.externalDeviceId = null;
            this.sendInBackground = null;
            this.isAdServicesEnabled = null;
            this.isIdfaReadingAllowed = null;
            this.isCostDataInAttributionEnabled = null;
            this.isDeferredDeeplinkOpeningEnabled = null;
            this.isSkanAttributionHandlingEnabled = null;
            this.isCoppaComplianceEnabled = null;
            this.shouldReadDeviceInfoOnce = null;
            this.attConsentWaitingSeconds = null;
            this.eventDeduplicationIdsMaxSize = null;
            this.isAppTrackingTransparencyUsageEnabled = null;
            this.isFirstSessionDelayEnabled = null;

            //config URL strategy parameters
            this.urlStrategyDomains = [];
            this.useSubdomains = null;
            this.isDataResidency = null;

            //config callbacks
            this.attributionCallback = null;
            this.eventSuccessCallback = null;
            this.eventFailureCallback = null;
            this.sessionSuccessCallback = null;
            this.sessionFailureCallback = null;
            this.skanUpdatedCallback = null;
            this.deferredDeeplinkCallback = null;

            //fb parameters
            this.fbPixelDefaultEventToken = null;
            this.fbPixelMapping = [];

            //store parameters
            this.storeInfo = null;
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
            this.isCostDataInAttributionEnabled = true;
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
        AdjustConfig.prototype.disableDeferredDeeplinkOpening = function() {
            this.isDeferredDeeplinkOpeningEnabled = false;
        };
        AdjustConfig.prototype.enableCoppaCompliance = function() {
            this.isCoppaComplianceEnabled = true;
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
        AdjustConfig.prototype.disableAppTrackingTransparencyUsage = function() {
            this.isAppTrackingTransparencyUsageEnabled = false;
        };
        AdjustConfig.prototype.enableFirstSessionDelay = function() {
            this.isFirstSessionDelayEnabled = true;
        };

        //URL strategy
        AdjustConfig.prototype.setUrlStrategy = function(urlStrategyDomains, useSubdomains, isDataResidency) {
            this.urlStrategyDomains = urlStrategyDomains;
            this.useSubdomains = useSubdomains;
            this.isDataResidency = isDataResidency;
        };

        //FB Pixel event config
        AdjustConfig.prototype.setFbPixelDefaultEventToken = function(fbPixelDefaultEventToken) {
            this.fbPixelDefaultEventToken = fbPixelDefaultEventToken;
        };
        AdjustConfig.prototype.addFbPixelMapping = function(fbEventNameKey, adjEventTokenValue) {
            this.fbPixelMapping.push(fbEventNameKey);
            this.fbPixelMapping.push(adjEventTokenValue);
        };

        //Store info
        AdjustConfig.prototype.setStoreInfo = function(storeInfo) {
            this.storeInfo = storeInfo;
        };

        //AdjustConfig's callback
        AdjustConfig.prototype.setAttributionCallback = function(attributionCallback) {
            const callbackId = window.randomCallbackIdWithPrefix("adjust_attributionCallback");
            Adjust._handleCallbackFromObjC(attributionCallback, callbackId);
            this.attributionCallback = callbackId;
        };

        AdjustConfig.prototype.setEventSuccessCallback = function(eventSuccessCallback) {
            const callbackId = window.randomCallbackIdWithPrefix("adjust_eventSuccessCallback");
            Adjust._handleCallbackFromObjC(eventSuccessCallback, callbackId);
            this.eventSuccessCallback = callbackId;
        };

        AdjustConfig.prototype.setEventFailureCallback = function(eventFailureCallback) {
            const callbackId = window.randomCallbackIdWithPrefix("adjust_eventFailureCallback");
            Adjust._handleCallbackFromObjC(eventFailureCallback, callbackId);
            this.eventFailureCallback = callbackId;
        };

        AdjustConfig.prototype.setSessionSuccessCallback = function(sessionSuccessCallback) {
            const callbackId = window.randomCallbackIdWithPrefix("adjust_sessionSuccessCallback");
            Adjust._handleCallbackFromObjC(sessionSuccessCallback, callbackId);
            this.sessionSuccessCallback = callbackId;
        };

        AdjustConfig.prototype.setSessionFailureCallback = function(sessionFailureCallback) {
            const callbackId = window.randomCallbackIdWithPrefix("adjust_sessionFailureCallback");
            Adjust._handleCallbackFromObjC(sessionFailureCallback, callbackId);
            this.sessionFailureCallback = callbackId;
        };

        AdjustConfig.prototype.setDeferredDeeplinkCallback = function(deferredDeeplinkCallback) {
            const callbackId = window.randomCallbackIdWithPrefix("adjust_deferredDeeplinkCallback");
            Adjust._handleCallbackFromObjC(deferredDeeplinkCallback, callbackId);
            this.deferredDeeplinkCallback = callbackId;
        };

        AdjustConfig.prototype.setSkanUpdatedCallback = function(skanUpdatedCallback) {
            const callbackId = window.randomCallbackIdWithPrefix("adjust_skanUpdatedCallback");
            Adjust._handleCallbackFromObjC(skanUpdatedCallback, callbackId);
            this.skanUpdatedCallback = callbackId;
        };

        // AdjustStoreInfo
        window.AdjustStoreInfo = function(storeName) {
            this.storeName = storeName;
            this.storeAppId = null;
        };

        AdjustStoreInfo.prototype.setStoreAppId = function(storeAppId) {
            this.storeAppId = storeAppId;
        };

        // Generate random callback id
        window.randomCallbackIdWithPrefix = function(prefix) {
            const randomString = (Math.random() + 1).toString(36).substring(7);
            return prefix + "_" + randomString;
        };

    })();); // END preprocessorJSCode
    //, augmentedSection];
#undef __adj_js_func__
    return preprocessorJSCode;
}

@end

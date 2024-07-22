var Adjust = {

    _postMessage(methodName, parameters = {}) {
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
            _parameters: parameters
        });
    },

    initSdk: function (adjustConfig) {
        this._postMessage("adjust_initSdk", adjustConfig);
    },

    setTestOptions: function (testOptions) {
        this._postMessage("adjust_setTestOptions", testOptions);
    },

    getSdkVersion: function () {
        this._postMessage("adjust_getSdkVersion");
    },

    trackEvent: function (adjustEvent) {
        this._postMessage("adjust_trackEvent", adjustEvent);
    },

    processDeeplink: function (url) {
        this._postMessage("adjust_processDeeplink", url);
    },

    trackSubsessionStart: function () {
        this._postMessage("adjust_trackSubsessionStart");
    },

    trackSubsessionEnd: function () {
        this._postMessage("adjust_trackSubsessionEnd");
    },

    trackThirdPartySharing: function (adjustThirdPartySharing) {
        this._postMessage("adjust_trackThirdPartySharing", adjustThirdPartySharing);
    },

    enable: function () {
        this._postMessage("adjust_enable");
    },

    disable: function () {
        this._postMessage("adjust_disable");
    },

    switchToOfflineMode: function () {
        this._postMessage("adjust_switchToOfflineMode");
    },

    switchBackToOnlineMode: function () {
        this._postMessage("adjust_switchBackToOnlineMode");
    },

    addGlobalCallbackParameter: function (key, value) {
        this._postMessage("adjust_addGlobalCallbackParameter", {
            _key: key, _keyType: typeof key,
            _value: value, _valueType: typeof value
        });
    },

    removeGlobalCallbackParameter: function (key) {
        this._postMessage("adjust_removeGlobalCallbackParameter", { _key: key, _keyType: typeof key });
    },

    removeGlobalCallbackParameters: function () {
        this._postMessage("adjust_removeGlobalCallbackParameters");
    },

    addGlobalPartnerParameter: function (key, value) {
        this._postMessage("adjust_addGlobalPartnerParameter", {
            _key: key, _keyType: typeof key,
            _value: value, _valueType: typeof value
        });
    },

    removeGlobalPartnerParameter: function (key) {
        this._postMessage("adjust_removeGlobalPartnerParameter", { _key: key, _keyType: typeof key });
    },

    removeGlobalPartnerParameters: function () {
        this._postMessage("adjust_removeGlobalCallbackParameters");
    },

    gdprForgetMe: function () {
        this._postMessage("adjust_gdprForgetMe");
    },

};

function AdjustConfig(appToken, environment) {
    this.appToken = appToken;
    this.environment = environment;
    this.logLevel = null;
    this.shouldLaunchDeeplink = null;
    this.sendInBackground = null;
    this.isCostDataInAttributionEnabled = null;
    this.defaultTracker = null;
    this.externalDeviceId = null;
    this.shouldReadDeviceInfoOnce = null;
    this.isAdServicesEnabled = null;
    this.isIdfaReadingAllowed = null;
    this.isSkanAttributionHandlingEnabled = null;
    this.isLinkMeEnabled = null;
    this.attConsentWaitingSeconds = null;
}

AdjustConfig.EnvironmentSandbox = 'sandbox';
AdjustConfig.EnvironmentProduction = 'production';

AdjustConfig.LogLevelVerbose = 'VERBOSE';
AdjustConfig.LogLevelDebug = 'DEBUG';
AdjustConfig.LogLevelInfo = 'INFO';
AdjustConfig.LogLevelWarn = 'WARN';
AdjustConfig.LogLevelError = 'ERROR';
AdjustConfig.LogLevelAssert = 'ASSERT';
AdjustConfig.LogLevelSuppress = 'SUPPRESS';

AdjustConfig.prototype.setLogLevel = function (logLevel) {
    this.logLevel = logLevel;
};

AdjustConfig.prototype.setShouldLaunchDeeplink = function (shouldLaunchDeeplink) {
    this.shouldLaunchDeeplink = shouldLaunchDeeplink;
};

AdjustConfig.prototype.setSendInBackground = function (sendInBackground) {
    this.sendInBackground = sendInBackground;
};

AdjustConfig.prototype.setCostDataInAttributionEnabled = function (isCostDataInAttributionEnabled) {
    this.isCostDataInAttributionEnabled = isCostDataInAttributionEnabled;
};

AdjustConfig.prototype.setDefaultTracker = function (defaultTracker) {
    this.defaultTracker = defaultTracker;
};

AdjustConfig.prototype.setExternalDeviceId = function (externalDeviceId) {
    this.externalDeviceId = externalDeviceId;
};

AdjustConfig.prototype.setShouldReadDeviceInfoOnce = function (shouldReadDeviceInfoOnce) {
    this.shouldReadDeviceInfoOnce = shouldReadDeviceInfoOnce;
};

AdjustConfig.prototype.setAdServicesEnabled = function (isAdServicesEnabled) {
    this.isAdServicesEnabled = isAdServicesEnabled;
};

AdjustConfig.prototype.setIdfaReadingAllowed = function (isIdfaReadingAllowed) {
    this.isIdfaReadingAllowed = isIdfaReadingAllowed;
};

AdjustConfig.prototype.setSkanAttributionHandlingEnabled = function (isSkanAttributionHandlingEnabled) {
    this.isSkanAttributionHandlingEnabled = isSkanAttributionHandlingEnabled;
};

AdjustConfig.prototype.setLinkMeEnabled = function (isLinkMeEnabled) {
    this.isLinkMeEnabled = isLinkMeEnabled;
};

AdjustConfig.prototype.setAttConsentWaitingSeconds = function (attConsentWaitingSeconds) {
    this.attConsentWaitingSeconds = attConsentWaitingSeconds;
};

function AdjustEvent(eventToken) {
    this.eventToken = eventToken;
    this.revenue = null;
    this.currency = null;
    this.deduplicationId = null;
    this.receipt = null;
    this.productId = null;
    this.transactionId = null;
    this.callbackId = null;
    this.callbackParameters = [];
    this.partnerParameters = [];
}

AdjustEvent.prototype.setRevenue = function (revenue, currency) {
    if (revenue != null) {
        this.revenue = revenue.toString();
        this.currency = currency;
    }
};

AdjustEvent.prototype.addCallbackParameter = function (key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    this.callbackParameters.push(key);
    this.callbackParameters.push(value);
};

AdjustEvent.prototype.addPartnerParameter = function (key, value) {
    if (typeof key !== 'string' || typeof value !== 'string') {
        console.log('Passed key or value is not of string type');
        return;
    }
    this.partnerParameters.push(key);
    this.partnerParameters.push(value);
};

AdjustEvent.prototype.setReceipt = function (receipt) {
    this.receipt = receipt;
};

AdjustEvent.prototype.setProductId = function (productId) {
    this.productId = productId;
};

AdjustEvent.prototype.setTransactionId = function (transactionId) {
    this.transactionId = transactionId;
};

AdjustEvent.prototype.setDeduplicationId = function (deduplicationId) {
    this.deduplicationId = deduplicationId;
};

AdjustEvent.prototype.setCallbackId = function (callbackId) {
    this.callbackId = callbackId;
};

function AdjustThirdPartySharing(isEnabled) {
    this.isEnabled = isEnabled;
    this.granularOptions = [];
    this.partnerSharingSettings = [];
}

AdjustThirdPartySharing.prototype.addGranularOption = function (partnerName, key, value) {
    this.granularOptions.push(partnerName);
    this.granularOptions.push(key);
    this.granularOptions.push(value);
};

AdjustThirdPartySharing.prototype.addPartnerSharingSetting = function (partnerName, key, value) {
    this.partnerSharingSettings.push(partnerName);
    this.partnerSharingSettings.push(key);
    this.partnerSharingSettings.push(value);
};

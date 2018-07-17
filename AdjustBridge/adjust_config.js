function AdjustConfig(appToken, environment, legacy) {

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
}

AdjustConfig.EnvironmentSandbox     = 'sandbox';
AdjustConfig.EnvironmentProduction  = 'production';

AdjustConfig.LogLevelVerbose        = 'VERBOSE',
AdjustConfig.LogLevelDebug          = 'DEBUG',
AdjustConfig.LogLevelInfo           = 'INFO',
AdjustConfig.LogLevelWarn           = 'WARN',
AdjustConfig.LogLevelError          = 'ERROR',
AdjustConfig.LogLevelAssert         = 'ASSERT',

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

module.exports = AdjustConfig;

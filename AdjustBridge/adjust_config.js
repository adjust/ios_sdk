function AdjustConfig(appToken, environment, legacy) {

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

    this.sdkPrefix = 'web-bridge4.9.1';

    this.logLevel = null;
    this.defaultTracker = null;

    this.sendInBackground = null;
    this.openDeferredDeeplink = null;
    this.eventBufferingEnabled = null;

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

AdjustConfig.prototype.setEventBufferingEnabled = function(isEnabled) {
    this.eventBufferingEnabled = isEnabled;
};
AdjustConfig.prototype.setSendInBackground = function(isEnabled) {
    this.sendInBackground = isEnabled;
};
AdjustConfig.prototype.setOpenDeferredDeeplink = function(shouldOpen) {
    this.openDeferredDeeplink = shouldOpen;
};
AdjustConfig.prototype.setLogLevel = function(logLevel) {
    this.logLevel = logLevel;
};
AdjustConfig.prototype.setProcessName = function(processName) {
    this.processName = processName;
};

AdjustConfig.prototype.setDefaultTracker = function(defaultTracker) {
    this.defaultTracker = defaultTracker;
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

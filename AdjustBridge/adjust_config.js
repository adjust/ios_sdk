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
    this.webBridgeLoggingEnabled = null;

    this.attributionCallback = null;
    this.eventSuccessCallback = null;
    this.eventFailureCallback = null;
    this.sessionSuccessCallback = null;
    this.sessionFailureCallback = null;
    this.deferredDeeplinkCallback = null;
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

AdjustConfig.prototype.getEventSuccessCallback = function() {
    return this.eventSuccessCallback;
};

AdjustConfig.prototype.getEventFailureCallback = function() {
    return this.eventFailureCallback;
};

AdjustConfig.prototype.getSessionSuccessCallback = function() {
    return this.sessionSuccessCallback;
};

AdjustConfig.prototype.getSessionFailureCallback = function() {
    return this.sessionFailureCallback;
};

AdjustConfig.prototype.getDeferredDeeplinkCallback = function() {
    return this.deferredDeeplinkCallback;
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

AdjustConfig.prototype.setWebBridgeLoggingEnabled = function(isEnabled) {
    this.webBridgeLoggingEnabled = isEnabled;
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

module.exports = AdjustConfig;

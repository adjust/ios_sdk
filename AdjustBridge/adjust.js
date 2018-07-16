var Adjust = {
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
    setPushToken: function (pushToken) {
        if (WebViewJavascriptBridge) {
            WebViewJavascriptBridge.callHandler('adjust_setPushToken', pushToken, null);
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
    },

    // metod replaced by setPushToken, that accepts a simple string
    setDeviceToken: function (deviceToken) {
        if (WebViewJavascriptBridge) {
            WebViewJavascriptBridge.callHandler('adjust_setDeviceToken', deviceToken, null);
        }
    }
};

module.exports = Adjust;

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

    // metod replaced by setPushToken, that accepts a simple string
    setDeviceToken: function (deviceToken) {
        if (WebViewJavascriptBridge) {
            WebViewJavascriptBridge.callHandler('adjust_setDeviceToken', deviceToken, null);
        }
    }
};

module.exports = Adjust;

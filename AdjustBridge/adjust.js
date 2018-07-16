var Adjust = {
    appDidLaunch: function (adjustConfig) {


        if (WebViewJavascriptBridge) {
            if (adjustConfig != null) {

                adjustConfig.iterateConfiguredCallbacks(
                    function(callbackName, callback) {
                        console.log("calling adjust_setCallback with " + callbackName);
                        WebViewJavascriptBridge.callHandler('adjust_setCallback', callbackName, callback);
                    }
                );
                WebViewJavascriptBridge.callHandler('adjust_appDidLaunch', adjustConfig, null)
            }
        }
    },
    trackEvent: function (adjustEvent) {
        if (WebViewJavascriptBridge != null) {
            WebViewJavascriptBridge.callHandler('adjust_trackEvent', adjustEvent, null)
    },
    setPushToken: function (pushToken) {
        if (WebViewJavascriptBridge) {
            WebViewJavascriptBridge.callHandler('adjust_setPushToken', pushToken, null);
        }
    },
    setOfflineMode: function(isOffline) {
        if (WebViewJavascriptBridge != null) {
            WebViewJavascriptBridge.callHandler('adjust_setOfflineMode', isOffline, null)
        }
    },

    setEnabled: function (enabled) {
        if (WebViewJavascriptBridge != null) {
            WebViewJavascriptBridge.callHandler('adjust_setEnabled', enabled, null)
        }
    },

    isEnabled: function (callback) {
        if (WebViewJavascriptBridge != null) {
            WebViewJavascriptBridge.callHandler('adjust_isEnabled', null, function(response) {
                callback(new Boolean(response))
            })
        }
    },

    getIdfa: function (callback) {
        if (WebViewJavascriptBridge != null) {
            WebViewJavascriptBridge.callHandler('adjust_idfa', null, function(response) {
                callback(response)
            })
        }
    },

    appWillOpenUrl: function (url) {
        if (WebViewJavascriptBridge != null) {
            WebViewJavascriptBridge.callHandler('adjust_appWillOpenUrl', url, null)
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

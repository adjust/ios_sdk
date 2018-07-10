var Adjust = {
    appDidLaunch: function (adjustConfig) {


        if (WebViewJavascriptBridge) {
            if (adjustConfig != null) {
                if (adjustConfig.getAttributionCallback() != null) {
                    WebViewJavascriptBridge.callHandler('adjust_setAttributionCallback', null, adjustConfig.getAttributionCallback())
                }

                if (adjustConfig.getEventSuccessCallback() != null) {
                    WebViewJavascriptBridge.callHandler('adjust_setEventSuccessCallback', null, adjustConfig.getEventSuccessCallback())
                }

                if (adjustConfig.getEventFailureCallback() != null) {
                    WebViewJavascriptBridge.callHandler('adjust_setEventFailureCallback', null, adjustConfig.getEventFailureCallback())
                }

                if (adjustConfig.getSessionSuccessCallback() != null) {
                    WebViewJavascriptBridge.callHandler('adjust_setSessionSuccessCallback', null, adjustConfig.getSessionSuccessCallback())
                }

                if (adjustConfig.getSessionFailureCallback() != null) {
                    WebViewJavascriptBridge.callHandler('adjust_setSessionFailureCallback', null, adjustConfig.getSessionFailureCallback())
                }

                if (adjustConfig.getDeferredDeeplinkCallback() != null) {
                    WebViewJavascriptBridge.callHandler('adjust_setDeferredDeeplinkCallback', null, adjustConfig.getDeferredDeeplinkCallback())
                }

                WebViewJavascriptBridge.callHandler('adjust_appDidLaunch', adjustConfig, null)
            }
        }
    },

    trackEvent: function (adjustEvent) {
        if (WebViewJavascriptBridge != null) {
            WebViewJavascriptBridge.callHandler('adjust_trackEvent', adjustEvent, null)
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
    }
};

module.exports = Adjust;

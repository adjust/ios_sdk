// simulator
//var urlOverwrite = 'http://127.0.0.1:8080';
//var controlUrl = 'ws://127.0.0.1:1987';
// device
var urlOverwrite = 'http://192.168.1.121:8080';
var controlUrl = 'ws://192.168.1.121:1987';

// local reference of the command executor
// originally it was this.adjustCommandExecutor of TestLibraryBridge var
// but for some reason, "this" on "startTestSession" was different in "adjustCommandExecutor"
var localAdjustCommandExecutor;

var TestLibraryBridge = {
    adjustCommandExecutor: function (commandRawJson) {
        console.log('TestLibraryBridge adjustCommandExecutor');
        const command = JSON.parse(commandRawJson);
        console.log('className: ' + command.className);
        console.log('functionName: ' + command.functionName);
        console.log('params: ' + JSON.stringify(command.params));

        if (command.className == 'TestOptions') {
            if (command.functionName != "teardown") {
                console.log('TestLibraryBridge TestOption only method should be teardown.');
                return;
            }
        }

        if (command.className == 'AdjustV4') {
            console.log('TestLibraryBridge AdjustV4 is not supported.');
            return;
        }
        // reflection based technique to call functions with the same name as the command function
        localAdjustCommandExecutor[command.functionName](command.params);
    },

    startTestSession: function () {
        console.log('TestLibraryBridge startTestSession');
        console.log('TestLibraryBridge startTestSession callHandler');
        localAdjustCommandExecutor = new AdjustCommandExecutor(urlOverwrite, controlUrl);
        Adjust.getSdkVersion(function(sdkVersion) {
            // pass the sdk version to native side
            const message = {
                action: 'adjustTLB_startTestSession',
                data: sdkVersion
            };
            window.webkit.messageHandlers.adjustTest.postMessage(message);
        });
    },
    addTestDirectory: function (directoryName) {
        const message = {
            action: 'adjustTLB_addTestDirectory',
            data: directoryName
        };
        window.webkit.messageHandlers.adjustTest.postMessage(message);
    },
    addTest: function (testName) {
        const message = {
            action: 'adjustTLB_addTest',
            data: testName
        };
        window.webkit.messageHandlers.adjustTest.postMessage(message);
    },
    teardownReturnExtraPath: function (extraPath) {
        this.extraPath = extraPath;
        // TODO - pending implementatio
        // Adjust.instance().teardown;
    },
};

var AdjustCommandExecutor = function (urlOverwrite, controlUrl) {
    this.urlOverwrite = urlOverwrite;
    this.controlUrl = controlUrl;
    this.extraPath = null;
    this.savedEvents = {};
    this.savedConfigs = {};
    this.savedCommands = [];
    this.nextToSendCounter = 0;
};

AdjustCommandExecutor.prototype.teardown = function (params) {
    console.log('TestLibraryBridge teardown');
    console.log('params: ' + JSON.stringify(params));

    for (key in params) {
        for (var i = 0; i < params[key].length; i += 1) {
            value = params[key][i];
            // send to test options to native side
            const message = {
                action: 'adjustTLB_addToTestOptionsSet',
                data: { key: key, value: value }
            };

            window.webkit.messageHandlers.adjustTest.postMessage(message);
        }
    }
};

AdjustCommandExecutor.prototype.testOptions = function(params) {
    console.log('TestLibraryBridge testOptions');
    console.log('params: ' + JSON.stringify(params));

    var TestOptions = function() {
        this.urlOverwrite = null;
        this.controlUrl = null;
        this.extraPath = null;
        this.timerIntervalInMilliseconds = null;
        this.timerStartInMilliseconds = null;
        this.sessionIntervalInMilliseconds = null;
        this.subsessionIntervalInMilliseconds = null;
        this.idfa = null;
        this.attStatus = null;
        this.teardown = null;
        this.deleteState = null;
        this.noBackoffWait = null;
        this.adServicesFrameworkEnabled = null;
    };

    var testOptions = new TestOptions();
    testOptions.urlOverwrite = this.urlOverwrite;
    testOptions.controlUrl = this.controlUrl;

    if ('basePath' in params) {
        this.extraPath = getFirstValue(params, 'basePath');
    }
    if ('timerInterval' in params) {
        testOptions.timerIntervalInMilliseconds = getFirstValue(params, 'timerInterval');
    }
    if ('timerStart' in params) {
        testOptions.timerStartInMilliseconds = getFirstValue(params, 'timerStart');
    }
    if ('sessionInterval' in params) {
        testOptions.sessionIntervalInMilliseconds = getFirstValue(params, 'sessionInterval');
    }
    if ('subsessionInterval' in params) {
        testOptions.subsessionIntervalInMilliseconds = getFirstValue(params, 'subsessionInterval');
    }
    if ('attStatus' in params) {
        var attStatus = getFirstValue(params, 'attStatus');
        testOptions.attStatus = attStatus;
    }
    if ('idfa' in params) {
        var idfa = getFirstValue(params, 'idfa');
        testOptions.idfa = idfa;
    }
    if ('noBackoffWait' in params) {
        var noBackoffWait = getFirstValue(params, 'noBackoffWait');
        testOptions.noBackoffWait = noBackoffWait == 'true';
    }
    // AdServices will not be used in test app by default
    testOptions.adServicesFrameworkEnabled = false;
    if ('adServicesFrameworkEnabled' in params) {
        var adServicesFrameworkEnabled = getFirstValue(params, 'adServicesFrameworkEnabled');
        testOptions.adServicesFrameworkEnabled = adServicesFrameworkEnabled == 'true';
    }
    if ('teardown' in params) {
        console.log('TestLibraryBridge hasOwnProperty teardown: ' + params['teardown']);

        var teardownOptions = params['teardown'];
        var teardownOptionsLength = teardownOptions.length;

        for (var i = 0; i < teardownOptionsLength; i++) {
            let teardownOption = teardownOptions[i];
            console.log('TestLibraryBridge teardown option nr ' + i + ' with value: ' + teardownOption);
            switch(teardownOption) {
                case 'resetSdk':
                    testOptions.teardown = true;
                    testOptions.extraPath = this.extraPath;
                    break;
                case 'deleteState':
                    testOptions.deleteState = true;
                    break;
                case 'resetTest':
                    // TODO: reset configs
                    // TODO: reset events
                    testOptions.timerIntervalInMilliseconds = -1;
                    testOptions.timerStartInMilliseconds = -1;
                    testOptions.sessionIntervalInMilliseconds = -1;
                    testOptions.subsessionIntervalInMilliseconds = -1;
                    break;
                case 'sdk':
                    testOptions.teardown = true;
                    testOptions.extraPath = null;
                    break;
                case 'test':
                    // TODO: null configs
                    // TODO: null events
                    // TODO: null delegate
                    this.extraPath = null;
                    testOptions.timerIntervalInMilliseconds = -1;
                    testOptions.timerStartInMilliseconds = -1;
                    testOptions.sessionIntervalInMilliseconds = -1;
                    testOptions.subsessionIntervalInMilliseconds = -1;
                    break;
            }
        }
    }
    Adjust.setTestOptions(testOptions);
};

AdjustCommandExecutor.prototype.config = function(params) {
    var configNumber = 0;
    if ('configName' in params) {
        var configName = getFirstValue(params, 'configName');
        configNumber = parseInt(configName.substr(configName.length - 1));
    }

    var adjustConfig;
    if (configNumber in this.savedConfigs) {
        adjustConfig = this.savedConfigs[configNumber];
    } else {
        var environment = getFirstValue(params, 'environment');
        var appToken = getFirstValue(params, 'appToken');

        adjustConfig = new AdjustConfig(appToken, environment);
        adjustConfig.setLogLevel(AdjustConfig.LogLevelVerbose);

        this.savedConfigs[configNumber] = adjustConfig;
    }

    if ('logLevel' in params) {
        var logLevelS = getFirstValue(params, 'logLevel');
        var logLevel = null;
        switch (logLevelS) {
            case "verbose":
                logLevel = AdjustConfig.LogLevelVerbose;
                break;
            case "debug":
                logLevel = AdjustConfig.LogLevelDebug;
                break;
            case "info":
                logLevel = AdjustConfig.LogLevelInfo;
                break;
            case "warn":
                logLevel = AdjustConfig.LogLevelWarn;
                break;
            case "error":
                logLevel = AdjustConfig.LogLevelError;
                break;
            case "assert":
                logLevel = AdjustConfig.LogLevelAssert;
                break;
            case "suppress":
                logLevel = AdjustConfig.LogLevelSuppress;
                break;
        }
        adjustConfig.setLogLevel(logLevel);
    }

    if ('sdkPrefix' in params) {
        var sdkPrefix = getFirstValue(params, 'sdkPrefix');
        adjustConfig.setSdkPrefix(sdkPrefix);
    }

    if ('defaultTracker' in params) {
        var defaultTracker = getFirstValue(params, 'defaultTracker');
        adjustConfig.setDefaultTracker(defaultTracker);
    }

    if ('externalDeviceId' in params) {
        var externalDeviceId = getFirstValue(params, 'externalDeviceId');
        adjustConfig.setExternalDeviceId(externalDeviceId);
    }

    if ('needsCost' in params) {
        var isCostDataInAttributionEnabledS = getFirstValue(params, 'needsCost');
        var isCostDataInAttributionEnabled = isCostDataInAttributionEnabledS == 'true';
        if (isCostDataInAttributionEnabled == true) {
            adjustConfig.enableCostDataInAttribution();
        }
    }

    if ('allowAdServicesInfoReading' in params) {
        var isAdServicesEnabledS = getFirstValue(params, 'allowAdServicesInfoReading');
        var isAdServicesEnabled = isAdServicesEnabledS == 'true';
        if (isAdServicesEnabled == false) {
            adjustConfig.disableAdServices();
        }
    }

    if ('allowIdfaReading' in params) {
        var allowIdfaReadingS = getFirstValue(params, 'allowIdfaReading');
        var allowIdfaReading = allowIdfaReadingS == 'true';
        if (allowIdfaReading == false) {
            adjustConfig.disableIdfaReading();
        }
    }

    if ('allowSkAdNetworkHandling' in params) {
        var allowSkAdNetworkHandlingS = getFirstValue(params, 'allowSkAdNetworkHandling');
        var allowSkAdNetworkHandling = allowSkAdNetworkHandlingS == 'true';
        if (allowSkAdNetworkHandling == false) {
            adjustConfig.disableSkanAttributionHandling();
        }
    }

    if ('sendInBackground' in params) {
        var sendInBackgroundS = getFirstValue(params, 'sendInBackground');
        var sendInBackground = sendInBackgroundS == 'true';
        adjustConfig.setSendInBackground(sendInBackground);
    }

    if ('attConsentWaitingSeconds' in params) {
        var attConsentWaitingSecondsS = getFirstValue(params, 'attConsentWaitingSeconds');
        var attConsentWaitingSeconds = parseFloat(attConsentWaitingSecondsS);
        adjustConfig.setAttConsentWaitingInterval(attConsentWaitingSeconds);
    }

    if ('eventDeduplicationIdsMaxSize' in params) {
        var eventDeduplicationIdsMaxSizeS = getFirstValue(params, 'eventDeduplicationIdsMaxSize');
        var eventDeduplicationIdsMaxSize = parseFloat(eventDeduplicationIdsMaxSizeS);
        adjustConfig.setEventDeduplicationIdsMaxSize(eventDeduplicationIdsMaxSize);
    }

    if ('coppaCompliant' in params) {
        var coppaCompliantS = getFirstValue(params, 'coppaCompliant');
        var coppaCompliant = coppaCompliantS == 'true';
        if (coppaCompliant == true) {
            adjustConfig.enableCoppaCompliance();
        }
    }

    if ('allowAttUsage' in params) {
        var allowaAttUsageS = getFirstValue(params, 'allowAttUsage');
        var allowaAttUsage = allowaAttUsageS == 'true';
        if (allowaAttUsage == false) {
            adjustConfig.disableAppTrackingTransparencyUsage();
        }
    }
    
    if ('firstSessionDelayEnabled' in params) {
        var firstSessionDelayEnabledS = getFirstValue(params, 'firstSessionDelayEnabled');
        var firstSessionDelayEnabled = firstSessionDelayEnabledS == 'true';
        if (firstSessionDelayEnabled == true) {
            adjustConfig.enableFirstSessionDelay();
        }
    }
    
    if ('storeName' in params) {
        var storeInfo;
        var storeName = getFirstValue(params, 'storeName');
        storeInfo = new AdjustStoreInfo(storeName);

        if ('storeAppId' in params) {
            var storeAppId = getFirstValue(params, 'storeAppId');
            storeInfo.setStoreAppId(storeAppId);
        }
        adjustConfig.setStoreInfo(storeInfo);
    }

    if ('attributionCallbackSendAll' in params) {
        console.log('AdjustCommandExecutor.prototype.config attributionCallbackSendAll');
        var extraPath = this.extraPath;
        adjustConfig.setAttributionCallback(
            function(attribution) {
                console.log('attributionCallback: ' + JSON.stringify(attribution));
                addInfoToSend('tracker_token', attribution.trackerToken);
                addInfoToSend('tracker_name', attribution.trackerName);
                addInfoToSend('network', attribution.network);
                addInfoToSend('campaign', attribution.campaign);
                addInfoToSend('adgroup', attribution.adgroup);
                addInfoToSend('creative', attribution.creative);
                addInfoToSend('click_label', attribution.click_label);
                addInfoToSend('cost_type', attribution.costType);
                addInfoToSend('cost_amount', attribution.costAmount);
                addInfoToSend('cost_currency', attribution.costCurrency);
                const jsonResponseWithoutFbInstallReferrer = { ...attribution.jsonResponse };
                if (jsonResponseWithoutFbInstallReferrer.cost_amount !== undefined) {
                    jsonResponseWithoutFbInstallReferrer.cost_amount = parseFloat(jsonResponseWithoutFbInstallReferrer.cost_amount).toFixed(2);
                }
                delete jsonResponseWithoutFbInstallReferrer.fb_install_referrer;
                addInfoToSend('json_response', JSON.stringify(jsonResponseWithoutFbInstallReferrer));
                sendInfoToServer(extraPath);
            }
        );
    }

    if ('sessionCallbackSendSuccess' in params) {
        console.log('AdjustCommandExecutor.prototype.config sessionCallbackSendSuccess');
        var extraPath = this.extraPath;
        adjustConfig.setSessionSuccessCallback(
            function(sessionSuccessResponseData) {
                console.log('sessionSuccessCallback: ' + JSON.stringify(sessionSuccessResponseData));
                addInfoToSend('message', sessionSuccessResponseData.message);
                addInfoToSend('timestamp', sessionSuccessResponseData.timestamp);
                addInfoToSend('adid', sessionSuccessResponseData.adid);
                addInfoToSend('jsonResponse', sessionSuccessResponseData.jsonResponse);
                sendInfoToServer(extraPath);
            }
        );
    }

    if ('sessionCallbackSendFailure' in params) {
        console.log('AdjustCommandExecutor.prototype.config sessionCallbackSendFailure');
        var extraPath = this.extraPath;
        adjustConfig.setSessionFailureCallback(
            function(sessionFailureResponseData) {
                console.log('sessionFailureCallback: ' + JSON.stringify(sessionFailureResponseData));
                addInfoToSend('message', sessionFailureResponseData.message);
                addInfoToSend('timestamp', sessionFailureResponseData.timestamp);
                addInfoToSend('adid', sessionFailureResponseData.adid);
                addInfoToSend('willRetry', sessionFailureResponseData.willRetry ? 'true' : 'false');
                addInfoToSend('jsonResponse', sessionFailureResponseData.jsonResponse);
                sendInfoToServer(extraPath);
            }
        );
    }

    if ('eventCallbackSendSuccess' in params) {
        console.log('AdjustCommandExecutor.prototype.config eventCallbackSendSuccess');
        var extraPath = this.extraPath;
        adjustConfig.setEventSuccessCallback(
            function(eventSuccessResponseData) {
                console.log('eventSuccessCallback: ' + JSON.stringify(eventSuccessResponseData));
                addInfoToSend('message', eventSuccessResponseData.message);
                addInfoToSend('timestamp', eventSuccessResponseData.timestamp);
                addInfoToSend('adid', eventSuccessResponseData.adid);
                addInfoToSend('eventToken', eventSuccessResponseData.eventToken);
                addInfoToSend('callbackId', eventSuccessResponseData.callbackId);
                addInfoToSend('jsonResponse', eventSuccessResponseData.jsonResponse);
                sendInfoToServer(extraPath);
            }
        );
    }

    if ('eventCallbackSendFailure' in params) {
        console.log('AdjustCommandExecutor.prototype.config eventCallbackSendFailure');
        var extraPath = this.extraPath;
        adjustConfig.setEventFailureCallback(
            function(eventFailureResponseData) {
                console.log('eventFailureCallback: ' + JSON.stringify(eventFailureResponseData));
                addInfoToSend('message', eventFailureResponseData.message);
                addInfoToSend('timestamp', eventFailureResponseData.timestamp);
                addInfoToSend('adid', eventFailureResponseData.adid);
                addInfoToSend('eventToken', eventFailureResponseData.eventToken);
                addInfoToSend('callbackId', eventFailureResponseData.callbackId);
                addInfoToSend('willRetry', eventFailureResponseData.willRetry ? 'true' : 'false');
                addInfoToSend('jsonResponse', eventFailureResponseData.jsonResponse);
                sendInfoToServer(extraPath);
            }
        );
    }

    if ('deferredDeeplinkCallback' in params) {
        console.log('AdjustCommandExecutor.prototype.config deferredDeeplinkCallback');
        var isOpeningDeferredDeeplinkEnabledS = getFirstValue(params, 'deferredDeeplinkCallback');
        if (isOpeningDeferredDeeplinkEnabledS === 'false') {
            adjustConfig.disableDeferredDeeplinkOpening();
        }
        var extraPath = this.extraPath;
        adjustConfig.setDeferredDeeplinkCallback(
            function(deeplink) {
                console.log('deferredDeeplinkCallback: ' + JSON.stringify(deeplink));
                addInfoToSend('deeplink', deeplink);
                sendInfoToServer(extraPath);
            }
        );
    }
};

var addInfoToSend = function (key, value) {
    const message = {
        action: 'adjustTLB_addInfoToSend',
        data: { key: key, value: value }
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
};

var sendInfoToServer = function (extraPath) {
    const message = {
        action: 'adjustTLB_sendInfoToServer',
        data: extraPath
    };
    window.webkit.messageHandlers.adjustTest.postMessage(message);
};

AdjustCommandExecutor.prototype.start = function(params) {
    this.config(params);
    var configNumber = 0;
    if ('configName' in params) {
        var configName = getFirstValue(params, 'configName');
        configNumber = parseInt(configName.substr(configName.length - 1));
    }

    var adjustConfig = this.savedConfigs[configNumber];
    Adjust.initSdk(adjustConfig);

    delete this.savedConfigs[0];
};

AdjustCommandExecutor.prototype.event = function(params) {
    var eventNumber = 0;
    if ('eventName' in params) {
        var eventName = getFirstValue(params, 'eventName');
        eventNumber = parseInt(eventName.substr(eventName.length - 1))
    }

    var adjustEvent;
    if (eventNumber in this.savedEvents) {
        adjustEvent = this.savedEvents[eventNumber];
    } else {
        var eventToken = getFirstValue(params, 'eventToken');
        adjustEvent = new AdjustEvent(eventToken);
        this.savedEvents[eventNumber] = adjustEvent;
    }

    if ('revenue' in params) {
        var revenueParams = getValues(params, 'revenue');
        var currency = revenueParams[0];
        var revenue = parseFloat(revenueParams[1]);
        adjustEvent.setRevenue(revenue, currency);
    }

    if ('callbackParams' in params) {
        var callbackParams = getValues(params, 'callbackParams');
        for (var i = 0; i < callbackParams.length; i = i + 2) {
            var key = callbackParams[i];
            var value = callbackParams[i + 1];
            adjustEvent.addCallbackParameter(key, value);
        }
    }

    if ('partnerParams' in params) {
        var partnerParams = getValues(params, 'partnerParams');
        for (var i = 0; i < partnerParams.length; i = i + 2) {
            var key = partnerParams[i];
            var value = partnerParams[i + 1];
            adjustEvent.addPartnerParameter(key, value);
        }
    }

    if ('callbackId' in params) {
        var callbackId = getFirstValue(params, 'callbackId');
        adjustEvent.setCallbackId(callbackId);
    }

    if ('deduplicationId' in params) {
        var deduplicationId = getFirstValue(params, 'deduplicationId');
        adjustEvent.setDeduplicationId(deduplicationId);
    }
};

AdjustCommandExecutor.prototype.trackEvent = function(params) {
    this.event(params);
    var eventNumber = 0;
    if ('eventName' in params) {
        var eventName = getFirstValue(params, 'eventName');
        eventNumber = parseInt(eventName.substr(eventName.length - 1))
    }

    var adjustEvent = this.savedEvents[eventNumber];
    Adjust.trackEvent(adjustEvent);

    delete this.savedEvents[0];
};

AdjustCommandExecutor.prototype.pause = function(params) {
    Adjust.trackSubsessionEnd();
};

AdjustCommandExecutor.prototype.resume = function(params) {
    Adjust.trackSubsessionStart();
};

AdjustCommandExecutor.prototype.setEnabled = function(params) {
    var enabled = getFirstValue(params, 'enabled') == 'true';
    if (enabled == true) {
        Adjust.enable();
    } else {
        Adjust.disable();
    }
};

AdjustCommandExecutor.prototype.setOfflineMode = function(params) {
    var enabled = getFirstValue(params, 'enabled') == 'true';
    if (enabled == true) {
        Adjust.switchToOfflineMode();
    } else {
        Adjust.switchBackToOnlineMode();
    }
};

AdjustCommandExecutor.prototype.gdprForgetMe = function(params) {
    Adjust.gdprForgetMe();
};

AdjustCommandExecutor.prototype.addGlobalCallbackParameter = function(params) {
    var list = getValues(params, 'KeyValue');

    for (var i = 0; i < list.length; i = i+2){
        var key = list[i];
        var value = list[i+1];
        Adjust.addGlobalCallbackParameter(key, value);
    }
};

AdjustCommandExecutor.prototype.addGlobalPartnerParameter = function(params) {
    var list = getValues(params, 'KeyValue');

    for (var i = 0; i < list.length; i = i+2){
        var key = list[i];
        var value = list[i+1];
        Adjust.addGlobalPartnerParameter(key, value);
    }
};

AdjustCommandExecutor.prototype.removeGlobalCallbackParameter = function(params) {
    var list = getValues(params, 'key');

    for (var i = 0; i < list.length; i++) {
        var key = list[i];
        Adjust.removeGlobalCallbackParameter(key);
    }
};

AdjustCommandExecutor.prototype.removeGlobalPartnerParameter = function(params) {
    var list = getValues(params, 'key');

    for (var i = 0; i < list.length; i++) {
        var key = list[i];
        Adjust.removeGlobalPartnerParameter(key);
    }
};

AdjustCommandExecutor.prototype.removeGlobalCallbackParameters = function(params) {
    Adjust.removeGlobalCallbackParameters();
};

AdjustCommandExecutor.prototype.removeGlobalPartnerParameters = function(params) {
    Adjust.removeGlobalPartnerParameters();
};

AdjustCommandExecutor.prototype.thirdPartySharing = function(params) {
    var isEnabledS = getFirstValue(params, 'isEnabled');

    var isEnabled = null;
    if (isEnabledS == 'true') {
        isEnabled = true;
    }
    if (isEnabledS == 'false') {
        isEnabled = false;
    }

    var adjustThirdPartySharing = new AdjustThirdPartySharing(isEnabled);
    if ('granularOptions' in params) {
        var granularOptions = getValues(params, 'granularOptions');
        for (var i = 0; i < granularOptions.length; i = i + 3) {
            var partnerName = granularOptions[i];
            var key = granularOptions[i + 1];
            var value = granularOptions[i + 2];
            adjustThirdPartySharing.addGranularOption(partnerName, key, value);
        }
    }
    if ('partnerSharingSettings' in params) {
        var partnerSharingSettings = getValues(params, 'partnerSharingSettings');
        for (var i = 0; i < partnerSharingSettings.length; i = i + 3) {
            var partnerName = partnerSharingSettings[i];
            var key = partnerSharingSettings[i + 1];
            var value = partnerSharingSettings[i + 2] == 'true';
            adjustThirdPartySharing.addPartnerSharingSetting(partnerName, key, value);
        }
    }

    Adjust.trackThirdPartySharing(adjustThirdPartySharing);
};

AdjustCommandExecutor.prototype.measurementConsent = function(params) {
    var consentMeasurement = getFirstValue(params, 'isEnabled') == 'true';
    Adjust.trackMeasurementConsent(consentMeasurement);
};

AdjustCommandExecutor.prototype.attributionGetter = function(params) {
    var extraPath = this.extraPath;
    Adjust.getAttribution(function(attribution) {
        addInfoToSend('tracker_token', attribution.trackerToken);
        addInfoToSend('tracker_name', attribution.trackerName);
        addInfoToSend('network', attribution.network);
        addInfoToSend('campaign', attribution.campaign);
        addInfoToSend('adgroup', attribution.adgroup);
        addInfoToSend('creative', attribution.creative);
        addInfoToSend('click_label', attribution.click_label);
        addInfoToSend('cost_type', attribution.costType);
        addInfoToSend('cost_amount', attribution.costAmount);
        addInfoToSend('cost_currency', attribution.costCurrency);
        const jsonResponseWithoutFbInstallReferrer = { ...attribution.jsonResponse };
        if (jsonResponseWithoutFbInstallReferrer.cost_amount !== undefined) {
            jsonResponseWithoutFbInstallReferrer.cost_amount = parseFloat(jsonResponseWithoutFbInstallReferrer.cost_amount).toFixed(2);
        }
        delete jsonResponseWithoutFbInstallReferrer.fb_install_referrer;
        addInfoToSend('json_response', JSON.stringify(jsonResponseWithoutFbInstallReferrer));
        sendInfoToServer(extraPath);
    });
}

AdjustCommandExecutor.prototype.endFirstSessionDelay = function(params) {
    Adjust.endFirstSessionDelay();
};

AdjustCommandExecutor.prototype.coppaComplianceInDelay = function(params) {
    var coppaCompliantS = getFirstValue(params, 'isEnabled');
    var coppaCompliant = coppaCompliantS == 'true';
    if (coppaCompliant == true) {
        Adjust.enableCoppaComplianceInDelay();
    } else {
        Adjust.disableCoppaComplianceInDelay();
    }
};

AdjustCommandExecutor.prototype.externalDeviceIdInDelay = function(params) {
    if ('externalDeviceId' in params) {
        var externalDeviceId = getFirstValue(params, 'externalDeviceId');
        Adjust.setExternalDeviceIdInDelay(externalDeviceId);
    }
};

// Util
function getValues(params, key) {
    if (key in params) {
        return params[key];
    }

    return null;
}

function getFirstValue(params, key) {
    if (key in params) {
        var param = params[key];

        if(param != null && param.length >= 1) {
            return param[0];
        }
    }

    return null;
}

module.exports = TestLibraryBridge;


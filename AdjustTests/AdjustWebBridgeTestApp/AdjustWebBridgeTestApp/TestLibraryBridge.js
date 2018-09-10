var localBaseUrl = 'http://127.0.0.1:8080';
var localGdprUrl = 'http://127.0.0.1:8080';

// local reference of the command executor
// originally it was this.adjustCommandExecutor of TestLibraryBridge var
// but for some reason, "this" on "startTestSession" was different in "adjustCommandExecutor"
var localAdjustCommandExecutor;

var TestLibraryBridge = {
    adjustCommandExecutor: function(commandRawJson) {
        console.log('TestLibraryBridge adjustCommandExecutor');
        const command = JSON.parse(commandRawJson);
        console.log('className: ' + command.className);
        console.log('functionName: ' + command.functionName);
        console.log('params: ' + JSON.stringify(command.params));

        // reflection based technique to call functions with the same name as the command function
        localAdjustCommandExecutor[command.functionName](command.params);
    },
    startTestSession: function () {
        console.log('TestLibraryBridge startTestSession');
        if (WebViewJavascriptBridge) {
            console.log('TestLibraryBridge startTestSession callHandler');

            localAdjustCommandExecutor = new AdjustCommandExecutor(localBaseUrl, localGdprUrl);
            // register objc->JS function for commands
            WebViewJavascriptBridge.registerHandler('adjustJS_commandExecutor', TestLibraryBridge.adjustCommandExecutor);
            // start test session in obj-c
            WebViewJavascriptBridge.callHandler('adjust_startTestSession', null, null);
        }
    }
};

var AdjustCommandExecutor = function(baseUrl, gdprUrl) {
    this.baseUrl           = baseUrl;
    this.gdprUrl           = gdprUrl;
    this.basePath          = null;
    this.gdprPath          = null;
    this.savedEvents       = {};
    this.savedConfigs      = {};
    this.savedCommands     = [];
    this.nextToSendCounter = 0;
};

AdjustCommandExecutor.prototype.testOptions = function(params) {
    console.log('TestLibraryBridge testOptions');
    console.log('params: ' + JSON.stringify(params));

    var TestOptions = function() {
        this.baseUrl = null;
        this.gdprUrl = null;
        this.basePath = null;
        this.gdprPath = null;
        this.timerIntervalInMilliseconds = null;
        this.timerStartInMilliseconds = null;
        this.sessionIntervalInMilliseconds = null;
        this.subsessionIntervalInMilliseconds = null;
        this.teardown = null;
        this.deleteState = null;
        this.noBackoffWait = null;
        this.iAdFrameworkEnabled = null;
    };

    var testOptions = new TestOptions();
    testOptions.baseUrl = this.baseUrl;
    testOptions.gdprUrl = this.gdprUrl;

    if ('basePath' in params) {
        var basePath = getFirstValue(params, 'basePath');
        console.log('TestLibraryBridge hasOwnProperty basePath, first: ' basePath);
        this.basePath = basePath;
        this.gdprPath = basePath;
    }

    if ('timerInterval' in params) {
        testOptions.timerIntervalInMilliseconds = getFirstValue(params, 'timerInterval');
    }
    if ('timerStart' in params) {
        testOptions.imerStartInMilliseconds = getFirstValue(params, 'timerStart');
    }
    if ('sessionInterval' in params) {
        testOptions.sessionIntervalInMilliseconds = getFirstValue(params, 'sessionInterval');
    }
    if ('subsessionInterval' in params) {
        testOptions.subsessionIntervalInMilliseconds = getFirstValue(params, 'subsessionInterval');
    }
    if ('noBackoffWait' in params) {
        testOptions.noBackoffWait = getFirstValue(params, 'noBackoffWait');
    }
    // iAd will not be used in test app by default
    testOptions.iAdFrameworkEnabled = false;
    if ('iAdFrameworkEnabled' in params) {
        testOptions.iAdFrameworkEnabled = getFirstValue(params, 'iAdFrameworkEnabled');
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
                    testOptions.basePath = this.basePath;
                    testOptions.gdprPath = this.gdprPath;
                    break;
                case 'deleteState':
                    testOptions.deleteState = true;
                    break;
                case 'resetTest':
                    //TODOD reset configs
                    //TODOD reset events
                    testOptions.timerIntervalInMilliseconds = -1;
                    testOptions.timerStartInMilliseconds = -1;
                    testOptions.sessionIntervalInMilliseconds = -1;
                    testOptions.subsessionIntervalInMilliseconds = -1;
                    break;
                case 'sdk':
                    testOptions.teardown = true;
                    testOptions.basePath = null;
                    testOptions.gdprPath = null;
                    break;
                case 'test':
                    //TODO null configs
                    //TODO null events
                    //TODO null delegate
                    this.basePath = null;
                    this.gdprPath = null;
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

AdjustCommandExecutor.prototype.testOptions = function(params) {
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

    if ('appSecret' in params) {
        var appSecretArray = getValues(params, 'appSecret');
        var secretId = appSecretArray[0].toString();
        var info1    = appSecretArray[1].toString();
        var info2    = appSecretArray[2].toString();
        var info3    = appSecretArray[3].toString();
        var info4    = appSecretArray[4].toString();

        adjustConfig.setAppSecret(secretId, info1, info2, info3, info4);
    }

    if ('delayStart' in params) {
        var delayStartS = getFirstValue(params, 'delayStart');
        var delayStart = parseFloat(delayStartS);
        adjustConfig.setDelayStart(delayStart);
    }

    if ('deviceKnown' in params) {
        var deviceKnownS = getFirstValue(params, 'deviceKnown');
        var deviceKnown = deviceKnownS == 'true';
        adjustConfig.setIsDeviceKnown(deviceKnown);
    }

    if ('eventBufferingEnabled' in params) {
        var eventBufferingEnabledS = getFirstValue(params, 'eventBufferingEnabled');
        var eventBufferingEnabled = eventBufferingEnabledS == 'true';
        adjustConfig.setEventBufferingEnabled(eventBufferingEnabled);
    }

    if ('sendInBackground' in params) {
        var sendInBackgroundS = getFirstValue(params, 'sendInBackground');
        var sendInBackground = sendInBackgroundS == 'true';
        adjustConfig.setSendInBackground(sendInBackground);
    }

    if ('userAgent' in params) {
        var userAgent = getFirstValue(params, 'userAgent');
        adjustConfig.setUserAgent(userAgent);
    }

    // TODO callbacks
};

AdjustCommandExecutor.prototype.start = function(params) {
    this.config(params);
    var configNumber = 0;
    if ('configName' in params) {
        var configName = getFirstValue(params, 'configName');
        configNumber = parseInt(configName.substr(configName.length - 1));
    }

    var adjustConfig = this.savedConfigs[configNumber];
    Adjust.appDidLaunch(adjustConfig);

    delete this.savedConfigs[0];
};

//Util
//======================
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

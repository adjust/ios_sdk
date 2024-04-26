//
//  ATAAdjustCommandExecutor.m
//  AdjustTestApp
//
//  Created by Pedro Silva (@nonelse) on 23rd August 2017.
//  Copyright © 2017-2018 Adjust GmbH. All rights reserved.
//

#import "Adjust.h"
#import "ADJAdjustFactory.h"
#import "ATAAdjustDelegate.h"
#import "ATAAdjustDelegateAttribution.h"
#import "ATAAdjustDelegateEventFailure.h"
#import "ATAAdjustDelegateEventSuccess.h"
#import "ATAAdjustDelegateSessionSuccess.h"
#import "ATAAdjustDelegateSessionFailure.h"
#import "ATAAdjustDelegateDeferredDeeplink.h"
#import "ATAAdjustDelegateSkan.h"
#import "ATAAdjustCommandExecutor.h"
#import "ViewController.h"

@interface ATAAdjustCommandExecutor ()

@property (nonatomic, copy) NSString *extraPath;
@property (nonatomic, strong) NSMutableDictionary *savedConfigs;
@property (nonatomic, strong) NSMutableDictionary *savedEvents;
@property (nonatomic, strong) NSObject<AdjustDelegate> *adjustDelegate;

@end

@implementation ATAAdjustCommandExecutor

- (id)init {
    self = [super init];

    if (self == nil) {
        return nil;
    }

    self.savedConfigs = [NSMutableDictionary dictionary];
    self.savedEvents = [NSMutableDictionary dictionary];
    self.adjustDelegate = nil;
    self.extraPath = nil;

    return self;
}

- (void)executeCommand:(NSString *)className
            methodName:(NSString *)methodName
            parameters:(NSDictionary *)parameters {
    NSLog(@"executeCommand className: %@, methodName: %@, parameters: %@", className, methodName, parameters);

    if ([methodName isEqualToString:@"testOptions"]) {
        [self testOptions:parameters];
    } else if ([methodName isEqualToString:@"config"]) {
        [self config:parameters];
    } else if ([methodName isEqualToString:@"start"]) {
        [self start:parameters];
    } else if ([methodName isEqualToString:@"event"]) {
        [self event:parameters];
    } else if ([methodName isEqualToString:@"trackEvent"]) {
        [self trackEvent:parameters];
    } else if ([methodName isEqualToString:@"resume"]) {
        [self resume:parameters];
    } else if ([methodName isEqualToString:@"pause"]) {
        [self pause:parameters];
    } else if ([methodName isEqualToString:@"setEnabled"]) {
        [self setEnabled:parameters];
    } else if ([methodName isEqualToString:@"setOfflineMode"]) {
        [self setOfflineMode:parameters];
    } else if ([methodName isEqualToString:@"sendFirstPackages"]) {
        [self sendFirstPackages:parameters];
    } else if ([methodName isEqualToString:@"addGlobalCallbackParameter"]) {
        [self addGlobalCallbackParameter:parameters];
    } else if ([methodName isEqualToString:@"addGlobalPartnerParameter"]) {
        [self addGlobalPartnerParameter:parameters];
    } else if ([methodName isEqualToString:@"removeGlobalCallbackParameter"]) {
        [self removeGlobalCallbackParameter:parameters];
    } else if ([methodName isEqualToString:@"removeGlobalPartnerParameter"]) {
        [self removeGlobalPartnerParameter:parameters];
    } else if ([methodName isEqualToString:@"removeGlobalCallbackParameters"]) {
        [self removeGlobalCallbackParameters:parameters];
    } else if ([methodName isEqualToString:@"removeGlobalPartnerParameters"]) {
        [self removeGlobalPartnerParameters:parameters];
    } else if ([methodName isEqualToString:@"setPushToken"]) {
        [self setPushToken:parameters];
    } else if ([methodName isEqualToString:@"openDeeplink"]) {
        [self openDeeplink:parameters];
    } else if ([methodName isEqualToString:@"gdprForgetMe"]) {
        [self gdprForgetMe:parameters];
    } else if ([methodName isEqualToString:@"thirdPartySharing"]) {
        [self thirdPartySharing:parameters];
    } else if ([methodName isEqualToString:@"measurementConsent"]) {
        [self measurementConsent:parameters];
    } else if ([methodName isEqualToString:@"trackSubscription"]) {
        [self trackSubscription:parameters];
    } else if ([methodName isEqualToString:@"trackAdRevenue"]) {
        [self trackAdRevenue:parameters];
    } else if ([methodName isEqualToString:@"getLastDeeplink"]) {
        [self getLastDeeplink:parameters];
    } else if ([methodName isEqualToString:@"verifyPurchase"]) {
        [self verifyPurchase:parameters];
    } else if ([methodName isEqualToString:@"processDeeplink"]) {
        [self processDeeplink:parameters];
    }
}

- (void)testOptions:(NSDictionary *)parameters {
    AdjustTestOptions *testOptions = [[AdjustTestOptions alloc] init];
    testOptions.urlOverwrite = urlOverwrite;

    if ([parameters objectForKey:@"basePath"]) {
        self.extraPath = [parameters objectForKey:@"basePath"][0];
    }
    if ([parameters objectForKey:@"timerInterval"]) {
        NSString *timerIntervalMilliS = [parameters objectForKey:@"timerInterval"][0];
        testOptions.timerIntervalInMilliseconds = [ATAAdjustCommandExecutor convertMilliStringToNumber:timerIntervalMilliS];
    }
    if ([parameters objectForKey:@"timerStart"]) {
        NSString *timerStartMilliS = [parameters objectForKey:@"timerStart"][0];
        testOptions.timerStartInMilliseconds = [ATAAdjustCommandExecutor convertMilliStringToNumber:timerStartMilliS];
    }
    if ([parameters objectForKey:@"sessionInterval"]) {
        NSString *sessionIntervalMilliS = [parameters objectForKey:@"sessionInterval"][0];
        testOptions.sessionIntervalInMilliseconds = [ATAAdjustCommandExecutor convertMilliStringToNumber:sessionIntervalMilliS];
    }
    if ([parameters objectForKey:@"subsessionInterval"]) {
        NSString *subsessionIntervalMilliS = [parameters objectForKey:@"subsessionInterval"][0];
        testOptions.subsessionIntervalInMilliseconds = [ATAAdjustCommandExecutor convertMilliStringToNumber:subsessionIntervalMilliS];
    }
    if ([parameters objectForKey:@"attStatus"]) {
        NSString *attStatusS = [parameters objectForKey:@"attStatus"][0];
        NSNumber *attStatusN = [NSNumber numberWithInt:[attStatusS intValue]];

        testOptions.attStatusInt = attStatusN;
    }
    if ([parameters objectForKey:@"idfa"]) {
        NSString *idfa = [parameters objectForKey:@"idfa"][0];
        testOptions.idfa = idfa;
    }
    if ([parameters objectForKey:@"noBackoffWait"]) {
        NSString *noBackoffWaitStr = [parameters objectForKey:@"noBackoffWait"][0];
        testOptions.noBackoffWait = NO;
        if ([noBackoffWaitStr isEqualToString:@"true"]) {
            testOptions.noBackoffWait = YES;
        }
    }
    testOptions.adServicesFrameworkEnabled = NO; // default value -> NO - AdServices will not be used in test app by default
    if ([parameters objectForKey:@"adServicesFrameworkEnabled"]) {
        NSString *adServicesFrameworkEnabledStr = [parameters objectForKey:@"adServicesFrameworkEnabled"][0];
        if ([adServicesFrameworkEnabledStr isEqualToString:@"true"]) {
            testOptions.adServicesFrameworkEnabled = YES;
        }
    }
    if ([parameters objectForKey:@"enableSigning"]) {
        NSString *enableSigningStr = [parameters objectForKey:@"enableSigning"][0];
        testOptions.enableSigning = NO;
        if ([enableSigningStr isEqualToString:@"true"]) {
            testOptions.enableSigning = YES;
        }
    }
    if ([parameters objectForKey:@"disableSigning"]) {
        NSString *disableSigningStr = [parameters objectForKey:@"disableSigning"][0];
        testOptions.disableSigning = NO;
        if ([disableSigningStr isEqualToString:@"true"]) {
            testOptions.disableSigning = YES;
        }
    }
    if ([parameters objectForKey:@"teardown"]) {
        NSArray *teardownOptions = [parameters objectForKey:@"teardown"];
        for (int i = 0; i < teardownOptions.count; i = i + 1) {
            NSString *teardownOption = teardownOptions[i];
            if ([teardownOption isEqualToString:@"resetSdk"]) {
                testOptions.teardown = YES;
                testOptions.extraPath = self.extraPath;
            }
            if ([teardownOption isEqualToString:@"deleteState"]) {
                testOptions.deleteState = YES;
            }
            if ([teardownOption isEqualToString:@"resetTest"]) {
                self.savedConfigs = [NSMutableDictionary dictionary];
                self.savedEvents = [NSMutableDictionary dictionary];
                self.adjustDelegate = nil;
                testOptions.timerIntervalInMilliseconds = [NSNumber numberWithInt:-1000];
                testOptions.timerStartInMilliseconds = [NSNumber numberWithInt:-1000];
                testOptions.sessionIntervalInMilliseconds = [NSNumber numberWithInt:-1000];
                testOptions.subsessionIntervalInMilliseconds = [NSNumber numberWithInt:-1000];
            }
            if ([teardownOption isEqualToString:@"sdk"]) {
                testOptions.teardown = YES;
                testOptions.extraPath = nil;
            }
            if ([teardownOption isEqualToString:@"test"]) {
                self.savedConfigs = nil;
                self.savedEvents = nil;
                self.adjustDelegate = nil;
                self.extraPath = nil;
                testOptions.timerIntervalInMilliseconds = [NSNumber numberWithInt:-1000];
                testOptions.timerStartInMilliseconds = [NSNumber numberWithInt:-1000];
                testOptions.sessionIntervalInMilliseconds = [NSNumber numberWithInt:-1000];
                testOptions.subsessionIntervalInMilliseconds = [NSNumber numberWithInt:-1000];
            }
        }
    }

    [Adjust setTestOptions:testOptions];
}

+ (NSNumber *)convertMilliStringToNumber:(NSString *)milliS {
    NSNumber * number = [NSNumber numberWithInt:[milliS intValue]];
    return number;
}

- (void)config:(NSDictionary *)parameters {
    NSNumber *configNumber = [NSNumber numberWithInt:0];

    if ([parameters objectForKey:@"configName"]) {
        NSString *configName = [parameters objectForKey:@"configName"][0];
        NSString *configNumberS = [configName substringFromIndex:[configName length] - 1];
        configNumber = [NSNumber numberWithInt:[configNumberS intValue]];
    }

    ADJConfig *adjustConfig = nil;

    if ([self.savedConfigs objectForKey:configNumber]) {
        adjustConfig = [self.savedConfigs objectForKey:configNumber];
    } else {
        NSString *environment = [parameters objectForKey:@"environment"][0];
        NSString *appToken = [parameters objectForKey:@"appToken"][0];

        adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];
        [self.savedConfigs setObject:adjustConfig forKey:configNumber];
    }
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.URL = nil;
    NSString *pasteboardContent = [parameters objectForKey:@"pasteboard"][0];
    if (pasteboardContent != nil) {
        pasteboard.URL = [NSURL URLWithString:pasteboardContent];
    }

    if ([parameters objectForKey:@"logLevel"]) {
        NSString *logLevelS = [parameters objectForKey:@"logLevel"][0];
        ADJLogLevel logLevel = [ADJLogger logLevelFromString:logLevelS];
        [adjustConfig setLogLevel:logLevel];
    }

    if ([parameters objectForKey:@"sdkPrefix"]) {
        NSString *sdkPrefix;
        if ([[parameters objectForKey:@"sdkPrefix"] count] == 0) {
            sdkPrefix = nil;
        } else {
            sdkPrefix = [parameters objectForKey:@"sdkPrefix"][0];
            if (sdkPrefix == (id)[NSNull null]) {
                sdkPrefix = nil;
            }
        }
        [adjustConfig setSdkPrefix:sdkPrefix];
    }

    if ([parameters objectForKey:@"defaultTracker"]) {
        NSString *defaultTracker;
        if ([[parameters objectForKey:@"defaultTracker"] count] == 0) {
            defaultTracker = nil;
        } else {
            defaultTracker = [parameters objectForKey:@"defaultTracker"][0];
            if (defaultTracker == (id)[NSNull null]) {
                defaultTracker = nil;
            }
        }
        [adjustConfig setDefaultTracker:defaultTracker];
    }

    if ([parameters objectForKey:@"delayStart"]) {
        NSString *delayStartS = [parameters objectForKey:@"delayStart"][0];
        double delayStart = [delayStartS doubleValue];
        [adjustConfig setDelayStart:delayStart];
    }
    
    if ([parameters objectForKey:@"needsCost"]) {
        NSString *needsCostS = [parameters objectForKey:@"needsCost"][0];
        [adjustConfig setNeedsCost:[needsCostS boolValue]];
    }
    
    if ([parameters objectForKey:@"coppaCompliant"]) {
        NSString *coppaCompliantEnabledS = [parameters objectForKey:@"coppaCompliant"][0];
        [adjustConfig setCoppaCompliantEnabled:[coppaCompliantEnabledS boolValue]];
    }

    if ([parameters objectForKey:@"sendInBackground"]) {
        NSString *sendInBackgroundS = [parameters objectForKey:@"sendInBackground"][0];
        [adjustConfig setSendInBackground:[sendInBackgroundS boolValue]];
    }
    
    if ([parameters objectForKey:@"allowIdfaReading"]) {
        NSString *allowIdfaReadingS = [parameters objectForKey:@"allowIdfaReading"][0];
        if ([allowIdfaReadingS boolValue] == NO) {
            [adjustConfig disableIdfaReading];
        }
    }

    if ([parameters objectForKey:@"allowAdServicesInfoReading"]) {
        NSString *allowAdServicesInfoReadingS = [parameters objectForKey:@"allowAdServicesInfoReading"][0];
        [adjustConfig setAllowAdServicesInfoReading:[allowAdServicesInfoReadingS boolValue]];
    }
    
    if ([parameters objectForKey:@"allowSkAdNetworkHandling"]) {
        NSString *allowSkAdNetworkHandlingS = [parameters objectForKey:@"allowSkAdNetworkHandling"][0];
        if ([allowSkAdNetworkHandlingS boolValue] == NO) {
            [adjustConfig deactivateSKAdNetworkHandling];
        }
    }

    if ([parameters objectForKey:@"externalDeviceId"]) {
        NSString *externalDeviceId = [parameters objectForKey:@"externalDeviceId"][0];
        [adjustConfig setExternalDeviceId:externalDeviceId];
    }
    
    if ([parameters objectForKey:@"checkPasteboard"]) {
        NSString *checkPasteboardS = [parameters objectForKey:@"checkPasteboard"][0];
        if ([checkPasteboardS boolValue] == YES) {
            [adjustConfig enableLinkMe];
        }
    }

    if ([parameters objectForKey:@"attributionCallbackSendAll"]) {
        NSLog(@"attributionCallbackSendAll detected");
        self.adjustDelegate =
            [[ATAAdjustDelegateAttribution alloc] initWithTestLibrary:self.testLibrary
                                                          andExtraPath:self.extraPath];
    }
    
    if ([parameters objectForKey:@"sessionCallbackSendSuccess"]) {
        NSLog(@"sessionCallbackSendSuccess detected");
        self.adjustDelegate =
            [[ATAAdjustDelegateSessionSuccess alloc] initWithTestLibrary:self.testLibrary
                                                             andExtraPath:self.extraPath];
    }
    
    if ([parameters objectForKey:@"sessionCallbackSendFailure"]) {
        NSLog(@"sessionCallbackSendFailure detected");
        self.adjustDelegate =
        [[ATAAdjustDelegateSessionFailure alloc] initWithTestLibrary:self.testLibrary
                                                         andExtraPath:self.extraPath];
    }
    
    if ([parameters objectForKey:@"eventCallbackSendSuccess"]) {
        NSLog(@"eventCallbackSendSuccess detected");
        self.adjustDelegate =
            [[ATAAdjustDelegateEventSuccess alloc] initWithTestLibrary:self.testLibrary
                                                           andExtraPath:self.extraPath];
    }
    
    if ([parameters objectForKey:@"eventCallbackSendFailure"]) {
        NSLog(@"eventCallbackSendFailure detected");
        self.adjustDelegate =
            [[ATAAdjustDelegateEventFailure alloc] initWithTestLibrary:self.testLibrary
                                                           andExtraPath:self.extraPath];
    }

    if ([parameters objectForKey:@"deferredDeeplinkCallback"]) {
        NSLog(@"deferredDeeplinkCallback detected");
        NSString *shouldOpenDeeplinkS = [parameters objectForKey:@"deferredDeeplinkCallback"][0];
        self.adjustDelegate =
            [[ATAAdjustDelegateDeferredDeeplink alloc]
                initWithTestLibrary:self.testLibrary
                extraPath:self.extraPath
                andReturnValue:[shouldOpenDeeplinkS boolValue]];
    }

    if ([parameters objectForKey:@"skanCallback"]) {
        NSLog(@"skanCallback detected");
        self.adjustDelegate =
            [[ATAAdjustDelegateSkan alloc] initWithTestLibrary:self.testLibrary
                                                  andExtraPath:self.extraPath];
    }

    if ([parameters objectForKey:@"attConsentWaitingSeconds"]) {
        NSString *attConsentWaitingSecondsS = [parameters objectForKey:@"attConsentWaitingSeconds"][0];
        [adjustConfig setAttConsentWaitingInterval:[attConsentWaitingSecondsS intValue]];
    }

    [adjustConfig setDelegate:self.adjustDelegate];
}

- (void)start:(NSDictionary *)parameters {
    [self config:parameters];

    NSNumber *configNumber = [NSNumber numberWithInt:0];
    if ([parameters objectForKey:@"configName"]) {
        NSString *configName = [parameters objectForKey:@"configName"][0];
        NSString *configNumberS = [configName substringFromIndex:[configName length] - 1];
        configNumber = [NSNumber numberWithInt:[configNumberS intValue]];
    }

    ADJConfig *adjustConfig = [self.savedConfigs objectForKey:configNumber];
    [adjustConfig setLogLevel:ADJLogLevelVerbose];
    [Adjust appDidLaunch:adjustConfig];
    [self.savedConfigs removeObjectForKey:[NSNumber numberWithInt:0]];
}

- (void)event:(NSDictionary *)parameters {
    NSNumber *eventNumber = [NSNumber numberWithInt:0];
    if ([parameters objectForKey:@"eventName"]) {
        NSString *eventName = [parameters objectForKey:@"eventName"][0];
        NSString *eventNumberS = [eventName substringFromIndex:[eventName length] - 1];
        eventNumber = [NSNumber numberWithInt:[eventNumberS intValue]];
    }

    ADJEvent *adjustEvent = nil;

    if ([self.savedEvents objectForKey:eventNumber]) {
        adjustEvent = [self.savedEvents objectForKey:eventNumber];
    } else {
        NSString *eventToken;
        if ([[parameters objectForKey:@"eventToken"] count] == 0) {
            eventToken = nil;
        } else {
            eventToken = [parameters objectForKey:@"eventToken"][0];
        }
        adjustEvent = [ADJEvent eventWithEventToken:eventToken];
        [self.savedEvents setObject:adjustEvent forKey:eventNumber];
    }

    if ([parameters objectForKey:@"revenue"]) {
        NSArray *currencyAndRevenue = [parameters objectForKey:@"revenue"];
        NSString *currency = currencyAndRevenue[0];
        double revenue = [currencyAndRevenue[1] doubleValue];
        [adjustEvent setRevenue:revenue currency:currency];
    }

    if ([parameters objectForKey:@"callbackParams"]) {
        NSArray *callbackParams = [parameters objectForKey:@"callbackParams"];
        for (int i = 0; i < callbackParams.count; i = i + 2) {
            NSString *key = callbackParams[i];
            NSString *value = callbackParams[i + 1];
            [adjustEvent addCallbackParameter:key value:value];
        }
    }

    if ([parameters objectForKey:@"partnerParams"]) {
        NSArray *partnerParams = [parameters objectForKey:@"partnerParams"];
        for (int i = 0; i < partnerParams.count; i = i + 2) {
            NSString *key = partnerParams[i];
            NSString *value = partnerParams[i + 1];
            [adjustEvent addPartnerParameter:key value:value];
        }
    }

    if ([parameters objectForKey:@"orderId"]) {
        NSString *transactionId;
        if ([[parameters objectForKey:@"orderId"] count] == 0) {
            transactionId = nil;
        } else {
            transactionId = [parameters objectForKey:@"orderId"][0];
            if (transactionId == (id)[NSNull null]) {
                transactionId = nil;
            }
        }
        [adjustEvent setTransactionId:transactionId];
    }

    if ([parameters objectForKey:@"callbackId"]) {
        NSString *callbackId = [parameters objectForKey:@"callbackId"][0];
        if (callbackId == (id)[NSNull null]) {
            callbackId = nil;
        }
        [adjustEvent setCallbackId:callbackId];
    }

    if ([parameters objectForKey:@"productId"]) {
        NSString *productId = [parameters objectForKey:@"productId"][0];
        if (productId == (id)[NSNull null]) {
            productId = nil;
        }
        [adjustEvent setProductId:productId];
    }

    if ([parameters objectForKey:@"transactionId"]) {
        NSString *transactionId = [parameters objectForKey:@"transactionId"][0];
        if (transactionId == (id)[NSNull null]) {
            transactionId = nil;
        }
        [adjustEvent setTransactionId:transactionId];
    }

    if ([parameters objectForKey:@"deduplicationId"]) {
        NSString *deduplicationId = [parameters objectForKey:@"deduplicationId"][0];
        if (deduplicationId == (id)[NSNull null]) {
            deduplicationId = nil;
        }
        [adjustEvent setDeduplicationId:deduplicationId];
    }

    if ([parameters objectForKey:@"receipt"]) {
        NSString *receiptString = [parameters objectForKey:@"receipt"][0];
        NSData *receipt = [receiptString dataUsingEncoding:NSUTF8StringEncoding];
        [adjustEvent setReceipt:receipt];
    }
}

- (void)trackEvent:(NSDictionary *)parameters {
    [self event:parameters];

    NSNumber *eventNumber = [NSNumber numberWithInt:0];
    if ([parameters objectForKey:@"eventName"]) {
        NSString *eventName = [parameters objectForKey:@"eventName"][0];
        NSString *eventNumberS = [eventName substringFromIndex:[eventName length] - 1];
        eventNumber = [NSNumber numberWithInt:[eventNumberS intValue]];
    }

    ADJEvent *adjustEvent = [self.savedEvents objectForKey:eventNumber];
    [Adjust trackEvent:adjustEvent];
    [self.savedEvents removeObjectForKey:[NSNumber numberWithInt:0]];
}

- (void)resume:(NSDictionary *)parameters {
    [Adjust trackSubsessionStart];
}

- (void)pause:(NSDictionary *)parameters {
    [Adjust trackSubsessionEnd];
}

- (void)setEnabled:(NSDictionary *)parameters {
    NSString *enabledS = [parameters objectForKey:@"enabled"][0];
    [Adjust setEnabled:[enabledS boolValue]];
}

- (void)setOfflineMode:(NSDictionary *)parameters {
    NSString *enabledS = [parameters objectForKey:@"enabled"][0];
    [Adjust setOfflineMode:[enabledS boolValue]];
}

- (void)sendFirstPackages:(NSDictionary *)parameters {
    [Adjust sendFirstPackages];
}

- (void)addGlobalCallbackParameter:(NSDictionary *)parameters {
    NSArray *keyValuesPairs = [parameters objectForKey:@"KeyValue"];
    for (int i = 0; i < keyValuesPairs.count; i = i + 2) {
        NSString *key = keyValuesPairs[i];
        NSString *value = keyValuesPairs[i + 1];
        [Adjust addGlobalCallbackParameter:value forKey:key];
    }
}

- (void)addGlobalPartnerParameter:(NSDictionary *)parameters {
    NSArray *keyValuesPairs = [parameters objectForKey:@"KeyValue"];
    for (int i = 0; i < keyValuesPairs.count; i = i + 2) {
        NSString *key = keyValuesPairs[i];
        NSString *value = keyValuesPairs[i + 1];
        [Adjust addGlobalPartnerParameter:value forKey:key];
    }
}

- (void)removeGlobalCallbackParameter:(NSDictionary *)parameters {
    NSArray *keys = [parameters objectForKey:@"key"];
    for (int i = 0; i < keys.count; i = i + 1) {
        NSString *key = keys[i];
        [Adjust removeGlobalCallbackParameterForKey:key];
    }
}

- (void)removeGlobalPartnerParameter:(NSDictionary *)parameters {
    NSArray *keys = [parameters objectForKey:@"key"];
    for (int i = 0; i < keys.count; i = i + 1) {
        NSString *key = keys[i];
        [Adjust removeGlobalPartnerParameterForKey:key];
    }
}

- (void)removeGlobalCallbackParameters:(NSDictionary *)parameters {
    [Adjust removeGlobalCallbackParameters];
}

- (void)removeGlobalPartnerParameters:(NSDictionary *)parameters {
    [Adjust removeGlobalPartnerParameters];
}

- (void)setPushToken:(NSDictionary *)parameters {
    NSString *deviceTokenS = [parameters objectForKey:@"pushToken"][0];
    NSData *deviceToken = [deviceTokenS dataUsingEncoding:NSUTF8StringEncoding];
    [Adjust setDeviceToken:deviceToken];
}

- (void)openDeeplink:(NSDictionary *)parameters {
    NSString *deeplinkS = [parameters objectForKey:@"deeplink"][0];
    NSURL *deeplink = [NSURL URLWithString:deeplinkS];
    [Adjust appWillOpenUrl:deeplink];
}

- (void)gdprForgetMe:(NSDictionary *)parameters {
    [Adjust gdprForgetMe];
}

- (void)thirdPartySharing:(NSDictionary *)parameters {
    NSString *isEnabledS = [parameters objectForKey:@"isEnabled"][0];

    NSNumber *isEnabled = nil;
    if ([isEnabledS isEqualToString:@"true"]) {
        isEnabled = [NSNumber numberWithBool:YES];
    }
    if ([isEnabledS isEqualToString:@"false"]) {
        isEnabled = [NSNumber numberWithBool:NO];
    }

    ADJThirdPartySharing *adjustThirdPartySharing =
        [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:isEnabled];

    if ([parameters objectForKey:@"granularOptions"]) {
        NSArray *granularOptions = [parameters objectForKey:@"granularOptions"];
        for (int i = 0; i < granularOptions.count; i = i + 3) {
            NSString *partnerName = granularOptions[i];
            NSString *key = granularOptions[i + 1];
            NSString *value = granularOptions[i + 2];
            [adjustThirdPartySharing addGranularOption:partnerName key:key value:value];
        }
    }
    
    if ([parameters objectForKey:@"partnerSharingSettings"]) {
        NSArray *partnerSharingSettings = [parameters objectForKey:@"partnerSharingSettings"];
        for (int i = 0; i < partnerSharingSettings.count; i = i + 3) {
            NSString *partnerName = partnerSharingSettings[i];
            NSString *key = partnerSharingSettings[i + 1];
            NSString *value = partnerSharingSettings[i + 2];
            [adjustThirdPartySharing addPartnerSharingSetting:partnerName key:key value:[value boolValue]];
        }
    }

    [Adjust trackThirdPartySharing:adjustThirdPartySharing];
}

- (void)measurementConsent:(NSDictionary *)parameters {
    NSString *isEnabledS = [parameters objectForKey:@"isEnabled"][0];
    [Adjust trackMeasurementConsent:[isEnabledS boolValue]];
}

- (void)trackSubscription:(NSDictionary *)parameters {
    NSDecimalNumber *price;
    NSString *currency;
    NSString *transactionId;
    NSData *receipt;
    NSDate *transactionDate;
    NSString *salesRegion;

    if ([parameters objectForKey:@"revenue"]) {
        price = [[NSDecimalNumber alloc] initWithDouble:[[parameters objectForKey:@"revenue"][0] doubleValue]];
    }
    if ([parameters objectForKey:@"currency"]) {
        currency = [parameters objectForKey:@"currency"][0];
    }
    if ([parameters objectForKey:@"transactionId"]) {
        transactionId = [parameters objectForKey:@"transactionId"][0];
    }
    if ([parameters objectForKey:@"receipt"]) {
        NSString *receiptString = [parameters objectForKey:@"receipt"][0];
        receipt = [receiptString dataUsingEncoding:NSUTF8StringEncoding];
    }
    if ([parameters objectForKey:@"transactionDate"]) {
        transactionDate = [NSDate dateWithTimeIntervalSince1970:[[parameters objectForKey:@"transactionDate"][0] doubleValue]];
    }
    if ([parameters objectForKey:@"salesRegion"]) {
        salesRegion = [parameters objectForKey:@"salesRegion"][0];
    }

    ADJSubscription *subscription = [[ADJSubscription alloc] initWithPrice:price
                                                                  currency:currency
                                                             transactionId:transactionId
                                                                andReceipt:receipt];
    [subscription setTransactionDate:transactionDate];
    [subscription setSalesRegion:salesRegion];

    if ([parameters objectForKey:@"callbackParams"]) {
        NSArray *callbackParams = [parameters objectForKey:@"callbackParams"];
        for (int i = 0; i < callbackParams.count; i = i + 2) {
            NSString *key = callbackParams[i];
            NSString *value = callbackParams[i + 1];
            [subscription addCallbackParameter:key value:value];
        }
    }

    if ([parameters objectForKey:@"partnerParams"]) {
        NSArray *partnerParams = [parameters objectForKey:@"partnerParams"];
        for (int i = 0; i < partnerParams.count; i = i + 2) {
            NSString *key = partnerParams[i];
            NSString *value = partnerParams[i + 1];
            [subscription addPartnerParameter:key value:value];
        }
    }

    [Adjust trackSubscription:subscription];
}

- (void)trackAdRevenue:(NSDictionary *)parameters {
    NSString *source = nil;
    if ([parameters objectForKey:@"adRevenueSource"]) {
        if ([[parameters objectForKey:@"adRevenueSource"] count] > 0) {
            source = [parameters objectForKey:@"adRevenueSource"][0];
        }
    }
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:source];
    
    if ([parameters objectForKey:@"revenue"]) {
        NSArray *currencyAndRevenue = [parameters objectForKey:@"revenue"];
        NSString *currency = currencyAndRevenue[0];
        double revenue = [currencyAndRevenue[1] doubleValue];
        [adRevenue setRevenue:revenue currency:currency];
    }
    
    if ([parameters objectForKey:@"adImpressionsCount"]) {
        int adImpressionsCount = [[parameters objectForKey:@"adImpressionsCount"][0] intValue];
        [adRevenue setAdImpressionsCount:adImpressionsCount];
    }
    
    if ([parameters objectForKey:@"adRevenueUnit"]) {
        NSString *adRevenueUnit = [parameters objectForKey:@"adRevenueUnit"][0];
        [adRevenue setAdRevenueUnit:adRevenueUnit];
    }
    
    if ([parameters objectForKey:@"adRevenuePlacement"]) {
        NSString *adRevenuePlacement = [parameters objectForKey:@"adRevenuePlacement"][0];
        [adRevenue setAdRevenuePlacement:adRevenuePlacement];
    }
    
    if ([parameters objectForKey:@"adRevenueNetwork"]) {
        NSString *adRevenueNetwork = [parameters objectForKey:@"adRevenueNetwork"][0];
        [adRevenue setAdRevenueNetwork:adRevenueNetwork];
    }
    
    if ([parameters objectForKey:@"callbackParams"]) {
        NSArray *callbackParams = [parameters objectForKey:@"callbackParams"];
        for (int i = 0; i < callbackParams.count; i = i + 2) {
            NSString *key = callbackParams[i];
            NSString *value = callbackParams[i + 1];
            [adRevenue addCallbackParameter:key value:value];
        }
    }

    if ([parameters objectForKey:@"partnerParams"]) {
        NSArray *partnerParams = [parameters objectForKey:@"partnerParams"];
        for (int i = 0; i < partnerParams.count; i = i + 2) {
            NSString *key = partnerParams[i];
            NSString *value = partnerParams[i + 1];
            [adRevenue addPartnerParameter:key value:value];
        }
    }
    
    [Adjust trackAdRevenue:adRevenue];
}

- (void)getLastDeeplink:(NSDictionary *)parameters {
    NSURL *lastDeeplink = [Adjust lastDeeplink];
    NSString *lastDeeplinkString = lastDeeplink == nil ? @"" : [lastDeeplink absoluteString];
    [self.testLibrary addInfoToSend:@"last_deeplink" value:lastDeeplinkString];
    [self.testLibrary sendInfoToServer:self.extraPath];
}

- (void)verifyPurchase:(NSDictionary *)parameters {
    NSData *receipt;
    NSString *transactionId;
    NSString *productId;

    if ([parameters objectForKey:@"receipt"]) {
        NSString *receiptString = [parameters objectForKey:@"receipt"][0];
        receipt = [receiptString dataUsingEncoding:NSUTF8StringEncoding];
    }
    if ([parameters objectForKey:@"transactionId"]) {
        transactionId = [parameters objectForKey:@"transactionId"][0];
    }
    if ([parameters objectForKey:@"productId"]) {
        productId = [parameters objectForKey:@"productId"][0];
    }

    ADJPurchase *purchase = [[ADJPurchase alloc] initWithTransactionId:transactionId
                                                             productId:productId
                                                            andReceipt:receipt];
    [Adjust verifyPurchase:purchase completionHandler:^(ADJPurchaseVerificationResult * _Nonnull verificationResult) {
        [self.testLibrary addInfoToSend:@"verification_status" value:verificationResult.verificationStatus];
        [self.testLibrary addInfoToSend:@"code" value:[NSString stringWithFormat:@"%d", verificationResult.code]];
        [self.testLibrary addInfoToSend:@"message" value:verificationResult.message];
        [self.testLibrary sendInfoToServer:self.extraPath];
    }];
}

- (void)processDeeplink:(NSDictionary *)parameters {
    NSString *deeplinkS = [parameters objectForKey:@"deeplink"][0];
    NSURL *deeplink = [NSURL URLWithString:deeplinkS];
    [Adjust processDeeplink:deeplink completionHandler:^(NSString * _Nonnull resolvedLink) {
        [self.testLibrary addInfoToSend:@"resolved_link" value:resolvedLink];
        [self.testLibrary sendInfoToServer:self.extraPath];
    }];
}

@end

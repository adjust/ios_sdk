//
//  AdjustBridge.m
//  Adjust SDK
//
//  Created by Pedro Filipe (@nonelse) on 27th April 2016.
//  Copyright © 2016-2018 Adjust GmbH. All rights reserved.
//

#import "Adjust.h"
// In case of erroneous import statement try with:
// #import <AdjustSdk/Adjust.h>
// (depends how you import the Adjust SDK to your app)

#import "AdjustBridge.h"
#import "ADJAdjustFactory.h"
#import "WKWebViewJavascriptBridge.h"

@interface AdjustBridge() <AdjustDelegate>

@property BOOL openDeferredDeeplink;
@property (nonatomic, copy) NSString *fbPixelDefaultEventToken;
@property (nonatomic, copy) NSString *attributionCallbackName;
@property (nonatomic, copy) NSString *eventSuccessCallbackName;
@property (nonatomic, copy) NSString *eventFailureCallbackName;
@property (nonatomic, copy) NSString *sessionSuccessCallbackName;
@property (nonatomic, copy) NSString *sessionFailureCallbackName;
@property (nonatomic, copy) NSString *deferredDeeplinkCallbackName;
@property (nonatomic, strong) NSMutableDictionary *fbPixelMapping;
@property (nonatomic, strong) ADJAttribution *attribution;

@end

@interface ADJAttributionGetter : NSObject<ADJAdjustAttributionCallback>

@property (nonatomic, strong) WVJBResponseCallback callback;

@end

@implementation AdjustBridge

#pragma mark - Object lifecycle

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _bridgeRegister = nil;
    [self resetAdjustBridge];
    return self;
}

- (void)resetAdjustBridge {
    self.attributionCallbackName = nil;
    self.eventSuccessCallbackName = nil;
    self.eventFailureCallbackName = nil;
    self.sessionSuccessCallbackName = nil;
    self.sessionFailureCallbackName = nil;
    self.deferredDeeplinkCallbackName = nil;
}

#pragma mark - AdjustDelegate methods

- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    if (self.attributionCallbackName == nil) {
        return;
    }
    [self.bridgeRegister callHandler:self.attributionCallbackName data:[attribution dictionary]];
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    if (self.eventSuccessCallbackName == nil) {
        return;
    }

    NSMutableDictionary *eventSuccessResponseDataDictionary = [NSMutableDictionary dictionary];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.message forKey:@"message"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.timeStamp forKey:@"timestamp"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.adid forKey:@"adid"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.eventToken forKey:@"eventToken"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.callbackId forKey:@"callbackId"];

    NSString *jsonResponse = [self convertJsonDictionaryToNSString:eventSuccessResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [eventSuccessResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self.bridgeRegister callHandler:self.eventSuccessCallbackName data:eventSuccessResponseDataDictionary];
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    if (self.eventFailureCallbackName == nil) {
        return;
    }

    NSMutableDictionary *eventFailureResponseDataDictionary = [NSMutableDictionary dictionary];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.message forKey:@"message"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.timeStamp forKey:@"timestamp"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.adid forKey:@"adid"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.eventToken forKey:@"eventToken"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.callbackId forKey:@"callbackId"];
    [eventFailureResponseDataDictionary setValue:[NSNumber numberWithBool:eventFailureResponseData.willRetry] forKey:@"willRetry"];

    NSString *jsonResponse = [self convertJsonDictionaryToNSString:eventFailureResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [eventFailureResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self.bridgeRegister callHandler:self.eventFailureCallbackName data:eventFailureResponseDataDictionary];
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    if (self.sessionSuccessCallbackName == nil) {
        return;
    }

    NSMutableDictionary *sessionSuccessResponseDataDictionary = [NSMutableDictionary dictionary];
    [sessionSuccessResponseDataDictionary setValue:sessionSuccessResponseData.message forKey:@"message"];
    [sessionSuccessResponseDataDictionary setValue:sessionSuccessResponseData.timeStamp forKey:@"timestamp"];
    [sessionSuccessResponseDataDictionary setValue:sessionSuccessResponseData.adid forKey:@"adid"];

    NSString *jsonResponse = [self convertJsonDictionaryToNSString:sessionSuccessResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [sessionSuccessResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self.bridgeRegister callHandler:self.sessionSuccessCallbackName data:sessionSuccessResponseDataDictionary];
}

- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    if (self.sessionFailureCallbackName == nil) {
        return;
    }

    NSMutableDictionary *sessionFailureResponseDataDictionary = [NSMutableDictionary dictionary];
    [sessionFailureResponseDataDictionary setValue:sessionFailureResponseData.message forKey:@"message"];
    [sessionFailureResponseDataDictionary setValue:sessionFailureResponseData.timeStamp forKey:@"timestamp"];
    [sessionFailureResponseDataDictionary setValue:sessionFailureResponseData.adid forKey:@"adid"];
    [sessionFailureResponseDataDictionary setValue:[NSNumber numberWithBool:sessionFailureResponseData.willRetry] forKey:@"willRetry"];

    NSString *jsonResponse = [self convertJsonDictionaryToNSString:sessionFailureResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [sessionFailureResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self.bridgeRegister callHandler:self.sessionFailureCallbackName data:sessionFailureResponseDataDictionary];
}

- (BOOL)adjustDeeplinkResponse:(NSURL *)deeplink {
    if (self.deferredDeeplinkCallbackName) {
        [self.bridgeRegister callHandler:self.deferredDeeplinkCallbackName data:[deeplink absoluteString]];
    }
    return self.openDeferredDeeplink;
}

#pragma mark - Public methods

- (void)augmentHybridWebView {
    NSString *fbAppId = [self getFbAppId];

    if (fbAppId == nil) {
        [[ADJAdjustFactory logger] error:@"FacebookAppID is not correctly configured in the pList"];
        return;
    }
    [_bridgeRegister augmentHybridWebView:fbAppId];
    [self registerAugmentedView];
}

- (void)loadWKWebViewBridge:(WKWebView *)wkWebView {
    [self loadWKWebViewBridge:wkWebView wkWebViewDelegate:nil];
}

- (void)loadWKWebViewBridge:(WKWebView *)wkWebView
          wkWebViewDelegate:(id<WKNavigationDelegate>)wkWebViewDelegate {
    if (self.bridgeRegister != nil) {
        // WebViewBridge already loaded.
        return;
    }

    _bridgeRegister = [[AdjustBridgeRegister alloc] initWithWKWebView:wkWebView];
    [self.bridgeRegister setWKWebViewDelegate:wkWebViewDelegate];

    [self.bridgeRegister registerHandler:@"adjust_appDidLaunch" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *appToken = [data objectForKey:@"appToken"];
        NSString *environment = [data objectForKey:@"environment"];
        NSString *allowSuppressLogLevel = [data objectForKey:@"allowSuppressLogLevel"];
        NSString *sdkPrefix = [data objectForKey:@"sdkPrefix"];
        NSString *defaultTracker = [data objectForKey:@"defaultTracker"];
        NSString *externalDeviceId = [data objectForKey:@"externalDeviceId"];
        NSString *logLevel = [data objectForKey:@"logLevel"];
        NSNumber *coppaCompliantEnabled = [data objectForKey:@"coppaCompliantEnabled"];
        NSNumber *sendInBackground = [data objectForKey:@"sendInBackground"];
        NSNumber *delayStart = [data objectForKey:@"delayStart"];
        NSNumber *needsCost = [data objectForKey:@"needsCost"];
        NSNumber *allowAdServicesInfoReading = [data objectForKey:@"allowAdServicesInfoReading"];
        NSNumber *isIdfaReadingAllowed = [data objectForKey:@"isIdfaReadingAllowed"];
        NSNumber *isSkanAttributionHandlingEnabled = [data objectForKey:@"isSkanAttributionHandlingEnabled"];
        NSNumber *openDeferredDeeplink = [data objectForKey:@"openDeferredDeeplink"];
        NSString *fbPixelDefaultEventToken = [data objectForKey:@"fbPixelDefaultEventToken"];
        id fbPixelMapping = [data objectForKey:@"fbPixelMapping"];
        NSString *attributionCallback = [data objectForKey:@"attributionCallback"];
        NSString *eventSuccessCallback = [data objectForKey:@"eventSuccessCallback"];
        NSString *eventFailureCallback = [data objectForKey:@"eventFailureCallback"];
        NSString *sessionSuccessCallback = [data objectForKey:@"sessionSuccessCallback"];
        NSString *sessionFailureCallback = [data objectForKey:@"sessionFailureCallback"];
        NSString *deferredDeeplinkCallback = [data objectForKey:@"deferredDeeplinkCallback"];
        NSString *urlStrategy = [data objectForKey:@"urlStrategy"];
        NSNumber *readDeviceInfoOnceEnabled = [data objectForKey:@"readDeviceInfoOnceEnabled"];
        NSNumber *attConsentWaitingSeconds = [data objectForKey:@"attConsentWaitingSeconds"];
        NSNumber *eventDeduplicationIdsMaxSize = [data objectForKey:@"eventDeduplicationIdsMaxSize"];

        ADJConfig *adjustConfig;
        if ([self isFieldValid:allowSuppressLogLevel]) {
            adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment allowSuppressLogLevel:[allowSuppressLogLevel boolValue]];
        } else {
            adjustConfig = [ADJConfig configWithAppToken:appToken environment:environment];
        }

        // No need to continue if adjust config is not valid.
        if (![adjustConfig isValid]) {
            return;
        }

        if ([self isFieldValid:sdkPrefix]) {
            [adjustConfig setSdkPrefix:sdkPrefix];
        }
        if ([self isFieldValid:defaultTracker]) {
            [adjustConfig setDefaultTracker:defaultTracker];
        }
        if ([self isFieldValid:externalDeviceId]) {
            [adjustConfig setExternalDeviceId:externalDeviceId];
        }
        if ([self isFieldValid:logLevel]) {
            [adjustConfig setLogLevel:[ADJLogger logLevelFromString:[logLevel lowercaseString]]];
        }
        if ([self isFieldValid:coppaCompliantEnabled]) {
            [adjustConfig setCoppaCompliantEnabled:[coppaCompliantEnabled boolValue]];
        }
        if ([self isFieldValid:sendInBackground]) {
            [adjustConfig setSendInBackground:[sendInBackground boolValue]];
        }
        if ([self isFieldValid:delayStart]) {
            [adjustConfig setDelayStart:[delayStart doubleValue]];
        }
        if ([self isFieldValid:needsCost]) {
            [adjustConfig setNeedsCost:[needsCost boolValue]];
        }
        if ([self isFieldValid:allowAdServicesInfoReading]) {
            [adjustConfig setAllowAdServicesInfoReading:[allowAdServicesInfoReading boolValue]];
        }
        if ([self isFieldValid:isIdfaReadingAllowed]) {
            if ([isIdfaReadingAllowed boolValue] == NO) {
                [adjustConfig disableIdfaReading];
            }
        }
        if ([self isFieldValid:attConsentWaitingSeconds]) {
            [adjustConfig setAttConsentWaitingInterval:[attConsentWaitingSeconds doubleValue]];
        }
        if ([self isFieldValid:isSkanAttributionHandlingEnabled]) {
            if ([isSkanAttributionHandlingEnabled boolValue] == NO) {
                [adjustConfig disableSkanAttributionHandling];
            }
        }
        if ([self isFieldValid:openDeferredDeeplink]) {
            self.openDeferredDeeplink = [openDeferredDeeplink boolValue];
        }
        if ([self isFieldValid:fbPixelDefaultEventToken]) {
            self.fbPixelDefaultEventToken = fbPixelDefaultEventToken;
        }
        if ([fbPixelMapping count] > 0) {
            self.fbPixelMapping = [[NSMutableDictionary alloc] initWithCapacity:[fbPixelMapping count] / 2];
        }
        for (int i = 0; i < [fbPixelMapping count]; i += 2) {
            NSString *key = [[fbPixelMapping objectAtIndex:i] description];
            NSString *value = [[fbPixelMapping objectAtIndex:(i + 1)] description];
            [self.fbPixelMapping setObject:value forKey:key];
        }
        if ([self isFieldValid:attributionCallback]) {
            self.attributionCallbackName = attributionCallback;
        }
        if ([self isFieldValid:eventSuccessCallback]) {
            self.eventSuccessCallbackName = eventSuccessCallback;
        }
        if ([self isFieldValid:eventFailureCallback]) {
            self.eventFailureCallbackName = eventFailureCallback;
        }
        if ([self isFieldValid:sessionSuccessCallback]) {
            self.sessionSuccessCallbackName = sessionSuccessCallback;
        }
        if ([self isFieldValid:sessionFailureCallback]) {
            self.sessionFailureCallbackName = sessionFailureCallback;
        }
        if ([self isFieldValid:deferredDeeplinkCallback]) {
            self.deferredDeeplinkCallbackName = deferredDeeplinkCallback;
        }

        // Set self as delegate if any callback is configured.
        // Change to swizzle the methods in the future.
        if (self.attributionCallbackName != nil
            || self.eventSuccessCallbackName != nil
            || self.eventFailureCallbackName != nil
            || self.sessionSuccessCallbackName != nil
            || self.sessionFailureCallbackName != nil
            || self.deferredDeeplinkCallbackName != nil) {
            [adjustConfig setDelegate:self];
        }
        if ([self isFieldValid:urlStrategy]) {
            [adjustConfig setUrlStrategy:urlStrategy];
        }
        if ([self isFieldValid:readDeviceInfoOnceEnabled]) {
            [adjustConfig setReadDeviceInfoOnceEnabled:[readDeviceInfoOnceEnabled boolValue]];
        }
        if ([self isFieldValid:eventDeduplicationIdsMaxSize]) {
            [adjustConfig setEventDeduplicationIdsMaxSize:[eventDeduplicationIdsMaxSize integerValue]];
        }

        [Adjust appDidLaunch:adjustConfig];
        [Adjust trackSubsessionStart];
    }];

    [self.bridgeRegister registerHandler:@"adjust_trackEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *eventToken = [data objectForKey:@"eventToken"];
        NSString *revenue = [data objectForKey:@"revenue"];
        NSString *currency = [data objectForKey:@"currency"];
        NSString *transactionId = [data objectForKey:@"transactionId"];
        NSString *deduplicationId = [data objectForKey:@"deduplicationId"];
        id callbackParameters = [data objectForKey:@"callbackParameters"];
        id partnerParameters = [data objectForKey:@"partnerParameters"];
        NSString *callbackId = [data objectForKey:@"callbackId"];

        ADJEvent *adjustEvent = [ADJEvent eventWithEventToken:eventToken];
        // No need to continue if adjust event is not valid
        if (![adjustEvent isValid]) {
            return;
        }

        if ([self isFieldValid:revenue] && [self isFieldValid:currency]) {
            double revenueValue = [revenue doubleValue];
            [adjustEvent setRevenue:revenueValue currency:currency];
        }
        if ([self isFieldValid:transactionId]) {
            [adjustEvent setTransactionId:transactionId];
        }
        if ([self isFieldValid:deduplicationId]) {
            [adjustEvent setDeduplicationId:deduplicationId];
        }
        for (int i = 0; i < [callbackParameters count]; i += 2) {
            NSString *key = [[callbackParameters objectAtIndex:i] description];
            NSString *value = [[callbackParameters objectAtIndex:(i + 1)] description];
            [adjustEvent addCallbackParameter:key value:value];
        }
        for (int i = 0; i < [partnerParameters count]; i += 2) {
            NSString *key = [[partnerParameters objectAtIndex:i] description];
            NSString *value = [[partnerParameters objectAtIndex:(i + 1)] description];
            [adjustEvent addPartnerParameter:key value:value];
        }
        if ([self isFieldValid:callbackId]) {
            [adjustEvent setCallbackId:callbackId];
        }

        [Adjust trackEvent:adjustEvent];
    }];

    [self.bridgeRegister registerHandler:@"adjust_trackSubsessionStart" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust trackSubsessionStart];
    }];

    [self.bridgeRegister registerHandler:@"adjust_trackSubsessionEnd" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust trackSubsessionEnd];
    }];

    [self.bridgeRegister registerHandler:@"adjust_setEnabled" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSNumber class]]) {
            return;
        }
        [Adjust setEnabled:[(NSNumber *)data boolValue]];
    }];

    [self.bridgeRegister registerHandler:@"adjust_isEnabled" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        responseCallback([NSNumber numberWithBool:[Adjust isEnabled]]);
    }];

    [self.bridgeRegister registerHandler:@"adjust_appWillOpenUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust appWillOpenUrl:[NSURL URLWithString:data]];
    }];

    [self.bridgeRegister registerHandler:@"adjust_setDeviceToken" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSString class]]) {
            return;
        }
        [Adjust setPushToken:(NSString *)data];
    }];

    [self.bridgeRegister registerHandler:@"adjust_setOfflineMode" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSNumber class]]) {
            return;
        }
        [Adjust setOfflineMode:[(NSNumber *)data boolValue]];
    }];

    [self.bridgeRegister registerHandler:@"adjust_sdkVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        NSString *sdkPrefix = (NSString *)data;
        NSString *sdkVersion = [NSString stringWithFormat:@"%@@%@", sdkPrefix, [Adjust sdkVersion]];
        responseCallback(sdkVersion);
    }];

    [self.bridgeRegister registerHandler:@"adjust_idfa" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        responseCallback([Adjust idfa]);
    }];

    [self.bridgeRegister registerHandler:@"adjust_idfv" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        responseCallback([Adjust idfv]);
    }];

    [self.bridgeRegister registerHandler:@"adjust_requestAppTrackingAuthorizationWithCompletionHandler" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        
        [Adjust requestAppTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
            responseCallback([NSNumber numberWithUnsignedInteger:status]);
        }];
    }];

    [self.bridgeRegister registerHandler:@"adjust_appTrackingAuthorizationStatus" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        responseCallback([NSNumber numberWithInt:[Adjust appTrackingAuthorizationStatus]]);
    }];

    [self.bridgeRegister registerHandler:@"adjust_updateSkanConversionValueCoarseValueLockWindowCompletionHandler"
                                 handler:^(id data, WVJBResponseCallback responseCallback) {
        NSNumber *conversionValue = [data objectForKey:@"conversionValue"];
        NSString *coarseValue = [data objectForKey:@"coarseValue"];
        NSNumber *lockWindow = [data objectForKey:@"lockWindow"];
        [Adjust updateSkanConversionValue:[conversionValue integerValue]
                              coarseValue:coarseValue
                               lockWindow:lockWindow
                        completionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                responseCallback([NSString stringWithFormat:@"%@", error]);
            }
        }];
    }];

    [self.bridgeRegister registerHandler:@"adjust_adid" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        responseCallback([Adjust adid]);
    }];

    [self.bridgeRegister registerHandler:@"adjust_attribution" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }

        ADJAttributionGetter * _Nonnull attributionGetter = [[ADJAttributionGetter alloc] init];
        attributionGetter.callback = responseCallback;
        [Adjust attributionWithCallback:attributionGetter];
    }];

    [self.bridgeRegister registerHandler:@"adjust_sendFirstPackages" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust sendFirstPackages];
    }];

    [self.bridgeRegister registerHandler:@"adjust_addGlobalCallbackParameter" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *key = [data objectForKey:@"key"];
        NSString *value = [data objectForKey:@"value"];
        [Adjust addGlobalCallbackParameter:value forKey:key];
    }];

    [self.bridgeRegister registerHandler:@"adjust_addGlobalPartnerParameter" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *key = [data objectForKey:@"key"];
        NSString *value = [data objectForKey:@"value"];
        [Adjust addGlobalPartnerParameter:value forKey:key];
    }];

    [self.bridgeRegister registerHandler:@"adjust_removeGlobalCallbackParameter" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSString class]]) {
            return;
        }
        [Adjust removeGlobalCallbackParameterForKey:(NSString *)data];
    }];

    [self.bridgeRegister registerHandler:@"adjust_removeGlobalPartnerParameter" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSString class]]) {
            return;
        }
        [Adjust removeGlobalPartnerParameterForKey:(NSString *)data];
    }];

    [self.bridgeRegister registerHandler:@"adjust_removeGlobalCallbackParameters" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust removeGlobalCallbackParameters];
    }];

    [self.bridgeRegister registerHandler:@"adjust_removeGlobalPartnerParameters" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust removeGlobalPartnerParameters];
    }];

    [self.bridgeRegister registerHandler:@"adjust_gdprForgetMe" handler:^(id data, WVJBResponseCallback responseCallback) {
        [Adjust gdprForgetMe];
    }];

    [self.bridgeRegister registerHandler:@"adjust_trackThirdPartySharing" handler:^(id data, WVJBResponseCallback responseCallback) {
        id isEnabledO = [data objectForKey:@"isEnabled"];
        id granularOptions = [data objectForKey:@"granularOptions"];
        id partnerSharingSettings = [data objectForKey:@"partnerSharingSettings"];

        NSNumber *isEnabled = nil;
        if ([isEnabledO isKindOfClass:[NSNumber class]]) {
            isEnabled = (NSNumber *)isEnabledO;
        }
        ADJThirdPartySharing *adjustThirdPartySharing =
        [[ADJThirdPartySharing alloc] initWithIsEnabledNumberBool:isEnabled];
        for (int i = 0; i < [granularOptions count]; i += 3) {
            NSString *partnerName = [[granularOptions objectAtIndex:i] description];
            NSString *key = [[granularOptions objectAtIndex:(i + 1)] description];
            NSString *value = [[granularOptions objectAtIndex:(i + 2)] description];
            [adjustThirdPartySharing addGranularOption:partnerName key:key value:value];
        }
        for (int i = 0; i < [partnerSharingSettings count]; i += 3) {
            NSString *partnerName = [[partnerSharingSettings objectAtIndex:i] description];
            NSString *key = [[partnerSharingSettings objectAtIndex:(i + 1)] description];
            BOOL value = [[partnerSharingSettings objectAtIndex:(i + 2)] boolValue];
            [adjustThirdPartySharing addPartnerSharingSetting:partnerName key:key value:value];
        }

        [Adjust trackThirdPartySharing:adjustThirdPartySharing];
    }];

    [self.bridgeRegister registerHandler:@"adjust_trackMeasurementConsent" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (![data isKindOfClass:[NSNumber class]]) {
            return;
        }
        [Adjust trackMeasurementConsent:[(NSNumber *)data boolValue]];
    }];

    [self.bridgeRegister registerHandler:@"adjust_lastDeeplink" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (responseCallback == nil) {
            return;
        }
        NSURL *lastDeeplink = [Adjust lastDeeplink];
        responseCallback(lastDeeplink != nil ? [lastDeeplink absoluteString] : nil);
    }];

    [self.bridgeRegister registerHandler:@"adjust_setTestOptions" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *urlOverwrite = [data objectForKey:@"urlOverwrite"];
        NSString *extraPath = [data objectForKey:@"extraPath"];
        NSNumber *timerIntervalInMilliseconds = [data objectForKey:@"timerIntervalInMilliseconds"];
        NSNumber *timerStartInMilliseconds = [data objectForKey:@"timerStartInMilliseconds"];
        NSNumber *sessionIntervalInMilliseconds = [data objectForKey:@"sessionIntervalInMilliseconds"];
        NSNumber *subsessionIntervalInMilliseconds = [data objectForKey:@"subsessionIntervalInMilliseconds"];
        NSNumber *teardown = [data objectForKey:@"teardown"];
        NSNumber *deleteState = [data objectForKey:@"deleteState"];
        NSNumber *noBackoffWait = [data objectForKey:@"noBackoffWait"];
        NSNumber *adServicesFrameworkEnabled = [data objectForKey:@"adServicesFrameworkEnabled"];
        NSNumber *attStatus = [data objectForKey:@"attStatus"];
        NSString *idfa = [data objectForKey:@"idfa"];

        AdjustTestOptions *testOptions = [[AdjustTestOptions alloc] init];

        if ([self isFieldValid:urlOverwrite]) {
            testOptions.urlOverwrite = urlOverwrite;
        }
        if ([self isFieldValid:extraPath]) {
            testOptions.extraPath = extraPath;
        }
        if ([self isFieldValid:timerIntervalInMilliseconds]) {
            testOptions.timerIntervalInMilliseconds = timerIntervalInMilliseconds;
        }
        if ([self isFieldValid:timerStartInMilliseconds]) {
            testOptions.timerStartInMilliseconds = timerStartInMilliseconds;
        }
        if ([self isFieldValid:sessionIntervalInMilliseconds]) {
            testOptions.sessionIntervalInMilliseconds = sessionIntervalInMilliseconds;
        }
        if ([self isFieldValid:subsessionIntervalInMilliseconds]) {
            testOptions.subsessionIntervalInMilliseconds = subsessionIntervalInMilliseconds;
        }
        if ([self isFieldValid:attStatus]) {
            testOptions.attStatusInt = attStatus;
        }
        if ([self isFieldValid:idfa]) {
            testOptions.idfa = idfa;
        }
        if ([self isFieldValid:teardown]) {
            testOptions.teardown = [teardown boolValue];
            if (testOptions.teardown) {
                [self resetAdjustBridge];
            }
        }
        if ([self isFieldValid:deleteState]) {
            testOptions.deleteState = [deleteState boolValue];
        }
        if ([self isFieldValid:noBackoffWait]) {
            testOptions.noBackoffWait = [noBackoffWait boolValue];
        }
        if ([self isFieldValid:adServicesFrameworkEnabled]) {
            testOptions.adServicesFrameworkEnabled = [adServicesFrameworkEnabled boolValue];
        }

        [Adjust setTestOptions:testOptions];
    }];

}

- (void)registerAugmentedView {
    [self.bridgeRegister registerHandler:@"adjust_fbPixelEvent" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSString *pixelID = [data objectForKey:@"pixelID"];
        if (pixelID == nil) {
            [[ADJAdjustFactory logger] error:@"Can't bridge an event without a referral Pixel ID. Check your webview Pixel configuration"];
            return;
        }
        NSString *evtName = [data objectForKey:@"evtName"];
        NSString *eventToken = [self getEventTokenFromFbPixelEventName:evtName];
        if (eventToken == nil) {
            [[ADJAdjustFactory logger] debug:@"No mapping found for the fb pixel event %@, trying to fall back to the default event token", evtName];
            eventToken = self.fbPixelDefaultEventToken;
        }
        if (eventToken == nil) {
            [[ADJAdjustFactory logger] debug:@"There is not a default event token configured or a mapping found for event named: '%@'. It won't be tracked as an adjust event", evtName];
            return;
        }

        ADJEvent *fbPixelEvent = [ADJEvent eventWithEventToken:eventToken];
        if (![fbPixelEvent isValid]) {
            return;
        }

        id customData = [data objectForKey:@"customData"];
        [fbPixelEvent addPartnerParameter:@"_fb_pixel_referral_id" value:pixelID];
        // [fbPixelEvent addPartnerParameter:@"_eventName" value:evtName];
        if ([customData isKindOfClass:[NSString class]]) {
            NSError *jsonParseError = nil;
            NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[customData dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&jsonParseError];
            [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString *keyS = [key description];
                NSString *valueS = [obj description];
                [fbPixelEvent addPartnerParameter:keyS value:valueS];
            }];
        }
        [Adjust trackEvent:fbPixelEvent];
    }];
}

#pragma mark - Private & helper methods

- (BOOL)isFieldValid:(NSObject *)field {
    if (field == nil) {
        return NO;
    }
    if ([field isKindOfClass:[NSNull class]]) {
        return NO;
    }
    if ([[field description] length] == 0) {
        return NO;
    }
    return !!field;
}

- (NSString *)getFbAppId {
    NSString *facebookLoggingOverrideAppID = [self getValueFromBundleByKey:@"FacebookLoggingOverrideAppID"];
    if (facebookLoggingOverrideAppID != nil) {
        return facebookLoggingOverrideAppID;
    }

    return [self getValueFromBundleByKey:@"FacebookAppID"];
}

- (NSString *)getValueFromBundleByKey:(NSString *)key {
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:key] copy];
}

- (NSString *)getEventTokenFromFbPixelEventName:(NSString *)fbPixelEventName {
    if (self.fbPixelMapping == nil) {
        return nil;
    }

    return [self.fbPixelMapping objectForKey:fbPixelEventName];
}

- (NSString *)convertJsonDictionaryToNSString:(NSDictionary *)jsonDictionary {
    if (jsonDictionary == nil) {
        return nil;
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Unable to conver NSDictionary with JSON response to JSON string: %@", error);
        return nil;
    }

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSNumber *)fieldToNSNumber:(NSObject *)field {
    if (![self isFieldValid:field]) {
        return nil;
    }
    NSNumberFormatter *formatString = [[NSNumberFormatter alloc] init];
    return [formatString numberFromString:[field description]];
}

@end

#pragma mark - ADJAttributionCallback protocol

@implementation ADJAttributionGetter

- (void)didReadWithAdjustAttribution:(nonnull ADJAttribution *)attribution {
    NSDictionary *attributionDictionary = nil;
    if (attribution != nil) {
        attributionDictionary = [attribution dictionary];
    }

    self.callback(attributionDictionary);
}

@end

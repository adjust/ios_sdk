//
//  AdjustBridge.m
//  Adjust
//
//  Created by Pedro Filipe (@nonelse) on 27th April 2016.
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import "AdjustBridge.h"
#import "AdjustBridgeConstants.h"
#import "AdjustBridgeRegister.h"
#import "AdjustBridgeUtil.h"

#import <AdjustSdk/AdjustSdk.h>

@interface AdjustBridge() <WKScriptMessageHandler, AdjustDelegate>

@property BOOL isDeferredDeeplinkOpeningEnabled;
@property (nonatomic, copy) NSString *attributionCallbackName;
@property (nonatomic, copy) NSString *eventSuccessCallbackName;
@property (nonatomic, copy) NSString *eventFailureCallbackName;
@property (nonatomic, copy) NSString *sessionSuccessCallbackName;
@property (nonatomic, copy) NSString *sessionFailureCallbackName;
@property (nonatomic, copy) NSString *deferredDeeplinkCallbackName;
@property (nonatomic, copy) NSString *skanUpdatedCallbackName;
@property (nonatomic, copy) NSString *fbPixelDefaultEventToken;
@property (nonatomic, strong) NSMutableArray *urlStrategyDomains;
@property (nonatomic, strong) NSMutableDictionary *fbPixelMapping;
@property (nonatomic, strong) ADJLogger *logger;

@end

@implementation AdjustBridge

#pragma mark - Init WKWebView

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }
    self.isDeferredDeeplinkOpeningEnabled = YES;
    _logger = [[ADJLogger alloc] init];
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
    self.skanUpdatedCallbackName = nil;
}

#pragma mark - Public Methods

- (void)loadWKWebViewBridge:(WKWebView *_Nonnull)wkWebView {
    if ([wkWebView isKindOfClass:WKWebView.class]) {
        self.wkWebView = wkWebView;
        WKUserContentController *controller = wkWebView.configuration.userContentController;
        NSString *adjust_js = [AdjustBridgeRegister AdjustBridge_js];
        [controller addUserScript:[[WKUserScript.class alloc]
                                   initWithSource:adjust_js
                                   injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                   forMainFrameOnly:NO]];
        [controller addScriptMessageHandler:self name:@"adjust"];
    }
}

- (void)augmentHybridWebView {
    NSString *fbAppId = [self getFbAppId];
    if (fbAppId == nil) {
        [self.logger error:@"FacebookAppID is not correctly configured in the pList"];
        return;
    }
    [AdjustBridgeRegister augmentHybridWebView:fbAppId];
}

#pragma mark - WKWebView Delegate

- (void)userContentController:(nonnull WKUserContentController *)userContentController
      didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    if ([message.body isKindOfClass:[NSDictionary class]]) {
        [self handleMessageFromWebview:message.body];
    }
}

#pragma mark - Handling Message from WKwebview

- (void)handleMessageFromWebview:(NSDictionary<NSString *,id> *)message {
    NSString *methodName = [message objectForKey:ADJWBMethodNameKey];
    NSString *callbackId = [message objectForKey:ADJWBCallbackIdKey];
    id parameters = [message objectForKey:ADJWBParametersKey];

    if ([methodName isEqual:ADJWBInitSdkMethodName]) {
        [self initSdk:parameters];
    } else if ([methodName isEqual:ADJWBTrackEventMethodName]) {
        [self trackEvent:parameters];
    } else if ([methodName isEqual:ADJWBGetSdkVersionMethodName]) {
        __block NSString *_Nullable localSdkPrefix = [parameters objectForKey:@"sdkPrefix"];
        [Adjust sdkVersionWithCompletionHandler:^(NSString * _Nullable sdkVersion) {
            NSString *joinedSdkVersion = [NSString stringWithFormat:@"%@@%@", localSdkPrefix, sdkVersion];
            [self execJsCallbackWithId:callbackId callbackData:joinedSdkVersion];
        }];
    } else if ([methodName isEqual:ADJWBGetIdfaMethodName]) {
        [Adjust idfaWithCompletionHandler:^(NSString * _Nullable idfa) {
            [self execJsCallbackWithId:callbackId callbackData:idfa];
        }];
    }  else if ([methodName isEqual:ADJWBGetIdfvMethodName]) {
        [Adjust idfvWithCompletionHandler:^(NSString * _Nullable idfv) {
            [self execJsCallbackWithId:callbackId callbackData:idfv];
        }];
    } else if ([methodName isEqual:ADJWBGetAdidMethodName]) {
        [Adjust adidWithCompletionHandler:^(NSString * _Nullable adid) {
            [self execJsCallbackWithId:callbackId callbackData:adid];
        }];
    } else if ([methodName isEqual:ADJWBGetAttributionMethodName]) {
        [Adjust attributionWithCompletionHandler:^(ADJAttribution * _Nullable attribution) {
            [self execJsCallbackWithId:callbackId callbackData:[attribution dictionary]];
        }];
    } else if ([methodName isEqual:ADJWBIsEnabledMethodName]) {
        [Adjust isEnabledWithCompletionHandler:^(BOOL isEnabled) {
            [self execJsCallbackWithId:callbackId callbackData:@(isEnabled).description];
        }];
    } else if ([methodName isEqual:ADJWBRequestAppTrackingMethodName]) {
        [Adjust requestAppTrackingAuthorizationWithCompletionHandler:^(NSUInteger status) {
            [self execJsCallbackWithId:callbackId callbackData:@(status).description];
        }];
    } else if ([methodName isEqual:ADJWBAppTrackingAuthorizationStatus]) {
        int appTrackingAuthorizationStatus = [Adjust appTrackingAuthorizationStatus];
        [self execJsCallbackWithId:callbackId callbackData:@(appTrackingAuthorizationStatus).description];
    } else if ([methodName isEqual:ADJWBSwitchToOfflineModeMethodName]) {
        [Adjust switchToOfflineMode];
    } else if ([methodName isEqual:ADJWBSwitchBackToOnlineMode]) {
        [Adjust switchBackToOnlineMode];
    } else if ([methodName isEqual:ADJWBEnableMethodName]) {
        [Adjust enable];
    } else if ([methodName isEqual:ADJWBDisableMethodName]) {
        [Adjust disable];
    } else if ([methodName isEqual:ADJWBTrackSubsessionStartMethodName]) {
        [Adjust trackSubsessionStart];
    } else if ([methodName isEqual:ADJWBTrackSubsessionEndMethodName]) {
        [Adjust trackSubsessionEnd];
    } else if ([methodName isEqual:ADJWBTrackMeasurementConsentMethodName]) {
        if (![parameters isKindOfClass:[NSNumber class]]) {
            return;
        }
        [Adjust trackMeasurementConsent:[(NSNumber *)parameters boolValue]];
    } else if ([methodName isEqual:ADJWBAddGlobalCallbackParameterMethodName]) {
        NSString *key = [parameters objectForKey:ADJWBKvKeyKey];
        NSString *value = [parameters objectForKey:ADJWBKvValueKey];
        [Adjust addGlobalCallbackParameter:value forKey:key];
    } else if ([methodName isEqual:ADJWBRemoveGlobalCallbackParameterMethodName]) {
        NSString *key = [parameters objectForKey:ADJWBKvKeyKey];
        [Adjust removeGlobalCallbackParameterForKey:key];
    } else if ([methodName isEqual:ADJWBRemoveGlobalCallbackParametersMethodName]) {
        [Adjust removeGlobalCallbackParameters];
    } else if ([methodName isEqual:ADJWBAddGlobalPartnerParameterMethodName]) {
        NSString *key = [parameters objectForKey:ADJWBKvKeyKey];
        NSString *value = [parameters objectForKey:ADJWBKvValueKey];
        [Adjust addGlobalPartnerParameter:value forKey:key];
    } else if ([methodName isEqual:ADJWBRemoveGlobalPartnerParameterMethodName]) {
        NSString *key = [parameters objectForKey:ADJWBKvKeyKey];
        [Adjust removeGlobalPartnerParameterForKey:key];
    } else if ([methodName isEqual:ADJWBRemoveGlobalPartnerParametersMethodName]) {
        [Adjust removeGlobalPartnerParameters];
    } else if ([methodName isEqual:ADJWBGdprForgetMeMethodName]) {
        [Adjust gdprForgetMe];
    } else if ([methodName isEqual:ADJWBTrackThirdPartySharingMethodName]) {
        [self trackThirdPartySharing:parameters];
    } else if ([methodName isEqual:ADJWBEndFirstSessionDelayMethodName]) {
        [Adjust endFirstSessionDelay];
    } else if ([methodName isEqual:ADJWBEnableCoppaComplianceInDelayMethodName]) {
        [Adjust enableCoppaComplianceInDelay];
    } else if ([methodName isEqual:ADJWBDisableCoppaComplianceInDelayMethodName]) {
        [Adjust disableCoppaComplianceInDelay];
    } else if ([methodName isEqual:ADJWBSetExternalDeviceIdInDelayMethodName]) {
        NSString *externalDeviceId = [parameters objectForKey:@"externalDeviceId"];
        [Adjust setExternalDeviceIdInDelay:externalDeviceId];
    } else if ([methodName isEqual:ADJWBSetTestOptionsMethodName]) {
        [self setTestOptions:parameters];
    } else if ([methodName isEqual:ADJWBFBPixelEventMethodName]) {
        [self trackFbPixelEvent:parameters];
    }
}

- (void)initSdk:(id)parameters {
    NSString *appToken = [parameters objectForKey:ADJWBAppTokenConfigKey];
    NSString *environment = [parameters objectForKey:ADJWBEnvironmentConfigKey];
    NSString *allowSuppressLogLevel = [parameters objectForKey:ADJWBAllowSuppressLogLevelConfigKey];
    NSString *sdkPrefix = [parameters objectForKey:ADJWBSdkPrefixConfigKey];
    NSString *defaultTracker = [parameters objectForKey:ADJWBDefaultTrackerConfigKey];
    NSString *externalDeviceId = [parameters objectForKey:ADJWBExternalDeviceIdConfigKey];
    NSString *logLevel = [parameters objectForKey:ADJWBLogLevelConfigKey];
    NSNumber *sendInBackground = [parameters objectForKey:ADJWBSendInBackgroundConfigKey];
    NSNumber *isCostDataInAttributionEnabled = [parameters objectForKey:ADJWBNeedsCostConfigKey];
    NSNumber *isAdServicesEnabled = [parameters objectForKey:ADJWBAllowAdServicesInfoReadingConfigKey];
    NSNumber *isIdfaReadingAllowed = [parameters objectForKey:ADJWBIsIdfaReadingAllowedConfigKey];
    NSNumber *isSkanAttributionHandlingEnabled = [parameters objectForKey:ADJWBIsSkanAttributionHandlingEnabledConfigKey];
    NSNumber *isDeferredDeeplinkOpeningEnabled = [parameters objectForKey:ADJWBIsDeferredDeeplinkOpeningEnabledConfigKey];
    NSNumber *isCoppaComplianceEnabled = [parameters objectForKey:ADJWBIsCoppaComplianceEnabledConfigKey];
    NSNumber *shouldReadDeviceInfoOnce = [parameters objectForKey:ADJWBReadDeviceInfoOnceEnabledConfigKey];
    NSNumber *attConsentWaitingSeconds = [parameters objectForKey:ADJWBAttConsentWaitingSecondsConfigKey];
    NSNumber *eventDeduplicationIdsMaxSize = [parameters objectForKey:ADJWBEventDeduplicationIdsMaxSizeConfigKey];
    NSNumber *isAppTrackingTransparencyUsageEnabled = [parameters objectForKey:ADJWBIsAppTrackingTransparencyUsageEnabledConfigKey];
    NSNumber *isFirstSessionDelayEnabled = [parameters objectForKey:ADJWBIsFirstSessionDelayEnabledConfigKey];

    id urlStrategyDomains = [parameters objectForKey:ADJWBUseStrategyDomainsConfigKey];
    NSNumber *useSubdomains = [parameters objectForKey:ADJWBUseSubdomainsConfigKey];
    NSNumber *isDataResidency = [parameters objectForKey:ADJWBIsDataResidencyConfigKey];

    //Adjust's callbacks
    NSString *attributionCallback = [parameters objectForKey:ADJWBAttributionCallbackConfigKey];
    NSString *eventSuccessCallback = [parameters objectForKey:ADJWBEventSuccessCallbackConfigKey];
    NSString *eventFailureCallback = [parameters objectForKey:ADJWBEventFailureCallbackConfigKey];
    NSString *sessionSuccessCallback = [parameters objectForKey:ADJWBSessionSuccessCallbackConfigKey];
    NSString *sessionFailureCallback = [parameters objectForKey:ADJWBSessionFailureCallbackConfigKey];
    NSString *skanUpdatedCallback = [parameters objectForKey:ADJWBSkanUpdatedCallbackConfigKey];
    NSString *deferredDeeplinkCallback = [parameters objectForKey:ADJWBDeferredDeeplinkCallbackConfigKey];

    //Fb parameters
    NSString *fbPixelDefaultEventToken = [parameters objectForKey:ADJWBFbPixelDefaultEventTokenConfigKey];
    id fbPixelMapping = [parameters objectForKey:ADJWBFbPixelMappingConfigKey];

    ADJConfig *adjustConfig;
    if ([AdjustBridgeUtil isFieldValid:allowSuppressLogLevel]) {
        adjustConfig = [[ADJConfig alloc] initWithAppToken:appToken
                                               environment:environment
                                          suppressLogLevel:[allowSuppressLogLevel boolValue]];
    } else {
        adjustConfig = [[ADJConfig alloc] initWithAppToken:appToken environment:environment];
    }

    if ([AdjustBridgeUtil isFieldValid:sdkPrefix]) {
        [adjustConfig setSdkPrefix:sdkPrefix];
    }

    if ([AdjustBridgeUtil isFieldValid:defaultTracker]) {
        [adjustConfig setDefaultTracker:defaultTracker];
    }

    if ([AdjustBridgeUtil isFieldValid:externalDeviceId]) {
        [adjustConfig setExternalDeviceId:externalDeviceId];
    }

    if ([AdjustBridgeUtil isFieldValid:logLevel]) {
        [adjustConfig setLogLevel:[ADJLogger logLevelFromString:[logLevel lowercaseString]]];
    }

    if ([AdjustBridgeUtil isFieldValid:sendInBackground]) {
        if ([sendInBackground boolValue] == YES) {
            [adjustConfig enableSendingInBackground];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:isCostDataInAttributionEnabled]) {
        if ([isCostDataInAttributionEnabled boolValue] == YES) {
            [adjustConfig enableCostDataInAttribution];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:isAdServicesEnabled]) {
        if ([isAdServicesEnabled boolValue] == NO) {
            [adjustConfig disableAdServices];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:isCoppaComplianceEnabled]) {
        if ([isCoppaComplianceEnabled boolValue] == YES) {
            [adjustConfig enableCoppaCompliance];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:isDeferredDeeplinkOpeningEnabled]) {
        self.isDeferredDeeplinkOpeningEnabled = [isDeferredDeeplinkOpeningEnabled boolValue];
    }

    if ([AdjustBridgeUtil isFieldValid:isIdfaReadingAllowed]) {
        if ([isIdfaReadingAllowed boolValue] == NO) {
            [adjustConfig disableIdfaReading];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:attConsentWaitingSeconds]) {
        [adjustConfig setAttConsentWaitingInterval:[attConsentWaitingSeconds doubleValue]];
    }

    if ([AdjustBridgeUtil isFieldValid:isSkanAttributionHandlingEnabled]) {
        if ([isSkanAttributionHandlingEnabled boolValue] == NO) {
            [adjustConfig disableSkanAttribution];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:shouldReadDeviceInfoOnce]) {
        if ([shouldReadDeviceInfoOnce boolValue] == YES) {
            [adjustConfig enableDeviceIdsReadingOnce];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:eventDeduplicationIdsMaxSize]) {
        [adjustConfig setEventDeduplicationIdsMaxSize:[eventDeduplicationIdsMaxSize integerValue]];
    }

    // fb parameters handling
    if ([AdjustBridgeUtil isFieldValid:fbPixelDefaultEventToken]) {
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

    if ([AdjustBridgeUtil isFieldValid:isAppTrackingTransparencyUsageEnabled]) {
        if ([isAppTrackingTransparencyUsageEnabled boolValue] == NO) {
            [adjustConfig disableAppTrackingTransparencyUsage];
        }
    }
    
    if ([AdjustBridgeUtil isFieldValid:isFirstSessionDelayEnabled]) {
        if ([isFirstSessionDelayEnabled boolValue] == YES) {
            [adjustConfig enableFirstSessionDelay];
        }
    }

    if ([AdjustBridgeUtil isFieldValid:attributionCallback]) {
        self.attributionCallbackName = attributionCallback;
    }
    if ([AdjustBridgeUtil isFieldValid:eventSuccessCallback]) {
        self.eventSuccessCallbackName = eventSuccessCallback;
    }
    if ([AdjustBridgeUtil isFieldValid:eventFailureCallback]) {
        self.eventFailureCallbackName = eventFailureCallback;
    }
    if ([AdjustBridgeUtil isFieldValid:sessionSuccessCallback]) {
        self.sessionSuccessCallbackName = sessionSuccessCallback;
    }
    if ([AdjustBridgeUtil isFieldValid:sessionFailureCallback]) {
        self.sessionFailureCallbackName = sessionFailureCallback;
    }
    if ([AdjustBridgeUtil isFieldValid:deferredDeeplinkCallback]) {
        self.deferredDeeplinkCallbackName = deferredDeeplinkCallback;
    }
    if ([AdjustBridgeUtil isFieldValid:skanUpdatedCallback]) {
        self.skanUpdatedCallbackName = skanUpdatedCallback;
    }

    // set self as delegate if any callback is configured
    // change to swizzle the methods in the future
    if (self.attributionCallbackName != nil
        || self.eventSuccessCallbackName != nil
        || self.eventFailureCallbackName != nil
        || self.sessionSuccessCallbackName != nil
        || self.sessionFailureCallbackName != nil
        || self.deferredDeeplinkCallbackName != nil
        || self.skanUpdatedCallbackName != nil) {
        [adjustConfig setDelegate:self];
    }

    // URL strategy
    if (urlStrategyDomains != nil && [urlStrategyDomains count] > 0) {
        self.urlStrategyDomains = [[NSMutableArray alloc] initWithCapacity:[urlStrategyDomains count]];
        for (int i = 0; i < [urlStrategyDomains count]; i += 1) {
            NSString *domain = [[urlStrategyDomains objectAtIndex:i] description];
            [self.urlStrategyDomains addObject:domain];
        }
    }
    if ([AdjustBridgeUtil isFieldValid:useSubdomains] && [AdjustBridgeUtil isFieldValid:isDataResidency]) {
        [adjustConfig setUrlStrategy:(NSArray *)self.urlStrategyDomains
                       useSubdomains:[useSubdomains boolValue]
                     isDataResidency:[isDataResidency boolValue]];
    }

    [Adjust initSdk:adjustConfig];
}

- (void)trackEvent:(NSDictionary *)parameters {
    NSString *eventToken = [parameters objectForKey:ADJWBEventTokenEventKey];
    NSString *revenue = [parameters objectForKey:ADJWBRevenueEventKey];
    NSString *currency = [parameters objectForKey:ADJWBCurrencyEventKey];
    NSString *deduplicationId = [parameters objectForKey:ADJWBDeduplicationIdEventKey];
    NSString *callbackId = [parameters objectForKey:ADJWBCallbackIdEventKey];
    id callbackParameters = [parameters objectForKey:ADJWBCallbackParametersEventKey];
    id partnerParameters = [parameters objectForKey:ADJWBPartnerParametersEventKey];

    ADJEvent *_Nonnull adjEvent = [[ADJEvent alloc] initWithEventToken:eventToken];

    if ([AdjustBridgeUtil isFieldValid:callbackId]) {
        [adjEvent setCallbackId:callbackId];
    }

    if ([AdjustBridgeUtil isFieldValid:deduplicationId]) {
        [adjEvent setDeduplicationId:deduplicationId];
    }

    if ([AdjustBridgeUtil isFieldValid:revenue] && [AdjustBridgeUtil isFieldValid:currency]) {
        double revenueValue = [revenue doubleValue];
        [adjEvent setRevenue:revenueValue currency:currency];
    }

    for (int i = 0; i < [callbackParameters count]; i += 2) {
        NSString *key = [[callbackParameters objectAtIndex:i] description];
        NSString *value = [[callbackParameters objectAtIndex:(i + 1)] description];
        [adjEvent addCallbackParameter:key value:value];
    }

    for (int i = 0; i < [partnerParameters count]; i += 2) {
        NSString *key = [[partnerParameters objectAtIndex:i] description];
        NSString *value = [[partnerParameters objectAtIndex:(i + 1)] description];
        [adjEvent addPartnerParameter:key value:value];
    }

    [Adjust trackEvent:adjEvent];
}

- (void)trackThirdPartySharing:(NSDictionary *)parameters {
    id isEnabledO = [parameters objectForKey:ADJWBIsEnabledTPSKey];
    id granularOptions = [parameters objectForKey:ADJWBGranularOptionsTPSKey];
    id partnerSharingSettings = [parameters objectForKey:ADJWBPartnerSharingSettingTPSKey];

    NSNumber *isEnabled = nil;
    if ([isEnabledO isKindOfClass:[NSNumber class]]) {
        isEnabled = (NSNumber *)isEnabledO;
    }

    ADJThirdPartySharing *adjustThirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabled:isEnabled];

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
}

- (void)setTestOptions:(NSDictionary *)data {
    [Adjust setTestOptions:[AdjustBridgeUtil getTestOptions:data]];

    NSNumber *teardown = [data objectForKey:@"teardown"];
    if ([AdjustBridgeUtil isFieldValid:teardown] && [teardown boolValue] == YES) {
        [self resetAdjustBridge];
    }
}

#pragma mark - Native to Javascript Callback Handling

- (void)execJsCallbackWithId:(NSString *)callbackId callbackData:(id)data {
    NSString *callbackParamString;
    if ([data isKindOfClass:[NSMutableDictionary class]] || [data isKindOfClass:[NSDictionary class]]) {
        callbackParamString = [AdjustBridgeUtil serializeData:data];
    }

    if ([data isKindOfClass:[NSString class]]){
        callbackParamString = data;
    }

    NSString *jsExecCommand = [NSString stringWithFormat:@"%@('%@')", callbackId, callbackParamString];

    [AdjustBridgeUtil launchInMainThread:^{
        [self.wkWebView evaluateJavaScript:jsExecCommand completionHandler:nil];
    }];
}

#pragma mark - AdjustDelegate methods

- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    if (self.attributionCallbackName == nil) {
        return;
    }
    [self execJsCallbackWithId:self.attributionCallbackName
                  callbackData:[attribution dictionary]];
}

- (void)adjustEventTrackingSucceeded:(ADJEventSuccess *)eventSuccessResponseData {
    if (self.eventSuccessCallbackName == nil) {
        return;
    }

    NSMutableDictionary *eventSuccessResponseDataDictionary = [NSMutableDictionary dictionary];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.message
                                          forKey:@"message"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.timestamp
                                          forKey:@"timestamp"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.adid
                                          forKey:@"adid"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.eventToken
                                          forKey:@"eventToken"];
    [eventSuccessResponseDataDictionary setValue:eventSuccessResponseData.callbackId
                                          forKey:@"callbackId"];
    NSString *jsonResponse = [AdjustBridgeUtil
                              convertJsonDictionaryToNSString:eventSuccessResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [eventSuccessResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self execJsCallbackWithId:self.eventSuccessCallbackName
                  callbackData:eventSuccessResponseDataDictionary];
}

- (void)adjustEventTrackingFailed:(ADJEventFailure *)eventFailureResponseData {
    if (self.eventFailureCallbackName == nil) {
        return;
    }

    NSMutableDictionary *eventFailureResponseDataDictionary = [NSMutableDictionary dictionary];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.message
                                          forKey:@"message"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.timestamp
                                          forKey:@"timestamp"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.adid
                                          forKey:@"adid"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.eventToken
                                          forKey:@"eventToken"];
    [eventFailureResponseDataDictionary setValue:eventFailureResponseData.callbackId
                                          forKey:@"callbackId"];
    [eventFailureResponseDataDictionary setValue:[NSNumber numberWithBool:eventFailureResponseData.willRetry]
                                          forKey:@"willRetry"];
    NSString *jsonResponse = [AdjustBridgeUtil
                              convertJsonDictionaryToNSString:eventFailureResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [eventFailureResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self execJsCallbackWithId:self.eventFailureCallbackName
                  callbackData:eventFailureResponseDataDictionary];
}

- (void)adjustSessionTrackingSucceeded:(ADJSessionSuccess *)sessionSuccessResponseData {
    if (self.sessionSuccessCallbackName == nil) {
        return;
    }

    NSMutableDictionary *sessionSuccessResponseDataDictionary = [NSMutableDictionary dictionary];
    [sessionSuccessResponseDataDictionary setValue:sessionSuccessResponseData.message
                                            forKey:@"message"];
    [sessionSuccessResponseDataDictionary setValue:sessionSuccessResponseData.timestamp
                                            forKey:@"timestamp"];
    [sessionSuccessResponseDataDictionary setValue:sessionSuccessResponseData.adid
                                            forKey:@"adid"];
    NSString *jsonResponse = [AdjustBridgeUtil
                              convertJsonDictionaryToNSString:sessionSuccessResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [sessionSuccessResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self execJsCallbackWithId:self.sessionSuccessCallbackName
                  callbackData:sessionSuccessResponseDataDictionary];
}

- (void)adjustSessionTrackingFailed:(ADJSessionFailure *)sessionFailureResponseData {
    if (self.sessionFailureCallbackName == nil) {
        return;
    }

    NSMutableDictionary *sessionFailureResponseDataDictionary = [NSMutableDictionary dictionary];
    [sessionFailureResponseDataDictionary setValue:sessionFailureResponseData.message
                                            forKey:@"message"];
    [sessionFailureResponseDataDictionary setValue:sessionFailureResponseData.timestamp
                                            forKey:@"timestamp"];
    [sessionFailureResponseDataDictionary setValue:sessionFailureResponseData.adid
                                            forKey:@"adid"];
    [sessionFailureResponseDataDictionary setValue:[NSNumber numberWithBool:sessionFailureResponseData.willRetry]
                                            forKey:@"willRetry"];
    NSString *jsonResponse = [AdjustBridgeUtil
                              convertJsonDictionaryToNSString:sessionFailureResponseData.jsonResponse];
    if (jsonResponse == nil) {
        jsonResponse = @"{}";
    }
    [sessionFailureResponseDataDictionary setValue:jsonResponse forKey:@"jsonResponse"];

    [self execJsCallbackWithId:self.sessionFailureCallbackName
                  callbackData:sessionFailureResponseDataDictionary];
}

- (BOOL)adjustDeferredDeeplinkReceived:(NSURL *)deeplink {
    if (self.deferredDeeplinkCallbackName) {
        [self execJsCallbackWithId:self.deferredDeeplinkCallbackName
                      callbackData:[deeplink absoluteString]];
    }
    return self.isDeferredDeeplinkOpeningEnabled;
}

- (void)adjustSkanUpdatedWithConversionData:(nonnull NSDictionary<NSString *, NSString *> *)data {
    if (self.skanUpdatedCallbackName == nil) {
        return;
    }

    NSMutableDictionary *skanUpdatedDictionary = [NSMutableDictionary dictionary];
    [skanUpdatedDictionary setValue:data[@"conversion_value"] forKey:@"conversionValue"];
    [skanUpdatedDictionary setValue:data[@"coarse_value"] forKey:@"coarseValue"];
    [skanUpdatedDictionary setValue:data[@"lock_window"] forKey:@"lockWindow"];
    [skanUpdatedDictionary setValue:data[@"error"] forKey:@"error"];

    [self execJsCallbackWithId:self.skanUpdatedCallbackName
                  callbackData:skanUpdatedDictionary];
}

#pragma mark - FB Pixel event handling

- (void)trackFbPixelEvent:(id)data {
    NSString *pixelID = [data objectForKey:@"pixelID"];
    if (pixelID == nil) {
        [self.logger error:@"Can't bridge an event without a referral Pixel ID. Check your webview Pixel configuration"];
        return;
    }
    NSString *evtName = [data objectForKey:@"evtName"];
    NSString *eventToken = [self getEventTokenFromFbPixelEventName:evtName];
    if (eventToken == nil) {
        [self.logger debug:@"No mapping found for the fb pixel event %@, trying to fall back to the default event token", evtName];
        eventToken = self.fbPixelDefaultEventToken;
    }
    if (eventToken == nil) {
        [self.logger  debug:@"There is not a default event token configured or a mapping found for event named: '%@'. It won't be tracked as an adjust event", evtName];
        return;
    }

    ADJEvent *fbPixelEvent = [[ADJEvent alloc] initWithEventToken:eventToken];
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
}

- (NSString *)getEventTokenFromFbPixelEventName:(NSString *)fbPixelEventName {
    if (self.fbPixelMapping == nil) {
        return nil;
    }
    return [self.fbPixelMapping objectForKey:fbPixelEventName];
}

- (NSString *)getFbAppId {
    NSString *facebookLoggingOverrideAppID =
    [self getValueFromBundleByKey:@"FacebookLoggingOverrideAppID"];
    if (facebookLoggingOverrideAppID != nil) {
        return facebookLoggingOverrideAppID;
    }
    return [self getValueFromBundleByKey:@"FacebookAppID"];
}

- (NSString *)getValueFromBundleByKey:(NSString *)key {
    return [[[NSBundle mainBundle] objectForInfoDictionaryKey:key] copy];
}

@end

//
//  AdjustBridgeConstants.m
//  Adjust
//
//  Created by Aditi Agrawal on 16/05/24.
//  Copyright © 2024-Present Adjust GmbH. All rights reserved.
//

#import "AdjustBridgeConstants.h"

NSString * const ADJWBMethodNameKey = @"_methodName";
NSString * const ADJWBParametersKey = @"_parameters";
NSString * const ADJWBCallbackIdKey = @"_callbackId";

// AdjustWebbridge Public APIs method name
NSString * const ADJWBInitSdkMethodName = @"adjust_initSdk";
NSString * const ADJWBTrackEventMethodName = @"adjust_trackEvent";
NSString * const ADJWBTrackThirdPartySharingMethodName = @"adjust_trackThirdPartySharing";
NSString * const ADJWBTrackSubsessionStartMethodName = @"adjust_trackSubsessionStart";
NSString * const ADJWBTrackSubsessionEndMethodName = @"adjust_trackSubsessionEnd";
NSString * const ADJWBTrackMeasurementConsentMethodName = @"adjust_trackMeasurementConsent";
NSString * const ADJWBRequestAppTrackingMethodName = @"adjust_requestAppTrackingAuthorizationWithCompletionHandler";
NSString * const ADJWBFBPixelEventMethodName = @"adjust_fbPixelEvent";
NSString * const ADJWBSetTestOptionsMethodName = @"adjust_setTestOptions";

NSString * const ADJWBEnableMethodName = @"adjust_enable";
NSString * const ADJWBDisableMethodName = @"adjust_disable";
NSString * const ADJWBSwitchToOfflineModeMethodName = @"adjust_switchToOfflineMode";
NSString * const ADJWBSwitchBackToOnlineMode = @"adjust_switchBackToOnlineMode";
NSString * const ADJWBGdprForgetMeMethodName = @"adjust_gdprForgetMe";
NSString * const ADJWBEndFirstSessionDelayMethodName = @"adjust_endFirstSessionDelay";
NSString * const ADJWBEnableCoppaComplianceInDelayMethodName = @"adjust_enableCoppaComplianceInDelay";
NSString * const ADJWBDisableCoppaComplianceInDelayMethodName = @"adjust_disableCoppaComplianceInDelay";
NSString * const ADJWBSetExternalDeviceIdInDelayMethodName = @"adjust_setExternalDeviceIdInDelay";

// AdjustWebbridge Global Callback and Partner method name
NSString * const ADJWBAddGlobalCallbackParameterMethodName = @"adjust_addGlobalCallbackParameter";
NSString * const ADJWBRemoveGlobalCallbackParameterMethodName = @"adjust_removeGlobalCallbackParameter";
NSString * const ADJWBRemoveGlobalCallbackParametersMethodName = @"adjust_removeGlobalCallbackParameters";
NSString * const ADJWBAddGlobalPartnerParameterMethodName = @"adjust_addGlobalPartnerParameter";
NSString * const ADJWBRemoveGlobalPartnerParameterMethodName = @"adjust_removeGlobalPartnerParameter";
NSString * const ADJWBRemoveGlobalPartnerParametersMethodName = @"adjust_removeGlobalPartnerParameters";

// AdjustWebbridge Getter APIs method name
NSString * const ADJWBIsEnabledMethodName = @"adjust_isEnabled";
NSString * const ADJWBGetSdkVersionMethodName = @"adjust_getSdkVersion";
NSString * const ADJWBGetIdfaMethodName = @"adjust_getIdfa";
NSString * const ADJWBGetIdfvMethodName = @"adjust_getIdfv";
NSString * const ADJWBGetAdidMethodName = @"adjust_getAdid";
NSString * const ADJWBGetAttributionMethodName = @"adjust_getAttribution";
NSString * const ADJWBAppTrackingAuthorizationStatus = @"adjust_appTrackingAuthorizationStatus";

// AdjustWebbridge Config keys
NSString * const ADJWBAppTokenConfigKey = @"appToken";
NSString * const ADJWBEnvironmentConfigKey = @"environment";
NSString * const ADJWBAllowSuppressLogLevelConfigKey = @"allowSuppressLogLevel";
NSString * const ADJWBSdkPrefixConfigKey = @"sdkPrefix";
NSString * const ADJWBDefaultTrackerConfigKey = @"defaultTracker";
NSString * const ADJWBExternalDeviceIdConfigKey = @"externalDeviceId";
NSString * const ADJWBLogLevelConfigKey = @"logLevel";
NSString * const ADJWBSendInBackgroundConfigKey = @"sendInBackground";
NSString * const ADJWBNeedsCostConfigKey = @"isCostDataInAttributionEnabled";
NSString * const ADJWBAllowAdServicesInfoReadingConfigKey = @"isAdServicesEnabled";
NSString * const ADJWBIsIdfaReadingAllowedConfigKey = @"isIdfaReadingAllowed";
NSString * const ADJWBIsSkanAttributionHandlingEnabledConfigKey = @"isSkanAttributionHandlingEnabled";
NSString * const ADJWBIsDeferredDeeplinkOpeningEnabledConfigKey = @"isDeferredDeeplinkOpeningEnabled";
NSString * const ADJWBIsCoppaComplianceEnabledConfigKey = @"isCoppaComplianceEnabled";
NSString * const ADJWBReadDeviceInfoOnceEnabledConfigKey = @"shouldReadDeviceInfoOnce";
NSString * const ADJWBAttConsentWaitingSecondsConfigKey = @"attConsentWaitingSeconds";
NSString * const ADJWBEventDeduplicationIdsMaxSizeConfigKey = @"eventDeduplicationIdsMaxSize";
NSString * const ADJWBUseStrategyDomainsConfigKey = @"urlStrategyDomains";
NSString * const ADJWBUseSubdomainsConfigKey = @"useSubdomains";
NSString * const ADJWBIsDataResidencyConfigKey = @"isDataResidency";
NSString * const ADJWBFbPixelDefaultEventTokenConfigKey = @"fbPixelDefaultEventToken";
NSString * const ADJWBFbPixelMappingConfigKey = @"fbPixelMapping";
NSString * const ADJWBIsAppTrackingTransparencyUsageEnabledConfigKey = @"isAppTrackingTransparencyUsageEnabled";
NSString * const ADJWBIsFirstSessionDelayEnabledConfigKey = @"isFirstSessionDelayEnabled";

// AdjustWebbridge Callbacks method name
NSString * const ADJWBAttributionCallbackConfigKey = @"attributionCallback";
NSString * const ADJWBEventSuccessCallbackConfigKey = @"eventSuccessCallback";
NSString * const ADJWBEventFailureCallbackConfigKey = @"eventFailureCallback";
NSString * const ADJWBSessionSuccessCallbackConfigKey = @"sessionSuccessCallback";
NSString * const ADJWBSessionFailureCallbackConfigKey = @"sessionFailureCallback";
NSString * const ADJWBSkanUpdatedCallbackConfigKey = @"skanUpdatedCallback";
NSString * const ADJWBDeferredDeeplinkCallbackConfigKey = @"deferredDeeplinkCallback";

// AdjustWebbridge Track Event keys
NSString * const ADJWBEventTokenEventKey = @"eventToken";
NSString * const ADJWBRevenueEventKey = @"revenue";
NSString * const ADJWBCurrencyEventKey = @"currency";
NSString * const ADJWBCallbackIdEventKey = @"callbackId";
NSString * const ADJWBDeduplicationIdEventKey = @"deduplicationId";
NSString * const ADJWBCallbackParametersEventKey = @"callbackParameters";
NSString * const ADJWBPartnerParametersEventKey = @"partnerParameters";

// AdjustWebbridge TPS keys
NSString * const ADJWBIsEnabledTPSKey = @"isEnabled";
NSString * const ADJWBGranularOptionsTPSKey = @"granularOptions";
NSString * const ADJWBPartnerSharingSettingTPSKey = @"partnerSharingSettings";

NSString * const ADJWBKvKeyKey = @"_key";
NSString * const ADJWBKvValueKey = @"_value";

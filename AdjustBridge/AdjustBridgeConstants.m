//
//  AdjustBridgeConstants.m
//  Adjust
//
//  Created by Aditi Agrawal on 16/05/24.
//

#import "AdjustBridgeConstants.h"

NSString *const ADJWBMethodNameKey = @"_methodName";
NSString *const ADJWBParametersKey = @"_parameters";

NSString *const ADJWBInitSdkMethodName = @"adjust_initSdk";
NSString *const ADJWBTrackEventMethodName = @"adjust_trackEvent";
NSString *const ADJWBProcessDeeplinkMethodName = @"adjust_processDeeplink";
NSString *const ADJWBTrackThirdPartySharingMethodName = @"adjust_trackThirdPartySharing";

NSString *const ADJWBTrackSubsessionStartMethodName = @"adjust_trackSubsessionStart";
NSString *const ADJWBTrackSubsessionEndMethodName = @"adjust_trackSubsessionEnd";
NSString *const ADJWBTrackMeasurementConsentMethodName = @"adjust_trackMeasurementConsent";

NSString *const ADJWBEnableMethodName = @"adjust_enable";
NSString *const ADJWBDisableMethodName = @"adjust_disable";
NSString *const ADJWBSwitchToOfflineModeMethodName = @"adjust_switchToOfflineMode";
NSString *const ADJWBSwitchBackToOnlineMode = @"adjust_switchBackToOnlineMode";
NSString *const ADJWBEnableCoppaCompliance = @"adjust_enableCoppaCompliance";
NSString *const ADJWBDisableCoppaCompliance = @"adjust_disableCoppaCompliance";

NSString *const ADJWBSendFirstPackagesMethodName = @"adjust_sendFirstPackages";
NSString *const ADJWBGdprForgetMeMethodName = @"adjust_gdprForgetMe";

NSString *const ADJWBAddGlobalCallbackParameterMethodName = @"adjust_addGlobalCallbackParameter";
NSString *const ADJWBRemoveGlobalCallbackParameterForKeyMethodName = @"adjust_removeGlobalCallbackParameterForKey";
NSString *const ADJWBRemoveGlobalCallbackParametersMethodName = @"adjust_removeGlobalCallbackParameters";
NSString *const ADJWBAddGlobalPartnerParameterMethodName = @"adjust_addGlobalPartnerParameter";
NSString *const ADJWBRemoveGlobalPartnerParameterForKeyMethodName = @"adjust_removeGlobalPartnerParameterForKey";
NSString *const ADJWBRemoveGlobalPartnerParametersMethodName = @"adjust_removeGlobalPartnerParameters";

NSString *const ADJWBGetSdkVersionMethodName = @"adjust_getSdkVersion";
NSString *const ADJWBGetSdkVersionAsyncGetterCallbackKey = @"getSdkVersionCallback";

NSString *const ADJWBAppTokenConfigKey = @"appToken";
NSString *const ADJWBEnvironmentConfigKey = @"environment";
NSString *const ADJWBAllowSuppressLogLevelConfigKey = @"allowSuppressLogLevel";
NSString *const ADJWBSdkPrefixConfigKey = @"sdkPrefix";
NSString *const ADJWBDefaultTrackerConfigKey = @"defaultTracker";
NSString *const ADJWBExternalDeviceIdConfigKey = @"externalDeviceId";
NSString *const ADJWBLogLevelConfigKey = @"logLevel";
NSString *const ADJWBSendInBackgroundConfigKey = @"sendInBackground";
NSString *const ADJWBNeedsCostConfigKey = @"isCostDataInAttributionEnabled";
NSString *const ADJWBAllowAdServicesInfoReadingConfigKey = @"isAdServicesEnabled";
NSString *const ADJWBIsIdfaReadingAllowedConfigKey = @"isIdfaReadingAllowed";
NSString *const ADJWBIsSkanAttributionHandlingEnabledConfigKey = @"isSkanAttributionHandlingEnabled";
NSString *const ADJWBIsDeferredDeeplinkOpeningEnabledConfigKey = @"isDeferredDeeplinkOpeningEnabled";
NSString *const ADJWBReadDeviceInfoOnceEnabledConfigKey = @"shouldReadDeviceInfoOnce";
NSString *const ADJWBAttConsentWaitingSecondsConfigKey = @"attConsentWaitingSeconds";
NSString *const ADJWBEventDeduplicationIdsMaxSizeConfigKey = @"eventDeduplicationIdsMaxSize";

NSString *const ADJWBAttributionCallbackConfigKey = @"attributionCallback";
NSString *const ADJWBEventSuccessCallbackConfigKey = @"eventSuccessCallback";
NSString *const ADJWBEventFailureCallbackConfigKey = @"eventFailureCallback";
NSString *const ADJWBSessionSuccessCallbackConfigKey = @"sessionSuccessCallback";
NSString *const ADJWBSessionFailureCallbackConfigKey = @"sessionFailureCallback";
NSString *const ADJWBDeferredDeeplinkCallbackConfigKey = @"deferredDeeplinkCallback";

NSString *const ADJWBEventTokenEventKey = @"eventToken";
NSString *const ADJWBRevenueEventKey = @"revenue";
NSString *const ADJWBCurrencyEventKey = @"currency";
NSString *const ADJWBCallbackIdEventKey = @"callbackId";
NSString *const ADJWBTransactionIdEventKey = @"transactionId";
NSString *const ADJWBDeduplicationIdEventKey = @"deduplicationId";
NSString *const ADJWBCallbackParametersEventKey = @"callbackParameters";
NSString *const ADJWBPartnerParametersEventKey = @"partnerParameters";

NSString *const ADJWBIsEnabledTPSKey = @"isEnabled";
NSString *const ADJWBGranularOptionsTPSKey = @"granularOptions";
NSString *const ADJWBPartnerSharingSettingTPSKey = @"partnerSharingSettings";

NSString *const ADJWBCallbackParameterKeyValueArrayAdRevenueKey = @"callbackParameterKeyValueArray";
NSString *const ADJWBPartnerParameterKeyValueArrayAdRevenueKey = @"partnerParameterKeyValueArray";

NSString *const ADJWBKvKeyKey = @"_key";
NSString *const ADJWBKvValueKey = @"_value";


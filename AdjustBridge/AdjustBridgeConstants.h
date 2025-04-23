//
//  AdjustBridgeConstants.h
//  Adjust
//
//  Created by Aditi Agrawal on 16/05/24.
//  Copyright © 2024-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const ADJWBMethodNameKey;
FOUNDATION_EXPORT NSString * const ADJWBParametersKey;
FOUNDATION_EXPORT NSString * const ADJWBCallbackIdKey;

FOUNDATION_EXPORT NSString * const ADJWBInitSdkMethodName;
FOUNDATION_EXPORT NSString * const ADJWBTrackEventMethodName;
FOUNDATION_EXPORT NSString * const ADJWBTrackThirdPartySharingMethodName;
FOUNDATION_EXPORT NSString * const ADJWBTrackSubsessionStartMethodName;
FOUNDATION_EXPORT NSString * const ADJWBTrackSubsessionEndMethodName;
FOUNDATION_EXPORT NSString * const ADJWBTrackMeasurementConsentMethodName;
FOUNDATION_EXPORT NSString * const ADJWBRequestAppTrackingMethodName;
FOUNDATION_EXPORT NSString * const ADJWBFBPixelEventMethodName;
FOUNDATION_EXPORT NSString * const ADJWBSetTestOptionsMethodName;

FOUNDATION_EXPORT NSString * const ADJWBEnableMethodName;
FOUNDATION_EXPORT NSString * const ADJWBDisableMethodName;
FOUNDATION_EXPORT NSString * const ADJWBSwitchToOfflineModeMethodName;
FOUNDATION_EXPORT NSString * const ADJWBSwitchBackToOnlineMode;
FOUNDATION_EXPORT NSString * const ADJWBGdprForgetMeMethodName;
FOUNDATION_EXPORT NSString * const ADJWBEndFirstSessionDelayMethodName;
FOUNDATION_EXPORT NSString * const ADJWBEnableCoppaComplianceInDelayMethodName;
FOUNDATION_EXPORT NSString * const ADJWBDisableCoppaComplianceInDelayMethodName;
FOUNDATION_EXPORT NSString * const ADJWBSetExternalDeviceIdInDelayMethodName;

FOUNDATION_EXPORT NSString * const ADJWBAddGlobalCallbackParameterMethodName;
FOUNDATION_EXPORT NSString * const ADJWBRemoveGlobalCallbackParameterMethodName;
FOUNDATION_EXPORT NSString * const ADJWBRemoveGlobalCallbackParametersMethodName;
FOUNDATION_EXPORT NSString * const ADJWBAddGlobalPartnerParameterMethodName;
FOUNDATION_EXPORT NSString * const ADJWBRemoveGlobalPartnerParameterMethodName;
FOUNDATION_EXPORT NSString * const ADJWBRemoveGlobalPartnerParametersMethodName;

FOUNDATION_EXPORT NSString * const ADJWBGetSdkVersionMethodName;
FOUNDATION_EXPORT NSString * const ADJWBGetIdfaMethodName;
FOUNDATION_EXPORT NSString * const ADJWBGetIdfvMethodName;
FOUNDATION_EXPORT NSString * const ADJWBIsEnabledMethodName;
FOUNDATION_EXPORT NSString * const ADJWBGetAdidMethodName;
FOUNDATION_EXPORT NSString * const ADJWBGetAttributionMethodName;
FOUNDATION_EXPORT NSString * const ADJWBAppTrackingAuthorizationStatus;

FOUNDATION_EXPORT NSString * const ADJWBAppTokenConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBEnvironmentConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBAllowSuppressLogLevelConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBSdkPrefixConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBDefaultTrackerConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBExternalDeviceIdConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBLogLevelConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBSendInBackgroundConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBNeedsCostConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBAllowAdServicesInfoReadingConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBIsIdfaReadingAllowedConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBIsSkanAttributionHandlingEnabledConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBIsDeferredDeeplinkOpeningEnabledConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBIsCoppaComplianceEnabledConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBUrlStrategyConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBReadDeviceInfoOnceEnabledConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBAttConsentWaitingSecondsConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBEventDeduplicationIdsMaxSizeConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBUseStrategyDomainsConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBUseSubdomainsConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBIsDataResidencyConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBFbPixelDefaultEventTokenConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBFbPixelMappingConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBIsAppTrackingTransparencyUsageEnabledConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBIsFirstSessionDelayEnabledConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBStoreInfoConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBStoreNameConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBStoreAppIdConfigKey;

FOUNDATION_EXPORT NSString * const ADJWBAttributionCallbackConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBEventSuccessCallbackConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBEventFailureCallbackConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBSessionSuccessCallbackConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBSessionFailureCallbackConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBSkanUpdatedCallbackConfigKey;
FOUNDATION_EXPORT NSString * const ADJWBDeferredDeeplinkCallbackConfigKey;

FOUNDATION_EXPORT NSString * const ADJWBEventTokenEventKey;
FOUNDATION_EXPORT NSString * const ADJWBRevenueEventKey;
FOUNDATION_EXPORT NSString * const ADJWBCurrencyEventKey;
FOUNDATION_EXPORT NSString * const ADJWBCallbackIdEventKey;
FOUNDATION_EXPORT NSString * const ADJWBDeduplicationIdEventKey;
FOUNDATION_EXPORT NSString * const ADJWBCallbackParametersEventKey;
FOUNDATION_EXPORT NSString * const ADJWBPartnerParametersEventKey;

FOUNDATION_EXPORT NSString * const ADJWBAdjustThirdPartySharingName;
FOUNDATION_EXPORT NSString * const ADJWBIsEnabledTPSKey;
FOUNDATION_EXPORT NSString * const ADJWBGranularOptionsTPSKey;
FOUNDATION_EXPORT NSString * const ADJWBPartnerSharingSettingTPSKey;

FOUNDATION_EXPORT NSString * const ADJWBKvKeyKey;
FOUNDATION_EXPORT NSString * const ADJWBKvValueKey;

NS_ASSUME_NONNULL_END

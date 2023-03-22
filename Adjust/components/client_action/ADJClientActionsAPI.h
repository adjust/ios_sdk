//
//  ADJClientActionsAPI.h
//  Adjust
//
//  Created by Pedro Silva on 22.07.22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJClientEventData.h"
#import "ADJClientAdRevenueData.h"
#import "ADJClientAddGlobalParameterData.h"
#import "ADJClientRemoveGlobalParameterData.h"
#import "ADJClientClearGlobalParametersData.h"
#import "ADJClientPushTokenData.h"
#import "ADJClientLaunchedDeeplinkData.h"
#import "ADJClientBillingSubscriptionData.h"
#import "ADJClientThirdPartySharingData.h"
#import "ADJClientActionHandler.h"
#import "ADJClientMeasurementConsentData.h"

@protocol ADJClientActionsAPI <NSObject>

- (void)ccTrackEventWithClientData:(nonnull ADJClientEventData *)clientEventData;

- (void)ccTrackAdRevenueWithClientData:(nonnull ADJClientAdRevenueData *)clientAdRevenueData;

- (void)ccTrackPushTokenWithClientData:(nonnull ADJClientPushTokenData *)clientPushTokenData;

- (void)ccTrackMeasurementConsent:(nonnull ADJClientMeasurementConsentData *)consentData;

- (void)ccTrackBillingSubscriptionWithClientData:
    (nonnull ADJClientBillingSubscriptionData *)clientBillingSubscriptionData;

- (void)ccTrackThirdPartySharingWithClientData:
    (nonnull ADJClientThirdPartySharingData *)clientThirdPartySharingData;

- (void)ccTrackLaunchedDeeplinkWithClientData:
    (nonnull ADJClientLaunchedDeeplinkData *)clientLaunchedDeeplinkData;

- (void)ccAddGlobalCallbackParameterWithClientData:
    (nonnull ADJClientAddGlobalParameterData *)clientAddGlobalCallbackParameterActionData;
- (void)ccRemoveGlobalCallbackParameterWithClientData:
    (nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalCallbackParameterActionData;
- (void)ccClearGlobalCallbackParametersWithClientData:
    (nonnull ADJClientClearGlobalParametersData *)clientClearGlobalCallbackParametersActionData;

- (void)ccAddGlobalPartnerParameterWithClientData:
    (nonnull ADJClientAddGlobalParameterData *)clientAddGlobalPartnerParameterActionData;
- (void)ccRemoveGlobalPartnerParameterWithClientData:
    (nonnull ADJClientRemoveGlobalParameterData *)clientRemoveGlobalPartnerParameterActionData;
- (void)ccClearGlobalPartnerParametersWithClientData:
    (nonnull ADJClientClearGlobalParametersData *)clientClearGlobalPartnerParametersActionData;
@end

//
//  ADJActivityKind.m
//  Adjust
//
//  Created by Christian Wellenbrock on 11.02.14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import "ADJActivityKind.h"

@implementation ADJActivityKindUtil

#pragma mark - Public methods

+ (ADJActivityKind)activityKindFromString:(NSString *)activityKindString {
    if ([@"session" isEqualToString:activityKindString]) {
        return ADJActivityKindSession;
    } else if ([@"event" isEqualToString:activityKindString]) {
        return ADJActivityKindEvent;
    } else if ([@"click" isEqualToString:activityKindString]) {
        return ADJActivityKindClick;
    } else if ([@"attribution" isEqualToString:activityKindString]) {
        return ADJActivityKindAttribution;
    } else if ([@"info" isEqualToString:activityKindString]) {
        return ADJActivityKindInfo;
    } else if ([@"gdpr" isEqualToString:activityKindString]) {
        return ADJActivityKindGdpr;
    } else if ([@"ad_revenue" isEqualToString:activityKindString]) {
        return ADJActivityKindAdRevenue;
    } else if ([@"disable_third_party_sharing" isEqualToString:activityKindString]) {
        return ADJActivityKindDisableThirdPartySharing;
    } else if ([@"subscription" isEqualToString:activityKindString]) {
        return ADJActivityKindSubscription;
    } else if ([@"third_party_sharing" isEqualToString:activityKindString]) {
        return ADJActivityKindThirdPartySharing;
    } else if ([@"measurement_consent" isEqualToString:activityKindString]) {
        return ADJActivityKindMeasurementConsent;
    } else if ([@"purchase_verification" isEqualToString:activityKindString]) {
        return ADJActivityKindPurchaseVerification;
    } else {
        return ADJActivityKindUnknown;
    }
}

+ (NSString *)activityKindToString:(ADJActivityKind)activityKind {
    switch (activityKind) {
        case ADJActivityKindSession:
            return @"session";
        case ADJActivityKindEvent:
            return @"event";
        case ADJActivityKindClick:
            return @"click";
        case ADJActivityKindAttribution:
            return @"attribution";
        case ADJActivityKindInfo:
            return @"info";
        case ADJActivityKindGdpr:
            return @"gdpr";
        case ADJActivityKindAdRevenue:
            return @"ad_revenue";
        case ADJActivityKindDisableThirdPartySharing:
            return @"disable_third_party_sharing";
        case ADJActivityKindSubscription:
            return @"subscription";
        case ADJActivityKindThirdPartySharing:
            return @"third_party_sharing";
        case ADJActivityKindMeasurementConsent:
            return @"measurement_consent";
        case ADJActivityKindPurchaseVerification:
            return @"purchase_verification";
        default:
            return @"unknown";
    }
}

@end

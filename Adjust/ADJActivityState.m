//
//  ADJActivityState.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJAdjustFactory.h"
#import "ADJActivityState.h"
#import "NSString+ADJAdditions.h"
#import "ADJUtil.h"

static const int kTransactionIdCount = 10;
static NSString *appToken = nil;

@implementation ADJActivityState

#pragma mark - Object lifecycle methods

- (id)init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    [self assignRandomToken:[ADJUtil generateRandomUuid]];

    self.eventCount = 0;
    self.sessionCount = 0;
    self.subsessionCount = -1;   // -1 means unknown
    self.sessionLength = -1;
    self.timeSpent = -1;
    self.lastActivity = -1;
    self.lastInterval = -1;
    self.enabled = YES;
    self.isGdprForgotten = NO;
    self.askingAttribution = NO;
    self.isThirdPartySharingDisabled = NO;
    self.isThirdPartySharingDisabledForCoppa = NO;
    self.deviceToken = nil;
    self.transactionIds = [NSMutableArray arrayWithCapacity:kTransactionIdCount];
    self.updatePackages = NO;
    self.updatePackagesAttData = NO;
    self.trackingManagerAuthorizationStatus = -1;

    return self;
}

#pragma mark - Public methods

+ (void)saveAppToken:(NSString *)appTokenToSave {
    @synchronized (self) {
        appToken = appTokenToSave;
    }
}

- (void)resetSessionAttributes:(double)now {
    self.subsessionCount = 1;
    self.sessionLength = 0;
    self.timeSpent = 0;
    self.lastInterval = -1;
    self.lastActivity = now;
}

- (void)addTransactionId:(NSString *)transactionId {
    // Create array.
    if (self.transactionIds == nil) {
        self.transactionIds = [NSMutableArray arrayWithCapacity:kTransactionIdCount];
    }

    // Make space.
    if (self.transactionIds.count == kTransactionIdCount) {
        [self.transactionIds removeObjectAtIndex:0];
    }

    // Add the new ID.
    [self.transactionIds addObject:transactionId];
}

- (BOOL)findTransactionId:(NSString *)transactionId {
    return [self.transactionIds containsObject:transactionId];
}

#pragma mark - Private & helper methods

- (void)assignRandomToken:(NSString *)randomToken {
    NSString *persistedDedupeToken = [ADJUtil getPersistedRandomToken];
    if (persistedDedupeToken != nil) {
        if ((bool)[[NSUUID alloc] initWithUUIDString:persistedDedupeToken]) {
            [[ADJAdjustFactory logger] verbose:@"Primary dedupe token successfully read"];
            self.dedupeToken = persistedDedupeToken;
            self.isPersisted = YES;
            return;
        }
    }
    
    self.dedupeToken = randomToken;
    self.isPersisted = [ADJUtil setPersistedRandomToken:self.dedupeToken];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ec:%d sc:%d ssc:%d ask:%d sl:%.1f ts:%.1f la:%.1f dt:%@ gdprf:%d dtps:%d dtpsc:%d att:%d",
            self.eventCount, self.sessionCount,
            self.subsessionCount, self.askingAttribution, self.sessionLength,
            self.timeSpent, self.lastActivity, self.deviceToken,
            self.isGdprForgotten, self.isThirdPartySharingDisabled, self.isThirdPartySharingDisabledForCoppa, self.trackingManagerAuthorizationStatus];
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    self.eventCount = [decoder decodeIntForKey:@"eventCount"];
    self.sessionCount = [decoder decodeIntForKey:@"sessionCount"];
    self.subsessionCount = [decoder decodeIntForKey:@"subsessionCount"];
    self.sessionLength = [decoder decodeDoubleForKey:@"sessionLength"];
    self.timeSpent = [decoder decodeDoubleForKey:@"timeSpent"];
    self.lastActivity = [decoder decodeDoubleForKey:@"lastActivity"];
    
    // Default values for migrating devices.
    if ([decoder containsValueForKey:@"uuid"]) {
        [self assignRandomToken:[decoder decodeObjectForKey:@"uuid"]];
    }
    if (self.dedupeToken == nil) {
        [self assignRandomToken:[ADJUtil generateRandomUuid]];
    }

    if ([decoder containsValueForKey:@"transactionIds"]) {
        self.transactionIds = [decoder decodeObjectForKey:@"transactionIds"];
    }
    if (self.transactionIds == nil) {
        self.transactionIds = [NSMutableArray arrayWithCapacity:kTransactionIdCount];
    }

    if ([decoder containsValueForKey:@"enabled"]) {
        self.enabled = [decoder decodeBoolForKey:@"enabled"];
    } else {
        self.enabled = YES;
    }

    if ([decoder containsValueForKey:@"isGdprForgotten"]) {
        self.isGdprForgotten = [decoder decodeBoolForKey:@"isGdprForgotten"];
    } else {
        self.isGdprForgotten = NO;
    }

    if ([decoder containsValueForKey:@"askingAttribution"]) {
        self.askingAttribution = [decoder decodeBoolForKey:@"askingAttribution"];
    } else {
        self.askingAttribution = NO;
    }

    if ([decoder containsValueForKey:@"isThirdPartySharingDisabled"]) {
        self.isThirdPartySharingDisabled = [decoder decodeBoolForKey:@"isThirdPartySharingDisabled"];
    } else {
        self.isThirdPartySharingDisabled = NO;
    }
    
    if ([decoder containsValueForKey:@"isThirdPartySharingDisabledForCoppa"]) {
        self.isThirdPartySharingDisabledForCoppa = [decoder decodeBoolForKey:@"isThirdPartySharingDisabledForCoppa"];
    } else {
        self.isThirdPartySharingDisabledForCoppa = NO;
    }

    if ([decoder containsValueForKey:@"deviceToken"]) {
        self.deviceToken = [decoder decodeObjectForKey:@"deviceToken"];
    }

    if ([decoder containsValueForKey:@"updatePackages"]) {
        self.updatePackages = [decoder decodeBoolForKey:@"updatePackages"];
    } else {
        self.updatePackages = NO;
    }

    if ([decoder containsValueForKey:@"updatePackagesAttData"]) {
        self.updatePackagesAttData = [decoder decodeBoolForKey:@"updatePackagesAttData"];
    } else {
        self.updatePackagesAttData = NO;
    }

    if ([decoder containsValueForKey:@"adid"]) {
        self.adid = [decoder decodeObjectForKey:@"adid"];
    }

    if ([decoder containsValueForKey:@"attributionDetails"]) {
        self.attributionDetails = [decoder decodeObjectForKey:@"attributionDetails"];
    }

    if ([decoder containsValueForKey:@"trackingManagerAuthorizationStatus"]) {
        self.trackingManagerAuthorizationStatus =
            [decoder decodeIntForKey:@"trackingManagerAuthorizationStatus"];
    } else {
        self.trackingManagerAuthorizationStatus = -1;
    }

    self.lastInterval = -1;

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.eventCount forKey:@"eventCount"];
    [encoder encodeInt:self.sessionCount forKey:@"sessionCount"];
    [encoder encodeInt:self.subsessionCount forKey:@"subsessionCount"];
    [encoder encodeDouble:self.sessionLength forKey:@"sessionLength"];
    [encoder encodeDouble:self.timeSpent forKey:@"timeSpent"];
    [encoder encodeDouble:self.lastActivity forKey:@"lastActivity"];
    [encoder encodeObject:self.dedupeToken forKey:@"uuid"];
    [encoder encodeObject:self.transactionIds forKey:@"transactionIds"];
    [encoder encodeBool:self.enabled forKey:@"enabled"];
    [encoder encodeBool:self.isGdprForgotten forKey:@"isGdprForgotten"];
    [encoder encodeBool:self.askingAttribution forKey:@"askingAttribution"];
    [encoder encodeBool:self.isThirdPartySharingDisabled forKey:@"isThirdPartySharingDisabled"];
    [encoder encodeBool:self.isThirdPartySharingDisabledForCoppa forKey:@"isThirdPartySharingDisabledForCoppa"];
    [encoder encodeObject:self.deviceToken forKey:@"deviceToken"];
    [encoder encodeBool:self.updatePackages forKey:@"updatePackages"];
    [encoder encodeBool:self.updatePackagesAttData forKey:@"updatePackagesAttData"];
    [encoder encodeObject:self.adid forKey:@"adid"];
    [encoder encodeObject:self.attributionDetails forKey:@"attributionDetails"];
    [encoder encodeInt:self.trackingManagerAuthorizationStatus
                   forKey:@"trackingManagerAuthorizationStatus"];
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    ADJActivityState *copy = [[[self class] allocWithZone:zone] init];

    // Copy only values used by package builder.
    if (copy) {
        copy.sessionCount = self.sessionCount;
        copy.subsessionCount = self.subsessionCount;
        copy.sessionLength = self.sessionLength;
        copy.timeSpent = self.timeSpent;
        copy.dedupeToken = [self.dedupeToken copyWithZone:zone];
        copy.lastInterval = self.lastInterval;
        copy.eventCount = self.eventCount;
        copy.enabled = self.enabled;
        copy.isGdprForgotten = self.isGdprForgotten;
        copy.lastActivity = self.lastActivity;
        copy.askingAttribution = self.askingAttribution;
        copy.isThirdPartySharingDisabled = self.isThirdPartySharingDisabled;
        copy.isThirdPartySharingDisabledForCoppa = self.isThirdPartySharingDisabledForCoppa;
        copy.deviceToken = [self.deviceToken copyWithZone:zone];
        copy.updatePackages = self.updatePackages;
        copy.updatePackagesAttData = self.updatePackagesAttData;
        copy.trackingManagerAuthorizationStatus = self.trackingManagerAuthorizationStatus;
    }
    
    return copy;
}

@end

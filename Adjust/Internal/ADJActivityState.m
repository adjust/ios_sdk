//
//  ADJActivityState.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJAdjustFactory.h"
#import "ADJActivityState.h"
#import "ADJAdditions.h"
#import "ADJUtil.h"

static NSString *appToken = nil;
static NSUInteger eventDeduplicationIdsArraySize = 10;

@implementation ADJActivityState

+ (BOOL)supportsSecureCoding {
    return YES;
}

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
    self.isThirdPartySharingDisabledForCoppa = NO;
    self.pushToken = nil;
    self.eventDeduplicationIds = [NSMutableArray array];
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

+ (void)setEventDeduplicationIdsArraySize:(NSInteger)size {
    @synchronized (self) {
        if (size >= 0) {
            eventDeduplicationIdsArraySize = size;
            [[ADJAdjustFactory logger] info:@"Setting deduplication IDs array size to: %ld", size];
        }
    }
}

- (void)resetSessionAttributes:(double)now {
    self.subsessionCount = 1;
    self.sessionLength = 0;
    self.timeSpent = 0;
    self.lastInterval = -1;
    self.lastActivity = now;
}

- (void)addEventDeduplicationId:(NSString *)deduplicationId {
    if (eventDeduplicationIdsArraySize == 0) {
        [[ADJAdjustFactory logger] error:@"Cannot add deduplication id - deduplication IDs array size configured to 0"];
        return;
    }
    // Make space.
    while (self.eventDeduplicationIds.count >= eventDeduplicationIdsArraySize) {
        [[ADJAdjustFactory logger] info:@"Removing deduplication ID \"%@\" to make space", self.eventDeduplicationIds[0]];
        [self.eventDeduplicationIds removeObjectAtIndex:0];
    }
    // Add the new ID.
    [[ADJAdjustFactory logger] info:@"Added deduplication ID \"%@\"", deduplicationId];
    [self.eventDeduplicationIds addObject:deduplicationId];
}

- (BOOL)eventDeduplicationIdExists:(NSString *)deduplicationId {
    return [self.eventDeduplicationIds containsObject:deduplicationId];
}

- (BOOL)isCoppaComplianceEnabled {
    return self.isThirdPartySharingDisabledForCoppa;
}
- (void)setCoppaComplianceWithIsEnabled:(BOOL)isCoppaComplianceEnabled {
    self.isThirdPartySharingDisabledForCoppa = isCoppaComplianceEnabled;
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
    return [NSString stringWithFormat:@"ec:%d sc:%d ssc:%d ask:%d sl:%.1f ts:%.1f la:%.1f pt:%@ gdprf:%d dtpsc:%d att:%d",
            self.eventCount, self.sessionCount,
            self.subsessionCount, self.askingAttribution, self.sessionLength,
            self.timeSpent, self.lastActivity, self.pushToken,
            self.isGdprForgotten, self.isThirdPartySharingDisabledForCoppa, self.trackingManagerAuthorizationStatus];
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
        [self assignRandomToken:[decoder decodeObjectOfClass:[NSString class] forKey:@"uuid"]];
    }
    if (self.dedupeToken == nil) {
        [self assignRandomToken:[ADJUtil generateRandomUuid]];
    }

    if ([decoder containsValueForKey:@"transactionIds"]) {
        NSSet *allowedClasses = [NSSet setWithObjects:[NSArray class], [NSString class], nil];
        self.eventDeduplicationIds = [decoder decodeObjectOfClasses:allowedClasses forKey:@"transactionIds"];
    }

    if (self.eventDeduplicationIds == nil) {
        self.eventDeduplicationIds = [NSMutableArray array];
    } else {
        while (self.eventDeduplicationIds.count > eventDeduplicationIdsArraySize) {
            [self.eventDeduplicationIds removeObjectAtIndex:0];
        }
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

    if ([decoder containsValueForKey:@"isThirdPartySharingDisabledForCoppa"]) {
        self.isThirdPartySharingDisabledForCoppa = [decoder decodeBoolForKey:@"isThirdPartySharingDisabledForCoppa"];
    } else {
        self.isThirdPartySharingDisabledForCoppa = NO;
    }

    if ([decoder containsValueForKey:@"deviceToken"]) {
        self.pushToken = [decoder decodeObjectOfClass:[NSString class] forKey:@"deviceToken"];
    }

    if ([decoder containsValueForKey:@"updatePackagesAttData"]) {
        self.updatePackagesAttData = [decoder decodeBoolForKey:@"updatePackagesAttData"];
    } else {
        self.updatePackagesAttData = NO;
    }

    if ([decoder containsValueForKey:@"adid"]) {
        self.adid = [decoder decodeObjectOfClass:[NSString class] forKey:@"adid"];
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
    [encoder encodeObject:self.eventDeduplicationIds forKey:@"transactionIds"];
    [encoder encodeBool:self.enabled forKey:@"enabled"];
    [encoder encodeBool:self.isGdprForgotten forKey:@"isGdprForgotten"];
    [encoder encodeBool:self.askingAttribution forKey:@"askingAttribution"];
    [encoder encodeBool:self.isThirdPartySharingDisabledForCoppa forKey:@"isThirdPartySharingDisabledForCoppa"];
    [encoder encodeObject:self.pushToken forKey:@"deviceToken"];
    [encoder encodeBool:self.updatePackagesAttData forKey:@"updatePackagesAttData"];
    [encoder encodeObject:self.adid forKey:@"adid"];
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
        copy.isThirdPartySharingDisabledForCoppa = self.isThirdPartySharingDisabledForCoppa;
        copy.pushToken = [self.pushToken copyWithZone:zone];
        copy.updatePackagesAttData = self.updatePackagesAttData;
        copy.trackingManagerAuthorizationStatus = self.trackingManagerAuthorizationStatus;
    }
    
    return copy;
}
@end

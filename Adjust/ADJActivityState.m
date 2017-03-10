//
//  ADJActivityState.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJKeychain.h"
#import "ADJAdjustFactory.h"
#import "ADJActivityState.h"
#import "UIDevice+ADJAdditions.h"

static const int kTransactionIdCount = 10;

@implementation ADJActivityState

#pragma mark - Object lifecycle methods

- (id)init {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    [self assignUuid:[UIDevice.currentDevice adjCreateUuid]];
    
    self.eventCount         = 0;
    self.sessionCount       = 0;
    self.subsessionCount    = -1;   // -1 means unknown
    self.sessionLength      = -1;
    self.timeSpent          = -1;
    self.lastActivity       = -1;
    self.lastInterval       = -1;
    self.enabled            = YES;
    self.askingAttribution  = NO;
    self.deviceToken        = nil;
    self.transactionIds     = [NSMutableArray arrayWithCapacity:kTransactionIdCount];
    self.updatePackages  = NO;
    
    return self;
}

#pragma mark - Public methods

- (void)resetSessionAttributes:(double)now {
    self.subsessionCount = 1;
    self.sessionLength   = 0;
    self.timeSpent       = 0;
    self.lastInterval    = -1;
    self.lastActivity    = now;
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

- (void)assignUuid:(NSString *)uuid {
    // First check if there's any UUID written in keychain.
    // If yes, use keychain value and flag it.
    // If not, use given UUID and store it to keychain.
    //      If successfully written, flag it.
    //      If writing failed, don't flat it.
    // Small addition as of iOS 10.3:
    // Keychain needs to be written in different way in order to persist value between (un)installs.

    // Check if device supports new writing method.
    // kSecAttrAccessGroupToken available since iOS 10.0.
    if (NULL == &kSecAttrAccessGroupToken) {
        // This device's iOS version doesn't support new writing method.
        [self assignUuidOldMethod:uuid];
        return;
    } else {
        // This device's iOS version supports new writing method.
        [self assignUuidNewMethod:uuid];
        return;
    }
}

- (void)assignUuidOldMethod:(NSString *)uuid {
    NSString *persistedUuid = [ADJKeychain valueForKeychainKeyOld:@"adjust_persisted_uuid" service:@"deviceInfo"];

    // Check if value exists in keychain.
    if (persistedUuid != nil) {
        // Check if value has UUID format.
        if ((bool)[[NSUUID alloc] initWithUUIDString:persistedUuid]) {
            [[ADJAdjustFactory logger] verbose:@"Value found and read from the keychain old way"];

            // Value written in keychain seems to have UUID format.
            self.uuid = persistedUuid;
            self.isPersisted = YES;

            return;
        }
    }

    // At this point, UUID was not persisted or if persisted, didn't have proper UUID format.

    // Since we don't have anything in the keychain, we'll use the passed UUID value.
    // Try to save that value to the keychain and flag if successfully written.
    self.uuid = uuid;
    self.isPersisted = [ADJKeychain setValue:self.uuid forKeychainKey:@"adjust_persisted_uuid" inService:@"deviceInfo"];
}

- (void)assignUuidNewMethod:(NSString *)uuid {
    NSString *persistedUuidNew = [ADJKeychain valueForKeychainKeyNew:@"adjust_persisted_uuid" service:@"deviceInfo"];

    // Check if value exists in keychain.
    if (persistedUuidNew != nil) {
        // Check if value has UUID format.
        if ((bool)[[NSUUID alloc] initWithUUIDString:persistedUuidNew]) {
            [[ADJAdjustFactory logger] verbose:@"Value found and read from the keychain new way"];

            // Value written in keychain seems to have UUID format.
            self.uuid = persistedUuidNew;
            self.isPersisted = YES;

            return;
        }
    }

    // At this point, UUID was not persisted with new method or if persisted, didn't have proper UUID format.

    // Check if it's still saved in the keychain with old writing method.
    NSString *persistedUuidOld = [ADJKeychain valueForKeychainKeyOld:@"adjust_persisted_uuid" service:@"deviceInfo"];

    if (persistedUuidOld != nil) {
        // Check if value has UUID format.
        if ((bool)[[NSUUID alloc] initWithUUIDString:persistedUuidOld]) {
            // Since we have the value in the keychain written with old method, we'll use it to save it with new one.
            self.uuid = persistedUuidOld;
        } else {
            // Since found value in the keychain doesn't have propper UUID format, we'll use passed UUID value.
            self.uuid = uuid;
        }
    } else {
        // Since we didn't find anything in the keychain with old method as well, we'll use the passed UUID value.
        self.uuid = uuid;
    }

    // Try to save that value to the keychain and flag if successfully written.
    self.isPersisted = [ADJKeychain setValue:self.uuid forKeychainKey:@"adjust_persisted_uuid" inService:@"deviceInfo"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ec:%d sc:%d ssc:%d ask:%d sl:%.1f ts:%.1f la:%.1f dt:%@",
            self.eventCount, self.sessionCount, self.subsessionCount, self.askingAttribution, self.sessionLength,
            self.timeSpent, self.lastActivity, self.deviceToken];
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    self.eventCount         = [decoder decodeIntForKey:@"eventCount"];
    self.sessionCount       = [decoder decodeIntForKey:@"sessionCount"];
    self.subsessionCount    = [decoder decodeIntForKey:@"subsessionCount"];
    self.sessionLength      = [decoder decodeDoubleForKey:@"sessionLength"];
    self.timeSpent          = [decoder decodeDoubleForKey:@"timeSpent"];
    self.lastActivity       = [decoder decodeDoubleForKey:@"lastActivity"];
    
    // Default values for migrating devices
    if ([decoder containsValueForKey:@"uuid"]) {
        [self assignUuid:[decoder decodeObjectForKey:@"uuid"]];
    }
    
    if (self.uuid == nil) {
        [self assignUuid:[UIDevice.currentDevice adjCreateUuid]];
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
    
    if ([decoder containsValueForKey:@"askingAttribution"]) {
        self.askingAttribution = [decoder decodeBoolForKey:@"askingAttribution"];
    } else {
        self.askingAttribution = NO;
    }
    
    if ([decoder containsValueForKey:@"deviceToken"]) {
        self.deviceToken        = [decoder decodeObjectForKey:@"deviceToken"];
    }
    
    if ([decoder containsValueForKey:@"updatePackages"]) {
        self.updatePackages     = [decoder decodeBoolForKey:@"updatePackages"];
    } else {
        self.updatePackages     = NO;
    }
    
    if ([decoder containsValueForKey:@"adid"]) {
        self.adid               = [decoder decodeObjectForKey:@"adid"];
    }
    
    if ([decoder containsValueForKey:@"attributionDetails"]) {
        self.attributionDetails = [decoder decodeObjectForKey:@"attributionDetails"];
    }
    
    self.lastInterval = -1;
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.eventCount         forKey:@"eventCount"];
    [encoder encodeInt:self.sessionCount       forKey:@"sessionCount"];
    [encoder encodeInt:self.subsessionCount    forKey:@"subsessionCount"];
    [encoder encodeDouble:self.sessionLength   forKey:@"sessionLength"];
    [encoder encodeDouble:self.timeSpent       forKey:@"timeSpent"];
    [encoder encodeDouble:self.lastActivity    forKey:@"lastActivity"];
    [encoder encodeObject:self.uuid            forKey:@"uuid"];
    [encoder encodeObject:self.transactionIds  forKey:@"transactionIds"];
    [encoder encodeBool:self.enabled           forKey:@"enabled"];
    [encoder encodeBool:self.askingAttribution forKey:@"askingAttribution"];
    [encoder encodeObject:self.deviceToken     forKey:@"deviceToken"];
    [encoder encodeBool:self.updatePackages    forKey:@"updatePackages"];
    [encoder encodeObject:self.adid            forKey:@"adid"];
    [encoder encodeObject:self.attributionDetails forKey:@"attributionDetails"];
}

#pragma mark - NSCopying protocol methods

- (id)copyWithZone:(NSZone *)zone {
    ADJActivityState *copy = [[[self class] allocWithZone:zone] init];
    
    // Copy only values used by package builder.
    if (copy) {
        copy.sessionCount       = self.sessionCount;
        copy.subsessionCount    = self.subsessionCount;
        copy.sessionLength      = self.sessionLength;
        copy.timeSpent          = self.timeSpent;
        copy.uuid               = [self.uuid copyWithZone:zone];
        copy.lastInterval       = self.lastInterval;
        copy.eventCount         = self.eventCount;
        copy.enabled            = self.enabled;
        copy.lastActivity       = self.lastActivity;
        copy.askingAttribution  = self.askingAttribution;
        copy.deviceToken        = [self.deviceToken copyWithZone:zone];
        copy.updatePackages     = self.updatePackages;
    }
    
    return copy;
}

@end

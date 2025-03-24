//
//  ADJActivityState.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJActivityState : NSObject <NSSecureCoding, NSCopying>

// Persistent data
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign) BOOL isGdprForgotten;
@property (nonatomic, assign) BOOL askingAttribution;
@property (nonatomic, assign) BOOL isThirdPartySharingDisabledForCoppa;

@property (nonatomic, copy) NSString *dedupeToken;
@property (nonatomic, copy) NSString *pushToken;
@property (nonatomic, assign) BOOL updatePackagesAttData;

@property (nonatomic, copy) NSString *adid;

@property (nonatomic, assign) int trackingManagerAuthorizationStatus;

// Global counters
@property (nonatomic, assign) int eventCount;
@property (nonatomic, assign) int sessionCount;

// Session attributes
@property (nonatomic, assign) int subsessionCount;

@property (nonatomic, assign) double timeSpent;
@property (nonatomic, assign) double lastActivity;      // Entire time in seconds since 1970
@property (nonatomic, assign) double sessionLength;     // Entire duration in seconds

// last stored event deduplication identifiers
@property (nonatomic, strong) NSMutableArray *eventDeduplicationIds;

// Not persisted, only injected
@property (nonatomic, assign) BOOL isPersisted;
@property (nonatomic, assign) double lastInterval;

- (void)resetSessionAttributes:(double)now;

+ (void)saveAppToken:(NSString *)appTokenToSave;
+ (void)setEventDeduplicationIdsArraySize:(NSInteger)size;

// Deduplication ID management
- (BOOL)eventDeduplicationIdExists:(NSString *)deduplicationId;
- (void)addEventDeduplicationId:(NSString *)deduplicationId;


- (BOOL)isCoppaComplianceEnabled;
- (void)setCoppaComplianceWithIsEnabled:(BOOL)isCoppaComplianceEnabled;

@end

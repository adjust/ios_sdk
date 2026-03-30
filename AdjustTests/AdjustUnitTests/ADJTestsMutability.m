//
//  AdjustUnitTests.m
//  AdjustUnitTests
//
//  Created by Uglješa Erceg (@uerceg) on 19th February 2026.
//  Copyright © 2026-Present Adjust GmbH. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "../../Adjust/Adjust.h"
#import "../../Adjust/ADJAdRevenue.h"
#import "../../Adjust/ADJAppStorePurchase.h"
#import "../../Adjust/ADJAppStoreSubscription.h"
#import "../../Adjust/ADJDeeplink.h"
#import "../../Adjust/ADJEvent.h"
#import "../../Adjust/ADJThirdPartySharing.h"
#import "../../Adjust/Internal/ADJActivityPackage.h"
#import "../../Adjust/Internal/ADJActivityState.h"
#import "../../Adjust/Internal/ADJEventMetadata.h"
#import "../../Adjust/Internal/ADJGlobalParameters.h"
#import "../../Adjust/Internal/ADJPackageHandler.h"
#import "../../Adjust/Internal/ADJPackageParams.h"
#import "../../Adjust/Internal/ADJUtil.h"
#import "../../Adjust/ADJLogger.h"
#import "../../Adjust/Internal/ADJAdjustFactory.h"

@class ADJInternalState;
@class ADJTrackingStatusManager;
@class ADJFirstSessionDelayManager;

#import "../../Adjust/Internal/ADJPackageBuilder.h"
#import "../../Adjust/Internal/ADJActivityHandler.h"

static NSString * const kGlobalCallbackParametersFilename = @"AdjustSessionCallbackParameters";
static NSString * const kGlobalPartnerParametersFilename = @"AdjustSessionPartnerParameters";
static NSString * const kActivityStateFilename = @"AdjustIoActivityState";
static NSString * const kPackageQueueFilename = @"AdjustIoPackageQueue";

@interface ADJActivityHandler (ADJTestsMutability)
@property (nonatomic, strong) ADJGlobalParameters *globalParameters;
@property (nonatomic, strong) ADJActivityState *activityState;
@property (nonatomic, weak) id<ADJLogger> logger;
- (void)readActivityState;
- (void)writeActivityStateI:(ADJActivityHandler *)selfI;
- (void)readGlobalCallbackParametersI:(ADJActivityHandler *)selfI;
- (void)readGlobalPartnerParametersI:(ADJActivityHandler *)selfI;
- (void)writeGlobalCallbackParametersI:(ADJActivityHandler *)selfI;
- (void)writeGlobalPartnerParametersI:(ADJActivityHandler *)selfI;
- (void)addGlobalCallbackParameterI:(ADJActivityHandler *)selfI
                              param:(NSString *)param
                             forKey:(NSString *)key;
- (void)addGlobalPartnerParameterI:(ADJActivityHandler *)selfI
                             param:(NSString *)param
                            forKey:(NSString *)key;
@end

@interface ADJPackageHandler (ADJTestsMutability)
@property (nonatomic, strong) NSMutableArray *packageQueue;
- (void)readPackageQueueI:(ADJPackageHandler *)selfI;
- (void)writePackageQueueS:(ADJPackageHandler *)selfS;
@end

@interface ADJTestsMutability : XCTestCase

@end

@implementation ADJTestsMutability

- (void)setUp {
    [super setUp];
    [ADJActivityState setEventDeduplicationIdsArraySize:10];
    [ADJUtil deleteFileWithName:kGlobalCallbackParametersFilename];
    [ADJUtil deleteFileWithName:kGlobalPartnerParametersFilename];
    [ADJUtil deleteFileWithName:kActivityStateFilename];
    [ADJUtil deleteFileWithName:kPackageQueueFilename];
}

- (void)tearDown {
    [ADJUtil deleteFileWithName:kGlobalCallbackParametersFilename];
    [ADJUtil deleteFileWithName:kGlobalPartnerParametersFilename];
    [ADJUtil deleteFileWithName:kActivityStateFilename];
    [ADJUtil deleteFileWithName:kPackageQueueFilename];
    [ADJActivityState setEventDeduplicationIdsArraySize:10];
    [super tearDown];
}

- (ADJActivityPackage *)buildSessionPackageWithActivityState:(ADJActivityState *)activityState {
    ADJPackageParams *packageParams = [ADJPackageParams new];
    packageParams.clientSdk = @"ios5.0.0";
    packageParams.buildNumber = @"42";
    packageParams.versionNumber = @"1.0.0";
    packageParams.bundleIdentifier = @"com.adjust.unittests";
    packageParams.deviceName = @"test-device";
    packageParams.deviceType = @"test-type";
    packageParams.fbAnonymousId = @"fb-anon";
    packageParams.installedAt = @"2026-02-19T00:00:00.000Z";
    packageParams.osName = @"ios";
    packageParams.osVersion = @"18.0";
    packageParams.startedAt = 1700000000.0;

    ADJConfig *config =
        [[ADJConfig alloc] initWithAppToken:@"123456789012"
                                environment:ADJEnvironmentSandbox];
    ADJGlobalParameters *globalParameters = [ADJGlobalParameters new];
    globalParameters.callbackParameters = [NSMutableDictionary dictionary];
    globalParameters.partnerParameters = [NSMutableDictionary dictionary];

    ADJPackageBuilder *builder = [[ADJPackageBuilder alloc]
                                  initWithPackageParams:packageParams
                                          activityState:activityState
                                                 config:config
                                       globalParameters:globalParameters
                                  trackingStatusManager:nil
                               firstSessionDelayManager:nil
                                              createdAt:1700000000.0
                                             odmEnabled:NO
                       remoteTriggerCallbackImplemented:NO];

    return [builder buildSessionPackage];
}

- (ADJActivityHandler *)buildBareActivityHandler {
    ADJActivityHandler *handler = [[ADJActivityHandler alloc] init];
    handler.logger = [ADJAdjustFactory logger];
    handler.globalParameters = [[ADJGlobalParameters alloc] init];
    return handler;
}

- (ADJActivityPackage *)buildQueuePackageWithIndex:(NSUInteger)index {
    ADJActivityPackage *package = [ADJActivityPackage new];
    package.path = [NSString stringWithFormat:@"/event/%lu", (unsigned long)index];
    package.clientSdk = @"ios5.0.0";
    package.parameters = [@{
        @"key": [NSString stringWithFormat:@"value-%lu", (unsigned long)index],
        @"nested": @{@"inner": [NSString stringWithFormat:@"inner-%lu", (unsigned long)index]}
    } mutableCopy];
    package.callbackParameters = @{
        @"cb": [NSString stringWithFormat:@"cb-%lu", (unsigned long)index]
    };
    package.partnerParameters = @{
        @"pt": [NSString stringWithFormat:@"pt-%lu", (unsigned long)index]
    };
    package.activityKind = ADJActivityKindEvent;
    package.suffix = [NSString stringWithFormat:@"-%lu", (unsigned long)index];
    return package;
}

- (void)testDecodeTransactionIdsIntoMutableArray {
    [ADJActivityState setEventDeduplicationIdsArraySize:2];

    ADJActivityState *state = [[ADJActivityState alloc] init];
    state.eventDeduplicationIds = (NSMutableArray *)[@[@"id-1", @"id-2"] copy];

    NSError *archiveError = nil;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:state
                                         requiringSecureCoding:YES
                                                         error:&archiveError];
    XCTAssertNotNil(data);
    XCTAssertNil(archiveError);

    NSError *unarchiveError = nil;
    ADJActivityState *decodedState =
        [NSKeyedUnarchiver unarchivedObjectOfClass:[ADJActivityState class]
                                          fromData:data
                                             error:&unarchiveError];
    XCTAssertNotNil(decodedState);
    XCTAssertNil(unarchiveError);

    XCTAssertNoThrow([decodedState addEventDeduplicationId:@"id-3"]);
    XCTAssertEqual(decodedState.eventDeduplicationIds.count, 2);
    XCTAssertEqualObjects(decodedState.eventDeduplicationIds[0], @"id-2");
    XCTAssertEqualObjects(decodedState.eventDeduplicationIds[1], @"id-3");
}

- (void)testCopyWithZoneCopiesIsPersisted {
    ADJActivityState *state = [[ADJActivityState alloc] init];
    state.dedupeToken = @"dedupe-token";
    state.isPersisted = YES;

    ADJActivityState *copy = [state copy];
    XCTAssertEqualObjects(copy.dedupeToken, state.dedupeToken);
    XCTAssertTrue(copy.isPersisted);
}

- (void)testDeepCopyCopiesIsPersisted {
    ADJActivityState *state = [[ADJActivityState alloc] init];
    state.dedupeToken = @"dedupe-token";
    state.isPersisted = YES;

    ADJActivityState *copy = [state deepCopy];
    XCTAssertEqualObjects(copy.dedupeToken, state.dedupeToken);
    XCTAssertTrue(copy.isPersisted);
}

- (void)testActivityStateDeepCopyIsolatedFromOriginalMutations {
    ADJActivityState *source = [[ADJActivityState alloc] init];
    source.enabled = YES;
    source.isGdprForgotten = YES;
    source.askingAttribution = YES;
    source.isThirdPartySharingDisabledForCoppa = YES;
    source.dedupeToken = @"original-token";
    source.pushToken = @"original-push";
    source.updatePackagesAttData = YES;
    source.adid = @"original-adid";
    source.trackingManagerAuthorizationStatus = 3;
    source.eventCount = 11;
    source.sessionCount = 12;
    source.subsessionCount = 13;
    source.timeSpent = 14.5;
    source.lastActivity = 15.5;
    source.sessionLength = 16.5;
    source.eventDeduplicationIds = [@[@"id-1", @"id-2"] mutableCopy];
    source.lastInterval = 17.5;
    source.isPersisted = YES;

    ADJActivityState *copy = [source deepCopy];
    copy.enabled = NO;
    copy.isGdprForgotten = NO;
    copy.askingAttribution = NO;
    copy.isThirdPartySharingDisabledForCoppa = NO;
    copy.dedupeToken = @"copy-token";
    copy.pushToken = @"copy-push";
    copy.updatePackagesAttData = NO;
    copy.adid = @"copy-adid";
    copy.trackingManagerAuthorizationStatus = 2;
    copy.eventCount = 21;
    copy.sessionCount = 22;
    copy.subsessionCount = 23;
    copy.timeSpent = 24.5;
    copy.lastActivity = 25.5;
    copy.sessionLength = 26.5;
    copy.eventDeduplicationIds = [copy.eventDeduplicationIds mutableCopy];
    [copy.eventDeduplicationIds removeAllObjects];
    [copy.eventDeduplicationIds addObjectsFromArray:@[@"copy-id-1", @"copy-id-2", @"copy-id-3"]];
    copy.lastInterval = 27.5;
    copy.isPersisted = NO;

    XCTAssertTrue(source.enabled);
    XCTAssertTrue(source.isGdprForgotten);
    XCTAssertTrue(source.askingAttribution);
    XCTAssertTrue(source.isThirdPartySharingDisabledForCoppa);
    XCTAssertEqualObjects(source.dedupeToken, @"original-token");
    XCTAssertEqualObjects(source.pushToken, @"original-push");
    XCTAssertTrue(source.updatePackagesAttData);
    XCTAssertEqualObjects(source.adid, @"original-adid");
    XCTAssertEqual(source.trackingManagerAuthorizationStatus, 3);
    XCTAssertEqual(source.eventCount, 11);
    XCTAssertEqual(source.sessionCount, 12);
    XCTAssertEqual(source.subsessionCount, 13);
    XCTAssertEqual(source.timeSpent, 14.5);
    XCTAssertEqual(source.lastActivity, 15.5);
    XCTAssertEqual(source.sessionLength, 16.5);
    XCTAssertEqual(source.eventDeduplicationIds.count, 2);
    XCTAssertEqualObjects(source.eventDeduplicationIds[0], @"id-1");
    XCTAssertEqualObjects(source.eventDeduplicationIds[1], @"id-2");
    XCTAssertEqual(source.lastInterval, 17.5);
    XCTAssertTrue(source.isPersisted);
}

- (void)testSessionPackageUsesPrimaryDedupeTokenForPersistedState {
    ADJActivityState *state = [[ADJActivityState alloc] init];
    state.dedupeToken = @"persisted-token";
    state.isPersisted = YES;
    state.sessionCount = 3;
    state.subsessionCount = 1;
    state.sessionLength = 10.0;
    state.timeSpent = 10.0;

    ADJActivityPackage *sessionPackage = [self buildSessionPackageWithActivityState:state];
    XCTAssertEqualObjects(sessionPackage.parameters[@"primary_dedupe_token"], @"persisted-token");
    XCTAssertNil(sessionPackage.parameters[@"secondary_dedupe_token"]);
}

- (void)testSessionPackageUsesSecondaryDedupeTokenForNonPersistedState {
    ADJActivityState *state = [[ADJActivityState alloc] init];
    state.dedupeToken = @"non-persisted-token";
    state.isPersisted = NO;
    state.sessionCount = 3;
    state.subsessionCount = 1;
    state.sessionLength = 10.0;
    state.timeSpent = 10.0;

    ADJActivityPackage *sessionPackage = [self buildSessionPackageWithActivityState:state];
    XCTAssertEqualObjects(sessionPackage.parameters[@"secondary_dedupe_token"], @"non-persisted-token");
    XCTAssertNil(sessionPackage.parameters[@"primary_dedupe_token"]);
}

- (void)testMutatingDeserializedGlobalParametersDoesNotThrow {
    NSDictionary *persistedCallbackParameters = @{@"cb-1": @"value-1"};
    NSDictionary *persistedPartnerParameters = @{@"pt-1": @"value-1"};

    [ADJUtil writeObject:persistedCallbackParameters
                fileName:kGlobalCallbackParametersFilename
              objectName:@"Global Callback parameters"
              syncObject:[ADJGlobalParameters class]];
    [ADJUtil writeObject:persistedPartnerParameters
                fileName:kGlobalPartnerParametersFilename
              objectName:@"Global Partner parameters"
              syncObject:[ADJGlobalParameters class]];

    ADJActivityHandler *handler = [[ADJActivityHandler alloc] init];
    handler.logger = [ADJAdjustFactory logger];
    handler.globalParameters = [[ADJGlobalParameters alloc] init];

    [handler readGlobalCallbackParametersI:handler];
    [handler readGlobalPartnerParametersI:handler];

    XCTAssertNoThrow([handler addGlobalCallbackParameterI:handler
                                                    param:@"value-2"
                                                   forKey:@"cb-2"]);
    XCTAssertNoThrow([handler addGlobalPartnerParameterI:handler
                                                   param:@"value-2"
                                                  forKey:@"pt-2"]);
}

- (void)testGlobalParametersConcurrentReadWriteRoundTrip {
    ADJActivityHandler *writer = [self buildBareActivityHandler];
    writer.globalParameters.callbackParameters = [NSMutableDictionary dictionary];
    writer.globalParameters.partnerParameters = [NSMutableDictionary dictionary];

    __block NSException *caughtException = nil;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t writerQueue =
        dispatch_queue_create("io.adjust.tests.global.writer", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t readerQueue =
        dispatch_queue_create("io.adjust.tests.global.reader", DISPATCH_QUEUE_CONCURRENT);

    NSUInteger iterationCount = 200;
    for (NSUInteger i = 0; i < iterationCount; i++) {
        dispatch_group_async(group, writerQueue, ^{
            @autoreleasepool {
                @try {
                    NSString *callbackKey = [NSString stringWithFormat:@"cb-%lu", (unsigned long)i];
                    NSString *partnerKey = [NSString stringWithFormat:@"pt-%lu", (unsigned long)i];
                    writer.globalParameters.callbackParameters[callbackKey] = @"value";
                    writer.globalParameters.partnerParameters[partnerKey] = @"value";
                    [writer writeGlobalCallbackParametersI:writer];
                    [writer writeGlobalPartnerParametersI:writer];
                } @catch (NSException *exception) {
                    @synchronized (self) {
                        if (caughtException == nil) {
                            caughtException = exception;
                        }
                    }
                }
            }
        });

        dispatch_group_async(group, readerQueue, ^{
            @autoreleasepool {
                @try {
                    ADJActivityHandler *reader = [self buildBareActivityHandler];
                    [reader readGlobalCallbackParametersI:reader];
                    [reader readGlobalPartnerParametersI:reader];
                    if (reader.globalParameters.callbackParameters != nil) {
                        reader.globalParameters.callbackParameters[@"probe"] = @"1";
                        [reader.globalParameters.callbackParameters removeObjectForKey:@"probe"];
                    }
                    if (reader.globalParameters.partnerParameters != nil) {
                        reader.globalParameters.partnerParameters[@"probe"] = @"1";
                        [reader.globalParameters.partnerParameters removeObjectForKey:@"probe"];
                    }
                } @catch (NSException *exception) {
                    @synchronized (self) {
                        if (caughtException == nil) {
                            caughtException = exception;
                        }
                    }
                }
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    XCTAssertNil(caughtException);

    ADJActivityHandler *finalReader = [self buildBareActivityHandler];
    [finalReader readGlobalCallbackParametersI:finalReader];
    [finalReader readGlobalPartnerParametersI:finalReader];

    XCTAssertTrue([finalReader.globalParameters.callbackParameters isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([finalReader.globalParameters.partnerParameters isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertNoThrow([finalReader.globalParameters.callbackParameters setObject:@"final" forKey:@"cb-final"]);
    XCTAssertNoThrow([finalReader.globalParameters.partnerParameters setObject:@"final" forKey:@"pt-final"]);
}

- (void)testActivityStatePersistRestoreUnderConcurrentAccess {
    [ADJActivityState setEventDeduplicationIdsArraySize:20];

    ADJActivityHandler *writer = [self buildBareActivityHandler];
    writer.activityState = [[ADJActivityState alloc] init];
    writer.activityState.eventDeduplicationIds = [NSMutableArray array];

    __block NSException *caughtException = nil;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t writerQueue =
        dispatch_queue_create("io.adjust.tests.activitystate.writer", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t readerQueue =
        dispatch_queue_create("io.adjust.tests.activitystate.reader", DISPATCH_QUEUE_CONCURRENT);

    NSUInteger iterationCount = 120;
    for (NSUInteger i = 0; i < iterationCount; i++) {
        dispatch_group_async(group, writerQueue, ^{
            @autoreleasepool {
                @try {
                    writer.activityState.sessionCount = (int)i;
                    writer.activityState.subsessionCount = (int)(i + 1);
                    writer.activityState.timeSpent = (double)i;
                    writer.activityState.sessionLength = (double)i + 0.5;
                    [writer.activityState addEventDeduplicationId:[NSString stringWithFormat:@"id-%lu", (unsigned long)i]];
                    [writer writeActivityStateI:writer];
                } @catch (NSException *exception) {
                    @synchronized (self) {
                        if (caughtException == nil) {
                            caughtException = exception;
                        }
                    }
                }
            }
        });

        dispatch_group_async(group, readerQueue, ^{
            @autoreleasepool {
                @try {
                    ADJActivityHandler *reader = [self buildBareActivityHandler];
                    [reader readActivityState];
                    if (reader.activityState != nil) {
                        [reader.activityState addEventDeduplicationId:[NSString stringWithFormat:@"probe-%lu", (unsigned long)i]];
                        reader.activityState.timeSpent += 1.0;
                    }
                } @catch (NSException *exception) {
                    @synchronized (self) {
                        if (caughtException == nil) {
                            caughtException = exception;
                        }
                    }
                }
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    XCTAssertNil(caughtException);

    ADJActivityHandler *finalReader = [self buildBareActivityHandler];
    [finalReader readActivityState];
    XCTAssertNotNil(finalReader.activityState);
    XCTAssertTrue([finalReader.activityState.eventDeduplicationIds isKindOfClass:[NSMutableArray class]]);
    XCTAssertNoThrow([finalReader.activityState addEventDeduplicationId:@"final-id"]);
}

- (void)testPackageQueuePersistRestoreUnderConcurrentAccess {
    ADJPackageHandler *writer = [[ADJPackageHandler alloc] init];
    writer.packageQueue = [NSMutableArray array];

    __block NSException *caughtException = nil;
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t writerQueue =
        dispatch_queue_create("io.adjust.tests.packagequeue.writer", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t readerQueue =
        dispatch_queue_create("io.adjust.tests.packagequeue.reader", DISPATCH_QUEUE_CONCURRENT);

    NSUInteger iterationCount = 120;
    for (NSUInteger i = 0; i < iterationCount; i++) {
        dispatch_group_async(group, writerQueue, ^{
            @autoreleasepool {
                @try {
                    [writer.packageQueue removeAllObjects];
                    [writer.packageQueue addObject:[self buildQueuePackageWithIndex:i]];
                    [writer.packageQueue addObject:[self buildQueuePackageWithIndex:i + 1000]];
                    [writer writePackageQueueS:writer];
                } @catch (NSException *exception) {
                    @synchronized (self) {
                        if (caughtException == nil) {
                            caughtException = exception;
                        }
                    }
                }
            }
        });

        dispatch_group_async(group, readerQueue, ^{
            @autoreleasepool {
                @try {
                    ADJPackageHandler *reader = [[ADJPackageHandler alloc] init];
                    [reader readPackageQueueI:reader];
                    if (reader.packageQueue.count == 0) {
                        return;
                    }

                    ADJActivityPackage *decodedPackage = reader.packageQueue[0];
                    if (decodedPackage.parameters != nil) {
                        NSMutableDictionary *mutableParameters = [decodedPackage.parameters mutableCopy];
                        mutableParameters[@"probe"] = @"1";
                        [mutableParameters removeObjectForKey:@"probe"];
                        decodedPackage.parameters = mutableParameters;
                    }

                    NSMutableDictionary *callbackParameters =
                        decodedPackage.callbackParameters != nil
                        ? [decodedPackage.callbackParameters mutableCopy]
                        : [NSMutableDictionary dictionary];
                    callbackParameters[@"probe"] = @"1";
                    decodedPackage.callbackParameters = callbackParameters;

                    [reader.packageQueue addObject:[self buildQueuePackageWithIndex:i + 2000]];
                    [reader.packageQueue removeLastObject];
                } @catch (NSException *exception) {
                    @synchronized (self) {
                        if (caughtException == nil) {
                            caughtException = exception;
                        }
                    }
                }
            }
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    XCTAssertNil(caughtException);

    ADJPackageHandler *finalReader = [[ADJPackageHandler alloc] init];
    [finalReader readPackageQueueI:finalReader];
    XCTAssertTrue([finalReader.packageQueue isKindOfClass:[NSMutableArray class]]);
    XCTAssertGreaterThan(finalReader.packageQueue.count, (NSUInteger)0);

    ADJActivityPackage *finalPackage = finalReader.packageQueue[0];
    NSMutableDictionary *finalMutableParameters = finalPackage.parameters != nil
        ? [finalPackage.parameters mutableCopy]
        : [NSMutableDictionary dictionary];
    XCTAssertNoThrow([finalMutableParameters setObject:@"final" forKey:@"probe-final"]);
    finalPackage.parameters = finalMutableParameters;
}

/*
- (void)testPackageQueueMutationAttackRaceReproducer {
    __block NSException *caughtException = nil;

    for (NSUInteger round = 0; round < 30; round++) {
        ADJPackageHandler *writer = [[ADJPackageHandler alloc] init];
        writer.packageQueue = [NSMutableArray array];

        ADJActivityPackage *attackedPackage = [self buildQueuePackageWithIndex:round];
        [writer.packageQueue addObject:[attackedPackage deepCopy]];

        __block BOOL keepMutating = YES;
        dispatch_group_t group = dispatch_group_create();

        dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
            @autoreleasepool {
                for (NSUInteger i = 0; i < 150000 && keepMutating; i++) {
                    @autoreleasepool {
                        @try {
                            NSMutableDictionary *params = attackedPackage.parameters != nil
                                ? [attackedPackage.parameters mutableCopy]
                                : [NSMutableDictionary dictionary];
                            NSString *key = [NSString stringWithFormat:@"stress_%lu", (unsigned long)(i % 32)];
                            NSString *value = [NSString stringWithFormat:@"v_%lu", (unsigned long)i];
                            if ((i % 3) == 0) {
                                params[key] = value;
                            } else if ((i % 3) == 1) {
                                [params removeObjectForKey:key];
                            } else {
                                params[key] = [NSString stringWithFormat:@"v_%lu_b", (unsigned long)i];
                            }
                            attackedPackage.parameters = params;
                            if ((i % 5) == 0) {
                                attackedPackage.waitBeforeSend = (double)(i % 17);
                            }
                            if ((i % 9) == 0) {
                                attackedPackage.callbackParameters = @{
                                    @"stress_cb": [NSString stringWithFormat:@"cb_%lu", (unsigned long)i]
                                };
                            }
                            if ((i % 11) == 0) {
                                attackedPackage.partnerParameters = @{
                                    @"stress_partner": [NSString stringWithFormat:@"p_%lu", (unsigned long)i]
                                };
                            }
                        } @catch (NSException *exception) {
                            @synchronized (self) {
                                if (caughtException == nil) {
                                    caughtException = exception;
                                }
                            }
                        }
                    }
                }
            }
        });

        dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            @autoreleasepool {
                for (NSUInteger i = 0; i < 2500; i++) {
                    @autoreleasepool {
                        @try {
                            [writer writePackageQueueS:writer];
                        } @catch (NSException *exception) {
                            @synchronized (self) {
                                if (caughtException == nil) {
                                    caughtException = exception;
                                }
                            }
                        }
                    }
                }
                keepMutating = NO;
            }
        });

        dispatch_group_async(group, dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
            @autoreleasepool {
                for (NSUInteger i = 0; i < 1200; i++) {
                    @autoreleasepool {
                        @try {
                            ADJPackageHandler *reader = [[ADJPackageHandler alloc] init];
                            [reader readPackageQueueI:reader];
                            if (reader.packageQueue.count == 0) {
                                continue;
                            }
                            ADJActivityPackage *decodedPackage = reader.packageQueue[0];
                            NSMutableDictionary *mutableParameters = decodedPackage.parameters != nil
                                ? [decodedPackage.parameters mutableCopy]
                                : [NSMutableDictionary dictionary];
                            mutableParameters[@"probe"] = @"x";
                            [mutableParameters removeObjectForKey:@"probe"];
                            decodedPackage.parameters = mutableParameters;
                        } @catch (NSException *exception) {
                            @synchronized (self) {
                                if (caughtException == nil) {
                                    caughtException = exception;
                                }
                            }
                        }
                    }
                }
            }
        });

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }

    XCTAssertNil(caughtException);
}
*/

- (void)testEventCopyStressSnapshotIsolation {
    ADJEvent *event = [[ADJEvent alloc] initWithEventToken:@"ev1234"];
    XCTAssertNotNil(event);

    for (NSUInteger i = 0; i < 750; i++) {
        @autoreleasepool {
            NSString *callbackId = [NSString stringWithFormat:@"cb_%lu", (unsigned long)i];
            NSString *dedupeId = [NSString stringWithFormat:@"dd_%lu", (unsigned long)i];
            NSString *transactionId = [NSString stringWithFormat:@"tx_%lu", (unsigned long)i];
            NSString *productId = [NSString stringWithFormat:@"prd_%lu", (unsigned long)i];
            NSString *callbackValue = [NSString stringWithFormat:@"c_%lu", (unsigned long)i];
            NSString *partnerValue = [NSString stringWithFormat:@"p_%lu", (unsigned long)i];

            [event setRevenue:((double)i + 1.0) currency:@"EUR"];
            [event setCallbackId:callbackId];
            [event setDeduplicationId:dedupeId];
            [event setTransactionId:transactionId];
            [event setProductId:productId];
            [event addCallbackParameter:@"cb_key" value:callbackValue];
            [event addPartnerParameter:@"pt_key" value:partnerValue];

            ADJEvent *snapshot = [event copy];
            XCTAssertNotNil(snapshot);

            [event setCallbackId:@"changed_after_copy"];
            [event addCallbackParameter:@"cb_key" value:@"changed_after_copy"];
            [event addPartnerParameter:@"pt_key" value:@"changed_after_copy"];

            XCTAssertEqualObjects(snapshot.callbackId, callbackId);
            XCTAssertEqualObjects(snapshot.deduplicationId, dedupeId);
            XCTAssertEqualObjects(snapshot.transactionId, transactionId);
            XCTAssertEqualObjects(snapshot.productId, productId);
            XCTAssertEqualObjects(snapshot.callbackParameters[@"cb_key"], callbackValue);
            XCTAssertEqualObjects(snapshot.partnerParameters[@"pt_key"], partnerValue);
        }
    }
}

- (void)testAdRevenueCopyStressSnapshotIsolation {
    ADJAdRevenue *adRevenue = [[ADJAdRevenue alloc] initWithSource:@"admob"];
    XCTAssertNotNil(adRevenue);

    for (NSUInteger i = 0; i < 750; i++) {
        @autoreleasepool {
            NSString *callbackValue = [NSString stringWithFormat:@"c_%lu", (unsigned long)i];
            NSString *partnerValue = [NSString stringWithFormat:@"p_%lu", (unsigned long)i];
            NSString *network = [NSString stringWithFormat:@"net_%lu", (unsigned long)i];
            NSString *unit = [NSString stringWithFormat:@"unit_%lu", (unsigned long)i];
            NSString *placement = [NSString stringWithFormat:@"placement_%lu", (unsigned long)i];
            NSNumber *impressions = @((int)i);

            [adRevenue setRevenue:((double)i + 0.55) currency:@"USD"];
            [adRevenue setAdImpressionsCount:(int)i];
            [adRevenue setAdRevenueNetwork:network];
            [adRevenue setAdRevenueUnit:unit];
            [adRevenue setAdRevenuePlacement:placement];
            [adRevenue addCallbackParameter:@"cb_key" value:callbackValue];
            [adRevenue addPartnerParameter:@"pt_key" value:partnerValue];

            ADJAdRevenue *snapshot = [adRevenue copy];
            XCTAssertNotNil(snapshot);

            [adRevenue setAdRevenueNetwork:@"changed_after_copy"];
            [adRevenue addCallbackParameter:@"cb_key" value:@"changed_after_copy"];
            [adRevenue addPartnerParameter:@"pt_key" value:@"changed_after_copy"];

            XCTAssertEqualObjects(snapshot.callbackParameters[@"cb_key"], callbackValue);
            XCTAssertEqualObjects(snapshot.partnerParameters[@"pt_key"], partnerValue);
            XCTAssertEqualObjects(snapshot.adRevenueNetwork, network);
            XCTAssertEqualObjects(snapshot.adRevenueUnit, unit);
            XCTAssertEqualObjects(snapshot.adRevenuePlacement, placement);
            XCTAssertEqualObjects(snapshot.adImpressionsCount, impressions);
        }
    }
}

- (void)testAppStoreSubscriptionCopyStressSnapshotIsolation {
    ADJAppStoreSubscription *subscription =
        [[ADJAppStoreSubscription alloc] initWithPrice:[NSDecimalNumber decimalNumberWithString:@"9.99"]
                                              currency:@"EUR"
                                         transactionId:@"tx_base"];
    XCTAssertNotNil(subscription);

    for (NSUInteger i = 0; i < 750; i++) {
        @autoreleasepool {
            NSDate *transactionDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)(1700000000 + i)];
            NSString *salesRegion = [NSString stringWithFormat:@"R%lu", (unsigned long)i];
            NSString *callbackValue = [NSString stringWithFormat:@"c_%lu", (unsigned long)i];
            NSString *partnerValue = [NSString stringWithFormat:@"p_%lu", (unsigned long)i];

            [subscription setTransactionDate:transactionDate];
            [subscription setSalesRegion:salesRegion];
            [subscription addCallbackParameter:@"cb_key" value:callbackValue];
            [subscription addPartnerParameter:@"pt_key" value:partnerValue];

            ADJAppStoreSubscription *snapshot = [subscription copy];
            XCTAssertNotNil(snapshot);

            [subscription setSalesRegion:@"changed_after_copy"];
            [subscription addCallbackParameter:@"cb_key" value:@"changed_after_copy"];
            [subscription addPartnerParameter:@"pt_key" value:@"changed_after_copy"];

            XCTAssertEqualObjects(snapshot.transactionDate, transactionDate);
            XCTAssertEqualObjects(snapshot.salesRegion, salesRegion);
            XCTAssertEqualObjects(snapshot.callbackParameters[@"cb_key"], callbackValue);
            XCTAssertEqualObjects(snapshot.partnerParameters[@"pt_key"], partnerValue);
        }
    }
}

- (void)testAppStorePurchaseCopyStressCopiesAllFields {
    for (NSUInteger i = 0; i < 2500; i++) {
        @autoreleasepool {
            NSString *transactionId = [NSString stringWithFormat:@"tx_%lu", (unsigned long)i];
            NSString *productId = [NSString stringWithFormat:@"prd_%lu", (unsigned long)i];

            ADJAppStorePurchase *purchase =
                [[ADJAppStorePurchase alloc] initWithTransactionId:transactionId
                                                          productId:productId];
            XCTAssertNotNil(purchase);

            ADJAppStorePurchase *snapshot = [purchase copy];
            XCTAssertNotNil(snapshot);
            XCTAssertNotEqual(purchase, snapshot);
            XCTAssertEqualObjects(snapshot.transactionId, transactionId);
            XCTAssertEqualObjects(snapshot.productId, productId);
        }
    }
}

- (void)testThirdPartySharingCopyStressSnapshotIsolation {
    ADJThirdPartySharing *thirdPartySharing = [[ADJThirdPartySharing alloc] initWithIsEnabled:@YES];
    XCTAssertNotNil(thirdPartySharing);

    for (NSUInteger i = 0; i < 500; i++) {
        @autoreleasepool {
            NSString *key = [NSString stringWithFormat:@"k_%lu", (unsigned long)i];
            NSString *value = [NSString stringWithFormat:@"v_%lu", (unsigned long)i];
            BOOL enabled = ((i % 2) == 0);

            [thirdPartySharing addGranularOption:@"partner_a" key:key value:value];
            [thirdPartySharing addPartnerSharingSetting:@"partner_a" key:key value:enabled];

            ADJThirdPartySharing *snapshot = [thirdPartySharing copy];
            XCTAssertNotNil(snapshot);

            [thirdPartySharing addGranularOption:@"partner_a" key:key value:@"changed_after_copy"];
            [thirdPartySharing addPartnerSharingSetting:@"partner_a" key:key value:!enabled];

            NSDictionary *snapshotGranularPartner = snapshot.granularOptions[@"partner_a"];
            NSDictionary *snapshotPartnerSettings = snapshot.partnerSharingSettings[@"partner_a"];
            XCTAssertEqualObjects(snapshotGranularPartner[key], value);
            XCTAssertEqualObjects(snapshotPartnerSettings[key], @(enabled));

            [snapshot addGranularOption:@"partner_a" key:@"copy_only" value:@"yes"];
            NSDictionary *sourceGranularPartner = thirdPartySharing.granularOptions[@"partner_a"];
            XCTAssertNil(sourceGranularPartner[@"copy_only"]);
        }
    }
}

- (void)testDeeplinkCopyStressSnapshotIsolation {
    ADJDeeplink *deeplink = [[ADJDeeplink alloc] initWithDeeplink:[NSURL URLWithString:@"adjust-test://open"]];
    XCTAssertNotNil(deeplink);

    for (NSUInteger i = 0; i < 1000; i++) {
        @autoreleasepool {
            NSString *referrerString = [NSString stringWithFormat:@"https://example.com/ref/%lu", (unsigned long)i];
            NSString *changedReferrerString = [NSString stringWithFormat:@"https://example.com/changed/%lu", (unsigned long)i];
            NSURL *referrer = [NSURL URLWithString:referrerString];
            NSURL *changedReferrer = [NSURL URLWithString:changedReferrerString];

            [deeplink setReferrer:referrer];
            ADJDeeplink *snapshot = [deeplink copy];
            XCTAssertNotNil(snapshot);

            [deeplink setReferrer:changedReferrer];

            XCTAssertEqualObjects(snapshot.deeplink.absoluteString, @"adjust-test://open");
            XCTAssertEqualObjects(snapshot.referrer.absoluteString, referrerString);
        }
    }
}

- (void)testDictionaryDeepCopyReturnsIndependentData {
    NSMutableDictionary *nestedSource = [@{@"inner": @"value"} mutableCopy];
    NSMutableDictionary *source = [@{@"nested": nestedSource, @42: @"answer"} mutableCopy];

    NSDictionary *copy = [ADJUtil dictionaryDeepCopy:source];

    nestedSource[@"inner"] = @"changed";
    source[@"new"] = @"new-value";

    NSDictionary *nestedCopy = copy[@"nested"];
    XCTAssertEqualObjects(nestedCopy[@"inner"], @"value");
    XCTAssertNil(copy[@"new"]);
    XCTAssertEqualObjects(copy[@"42"], @"answer");
}

- (void)testDictionaryDeepCopyHandlesNil {
    XCTAssertNil([ADJUtil dictionaryDeepCopy:nil]);
}

- (void)testGlobalParametersDeepCopyCreatesIndependentMutableDictionaries {
    ADJGlobalParameters *source = [ADJGlobalParameters new];
    source.callbackParameters = [@{@"cb": @"1"} mutableCopy];
    source.partnerParameters = [@{@"pt": @"1"} mutableCopy];

    ADJGlobalParameters *copy = [source deepCopy];
    copy.callbackParameters[@"cb"] = @"2";
    copy.partnerParameters[@"pt"] = @"2";

    XCTAssertEqualObjects(source.callbackParameters[@"cb"], @"1");
    XCTAssertEqualObjects(source.partnerParameters[@"pt"], @"1");
    XCTAssertTrue([copy.callbackParameters isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([copy.partnerParameters isKindOfClass:[NSMutableDictionary class]]);
}

- (void)testEventMetadataDeepCopyIsIndependent {
    ADJEventMetadata *source = [ADJEventMetadata new];
    XCTAssertEqual([source incrementedSequenceForEventToken:@"token"], (NSUInteger)1);

    ADJEventMetadata *copy = [source deepCopy];
    XCTAssertEqual([copy incrementedSequenceForEventToken:@"token"], (NSUInteger)2);
    XCTAssertEqual([source incrementedSequenceForEventToken:@"token"], (NSUInteger)2);
}

- (void)testPackageParamsCopyCopiesAllFields {
    ADJPackageParams *source = [ADJPackageParams new];
    source.fbAnonymousId = @"fb";
    source.idfv = @"idfv";
    source.clientSdk = @"sdk";
    source.bundleIdentifier = @"bundle";
    source.buildNumber = @"42";
    source.versionNumber = @"1.2.3";
    source.deviceType = @"type";
    source.deviceName = @"name";
    source.osName = @"ios";
    source.osVersion = @"18";
    source.installedAt = @"installed";
    source.startedAt = 7;
    source.idfaCached = @"idfa";

    ADJPackageParams *copy = [source copy];
    XCTAssertNotEqual(source, copy);
    XCTAssertEqualObjects(copy.fbAnonymousId, source.fbAnonymousId);
    XCTAssertEqualObjects(copy.idfv, source.idfv);
    XCTAssertEqualObjects(copy.clientSdk, source.clientSdk);
    XCTAssertEqualObjects(copy.bundleIdentifier, source.bundleIdentifier);
    XCTAssertEqualObjects(copy.buildNumber, source.buildNumber);
    XCTAssertEqualObjects(copy.versionNumber, source.versionNumber);
    XCTAssertEqualObjects(copy.deviceType, source.deviceType);
    XCTAssertEqualObjects(copy.deviceName, source.deviceName);
    XCTAssertEqualObjects(copy.osName, source.osName);
    XCTAssertEqualObjects(copy.osVersion, source.osVersion);
    XCTAssertEqualObjects(copy.installedAt, source.installedAt);
    XCTAssertEqual(copy.startedAt, source.startedAt);
    XCTAssertEqualObjects(copy.idfaCached, source.idfaCached);
}

- (void)testActivityPackageDeepCopyIsolatedFromOriginalMutations {
    ADJActivityPackage *source = [ADJActivityPackage new];
    source.path = @"/session";
    source.clientSdk = @"ios5.0.0";
    source.parameters = [@{@"key": @"value", @"nested": @{@"inner": @"p-1"}} mutableCopy];
    source.callbackParameters = @{@"cb": @"1", @"nested": @{@"inner": @"cb-1"}};
    source.partnerParameters = @{@"pt": @"1", @"nested": @{@"inner": @"pt-1"}};
    __block NSUInteger sourceCallbackCallCount = 0;
    __block NSUInteger copyCallbackCallCount = 0;
    source.purchaseVerificationCallback = ^(id _unused) {
        sourceCallbackCallCount += 1;
    };
    ADJEvent *sourceEvent = [[ADJEvent alloc] initWithEventToken:@"abc123"];
    XCTAssertNotNil(sourceEvent);
    source.event = sourceEvent;
    source.errorCount = 2;
    source.firstErrorCode = @100;
    source.lastErrorCode = @200;
    source.waitBeforeSend = 1.5;
    source.suffix = @"suffix";
    source.activityKind = ADJActivityKindSession;

    ADJActivityPackage *copy = [source deepCopy];
    copy.path = @"/event";
    copy.clientSdk = @"ios6.0.0";
    NSMutableDictionary *copyParameters = [copy.parameters mutableCopy];
    copyParameters[@"key"] = @"changed";
    copyParameters[@"added"] = @"new";
    copy.parameters = copyParameters;
    NSMutableDictionary *copyCallbackParameters = [copy.callbackParameters mutableCopy];
    copyCallbackParameters[@"cb"] = @"2";
    copy.callbackParameters = copyCallbackParameters;
    NSMutableDictionary *copyPartnerParameters = [copy.partnerParameters mutableCopy];
    copyPartnerParameters[@"pt"] = @"2";
    copy.partnerParameters = copyPartnerParameters;
    copy.purchaseVerificationCallback = ^(id _unused) {
        copyCallbackCallCount += 1;
    };
    ADJEvent *copyEvent = [[ADJEvent alloc] initWithEventToken:@"def456"];
    XCTAssertNotNil(copyEvent);
    copy.event = copyEvent;
    copy.errorCount = 9;
    copy.firstErrorCode = @900;
    copy.lastErrorCode = @901;
    copy.waitBeforeSend = 9.5;
    copy.suffix = @"changed-suffix";
    copy.activityKind = ADJActivityKindEvent;

    source.purchaseVerificationCallback(nil);
    copy.purchaseVerificationCallback(nil);

    XCTAssertEqualObjects(source.path, @"/session");
    XCTAssertEqualObjects(source.clientSdk, @"ios5.0.0");
    XCTAssertEqualObjects(source.parameters[@"key"], @"value");
    XCTAssertNil(source.parameters[@"added"]);
    XCTAssertEqualObjects(source.callbackParameters[@"cb"], @"1");
    XCTAssertEqualObjects(source.partnerParameters[@"pt"], @"1");
    XCTAssertEqual(sourceCallbackCallCount, (NSUInteger)1);
    XCTAssertEqual(copyCallbackCallCount, (NSUInteger)1);
    XCTAssertEqual(source.event, sourceEvent);
    XCTAssertEqual(source.errorCount, (NSUInteger)2);
    XCTAssertEqualObjects(source.firstErrorCode, @100);
    XCTAssertEqualObjects(source.lastErrorCode, @200);
    XCTAssertEqual(source.waitBeforeSend, 1.5);
    XCTAssertEqualObjects(source.suffix, @"suffix");
    XCTAssertEqual(source.activityKind, ADJActivityKindSession);
}

@end

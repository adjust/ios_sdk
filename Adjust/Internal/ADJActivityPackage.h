//
//  ADJActivityPackage.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJActivityKind.h"
#import "ADJEvent.h"

@interface ADJActivityPackage : NSObject <NSSecureCoding>

// Data

@property (nonatomic, copy) NSString *path;

@property (nonatomic, copy) NSString *clientSdk;

@property (nonatomic, strong) NSMutableDictionary *parameters;

@property (nonatomic, strong) NSDictionary *partnerParameters;

@property (nonatomic, strong) NSDictionary *callbackParameters;

@property (nonatomic, copy) void (^purchaseVerificationCallback)(id);

@property (nonatomic, strong) ADJEvent *event;

@property (nonatomic, assign) NSUInteger errorCount;

@property (nonatomic, copy) NSNumber *firstErrorCode;

@property (nonatomic, copy) NSNumber *lastErrorCode;

@property (nonatomic, assign) double waitBeforeSend;

- (void)addError:(NSNumber *)errorCode;

// Logs

@property (nonatomic, copy) NSString *suffix;

@property (nonatomic, assign) ADJActivityKind activityKind;

- (NSString *)extendedString;

- (NSString *)successMessage;

- (NSString *)failureMessage;

@end

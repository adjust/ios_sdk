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

@property (atomic, copy) NSString *path;

@property (atomic, copy) NSString *clientSdk;

@property (atomic, copy) NSDictionary *parameters;

@property (atomic, copy) NSDictionary *partnerParameters;

@property (atomic, copy) NSDictionary *callbackParameters;

@property (atomic, copy) void (^purchaseVerificationCallback)(id);

@property (atomic, strong) ADJEvent *event;

@property (atomic, assign) NSUInteger errorCount;

@property (atomic, copy) NSNumber *firstErrorCode;

@property (atomic, copy) NSNumber *lastErrorCode;

@property (atomic, assign) double waitBeforeSend;

- (void)addError:(NSNumber *)errorCode;
- (ADJActivityPackage *)deepCopy;

// Logs

@property (atomic, copy) NSString *suffix;

@property (atomic, assign) ADJActivityKind activityKind;

- (NSString *)extendedString;

- (NSString *)successMessage;

- (NSString *)failureMessage;

@end

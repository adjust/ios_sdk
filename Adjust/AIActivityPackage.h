//
//  AIActivityPackage.h
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "AIActivityKind.h"

@interface AIActivityPackage : NSObject <NSCoding>

// data
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *clientSdk;
@property (nonatomic, retain) NSDictionary *parameters;

// logs
@property (nonatomic, assign) AIActivityKind activityKind;
@property (nonatomic, copy) NSString *suffix;

- (NSString *)extendedString;
- (NSString *)successMessage;
- (NSString *)failureMessage;

@end

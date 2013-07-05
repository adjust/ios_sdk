//
//  AIActivityPackage.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 03.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

@interface AIActivityPackage : NSObject <NSCoding>

// data
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *clientSdk;
@property (nonatomic, retain) NSDictionary *parameters;

// logs
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *suffix;

- (NSString *)extendedString;
- (NSString *)successMessage;
- (NSString *)failureMessage;

@end
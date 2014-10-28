//
//  AIUserAgent.h
//  adjust
//
//  Created by Pedro Filipe on 28/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIUserAgent : NSObject<NSCopying>

@property (nonatomic, copy) NSString *bundeIdentifier;
@property (nonatomic, copy) NSString *bundleVersion;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *osName;
@property (nonatomic, copy) NSString *systemVersion;
@property (nonatomic, copy) NSString *languageCode;
@property (nonatomic, copy) NSString *countryCode;

@end

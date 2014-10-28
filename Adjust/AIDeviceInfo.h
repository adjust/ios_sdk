//
//  AIDeviceInfo.h
//  adjust
//
//  Created by Pedro Filipe on 17/10/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIDeviceInfo : NSObject

@property (nonatomic, copy) NSString *appToken;
@property (nonatomic, copy) NSString *macSha1;
@property (nonatomic, copy) NSString *macShortMd5;
@property (nonatomic, copy) NSString *idForAdvertisers;
@property (nonatomic, copy) NSString *fbAttributionId;
@property (nonatomic, copy) NSString *environment;
@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, copy) NSString *clientSdk;
//@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) BOOL trackingEnabled;
@property (nonatomic, assign) BOOL isIad;
@property (nonatomic, copy) NSString *vendorId;
@property (nonatomic, copy) NSString *pushToken;


@end

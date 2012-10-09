//
//  UIDevice+AIAdditions.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDevice(AIAdditions)

- (NSString *)aiIdForAdvertisers;
- (NSString *)aiMacAddress;
- (NSString *)aiDeviceType;
- (NSString *)aiDeviceName;

@end

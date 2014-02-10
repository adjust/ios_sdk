//
//  UIDevice+AIAdditions.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012-2013 adeven. All rights reserved.
//

@interface UIDevice(AIAdditions)

- (BOOL)aiTrackingEnabled;
- (NSString *)aiIdForAdvertisers;
- (NSString *)aiFbAttributionId;
- (NSString *)aiMacAddress;
- (NSString *)aiDeviceType;
- (NSString *)aiDeviceName;
- (NSString *)aiCreateUuid;

@end

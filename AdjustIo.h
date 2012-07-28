//
//  AdjustIo.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdjustIo : NSObject


#pragma mark class methods (for most common use cases)

// tell AdjustIo that the application did finish launching
+ (void)appDidLaunch:(NSString *)appId;

// enable tracking of the UDID (which is discouraged by Apple and disabled by default)
+ (void)trackDeviceId;


#pragma mark instance methods (when multipe instances are needed)

- (void)appDidLaunch:(NSString *)appId;
- (void)trackDeviceId;

@end

//
//  TestLibraryBridge.h
//  AdjustWebBridgeTestApp
//
//  Created by Aditi Agrawal on 24/07/24.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdjustBridge/AdjustBridge.h>
#import "ATLTestLibrary.h"

// simulator
//static NSString * urlOverwrite = @"http://127.0.0.1:8080";
//static NSString * controlUrl = @"ws://127.0.0.1:1987";

// device
static NSString * urlOverwrite = @"http://192.168.178.81:8080";
static NSString * controlUrl = @"ws://192.168.178.81:1987";

@interface TestLibraryBridge : NSObject<AdjustCommandDelegate>

- (id)initWithAdjustBridge:(AdjustBridge *)adjustBridge;

@end


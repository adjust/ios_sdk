//
//  TestLibraryBridge.h
//  AdjustWebBridgeTestApp
//
//  Created by Pedro on 06.08.18.
//  Copyright © 2018 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATLTestLibrary.h"
#import "AdjustBridgeRegister.h"

static NSString * baseUrl = @"http://127.0.0.1:8080";
static NSString * gdprUrl = @"http://127.0.0.1:8080";

@interface TestLibraryBridge : NSObject<AdjustCommandDelegate>

- (id)initWithAdjustBridgeRegister:(AdjustBridgeRegister *)adjustBridgeRegister;

@end

//
//  AdjustInit.h
//  example
//
//  Created by Pedro Filipe on 18/11/14.
//  Copyright (c) 2014 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJConfig.h"

@interface ExampleAdjustHelper : NSObject

+ (void) initAdjust: (NSObject<AdjustDelegate> *)adjustDelegate;

+ (void) triggerEvent: (NSString*) eventToken;
@end

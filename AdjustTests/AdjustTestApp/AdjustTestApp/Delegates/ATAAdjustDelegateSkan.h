//
//  ATAAdjustDelegateSkan.h
//  AdjustTestApp
//
//  Created by Uglješa Erceg (uerceg) on 23rd April 2024.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Adjust.h"
#import "ATLTestLibrary.h"

@interface ATAAdjustDelegateSkan : NSObject<AdjustDelegate>

- (id)initWithTestLibrary:(ATLTestLibrary *)testLibrary andExtraPath:(NSString *)extraPath;

@end

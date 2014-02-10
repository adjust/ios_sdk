//
//  AILoggerMock.h
//  AdjustIo
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AILogger.h"

@interface AILoggerMock : NSObject <AILogger>
    - (void)test:(NSString *)message, ...;
@end

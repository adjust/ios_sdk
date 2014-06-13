//
//  AILoggerMock.h
//  Adjust
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AILogger.h"

static const int AILogLevelTest = 0;

@interface AILoggerMock : NSObject <AILogger>
    - (void)test:(NSString *)message, ...;
    - (BOOL) containsMessage:(NSInteger)logLevel beginsWith:(NSString *)beginsWith;
@end

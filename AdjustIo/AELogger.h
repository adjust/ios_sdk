//
//  AELogger.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

// A simple logger with one log level.
@interface AELogger : NSObject

@property (copy) NSString *logTag;
@property (assign) BOOL loggingEnabled;

- (id)initWithTag:(NSString *)logTag enabled:(BOOL)enabled;
+ (AELogger *)loggerWithTag:(NSString *)logTag enabled:(BOOL)enabled;

- (void)log:(NSString *)message, ...;

@end

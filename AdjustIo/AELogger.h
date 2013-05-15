//
//  AELogger.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AELogLevelVerbose = 1,
    AELogLevelDebug   = 2,
    AELogLevelInfo    = 3,
    AELogLevelWarn    = 4,
    AELogLevelError   = 5,
    AELogLevelAssert  = 6
} AELogLevel;

// A simple logger with multiple log levels.
@interface AELogger : NSObject

@property (copy) NSString *logTag;
@property (assign) AELogLevel logLevel;

- (id)initWithTag:(NSString *)logTag;
+ (AELogger *)loggerWithTag:(NSString *)logTag;

- (void)verbose:(NSString *)message, ...;
- (void)debug:  (NSString *)message, ...;
- (void)info:   (NSString *)message, ...;
- (void)warn:   (NSString *)message, ...;
- (void)error:  (NSString *)message, ...;

@end

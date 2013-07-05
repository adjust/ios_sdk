//
//  AILogger.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

typedef enum {
    AILogLevelVerbose = 1,
    AILogLevelDebug   = 2,
    AILogLevelInfo    = 3,
    AILogLevelWarn    = 4,
    AILogLevelError   = 5,
    AILogLevelAssert  = 6
} AILogLevel;

// A simple logger with multiple log levels.
@interface AILogger : NSObject

@property (copy) NSString *logTag;
@property (assign) AILogLevel logLevel;

// convenience methods
+ (void)setLogTag:(NSString *)logTag;
+ (void)setLogLevel:(AILogLevel)logLevel;
+ (void)verbose:(NSString *)message, ...;
+ (void)debug:  (NSString *)message, ...;
+ (void)info:   (NSString *)message, ...;
+ (void)warn:   (NSString *)message, ...;
+ (void)error:  (NSString *)message, ...;

+ (AILogger *)loggerWithTag:(NSString *)logTag;
- (id)initWithTag:(NSString *)logTag;

- (void)verbose:(NSString *)message, ...;
- (void)debug:  (NSString *)message, ...;
- (void)info:   (NSString *)message, ...;
- (void)warn:   (NSString *)message, ...;
- (void)error:  (NSString *)message, ...;

@end

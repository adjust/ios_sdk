//
//  AILogger.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AILogger.h"

static AILogger *defaultLogger;


#pragma mark -
@implementation AILogger

+ (void)setLogTag:(NSString *)logTag {
    AILogger.getDefaultLogger.logTag = logTag;
}

+ (void)setLogLevel:(AILogLevel)logLevel {
    AILogger.getDefaultLogger.logLevel = logLevel;
}

+ (AILogger *)loggerWithTag:(NSString *)logTag {
    return [[AILogger alloc] initWithTag:logTag];
}

- (id)initWithTag:(NSString *)tag {
    self = [super init];
    if (self == nil) return nil;

    self.logTag = tag;
    self.logLevel = AILogLevelInfo;

    return self;
}

- (void)verbose:(NSString *)format, ... {
    if (self.logLevel > AILogLevelVerbose) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"v" format:format parameters:parameters];
}

- (void)debug:(NSString *)format, ... {
    if (self.logLevel > AILogLevelDebug) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"d" format:format parameters:parameters];
}

- (void)info:(NSString *)format, ... {
    if (self.logLevel > AILogLevelInfo) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"i" format:format parameters:parameters];
}

- (void)warn:(NSString *)format, ... {
    if (self.logLevel > AILogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}

- (void)error:(NSString *)format, ... {
    if (self.logLevel > AILogLevelError) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"e" format:format parameters:parameters];
}

+ (void)verbose:(NSString *)format, ... {
    if (AILogger.getDefaultLogger.logLevel > AILogLevelVerbose) return;
    va_list parameters; va_start(parameters, format);
    [AILogger.getDefaultLogger logLevel:@"v" format:format parameters:parameters];
}

+ (void)debug:(NSString *)format, ... {
    if (AILogger.getDefaultLogger.logLevel > AILogLevelDebug) return;
    va_list parameters; va_start(parameters, format);
    [AILogger.getDefaultLogger logLevel:@"d" format:format parameters:parameters];
}

+ (void)info:(NSString *)format, ... {
    if (AILogger.getDefaultLogger.logLevel > AILogLevelInfo) return;
    va_list parameters; va_start(parameters, format);
    [AILogger.getDefaultLogger logLevel:@"i" format:format parameters:parameters];
}

+ (void)warn:(NSString *)format, ... {
    if (AILogger.getDefaultLogger.logLevel > AILogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [AILogger.getDefaultLogger logLevel:@"w" format:format parameters:parameters];
}

+ (void)error:(NSString *)format, ... {
    if (AILogger.getDefaultLogger.logLevel > AILogLevelError) return;
    va_list parameters; va_start(parameters, format);
    [AILogger.getDefaultLogger logLevel:@"e" format:format parameters:parameters];
}

- (void)logLevel:(NSString *)logLevel format:(NSString *)format parameters:(va_list) parameters {
    NSString *string = [[NSString alloc] initWithFormat:format arguments:parameters];
    va_end(parameters);

    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSLog(@"\t[%@]%@: %@", self.logTag, logLevel, line);
    }
}

#pragma mark private
+ (AILogger *)getDefaultLogger {
    if (defaultLogger == nil) {
        defaultLogger = [AILogger loggerWithTag:@"AdjustIo"];
    }
    return defaultLogger;
}

@end

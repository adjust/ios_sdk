//
//  AILogger.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 2012-11-15.
//  Copyright (c) 2012-2013 adeven. All rights reserved.
//

#import "AILogger.h"

static NSString * const kLogTag = @"AdjustIo";

static AILogLevel staticLogLevel = AILogLevelInfo;


#pragma mark -
@implementation AILogger

+ (void)setLogLevel:(AILogLevel)logLevel {
    staticLogLevel = logLevel;
}

+ (void)verbose:(NSString *)format, ... {
    if (staticLogLevel > AILogLevelVerbose) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"v" format:format parameters:parameters];
}

+ (void)debug:(NSString *)format, ... {
    if (staticLogLevel > AILogLevelDebug) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"d" format:format parameters:parameters];
}

+ (void)info:(NSString *)format, ... {
    if (staticLogLevel > AILogLevelInfo) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"i" format:format parameters:parameters];
}

+ (void)warn:(NSString *)format, ... {
    if (staticLogLevel > AILogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}

+ (void)error:(NSString *)format, ... {
    if (staticLogLevel > AILogLevelError) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"e" format:format parameters:parameters];
}

+ (void)assert:(NSString *)format, ... {
    if (staticLogLevel > AILogLevelAssert) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"a" format:format parameters:parameters];
}

// private implementation
+ (void)logLevel:(NSString *)logLevel format:(NSString *)format parameters:(va_list)parameters {
    NSString *string = [[NSString alloc] initWithFormat:format arguments:parameters];
    va_end(parameters);

    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSLog(@"\t[%@]%@: %@", kLogTag, logLevel, line);
    }
}

@end

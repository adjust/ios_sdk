//
//  AILogger.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2012-11-15.
//  Copyright (c) 2012-2014 adjust GmbH. All rights reserved.
//

#import "AILogger.h"

static NSString * const kLogTag = @"Adjust";

@interface AILogger()

@property (nonatomic, assign) AILogLevel loglevel;

@end

#pragma mark -
@implementation AILogger


- (void)setLogLevel:(AILogLevel)logLevel {
    self.loglevel = logLevel;
}

- (void)verbose:(NSString *)format, ... {
    if (self.loglevel > AILogLevelVerbose) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"v" format:format parameters:parameters];
}

- (void)debug:(NSString *)format, ... {
    if (self.loglevel > AILogLevelDebug) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"d" format:format parameters:parameters];
}

- (void)info:(NSString *)format, ... {
    if (self.loglevel > AILogLevelInfo) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"i" format:format parameters:parameters];
}

- (void)warn:(NSString *)format, ... {
    if (self.loglevel > AILogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}

- (void)error:(NSString *)format, ... {
    if (self.loglevel > AILogLevelError) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"e" format:format parameters:parameters];
}

- (void)assert:(NSString *)format, ... {
    if (self.loglevel > AILogLevelAssert) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"a" format:format parameters:parameters];
}

// private implementation
- (void)logLevel:(NSString *)logLevel format:(NSString *)format parameters:(va_list)parameters {
    NSString *string = [[NSString alloc] initWithFormat:format arguments:parameters];
    va_end(parameters);

    NSArray *lines = [string componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSLog(@"\t[%@]%@: %@", kLogTag, logLevel, line);
    }
}

+ (AILogLevel)LogLevelFromString:(NSString *)logLevelString {
    if ([logLevelString isEqualToString:@"verbose"])
        return AILogLevelVerbose;

    if ([logLevelString isEqualToString:@"debug"])
        return AILogLevelDebug;

    if ([logLevelString isEqualToString:@"info"])
        return AILogLevelInfo;

    if ([logLevelString isEqualToString:@"warn"])
        return AILogLevelWarn;

    if ([logLevelString isEqualToString:@"error"])
        return AILogLevelError;

    if ([logLevelString isEqualToString:@"assert"])
        return AILogLevelAssert;

    // default value if string does not match
    return AILogLevelInfo;
}

@end

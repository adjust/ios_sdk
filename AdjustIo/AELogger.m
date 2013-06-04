//
//  AELogger.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AELogger.h"

@implementation AELogger
@synthesize logTag = _logTag;

- (id)initWithTag:(NSString *)tag {
    self = [super init];
    if (self == nil) return nil;

    self.logTag = tag;
    self.logLevel = AELogLevelInfo;

    return self;
}

+ (AELogger *)loggerWithTag:(NSString *)logTag {
    return [[AELogger alloc] initWithTag:logTag];
}

- (void)verbose:(NSString *)format, ... {
    if (self.logLevel > AELogLevelVerbose) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"v" format:format parameters:parameters];
}

- (void)debug:(NSString *)format, ... {
    if (self.logLevel > AELogLevelDebug) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"d" format:format parameters:parameters];
}

- (void)info:(NSString *)format, ... {
    if (self.logLevel > AELogLevelInfo) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"i" format:format parameters:parameters];
}

- (void)warn:(NSString *)format, ... {
    if (self.logLevel > AELogLevelWarn) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"w" format:format parameters:parameters];
}

- (void)error:(NSString *)format, ... {
    if (self.logLevel > AELogLevelError) return;
    va_list parameters; va_start(parameters, format);
    [self logLevel:@"e" format:format parameters:parameters];
}

- (void)logLevel:(NSString *)logLevel format:(NSString *)format parameters:(va_list) parameters {
    NSString *logString = [[NSString alloc] initWithFormat:format arguments:parameters];
    NSLog(@"[%@]%@: %@", self.logTag, logLevel, logString);
    va_end(parameters);
}

@end

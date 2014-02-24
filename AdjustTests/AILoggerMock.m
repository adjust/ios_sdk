//
//  AILoggerMock.m
//  Adjust
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AILoggerMock.h"

static NSString * const kLogTag = @"AdjustTests";

@interface AILoggerMock()

@property (nonatomic, strong) NSMutableString *logBuffer;
@property (nonatomic, strong) NSDictionary *logMap;

@end

@implementation AILoggerMock

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    self.logBuffer = [[NSMutableString alloc] init];
    self.logMap = @{
        @0 : [NSMutableArray array],
        @1 : [NSMutableArray array],
        @2 : [NSMutableArray array],
        @3 : [NSMutableArray array],
        @4 : [NSMutableArray array],
        @5 : [NSMutableArray array],
        @6 : [NSMutableArray array],
    };

    return self;
}

- (NSString *)description {
    return self.logBuffer;
}

- (BOOL) containsMessage:(NSInteger)logLevel beginsWith:(NSString *)beginsWith {
    NSMutableArray  *logArray = (NSMutableArray *)self.logMap[@(logLevel)];
    for (int i = 0; i < [logArray count]; i++) {
        NSString *logMessage = logArray[i];
        if ([logMessage hasPrefix:beginsWith]) {
            [logArray removeObjectsInRange:NSMakeRange(0, i + 1)];
            NSLog(@"%@ found", beginsWith);
            return YES;
        }
    }
    NSLog(@"%@ not in (%@)", beginsWith, [logArray componentsJoinedByString:@","]);
    return NO;
}

- (void)setLogLevel:(AILogLevel)logLevel {
    [self test:@"AILogger setLogLevel logLevel:%@", logLevel];
}

- (void)test:(NSString *)format, ... {
    va_list parameters; va_start(parameters, format);
    [self logLevel:AILogLevelTest logPrefix:@"t" format:format parameters:parameters];
}


- (void)verbose:(NSString *)format, ... {
    va_list parameters; va_start(parameters, format);
    [self logLevel:AILogLevelVerbose logPrefix:@"v" format:format parameters:parameters];
}

- (void)debug:  (NSString *)format, ... {
    va_list parameters; va_start(parameters, format);
    [self logLevel:AILogLevelDebug logPrefix:@"d" format:format parameters:parameters];
}

- (void)info:   (NSString *)format, ... {
    va_list parameters; va_start(parameters, format);
    [self logLevel:AILogLevelInfo logPrefix:@"i" format:format parameters:parameters];
}

- (void)warn:   (NSString *)format, ... {
    va_list parameters; va_start(parameters, format);
    [self logLevel:AILogLevelWarn logPrefix:@"w" format:format parameters:parameters];
}

- (void)error:  (NSString *)format, ... {
    va_list parameters; va_start(parameters, format);
    [self logLevel:AILogLevelError logPrefix:@"e" format:format parameters:parameters];
}

- (void)assert: (NSString *)format, ... {
    va_list parameters; va_start(parameters, format);
    [self logLevel:AILogLevelAssert logPrefix:@"a" format:format parameters:parameters];
}

// private implementation
- (void)logLevel:(NSInteger)logLevel  logPrefix:(NSString *)logPrefix format:(NSString *)format parameters:(va_list)parameters {
    NSString *formatedMessage = [[NSString alloc] initWithFormat:format arguments:parameters];
    va_end(parameters);
    
    NSString *logMessage = [NSString stringWithFormat:@"\t[%@]%@: %@", kLogTag, logPrefix, formatedMessage];
    
    [self.logBuffer appendString:logMessage];
    
    NSMutableArray *logArray = (NSMutableArray *)self.logMap[@(logLevel)];
    [logArray addObject:formatedMessage];

    NSArray *lines = [formatedMessage componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        NSLog(@"\t[%@]%@: %@", kLogTag, logPrefix, line);
    }
}

@end

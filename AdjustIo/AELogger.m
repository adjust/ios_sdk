//
//  AELogger.m
//  AdjustIo
//
//  Created by Christian Wellenbrock on 15.11.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import "AELogger.h"

@implementation AELogger

- (id)initWithTag:(NSString *)tag enabled:(BOOL)enabled {
    self = [super init];
    if (self == nil) return nil;

    self.logTag = tag;
    self.loggingEnabled = enabled;

    return self;
}

+ (AELogger *)loggerWithTag:(NSString *)logTag enabled:(BOOL)enabled {
    return [[[AELogger alloc] initWithTag:logTag enabled:enabled] autorelease];
}

- (void)log:(NSString *)format, ... {
    if (!self.loggingEnabled) {
        return;
    }

    va_list ap;
    va_start(ap, format);
    NSLog(@"\t[%@] %@", self.logTag, [[NSString alloc] initWithFormat:format arguments:ap]);
    va_end(ap);
}

@end

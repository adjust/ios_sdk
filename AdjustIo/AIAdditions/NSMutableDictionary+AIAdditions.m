//
//  NSMutableDictionary.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 03.06.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "NSMutableDictionary+AIAdditions.h"

@implementation NSMutableDictionary(AIAdditions)

- (void)trySetObject:(id)value forKey:(NSString *)key {
    if (value != nil) {
        [self setObject:value forKey:key];
    }
}

- (void)setInteger:(int)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithInt:value] forKey:key];
}

- (void)setDate:(NSDate *)date forKey:(NSString *)key {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZZZZ";
    [self setObject:[formatter stringFromDate:date] forKey:key];
}

@end

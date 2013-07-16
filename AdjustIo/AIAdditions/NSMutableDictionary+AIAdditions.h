//
//  NSMutableDictionary.h
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 03.06.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary(AIAdditions)

- (void)trySetObject:(id)value forKey:(NSString *)key;
- (void)setInteger:(int)value  forKey:(NSString *)key;
- (void)setDate:(NSDate *)date forKey:(NSString *)key;

@end

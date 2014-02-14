//
//  NSString+AIAdditions.h
//  Adjust
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012-2013 adeven. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString(AIAdditions)

- (NSString *)aiTrim;
- (NSString *)aiQuote;
- (NSString *)aiMd5;
- (NSString *)aiSha1;
- (NSString *)aiUrlEncode;
- (NSString *)aiRemoveColons;

+ (NSString *)aiJoin:(NSString *)strings, ...;

@end

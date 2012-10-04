//
//  NSString+AIAdditions.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 23.07.12.
//  Copyright (c) 2012 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(AIAdditions)

- (NSString *)aiTrim;
- (NSString *)aiMd5;
- (NSData *)aiDecodeBase64;

@end

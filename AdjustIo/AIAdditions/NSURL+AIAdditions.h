//
//  NSURL+AYNAdditions.h
//  AdjustIo
//
//  Created by François Benaiteau on 10/14/13.
//  Copyright (c) 2013 SinnerScharderMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (AIAdditions)
+ (BOOL)ai_addSkipBackupAttributeToItemAtFilePath:(NSString*)path;
+ (BOOL)ai_addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
@end

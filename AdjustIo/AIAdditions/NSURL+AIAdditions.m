//
//  NSURL+AIAdditions.m
//  AdjustIo
//
//  Created by François Benaiteau on 10/14/13.
//  Copyright (c) 2013 SinnerScharderMobile. All rights reserved.
//

#import "NSURL+AIAdditions.h"

@implementation NSURL (AYNAdditions)


+ (BOOL)ai_addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue:[NSNumber numberWithBool:YES]
                                  forKey:NSURLIsExcludedFromBackupKey
                                   error:&error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (BOOL)ai_addSkipBackupAttributeToItemAtFilePath:(NSString*)path
{
   NSURL* url = [NSURL fileURLWithPath:path];
   return [self ai_addSkipBackupAttributeToItemAtURL:url];

}

@end

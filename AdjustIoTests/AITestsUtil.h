//
//  AITestsUtil.h
//  Adjust
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AILoggerMock.h"
#import "AIActivityPackage.h"

@interface AITestsUtil : NSObject

+ (NSString *)getFilename:(NSString *)filename;
+ (BOOL)deleteFile:(NSString *)filename logger:(AILoggerMock *)loggerMock;
+ (AIActivityPackage *)buildEmptyPackage;

@end

//
//  AITestsUtil.h
//  Adjust
//
//  Created by Pedro Filipe on 12/02/14.
//  Copyright (c) 2014 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AILoggerMock.h"
#import "AIActivityPackage.h"
#import "Adjust.h"

@interface AITestsUtil : NSObject <AdjustDelegate>

+ (NSString *)getFilename:(NSString *)filename;
+ (BOOL)deleteFile:(NSString *)filename logger:(AILoggerMock *)loggerMock;
+ (AIActivityPackage *)buildEmptyPackage;

- (void)adjustFinishedTrackingWithResponse:(AIResponseData *)responseData;

@end

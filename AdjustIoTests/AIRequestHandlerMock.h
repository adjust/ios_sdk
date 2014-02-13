//
//  AIRequestHandlerMock.h
//  Adjust
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AIRequestHandler.h"

@interface AIRequestHandlerMock : NSObject <AIRequestHandler>

@property (nonatomic, assign) BOOL connectionError;

@end

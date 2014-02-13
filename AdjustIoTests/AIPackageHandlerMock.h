//
//  AIPackageHandlerMock.h
//  Adjust
//
//  Created by Pedro Filipe on 10/02/14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import "AIPackageHandler.h"

@interface AIPackageHandlerMock : NSObject <AIPackageHandler>

@property (nonatomic, strong) NSMutableArray *packageQueue;

@property (nonatomic, strong) AIResponseData *responseData;
@property (nonatomic, strong) AIActivityPackage * activityPackage;

@end

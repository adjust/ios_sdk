//
//  AIResponseData.h
//  AdjustIo
//
//  Created by Christian Wellenbrock on 07.02.14.
//  Copyright (c) 2014 adeven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AIResponseData : NSObject

@property (nonatomic, copy) NSString *trackerToken;
@property (nonatomic, copy) NSString *trackerName;
@property (nonatomic, copy) NSString *error;

+ (AIResponseData *)dataWithJsonString:(NSString *)string;

- (id)initWithJsonString:(NSString *)string;

@end

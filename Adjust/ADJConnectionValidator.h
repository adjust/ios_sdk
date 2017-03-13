//
//  ADJConnectionValidator.h
//  Adjust
//
//  Created by Uglješa Erceg on 14/02/2017.
//  Copyright © 2017 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJConnectionValidator : NSObject <NSURLSessionDelegate>

@property (nonatomic, assign) int expectedTce;

@property (nonatomic, assign) BOOL didValidationHappen;

@property (nonatomic, assign, readonly) BOOL validationResult;

@end

//
//  ADJUrlStrategy.h
//  Adjust
//
//  Created by Pedro S. on 11.08.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityKind.h"

@interface ADJUrlStrategy : NSObject

@property (nonatomic, readonly, copy) NSString *extraPath;

- (instancetype)initWithUrlStrategyInfo:(NSString *)urlStrategyInfo
                              extraPath:(NSString *)extraPath;

- (NSString *)getUrlHostStringByPackageKind:(ADJActivityKind)activityKind;

- (void)resetAfterSuccess;
- (BOOL)shouldRetryAfterFailure:(ADJActivityKind)activityKind;

@end

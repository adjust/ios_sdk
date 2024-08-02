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

- (instancetype)initWithUrlStrategyDomains:(NSArray *)domains
                                 extraPath:(NSString *)extraPath
                             useSubdomains:(BOOL)useSubdomains;

- (NSString *)urlForActivityKind:(ADJActivityKind)activityKind
                  isConsentGiven:(BOOL)isConsentGiven
               withSendingParams:(NSMutableDictionary *)sendingParams;

- (void)resetAfterSuccess;

- (BOOL)shouldRetryAfterFailure:(ADJActivityKind)activityKind;

@end

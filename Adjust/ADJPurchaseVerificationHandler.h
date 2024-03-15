//
//  ADJPurchaseVerificationHandler.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on May 25th 2023.
//  Copyright © 2023 Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityPackage.h"
#import "ADJActivityHandler.h"
#import "ADJRequestHandler.h"
#import "ADJUrlStrategy.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADJPurchaseVerificationHandler : NSObject <ADJResponseCallback>

- (id)initWithActivityHandler:(id<ADJActivityHandler>)activityHandler
                startsSending:(BOOL)startsSending
                    userAgent:(NSString *)userAgent
                  urlStrategy:(ADJUrlStrategy *)urlStrategy;
- (void)pauseSending;
- (void)resumeSending;
- (void)sendPurchaseVerificationPackage:(ADJActivityPackage *)purchaseVerificationPackage;
- (void)updatePackagesWithAttStatus:(int)attStatus;
- (void)teardown;

@end

NS_ASSUME_NONNULL_END

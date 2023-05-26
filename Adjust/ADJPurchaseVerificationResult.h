//
//  ADJPurchaseVerificationResult.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on May 25th 2023.
//  Copyright © 2023 Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ADJPurchaseVerificationResult : NSObject

/**
 *  @property   message
 *
 *  @brief      Text message about current state of receipt verification.
 */
@property (nonatomic, copy) NSString *message;

/**
 *  @property   code
 *
 *  @brief      Response code returned from Adjust backend server.
 */
@property (nonatomic, assign) int code;

/**
 *  @property   verificationStatus
 *
 *  @brief      State of verification (success / failure / unknown / not verified)
 */
@property (nonatomic, copy) NSString *verificationStatus;

@end

NS_ASSUME_NONNULL_END

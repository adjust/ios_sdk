//
//  ADJRemoteTrigger.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on December 3rd 2025.
//  Copyright © 2025-present Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * @brief Remote trigger object containing label and payload from backend.
 */
@interface ADJRemoteTrigger : NSObject

/**
 * @brief Label identifying the type of remote trigger.
 */
@property (nonatomic, copy, readonly, nonnull) NSString *label;

/**
 * @brief Payload data in JSON format (NSDictionary).
 */
@property (nonatomic, strong, readonly, nonnull) NSDictionary *payload;

/**
 * @brief Initializes a remote trigger object.
 *
 * @param label The label identifying the trigger type.
 * @param payload The payload data as a dictionary.
 *
 * @returns Initialized remote trigger object.
 */
- (nonnull instancetype)initWithLabel:(nonnull NSString *)label
                               payload:(nonnull NSDictionary *)payload;

@end


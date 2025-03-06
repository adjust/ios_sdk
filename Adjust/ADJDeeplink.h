//
//  ADJDeeplink.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on 18th July 2024.
//  Copyright © 2024-Present Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJDeeplink : NSObject

/**
 * @brief Deeplink value.
 */
@property (nonatomic, copy, readonly, nonnull) NSURL *deeplink;

/**
 * @brief Referrer value.
 */
@property (nonatomic, copy, readonly, nonnull) NSURL *referrer;

/**
 * @brief Initializes a Deeplink object with the provided deeplink URL.
 *
 * @param deeplink The URL representing the deeplink.
 * @return An instance of ADJDeeplink, or nil if initialization fails.
 */
- (nullable ADJDeeplink *)initWithDeeplink:(nonnull NSURL *)deeplink;

/**
 * @brief Sets the referrer URL for the Deeplink object.
 *
 * @param referrer The URL that refers the user to the deeplink, typically from an organic search.
 */
- (void)setReferrer:(nonnull NSURL *)referrer;

@end

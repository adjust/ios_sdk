//
//  ADJDeeplink.h
//  Adjust
//
//  Created by Uglješa Erceg (@uerceg) on 18th July 2024.
//  Copyright © 2024-Present Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJDeeplink : NSObject

@property (nonatomic, copy, readonly, nonnull) NSURL *deeplink;
@property (nonatomic, copy, readonly, nonnull) NSURL *referrer;

- (nullable ADJDeeplink *)initWithDeeplink:(nonnull NSURL *)deeplink;

- (void)setReferrer:(nonnull NSURL *)referrer;

@end

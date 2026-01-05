//
//  ADJLinkResolution.h
//  Adjust
//
//  Created by Pedro Silva (@nonelse) on 26th April 2021.
//  Copyright © 2021-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJLinkResolution : NSObject

+ (void)resolveLinkWithUrl:(nonnull NSURL *)url
     resolveUrlSuffixArray:(nullable NSArray<NSString *> *)resolveUrlSuffixArray
                  callback:(nonnull void (^)(NSURL *_Nullable resolvedLink))callback;

@end

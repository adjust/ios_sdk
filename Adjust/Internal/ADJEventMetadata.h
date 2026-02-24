//
//  ADJEventMetadata.h
//  Adjust
//
//  Created by Genady Buchatsky on 27.11.25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJEventMetadata : NSObject <NSSecureCoding>
- (NSUInteger)incrementedSequenceForEventToken:(NSString * _Nonnull)token;
- (nonnull ADJEventMetadata *)deepCopy;
@end

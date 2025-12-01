//
//  ADJEventMetaData.h
//  Adjust
//
//  Created by Genady Buchatsky on 27.11.25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJEventMetaData : NSObject <NSSecureCoding>
- (NSUInteger)incrementedSequenceForEventToken:(NSString *)token;
@end

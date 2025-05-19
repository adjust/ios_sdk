//
//  ADJOdmPlugin.h
//  Adjust
//
//  Created by Genady Buchatsky on 13.05.25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJOdmPlugin : NSObject
+ (nullable NSString *)version;
+ (void)setOdmAppFirstLaunchTimestamp:(NSDate *_Nonnull)time;
+ (void)fetchOdmInfoWithCompletion:(void (^_Nonnull)(NSString * _Nullable odmInfo, NSError * _Nullable error))completion;
@end

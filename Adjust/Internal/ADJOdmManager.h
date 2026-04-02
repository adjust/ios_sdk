//
//  ADJOdmManager.h
//  Adjust
//
//  Created by Genady Buchatsky on 14.03.25.
//  Copyright © 2025-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ADJHandleGoogleOdmInfoBlock)(NSString * _Nullable odmInfo, NSError * _Nullable error);

@interface ADJOdmManager : NSObject

- (id _Nullable)initIfPluginAvailbleAndFetchOdmData;
- (void)handleFetchedOdmInfoWithCompletionHandler:(nonnull ADJHandleGoogleOdmInfoBlock)completion;
- (void)completeProcessingOdmInfoWithSuccess:(BOOL)success;

@end

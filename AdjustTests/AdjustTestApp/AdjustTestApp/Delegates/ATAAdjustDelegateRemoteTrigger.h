//
//  ATAAdjustDelegateRemoteTrigger.h
//  AdjustTestApp
//
//  Created by Uglješa Erceg (@uerceg) on December 3rd 2025.
//  Copyright © 2025-present Adjust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AdjustSdk/AdjustSdk.h>
#import "ATLTestLibrary.h"

@interface ATAAdjustDelegateRemoteTrigger : NSObject<AdjustDelegate>

- (id)initWithTestLibrary:(ATLTestLibrary *)testLibrary andExtraPath:(NSString *)extraPath;

@end


//
//  AdjustLoggingHelper.h
//  AdjustExample-iWatch
//
//  Created by Uglješa Erceg (@uerceg) on 6th April 2016
//  Copyright © 2016-Present Adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdjustLoggingHelper : NSObject

+ (id)sharedInstance;

- (void)logText:(NSString *)text;

@end

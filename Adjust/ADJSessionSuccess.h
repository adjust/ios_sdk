//
//  ADJSuccessResponseData.h
//  adjust
//
//  Created by Pedro Filipe on 05/01/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityKind.h"

@interface ADJSessionSuccess : NSObject <NSCopying>

// activity type of the tracked package. For now only "event" is tracked.
@property (nonatomic, copy) NSString * activityKindString;

// message from the server.
@property (nonatomic, copy) NSString * message;

// timeStamp from the server.
@property (nonatomic, copy) NSString * timeStamp;

// adid of the device.
@property (nonatomic, copy) NSString * adid;

// the server response in json format
@property (nonatomic, retain) NSDictionary *jsonResponse;

+ (ADJSessionSuccess *)sessionSuccessResponseData;
- (id)init;

@end

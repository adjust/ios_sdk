//
//  ADJFailureResponseData.h
//  adjust
//
//  Created by Pedro Filipe on 05/01/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityKind.h"

@interface ADJFailureResponseData : NSObject <NSCopying>

@property (nonatomic, copy) NSString * activityKindString;

@property (nonatomic, copy) NSString * message;

@property (nonatomic, copy) NSString * timeStamp;

@property (nonatomic, copy) NSString * adid;

@property (nonatomic, copy) NSString * eventToken;

@property (nonatomic, assign) BOOL willRetry;

@property (nonatomic, retain) NSDictionary *jsonResponse;

+ (ADJFailureResponseData *)failureResponseData;
- (id)init;

@end

//
//  ADJResponseData.h
//  adjust
//
//  Created by Pedro Filipe on 07/12/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJActivityPackage.h"
#import "ADJAttribution.h"
#import "ADJSuccessResponseData.h"
#import "ADJFailureResponseData.h"

@interface ADJResponseData : NSObject <NSCopying>

@property (nonatomic, assign) ADJActivityKind activityKind;

@property (nonatomic, copy) NSString * message;

@property (nonatomic, copy) NSString * timeStamp;

@property (nonatomic, copy) NSString * adid;

@property (nonatomic, copy) NSString * eventToken;

@property (nonatomic, assign) BOOL success;

@property (nonatomic, assign) BOOL willRetry;

@property (nonatomic, retain) NSDictionary *jsonResponse;

@property (nonatomic, copy) ADJAttribution *attribution;

+ (ADJResponseData *)responseDataWithActivityPackage:(ADJActivityPackage *)activityPackage;
- (id)initWithActivityPackage:(ADJActivityPackage *)activityPackage;

- (ADJSuccessResponseData *)successResponseData;
- (ADJFailureResponseData *)failureResponseData;

@end

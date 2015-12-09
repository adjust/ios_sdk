//
//  ADJResponseData.h
//  adjust
//
//  Created by Pedro Filipe on 07/12/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJResponseData : NSObject <NSCopying>

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *timeStamp;

@property (nonatomic, retain) NSDictionary *jsonResponse;

+ (ADJResponseData *)responseData;
- (id)init;

@end

//
//  ADJResponseDataTasks.h
//  adjust
//
//  Created by Pedro Filipe on 08/12/15.
//  Copyright © 2015 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ADJResponseData.h"
#import "ADJAttribution.h"
#import "ADJEvent.h"

@interface ADJResponseDataTasks : NSObject

@property (nonatomic, retain) ADJResponseData * responseData;

@property (nonatomic, copy) ADJAttribution *attribution;

@property (nonatomic, copy) ADJFinishActivity finishDelegate;

+ (ADJResponseDataTasks *)responseDataTasks;
- (id)init;

@end

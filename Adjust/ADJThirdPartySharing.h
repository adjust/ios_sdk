//
//  ADJThirdPartySharing.h
//  AdjustSdk
//
//  Created by Pedro S. on 02.12.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJThirdPartySharing : NSObject

@property (nonatomic, strong) NSNumber *enable;
@property (nonatomic, strong) NSMutableDictionary *granularOptions;

@end


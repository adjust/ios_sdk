//
//  ATLControlSignal.h
//  AdjustTestLibrary
//
//  Created by Serj on 20.02.19.
//  Copyright © 2019 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ATLSignalTypeInfo               = 1,
    ATLSignalTypeInit               = 2,
    ATLSignalTypeInitTestSession    = 3,
    ATLSignalTypeEndWait            = 4,
    ATLSignalTypeCancelCurrentTest  = 5,
    ATLSignalTypeUnknown            = 6
} ATLSignalType;

@interface ATLControlSignal : NSObject

- (id)initWithSignalType:(ATLSignalType)signalType;

- (id)initWithSignalType:(ATLSignalType)signalType
            andSignalValue:(NSString*)signalValue;

- (id)initWithJson:(NSString*)json;

- (NSString*)toJson;

- (NSString*)getValue;

- (ATLSignalType)getType;

@end

NS_ASSUME_NONNULL_END

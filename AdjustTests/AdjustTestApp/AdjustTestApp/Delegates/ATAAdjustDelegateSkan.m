//
//  ATAAdjustDelegateSkan.m
//  AdjustTestApp
//
//  Created by Uglješa Erceg (uerceg) on 23rd April 2024.
//  Copyright © 2024 Adjust GmbH. All rights reserved.
//

#import "ATAAdjustDelegateSkan.h"

@interface ATAAdjustDelegateSkan ()

@property (nonatomic, strong) ATLTestLibrary *testLibrary;
@property (nonatomic, copy) NSString *extraPath;

@end

@implementation ATAAdjustDelegateSkan

- (id)initWithTestLibrary:(ATLTestLibrary *)testLibrary andExtraPath:(NSString *)extraPath {
    self = [super init];
    
    if (nil == self) {
        return nil;
    }
    
    self.testLibrary = testLibrary;
    self.extraPath = extraPath;

    return self;
}

- (void)adjustSKAdNetworkUpdatedWithConversionData:(nonnull NSDictionary<NSString *, NSString *> *)data {
    NSLog(@"SKAN callback called!");

    for (NSString *key in data) {
        [self.testLibrary addInfoToSend:key value:[data objectForKey:key]];
    }

    [self.testLibrary sendInfoToServer:self.extraPath];
}

@end

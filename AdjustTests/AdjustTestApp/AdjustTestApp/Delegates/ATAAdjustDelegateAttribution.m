//
//  ATAAdjustDelegateAttribution.m
//  AdjustTestApp
//
//  Created by Uglješa Erceg (uerceg) on 8th December 2017.
//  Copyright © 2017 Adjust GmbH. All rights reserved.
//

#import "ATAAdjustDelegateAttribution.h"

@interface ATAAdjustDelegateAttribution ()

@property (nonatomic, strong) ATLTestLibrary *testLibrary;
@property (nonatomic, copy) NSString *extraPath;

@end

@implementation ATAAdjustDelegateAttribution

- (id)initWithTestLibrary:(ATLTestLibrary *)testLibrary andExtraPath:(NSString *)extraPath {
    self = [super init];
    
    if (nil == self) {
        return nil;
    }
    
    self.testLibrary = testLibrary;
    self.extraPath = extraPath;

    return self;
}

- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    NSLog(@"Attribution callback called!");
    NSLog(@"Attribution: %@", attribution);
    
    [self.testLibrary addInfoToSend:@"trackerToken" value:attribution.trackerToken];
    [self.testLibrary addInfoToSend:@"trackerName" value:attribution.trackerName];
    [self.testLibrary addInfoToSend:@"network" value:attribution.network];
    [self.testLibrary addInfoToSend:@"campaign" value:attribution.campaign];
    [self.testLibrary addInfoToSend:@"adgroup" value:attribution.adgroup];
    [self.testLibrary addInfoToSend:@"creative" value:attribution.creative];
    [self.testLibrary addInfoToSend:@"clickLabel" value:attribution.clickLabel];
    [self.testLibrary addInfoToSend:@"adid" value:attribution.adid];
    [self.testLibrary addInfoToSend:@"costType" value:attribution.costType];
    [self.testLibrary addInfoToSend:@"costAmount" value:[attribution.costAmount stringValue]];
    [self.testLibrary addInfoToSend:@"costCurrency" value:attribution.costCurrency];
    [self.testLibrary addInfoToSend:@"state" value:attribution.state];

    [self.testLibrary sendInfoToServer:self.extraPath];
}

@end

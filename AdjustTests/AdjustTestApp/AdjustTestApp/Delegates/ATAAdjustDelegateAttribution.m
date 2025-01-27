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
    
    [self.testLibrary addInfoToSend:@"tracker_token" value:attribution.trackerToken];
    [self.testLibrary addInfoToSend:@"tracker_name" value:attribution.trackerName];
    [self.testLibrary addInfoToSend:@"network" value:attribution.network];
    [self.testLibrary addInfoToSend:@"campaign" value:attribution.campaign];
    [self.testLibrary addInfoToSend:@"adgroup" value:attribution.adgroup];
    [self.testLibrary addInfoToSend:@"creative" value:attribution.creative];
    [self.testLibrary addInfoToSend:@"click_label" value:attribution.clickLabel];
    [self.testLibrary addInfoToSend:@"cost_type" value:attribution.costType];
    [self.testLibrary addInfoToSend:@"cost_amount" value:[attribution.costAmount stringValue]];
    [self.testLibrary addInfoToSend:@"cost_currency" value:attribution.costCurrency];
    NSMutableDictionary *jsonResponseCopy = [attribution.jsonResponse mutableCopy];
    [jsonResponseCopy removeObjectForKey:@"fb_install_referrer"];
    [jsonResponseCopy setObject:[NSString stringWithFormat:@"%.2f", [jsonResponseCopy[@"cost_amount"] doubleValue]]
                         forKey:@"cost_amount"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonResponseCopy
                                                       options:0
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.testLibrary addInfoToSend:@"json_response" value:jsonString];

    [self.testLibrary sendInfoToServer:self.extraPath];
}

@end

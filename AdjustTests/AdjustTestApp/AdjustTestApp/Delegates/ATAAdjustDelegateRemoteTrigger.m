//
//  ATAAdjustDelegateRemoteTrigger.m
//  AdjustTestApp
//
//  Created by Uglješa Erceg (@uerceg) on December 3rd 2025.
//  Copyright © 2025-present Adjust. All rights reserved.
//

#import "ATAAdjustDelegateRemoteTrigger.h"

@interface ATAAdjustDelegateRemoteTrigger ()

@property (nonatomic, strong) ATLTestLibrary *testLibrary;
@property (nonatomic, copy) NSString *extraPath;

@end

@implementation ATAAdjustDelegateRemoteTrigger

- (id)initWithTestLibrary:(ATLTestLibrary *)testLibrary andExtraPath:(NSString *)extraPath {
    self = [super init];
    
    if (nil == self) {
        return nil;
    }
    
    self.testLibrary = testLibrary;
    self.extraPath = extraPath;

    return self;
}

- (void)adjustRemoteTriggerReceived:(ADJRemoteTrigger *)remoteTrigger {
    NSLog(@"Remote trigger callback called!");
    NSLog(@"Remote trigger label: %@, payload: %@", remoteTrigger.label, remoteTrigger.payload);
    
    [self.testLibrary addInfoToSend:@"label" value:remoteTrigger.label];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:remoteTrigger.payload
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"Unable to convert NSDictionary payload to JSON string: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self.testLibrary addInfoToSend:@"payload" value:jsonString];
    }
    
    [self.testLibrary sendInfoToServer:self.extraPath];
}

@end


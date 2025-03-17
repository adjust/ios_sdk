//
//  ADJActivityPackage.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "ADJActivityKind.h"
#import "ADJActivityPackage.h"

@implementation ADJActivityPackage

#pragma mark - Public methods
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (NSString *)extendedString {
    NSMutableString *builder = [NSMutableString string];
    NSArray *excludedKeys = @[
        @"secret_id",
        @"signature",
        @"headers_id",
        @"native_version",
        @"adj_signing_id"];

    [builder appendFormat:@"Path:      %@\n", self.path];
    [builder appendFormat:@"ClientSdk: %@\n", self.clientSdk];

    if (self.parameters != nil) {
        NSArray *sortedKeys = [[self.parameters allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
        NSUInteger keyCount = [sortedKeys count];

        [builder appendFormat:@"Parameters:"];

        for (NSUInteger i = 0; i < keyCount; i++) {
            NSString *key = (NSString *)[sortedKeys objectAtIndex:i];

            if ([excludedKeys containsObject:key]) {
                continue;
            }

            NSString *value = [self.parameters objectForKey:key];

            [builder appendFormat:@"\n\t\t%-22s %@", [key UTF8String], value];
        }
    }

    return builder;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@", [ADJActivityKindUtil activityKindToString:self.activityKind], self.suffix];
}

- (NSString *)successMessage {
    return [NSString stringWithFormat:@"Tracked %@%@", [ADJActivityKindUtil activityKindToString:self.activityKind], self.suffix];
}

- (NSString *)failureMessage {
    return [NSString stringWithFormat:@"Failed to track %@%@", [ADJActivityKindUtil activityKindToString:self.activityKind], self.suffix];
}

- (void)addError:(NSNumber *)errorCode {
    self.errorCount = self.errorCount + 1;

    if (self.firstErrorCode == nil) {
        self.firstErrorCode = errorCode;
    } else {
        self.lastErrorCode = errorCode;
    }
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];

    if (self == nil) {
        return self;
    }

    self.path = [decoder decodeObjectOfClass:[NSString class] forKey:@"path"];
    self.suffix = [decoder decodeObjectOfClass:[NSString class] forKey:@"suffix"];
    self.clientSdk = [decoder decodeObjectOfClass:[NSString class] forKey:@"clientSdk"];

    NSSet *allowedClasses = [NSSet setWithObjects:[NSDictionary class], [NSString class], nil];
    self.parameters = [decoder decodeObjectOfClasses:allowedClasses forKey:@"parameters"];
    self.partnerParameters = [decoder decodeObjectOfClasses:allowedClasses forKey:@"partnerParameters"];
    self.callbackParameters = [decoder decodeObjectOfClasses:allowedClasses forKey:@"callbackParameters"];

    NSString *kindString = [decoder decodeObjectOfClass:[NSString class] forKey:@"kind"];
    self.activityKind = [ADJActivityKindUtil activityKindFromString:kindString];

    id errorCountObject = [decoder decodeObjectOfClass:[NSNumber class] forKey:@"errorCount"];
    if (errorCountObject != nil) {
        self.errorCount = ((NSNumber *)errorCountObject).unsignedIntegerValue;
    }
    self.firstErrorCode = [decoder decodeObjectOfClass:[NSNumber class] forKey:@"firstErrorCode"];
    self.lastErrorCode = [decoder decodeObjectOfClass:[NSNumber class] forKey:@"lastErrorCode"];

    id waitBeforeSendObject = [decoder decodeObjectOfClass:[NSNumber class] forKey:@"waitBeforeSend"];
    if (waitBeforeSendObject != nil) {
        self.waitBeforeSend = ((NSNumber *)waitBeforeSendObject).doubleValue;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSString *kindString = [ADJActivityKindUtil activityKindToString:self.activityKind];

    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeObject:kindString forKey:@"kind"];
    [encoder encodeObject:self.suffix forKey:@"suffix"];
    [encoder encodeObject:self.clientSdk forKey:@"clientSdk"];
    [encoder encodeObject:self.parameters forKey:@"parameters"];
    [encoder encodeObject:self.callbackParameters forKey:@"callbackParameters"];
    [encoder encodeObject:self.partnerParameters forKey:@"partnerParameters"];
    [encoder encodeObject:@(self.errorCount) forKey:@"errorCount"];
    [encoder encodeObject:self.firstErrorCode forKey:@"firstErrorCode"];
    [encoder encodeObject:self.lastErrorCode forKey:@"lastErrorCode"];
    [encoder encodeObject:@(self.waitBeforeSend) forKey:@"waitBeforeSend"];
}

@end

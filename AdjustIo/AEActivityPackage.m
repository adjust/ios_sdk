//
//  AEActivityPackage.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 03.07.13.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AEActivityPackage.h"

@implementation AEActivityPackage

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return self;

    self.path = [decoder decodeObjectForKey:@"path"];
    self.userAgent = [decoder decodeObjectForKey:@"userAgent"];
    self.parameters = [decoder decodeObjectForKey:@"parameters"];
    self.kind = [decoder decodeObjectForKey:@"kind"];
    self.suffix = [decoder decodeObjectForKey:@"suffix"];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeObject:self.userAgent forKey:@"userAgent"];
    [encoder encodeObject:self.parameters forKey:@"parameters"];
    [encoder encodeObject:self.kind forKey:@"kind"];
    [encoder encodeObject:self.suffix forKey:@"suffix"];
}

@end

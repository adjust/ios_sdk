//
//  AIActivityState.m
//  AdjustIosApp
//
//  Created by Christian Wellenbrock on 2013-07-02.
//  Copyright (c) 2013 adeven. All rights reserved.
//

#import "AIActivityState.h"
#import "AIPackageBuilder.h"


#pragma mark public implementation
@implementation AIActivityState

- (id)init {
    self = [super init];
    if (self == nil) return nil;

    self.eventCount      = 0;
    self.sessionCount    = 0;
    self.subsessionCount = -1; // -1 means unknown
    self.sessionLength   = -1;
    self.timeSpent       = -1;
    self.lastActivity    = -1;
    self.createdAt       = -1;
    self.lastInterval    = -1;

    return self;
}

- (void)startNextSession:(long)now {
    self.sessionCount++;
    self.subsessionCount = 1;
    self.sessionLength   = 0;
    self.timeSpent       = 0;
    self.lastActivity    = now;
    self.createdAt       = -1;
    self.lastInterval    = -1;
}

- (void)injectSessionAttributes:(AIPackageBuilder *)builder {
    [self injectGeneralAttributes:builder];
    builder.lastInterval = self.lastInterval;
}

- (void)injectEventAttributes:(AIPackageBuilder *)builder {
    [self injectGeneralAttributes:builder];
    builder.eventCount = self.eventCount;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ec:%d sc:%d ssc:%d sl:%.1f ts:%.1f la:%.1f",
            self.eventCount, self.sessionCount, self.subsessionCount, self.sessionLength,
            self.timeSpent, self.lastActivity];
}

#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return nil;

    self.eventCount      = [decoder decodeIntForKey:@"eventCount"];
    self.sessionCount    = [decoder decodeIntForKey:@"sessionCount"];
    self.subsessionCount = [decoder decodeIntForKey:@"subsessionCount"];
    self.sessionLength   = [decoder decodeDoubleForKey:@"sessionLength"];
    self.timeSpent       = [decoder decodeDoubleForKey:@"timeSpent"];
    self.createdAt       = [decoder decodeDoubleForKey:@"createdAt"];
    self.lastActivity    = [decoder decodeDoubleForKey:@"lastActivity"];

    self.lastInterval = -1;

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.eventCount       forKey:@"eventCount"];
    [encoder encodeInt:self.sessionCount     forKey:@"sessionCount"];
    [encoder encodeInt:self.subsessionCount  forKey:@"subsessionCount"];
    [encoder encodeDouble:self.sessionLength forKey:@"sessionLength"];
    [encoder encodeDouble:self.timeSpent     forKey:@"timeSpent"];
    [encoder encodeDouble:self.createdAt     forKey:@"createdAt"];
    [encoder encodeDouble:self.lastActivity  forKey:@"lastActivity"];
}


#pragma mark private implementation

- (void)injectGeneralAttributes:(AIPackageBuilder *)builder {
    builder.sessionCount    = self.sessionCount;
    builder.subsessionCount = self.subsessionCount;
    builder.sessionLength   = self.sessionLength;
    builder.timeSpent       = self.timeSpent;
    builder.createdAt       = self.createdAt;
}

@end

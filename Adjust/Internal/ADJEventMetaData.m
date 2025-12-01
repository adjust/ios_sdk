//
//  ADJEventMetaData.m
//  Adjust
//
//  Created by Genady Buchatsky on 27.11.25.
//  Copyright © 2025 Adjust GmbH. All rights reserved.
//

#import "ADJEventMetaData.h"
#import "ADJAdjustFactory.h"
#import "ADJLogger.h"
#import "ADJUtil.h"

@interface ADJEventMetaData ()
@property (nonatomic, weak) id<ADJLogger> logger;
@property (nonatomic, strong) NSMutableDictionary *eventSequence;
@end

@implementation ADJEventMetaData

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;

    _logger = [ADJAdjustFactory logger];
    _eventSequence = [NSMutableDictionary dictionary];
    return self;
}

- (NSUInteger)incrementedSequenceForEventToken:(NSString *)token {
    NSUInteger retVal = 0;
    NSNumber *eventCounter = [self.eventSequence objectForKey:token];
    if (eventCounter != nil) {
        retVal = [eventCounter unsignedIntegerValue];
    }

    retVal += 1;
    [self.eventSequence setObject:[NSNumber numberWithUnsignedInteger:retVal]
                           forKey:token];
    return retVal;
}

#pragma mark - NSCoding protocol methods

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self == nil) return nil;

    if ([decoder containsValueForKey:@"eventSequence"]) {
        NSSet *allowedClasses = [NSSet setWithObjects:
                                 [NSMutableDictionary class],
                                 [NSString class],
                                 [NSNumber class],
                                 nil];
        self.eventSequence = [decoder decodeObjectOfClasses:allowedClasses forKey:@"eventSequence"];
    }

    if (self.eventSequence == nil) {
        self.eventSequence = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.eventSequence forKey:@"eventSequence"];
}

@end

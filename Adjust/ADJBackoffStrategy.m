//
//  ADJBackoffStrategy.m
//  Adjust
//
//  Created by Pedro Filipe on 20/04/16.
//  Copyright © 2016 adjust GmbH. All rights reserved.
//

#import "ADJBackoffStrategy.h"

@implementation ADJBackoffStrategy

+ (ADJBackoffStrategy *)backoffStrategyWithType:(ADJBackoffStrategyType)strategyType {
    return [[ADJBackoffStrategy alloc] initWithType:strategyType];
}

- (id) initWithType:(ADJBackoffStrategyType)strategyType {
    self = [super init];
    if (self == nil) return nil;

    switch (strategyType) {
        case ADJLongWait:
            [self saveStrategy:1
              secondMultiplier:120
                       maxWait:60*60*24
                     minJitter:50
                     maxJitter:100];
            break;
        case ADJShortWait:
            [self saveStrategy:1
              secondMultiplier:0.2
                       maxWait:60
                     minJitter:50
                     maxJitter:100];
            break;
        case ADJTestWait:
            [self saveStrategy:1
              secondMultiplier:0.2
                       maxWait:1
                     minJitter:50
                     maxJitter:100];
            break;
        case ADJNoWait:
            [self saveStrategy:100
              secondMultiplier:1
                       maxWait:1
                     minJitter:50
                     maxJitter:100];
            break;
        default:
            break;
    }

    return self;
}

- (void)saveStrategy:(NSInteger)minRetries
    secondMultiplier:(NSTimeInterval)secondMultiplier
             maxWait:(NSTimeInterval)maxWait
           minJitter:(NSInteger)minJitter
           maxJitter:(NSInteger)maxJitter
{
    self.minRetries = minRetries;
    self.secondMultiplier = secondMultiplier;
    self.maxWait = maxWait;
    self.minJitter = minJitter;
    self.maxJitter = maxJitter;
}

@end

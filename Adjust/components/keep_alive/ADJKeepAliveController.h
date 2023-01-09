//
//  ADJKeepAliveController.h
//  Adjust
//
//  Created by Pedro S. on 16.02.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADJCommonBase.h"
#import "ADJMeasurementSessionStartSubscriber.h"
#import "ADJLifecycleSubscriber.h"
#import "ADJKeepAliveSubscriber.h"
#import "ADJThreadExecutorFactory.h"

@interface ADJKeepAliveController : ADJCommonBase<
    // subscriptions
    ADJMeasurementSessionStartSubscriber,
    ADJLifecycleSubscriber
>
- (void)ccSubscribeToPublishersWithMeasurementSessionStartPublisher:(nonnull ADJMeasurementSessionStartPublisher *)sdkSessionStartPublisher
                                         lifecyclePublisher:(nonnull ADJLifecyclePublisher *)lifecyclePublisher;

// publishers
@property (nonnull, readonly, strong, nonatomic)ADJKeepAlivePublisher *keepAlivePublisher;

// instantiation
- (nonnull instancetype)initWithLoggerFactory:(nonnull id<ADJLoggerFactory>)loggerFactory
                        threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
                    foregroundTimerStartMilli:(nonnull ADJTimeLengthMilli *)foregroundTimerStartMilli
                 foregroundTimerIntervalMilli:(nonnull ADJTimeLengthMilli *)foregroundTimerIntervalMilli;

@end

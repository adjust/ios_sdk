//
//  ADJPreSdkInitRootController.m
//  AdjustV5
//
//  Created by Pedro S. on 24.01.21.
//  Copyright © 2021 adjust GmbH. All rights reserved.
//

#import "ADJPreSdkInitRootController.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nonnull, readonly, strong, nonatomic) ADJSdkActiveController *sdkActiveController;
 @property (nonnull, readonly, strong, nonatomic) ADJStorageRootController *storageRootController;
 @property (nonnull, readonly, strong, nonatomic) ADJDeviceController *deviceController;
 @property (nonnull, readonly, strong, nonatomic) ADJClientActionController *clientActionController;
 @property (nonnull, readonly, strong, nonatomic) ADJGdprForgetController *gdprForgetController;
 @property (nonnull, readonly, strong, nonatomic) ADJLifecycleController *lifecycleController;
 @property (nonnull, readonly, strong, nonatomic) ADJOfflineController *offlineController;
 @property (nonnull, readonly, strong, nonatomic) ADJClientCallbacksController *clientCallbacksController;
 @property (nonnull, readonly, strong, nonatomic) ADJPluginController *pluginController;
 */

@implementation ADJPreSdkInitRootController
#pragma mark Instantiation

- (nonnull instancetype)initWithInstanceId:(nonnull NSString *)instanceId
                                     clock:(nonnull ADJClock *)clock
                             sdkConfigData:(nonnull ADJSdkConfigData *)sdkConfigData
                             threadFactory:(nonnull ADJThreadController *)threadFactory
                             loggerFactory:(nonnull ADJLogController *)loggerFactory
                            clientExecutor:(nonnull ADJSingleThreadExecutor *)clientExecutor
                      clientReturnExecutor:(nonnull id<ADJClientReturnExecutor>)clientReturnExecutor
                        publishersRegistry:(nonnull ADJPublishersRegistry *)pubRegistry {

    self = [super initWithLoggerFactory:loggerFactory source:@"PreSdkInitRootController"];
    
    _storageRootController = [[ADJStorageRootController alloc] initWithLoggerFactory:loggerFactory
                                                               threadExecutorFactory:threadFactory
                                                                          instanceId:instanceId];

    _gdprForgetController = [[ADJGdprForgetController alloc] initWithLoggerFactory:loggerFactory
                                                            gdprForgetStateStorage:_storageRootController.gdprForgetStateStorage
                                                             threadExecutorFactory:threadFactory
                                                         gdprForgetBackoffStrategy:sdkConfigData.gdprForgetBackoffStrategy
                                                                publishersRegistry:pubRegistry];

    _lifecycleController = [[ADJLifecycleController alloc] initWithLoggerFactory:loggerFactory
                                                                threadController:threadFactory
                                                 doNotReadCurrentLifecycleStatus:sdkConfigData.doNotReadCurrentLifecycleStatus
                                                              publishersRegistry:pubRegistry];

    _offlineController = [[ADJOfflineController alloc] initWithLoggerFactory:loggerFactory
                                                          publishersRegistry:pubRegistry];

    _clientActionController = [[ADJClientActionController alloc] initWithLoggerFactory:loggerFactory
                                                                   clientActionStorage:_storageRootController.clientActionStorage
                                                                                 clock:clock];

    _deviceController =
        [[ADJDeviceController alloc]
            initWithLoggerFactory:loggerFactory
            threadExecutorFactory:threadFactory
            clock:clock
            deviceIdsStorage:_storageRootController.deviceIdsStorage
            keychainStorage:_storageRootController.keychainStorage
            deviceIdsConfigData:sdkConfigData.sessionDeviceIdsConfigData];
    
    _clientCallbacksController = [[ADJClientCallbacksController alloc] initWithLoggerFactory:loggerFactory
                                                                     attributionStateStorage:_storageRootController.attributionStateStorage
                                                                        clientReturnExecutor:clientReturnExecutor
                                                                            deviceController:_deviceController];

    _pluginController = [[ADJPluginController alloc] initWithLoggerFactory:loggerFactory];

    _sdkActiveController = [[ADJSdkActiveController alloc] initWithLoggerFactory:loggerFactory
                                                              activeStateStorage:_storageRootController.sdkActiveStateStorage
                                                                  clientExecutor:clientExecutor
                                                                     isForgotten:[_gdprForgetController isForgotten]
                                                              publishersRegistry:pubRegistry];
    return self;
}

- (void)
    setDependenciesWithPackageBuilder:(ADJSdkPackageBuilder *)sdkPackageBuilder
    clock:(ADJClock *)clock
    loggerFactory:(id<ADJLoggerFactory>)loggerFactory
    threadExecutorFactory:(nonnull id<ADJThreadExecutorFactory>)threadExecutorFactory
    sdkPackageSenderFactory:(id<ADJSdkPackageSenderFactory>)sdkPackageSenderFactory
{

    [self.gdprForgetController
         ccSetDependenciesAtSdkInitWithSdkPackageBuilder:sdkPackageBuilder
         clock:clock
         loggerFactory:loggerFactory
         threadExecutorFactory:threadExecutorFactory
         sdkPackageSenderFactory:sdkPackageSenderFactory];
}

- (void)subscribeToPublishers:(ADJPublishersRegistry *)pubRegistry {
    [pubRegistry addSubscriberToPublishers:self.lifecycleController];
    [pubRegistry addSubscriberToPublishers:self.offlineController];
    [pubRegistry addSubscriberToPublishers:self.clientActionController];
    [pubRegistry addSubscriberToPublishers:self.deviceController];
    [pubRegistry addSubscriberToPublishers:self.gdprForgetController];
    [pubRegistry addSubscriberToPublishers:self.pluginController];
    [pubRegistry addSubscriberToPublishers:self.sdkActiveController];
}

@end

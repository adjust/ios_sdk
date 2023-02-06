//
//  ADJEntryRoot.m
//  Adjust
//
//  Created by Aditi Agrawal on 12/07/22.
//  Copyright © 2022 Adjust GmbH. All rights reserved.
//

#import "ADJEntryRoot.h"
#import "ADJInstanceRoot.h"
#import "ADJSdkConfigData.h"
#import "ADJConstants.h"
#import "ADJInstanceIdData.h"

#pragma mark Fields
#pragma mark - Public properties
/* .h
 @property (nullable, readonly, strong, nonatomic) NSString *sdkPrefix;
 */

@interface ADJEntryRoot ()
#pragma mark - Injected dependencies
@property (nullable, readwrite, strong, nonatomic) NSString *sdkPrefix;
@property (nonnull, readwrite, strong, nonatomic) ADJSdkConfigData *sdkConfigData;

#pragma mark - Internal variables
@property (nonnull, readwrite, strong, nonatomic)
    NSMutableDictionary<NSString *, ADJInstanceRoot *> *instanceMap;

@end

@implementation ADJEntryRoot
#pragma mark Instantiation
+ (nonnull ADJEntryRoot *)instanceWithClientId:(nullable NSString *)clientId
                                 sdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
{
    ADJEntryRoot *_Nonnull entryRoot = [[ADJEntryRoot alloc] initWithClientId:clientId
                                                                sdkConfigData:sdkConfigData];

    ADJInstanceIdData *_Nonnull firstInstanceId =
        [[ADJInstanceIdData alloc] initFirstInstanceWithClientId:clientId];

    ADJInstanceRoot *instanceRoot = [ADJInstanceRoot
                                     instanceWithConfigData:entryRoot->_sdkConfigData
                                     instanceId:firstInstanceId
                                     entryRootBag:entryRoot];

    [entryRoot->_instanceMap setObject:instanceRoot forKey:firstInstanceId.idString];

    return entryRoot;
}

- (nonnull instancetype)initWithClientId:(nullable NSString *)clientId
                           sdkConfigData:(nullable ADJSdkConfigData *)sdkConfigData
{
    self = [super init];
    _sdkPrefix = nil;

    _sdkConfigData = sdkConfigData ?: [[ADJSdkConfigData alloc] initWithDefaultValues];

    _instanceMap = [[NSMutableDictionary alloc] init];

    return self;
}

- (nullable instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Public API
- (nonnull ADJInstanceRoot *)instanceForClientId:(nullable NSString *)clientId {
    ADJInstanceRoot *_Nullable instanceRoot =
        [self.instanceMap objectForKey:[ADJInstanceIdData toIdStringWithClientId:clientId]];
    if (instanceRoot != nil) {
        return instanceRoot;
    }

    @synchronized ([ADJEntryRoot class]) {
        // repeat map query to detect duplicate concurrent access
        instanceRoot =
            [self.instanceMap objectForKey:[ADJInstanceIdData toIdStringWithClientId:clientId]];
        if (instanceRoot != nil) {
            return instanceRoot;
        }

        ADJInstanceIdData *_Nonnull newInstanceId =
            [[ADJInstanceIdData alloc] initNonFirstWithClientId:clientId];

        ADJInstanceRoot *newInstanceRoot =
            [ADJInstanceRoot instanceWithConfigData:self.sdkConfigData
                                         instanceId:newInstanceId
                                       entryRootBag:self];

        [self.instanceMap setObject:newInstanceRoot forKey:newInstanceId.idString];

        return newInstanceRoot;
    }
}

- (void)finalizeAtTeardownWithCloseStorageBlock:(nullable void (^)(void))closeStorageBlock {
    @synchronized ([ADJEntryRoot class]) {
        [self.instanceMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
            ADJInstanceRoot * instanceRoot = (ADJInstanceRoot *)obj;
            [instanceRoot finalizeAtTeardownWithBlock:closeStorageBlock];
        }];
    }
}

@end

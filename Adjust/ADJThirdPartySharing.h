//
//  ADJThirdPartySharing.h
//  AdjustSdk
//
//  Created by Pedro S. on 02.12.20.
//  Copyright © 2020 adjust GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADJThirdPartySharing : NSObject

@property (nonatomic, nullable, readonly, strong) NSNumber *enabled;
@property (nonatomic, nonnull, readonly, strong) NSMutableDictionary *granularOptions;
@property (nonatomic, nonnull, readonly, strong) NSMutableDictionary *partnerSharingSettings;

- (nullable id)initWithIsEnabledNumberBool:(nullable NSNumber *)isEnabledNumberBool;

- (void)addGranularOption:(nonnull NSString *)partnerName
                      key:(nonnull NSString *)key
                    value:(nonnull NSString *)value;

- (void)addPartnerSharingSetting:(nonnull NSString *)partnerName
                             key:(nonnull NSString *)key
                           value:(BOOL)value;

@end


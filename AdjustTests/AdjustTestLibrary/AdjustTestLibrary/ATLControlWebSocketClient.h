//
//  ATLControlWebSocketClient.h
//  AdjustTestLibrary
//
//  Created by Serj on 20.02.19.
//  Copyright © 2019 adjust. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PocketSocket/PSWebSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATLControlWebSocketClient : NSObject <PSWebSocketDelegate>

@property (nonatomic, strong) PSWebSocket *socket;

- (void)initializeWebSocketWithControlUrl:(NSString *)controlUrl;

@end

NS_ASSUME_NONNULL_END

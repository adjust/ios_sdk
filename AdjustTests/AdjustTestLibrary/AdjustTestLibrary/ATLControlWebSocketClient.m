//
//  ATLControlWebSocketClient.m
//  AdjustTestLibrary
//
//  Created by Serj on 20.02.19.
//  Copyright © 2019 adjust. All rights reserved.
//

#import "ATLControlWebSocketClient.h"
#import "ATLControlSignal.h"
#import "ATLUtil.h"

@interface ATLControlWebSocketClient()

@property (nonatomic, copy) NSString *webSocketClientId;

@end

@implementation ATLControlWebSocketClient

- (void)initializeWebSocketWithControlUrl:(NSString *)controlUrl {
    // create the NSURLRequest that will be sent as the handshake
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:controlUrl]];
    
    // create the socket and assign delegate
    self.socket = [PSWebSocket clientSocketWithRequest:request];
    self.socket.delegate = self;
    
    self.webSocketClientId = [[NSUUID UUID] UUIDString];
    
    // open socket
    [self.socket open];
}

#pragma mark - PSWebSocketDelegate

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
    [ATLUtil debug:@"[WebSocket] connection opened with the server"];
    ATLControlSignal *initSignal = [[ATLControlSignal alloc] initWithSignalType:ATLSignalTypeInit andSignalValue:self.webSocketClientId];
    [webSocket send:[initSignal toJson]];
}

- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    [ATLUtil debug:@"[WebSocket] received a message: %@", message];
    ATLControlSignal *incomingSignal = [[ATLControlSignal alloc] initWithJson:message];
    [self handleIncomingSignal:incomingSignal];
}

- (void)handleIncomingSignal:(ATLControlSignal*)incomingSignal {
    if ([incomingSignal getType] == ATLSignalTypeInfo) {
        [ATLUtil debug:@"[WebSocket] info from the server: %@", [incomingSignal getValue]];
    } else if ([incomingSignal getType] == ATLSignalTypeEndWait) {
        [ATLUtil debug:@"[WebSocket] end wait signal recevied, reason: %@", [incomingSignal getValue]];
        
    } else if ([incomingSignal getType] == ATLSignalTypeCancelCurrentTest) {
        [ATLUtil debug:@"[WebSocket] cancel test recevied, reason: %@", [incomingSignal getValue]];
        
    } else {
        [ATLUtil debug:@"[WebSocket] unknown signal received by the server. Value: %@", [incomingSignal getValue]];
    }
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    [ATLUtil debug:@"[WebSocket] handshake/connection failed with an error: %@", error];
}

- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [ATLUtil debug:@"websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO"];
}

@end

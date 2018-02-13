//
//  ATLControlChannel.m
//  AdjustTestLibrary
//
//  Created by Pedro on 23.08.17.
//  Copyright © 2017 adjust. All rights reserved.
//

#import "ATLControlChannel.h"
#import "ATLUtil.h"
#import "ATLConstants.h"
#import "ATLUtilNetworking.h"

static NSString * const CONTROL_START_PATH = @"/control_start";
static NSString * const CONTROL_CONTINUE_PATH = @"/control_continue";

@interface ATLControlChannel()

@property (nonatomic, strong) NSOperationQueue* operationQueue;
//@property (nonatomic, strong) ATLTestLibrary * testLibrary;
@property (nonatomic, weak) ATLTestLibrary * testLibrary;
@property (nonatomic, assign) BOOL closed;
@end

@implementation ATLControlChannel

- (id)initWithTestLibrary:(ATLTestLibrary *)testLibrary {
    self = [super init];
    if (self == nil) return nil;

    self.testLibrary = testLibrary;

    self.operationQueue = [[NSOperationQueue alloc] init];
    [self.operationQueue setMaxConcurrentOperationCount:1];

    self.closed = NO;

    [self sendControlRequest:CONTROL_START_PATH];

    return self;
}

- (void)teardown {
    self.closed = YES;
    if (self.operationQueue != nil) {
        [ATLUtil debug:@"queue cancel control channel thread queue"];
        [ATLUtil addOperationAfterLast:self.operationQueue
                                 block:^{
                                     [ATLUtil debug:@"cancel control channel thread queue"];
                                     if (self.operationQueue != nil) {
                                         [self.operationQueue cancelAllOperations];
                                     }
                                     self.operationQueue = nil;
                                     self.testLibrary = nil;
                                 }];
    } else {
        self.operationQueue = nil;
        self.testLibrary = nil;
    }
}

- (void)sendControlRequest:(NSString *)controlPath {
    [ATLUtil addOperationAfterLast:self.operationQueue
                             block:^{
                                 NSDate *timeBefore = [NSDate date];
                                 [ATLUtil debug:@"time before wait: %@", [ATLUtil formatDate:timeBefore]];

                                 ATLHttpRequest * requestData = [[ATLHttpRequest alloc] init];
                                 requestData.path = [ATLUtilNetworking appendBasePath:[self.testLibrary currentBasePath] path:controlPath];

                                 [ATLUtilNetworking sendPostRequest:requestData
                                                    responseHandler:^(ATLHttpResponse *httpResponse) {
                                                        NSDate *timeAfter = [NSDate date];
                                                        [ATLUtil debug:@"time after wait: %@", [ATLUtil formatDate:timeAfter]];
                                                        NSTimeInterval timeElapsedSeconds = [timeAfter timeIntervalSinceDate:timeBefore];
                                                        [ATLUtil debug:@"seconds elapsed waiting %f", timeElapsedSeconds];

                                                        [self readHeaders:httpResponse];
                                                    }];
                             }];
}
- (void)readHeaders:(ATLHttpResponse *)httpResponse {
    [ATLUtil addOperationAfterLast:self.operationQueue blockWithOperation:^(NSBlockOperation * operation) {
        [self readHeadersI:httpResponse];
    }];
}
- (void)readHeadersI:(ATLHttpResponse *)httpResponse {
    if (self.closed) {
        [ATLUtil debug:@"control channel already closed"];
        return;
    }

    if ([httpResponse.headerFields objectForKey:TEST_CANCELTEST_HEADER]) {
        [ATLUtil debug:@"Test canceled due to %@", httpResponse.headerFields[TEST_CANCELTEST_HEADER]];
        [self.testLibrary resetTestLibrary];
        [ATLUtil debug:@"control channel send readResponse to test library"];
        [self.testLibrary readResponse:httpResponse];
    }

    if ([httpResponse.headerFields objectForKey:TEST_ENDWAIT_HEADER]) {
        NSString * waitEndReason = httpResponse.headerFields[TEST_ENDWAIT_HEADER];
        [self sendControlRequest:CONTROL_CONTINUE_PATH];
        [self endWait:waitEndReason];
    }
}

- (void)endWait:(NSString *)waitEndReason {
    [ATLUtil debug:@"End wait from control channel due to %@", waitEndReason];
    [[self.testLibrary waitControlQueue] enqueue:waitEndReason];
    [ATLUtil debug:@"Wait ended from control channel due to %@", waitEndReason];
}
@end

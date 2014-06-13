//
//  AIPackageHandler.m
//  Adjust
//
//  Created by Christian Wellenbrock on 2013-07-03.
//  Copyright (c) 2013 adjust GmbH. All rights reserved.
//

#import "AIPackageHandler.h"
#import "AIActivityHandler.h"
#import "AIRequestHandler.h"
#import "AIActivityPackage.h"
#import "AIResponseData.h"
#import "AILogger.h"
#import "AIUtil.h"
#import "AIAdjustFactory.h"

static NSString   * const kPackageQueueFilename = @"AdjustIoPackageQueue";
static const char * const kInternalQueueName    = "io.adjust.PackageQueue";


#pragma mark - private
@interface AIPackageHandler()

@property (nonatomic) dispatch_queue_t internalQueue;
@property (nonatomic) dispatch_semaphore_t sendingSemaphore;
@property (nonatomic, assign) id<AIActivityHandler> activityHandler;
@property (nonatomic, retain) id<AIRequestHandler> requestHandler;
@property (nonatomic, retain) id<AILogger> logger;
@property (nonatomic, retain) NSMutableArray *packageQueue;
@property (nonatomic, assign, getter = isPaused) BOOL paused;

@end


#pragma mark -
@implementation AIPackageHandler

+ (id<AIPackageHandler>)handlerWithActivityHandler:(id<AIActivityHandler>)activityHandler {
    return [[AIPackageHandler alloc] initWithActivityHandler:activityHandler];
}

- (id)initWithActivityHandler:(id<AIActivityHandler>)activityHandler {
    self = [super init];
    if (self == nil) return nil;

    self.internalQueue = dispatch_queue_create(kInternalQueueName, DISPATCH_QUEUE_SERIAL);
    self.activityHandler = activityHandler;

    dispatch_async(self.internalQueue, ^{
        [self initInternal];
    });

    return self;
}

- (void)addPackage:(AIActivityPackage *)package {
    dispatch_async(self.internalQueue, ^{
        [self addInternal:package];
    });
}

- (void)sendFirstPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendFirstInternal];
    });
}

- (void)sendNextPackage {
    dispatch_async(self.internalQueue, ^{
        [self sendNextInternal];
    });
}

- (void)closeFirstPackage {
    dispatch_semaphore_signal(self.sendingSemaphore);
}

- (void)pauseSending {
    self.paused = YES;
}

- (void)resumeSending {
    self.paused = NO;
}

- (void)finishedTrackingActivity:(AIActivityPackage *)activityPackage withResponse:(AIResponseData *)response {
    response.activityKind = activityPackage.activityKind;
    [self.activityHandler finishedTrackingWithResponse:response];
}


#pragma mark - internal
- (void)initInternal {
    self.requestHandler = [AIAdjustFactory requestHandlerForPackageHandler:self];
    self.logger = AIAdjustFactory.logger;
    self.sendingSemaphore = dispatch_semaphore_create(1);
    [self readPackageQueue];
}

- (void)addInternal:(AIActivityPackage *)newPackage {
    [self.packageQueue addObject:newPackage];
    [self.logger debug:@"Added package %d (%@)", self.packageQueue.count, newPackage];
    [self.logger verbose:@"%@", newPackage.extendedString];

    [self writePackageQueue];
}

- (void)sendFirstInternal {
    if (self.packageQueue.count == 0) return;

    if (self.isPaused) {
        [self.logger debug:@"Package handler is paused"];
        return;
    }

    if (dispatch_semaphore_wait(self.sendingSemaphore, DISPATCH_TIME_NOW) != 0) {
        [self.logger verbose:@"Package handler is already sending"];
        return;
    }

    AIActivityPackage *activityPackage = [self.packageQueue objectAtIndex:0];
    if (![activityPackage isKindOfClass:[AIActivityPackage class]]) {
        [self.logger error:@"Failed to read activity package"];
        [self sendNextInternal];
        return;
    }

    [self.requestHandler sendPackage:activityPackage];
}

- (void)sendNextInternal {
    [self.packageQueue removeObjectAtIndex:0];
    [self writePackageQueue];
    dispatch_semaphore_signal(self.sendingSemaphore);
    [self sendFirstInternal];
}

#pragma mark - private
- (void)readPackageQueue {
    @try {
        NSString *filename = self.packageQueueFilename;
        id object = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
        if ([object isKindOfClass:[NSArray class]]) {
            self.packageQueue = object;
            [self.logger debug:@"Package handler read %d packages", self.packageQueue.count];
            return;
        } else if (object == nil) {
            [self.logger verbose:@"Package queue file not found"];
        } else {
            [self.logger error:@"Failed to read package queue"];
        }
    } @catch (NSException *exception) {
        [self.logger error:@"Failed to read package queue (%@)", exception];
    }

    // start with a fresh package queue in case of any exception
    self.packageQueue = [NSMutableArray array];
}

- (void)writePackageQueue {
    NSString *filename = self.packageQueueFilename;
    BOOL result = [NSKeyedArchiver archiveRootObject:self.packageQueue toFile:filename];
    if (result == YES) {
        [AIUtil excludeFromBackup:filename];
        [self.logger debug:@"Package handler wrote %d packages", self.packageQueue.count];
    } else {
        [self.logger error:@"Failed to write package queue"];
    }
}

- (NSString *)packageQueueFilename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filename = [path stringByAppendingPathComponent:kPackageQueueFilename];
    return filename;
}

@end

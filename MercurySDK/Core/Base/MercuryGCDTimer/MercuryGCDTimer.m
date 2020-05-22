//
//  MercuryGCDTimer.m
//  MercurySDK
//
//  Created by CherryKing on 2020/4/1.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercuryGCDTimer.h"

@interface MercuryGCDTimer ()
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, assign, getter=isPauseFlag) BOOL pauseFlag;

@end

@implementation MercuryGCDTimer

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval runBlock:(void (^)(void))runBlock {
    return [[MercuryGCDTimer new] initWithTimeInterval:timeInterval runBlock:runBlock];
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval runBlock:(void (^)(void))runBlock {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, timeInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer, ^{
       dispatch_async(dispatch_get_main_queue(), runBlock);
    });
    _pauseFlag = NO;
    dispatch_resume(_timer);
    
    return self;
}

- (void)pauseTimer {
    if (!_pauseFlag && self.timer) {
        dispatch_suspend(_timer);
        _pauseFlag = YES;
    }
}

- (void)resumeTimer {
    if (_pauseFlag && self.timer) {
        dispatch_resume(_timer);
        _pauseFlag = NO;
    }
}

- (void)stopTimer {
    if (self.timer) {
        dispatch_cancel(self.timer);
        self.timer = nil;
        _pauseFlag = NO;
    }
}

@end

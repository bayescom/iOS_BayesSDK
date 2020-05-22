//
//  MercuryGCDTimer.h
//  MercurySDK
//
//  Created by CherryKing on 2020/4/1.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryGCDTimer : NSObject

/// 构建一个机遇GCD的Timer，一但被创建会立即开始触发
/// @param timeInterval 触发间隔
/// @param runBlock 需要执行的block
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)timeInterval runBlock:(void (^)(void))runBlock;

/// 暂停定时器
- (void)pauseTimer;

/// 继续执行定时器
- (void)resumeTimer;

/// 停止并销毁Timer
- (void)stopTimer;
@end

NS_ASSUME_NONNULL_END

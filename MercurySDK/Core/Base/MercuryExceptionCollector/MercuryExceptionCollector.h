//
//  MercuryExceptionCollector.h
//  MercurySDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

// 发生异常的通知
static NSString * _Nonnull const ExcepitionHappenedNotification = @"ExcepitionHappenedNotification";

void mercury_handleErrorWithException(NSException * _Nullable exception);

NS_ASSUME_NONNULL_BEGIN

@interface MercuryExceptionCollector : NSObject

/**
 处理异常信息
 
 @param exception 异常
 */
+ (void)handleErrorWithException:(NSException *)exception;

@end

NS_ASSUME_NONNULL_END

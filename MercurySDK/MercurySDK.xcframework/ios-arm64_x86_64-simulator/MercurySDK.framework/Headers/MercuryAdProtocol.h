//
//  MercuryAdProtocol.h
//  MercurySDK
//
//  Created by guangyao on 2025/9/16.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryAdProtocol <NSObject>

@optional

/// 获取广告剩余有效时间（秒）
- (NSTimeInterval)getAdValidSeconds;

/// 竞败之后调用
/// - Parameter price: 竞胜方出价 (单位: 分)
- (void)sendLossNotificationWithPrice:(NSInteger)price;


@end

NS_ASSUME_NONNULL_END

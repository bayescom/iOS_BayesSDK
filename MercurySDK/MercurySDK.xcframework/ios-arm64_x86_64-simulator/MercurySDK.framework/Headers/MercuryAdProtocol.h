//
//  MercuryAdProtocol.h
//  MercurySDK
//
//  Created by guangyao on 2025/9/16.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 竞败原因
typedef NS_ENUM(NSInteger, MercuryAdBidLossReason) {
    /// 其他原因
    MercuryAdBidLossReasonOther = 0,
    /// 比价落败
    MercuryAdBidLossReasonPrice = 1,
    /// 出价低于底价
    MercuryAdBidLossReasonBelowFloorPrice = 2,
    /// 返回超时
    MercuryAdBidLossReasonTimeout = 3,
    /// 参数缺失返回无效
    MercuryAdBidLossReasonInvalidResponse = 4,
    /// 先审后投审核中
    MercuryAdBidLossReasonUnderReview = 5,
    /// 素材审核不通过
    MercuryAdBidLossReasonMaterialRejected = 6,
    /// 素材类型与尺寸不匹配
    MercuryAdBidLossReasonMaterialMismatch = 7,
    /// 广告主包名过滤
    MercuryAdBidLossReasonAdvertiserBundleFiltered = 8,
    /// 广告主域名过滤
    MercuryAdBidLossReasonAdvertiserDomainFiltered = 9,
    /// 链接非https过滤
    MercuryAdBidLossReasonNonHTTPS = 10,
    /// 监测地址过长
    MercuryAdBidLossReasonTrackingURLTooLong = 11,
};

@protocol MercuryAdProtocol <NSObject>

@optional

/// 获取广告剩余有效时间（秒）
- (NSTimeInterval)getAdValidSeconds;

/// 竞胜之后调用
/// - Parameters:
///   - winPrice: 竞胜价格，单位：分/CPM（千次展示）
///   - highestLossPrice: 最高竞败价格，单位：分/CPM（千次展示）
- (void)sendWinNotificationWithWinPrice:(double)winPrice
                       highestLossPrice:(double)highestLossPrice;

/// 竞败之后调用
/// - Parameters:
///   - winPrice: 竞胜价格，单位：分/CPM（千次展示）
///   - lossReason: 竞败原因
- (void)sendLossNotificationWithWinPrice:(double)winPrice
                              lossReason:(MercuryAdBidLossReason)lossReason;

/// 竞败之后调用
/// - Parameter price: 竞胜价格，单位：分/CPM（千次展示）
- (void)sendLossNotificationWithPrice:(NSInteger)price
    __attribute__((deprecated("Use sendLossNotificationWithWinPrice:lossReason: instead.")));


@end

NS_ASSUME_NONNULL_END

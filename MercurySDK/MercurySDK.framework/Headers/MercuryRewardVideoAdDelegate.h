//
//  MercuryRewardVideoAdDelegate.h
//  MercurySDK
//
//  Created by guangyao on 2023/12/18.
//  Copyright © 2023 mercury. All rights reserved.
//

@class MercuryRewardVideoAd;
@protocol MercuryRewardVideoAdDelegate <NSObject>

@optional
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

/// 广告加载失败回调
- (void)mercury_rewardAdFailError:(nullable NSError *)error __attribute__((deprecated("接口即将废弃，请使用 mercury_rewardVideoAd:didFailWithError:")));

/// 视频广告各种错误信息回调
- (void)mercury_rewardVideoAd:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd didFailWithError:(NSError *_Nullable)error;

/// 视频数据下载成功回调，已经下载过的视频会直接回调
- (void)mercury_rewardVideoAdVideoDidLoad:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

/// 视频播放页即将曝光回调
- (void)mercury_rewardVideoAdWillVisible:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

/// 视频广告曝光回调
- (void)mercury_rewardVideoAdDidExposed:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

/// 视频播放页关闭回调
- (void)mercury_rewardVideoAdDidClose:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

/// 视频广告信息点击回调
- (void)mercury_rewardVideoAdDidClicked:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

/// 视频广告播放达到激励条件回调
- (void)mercury_rewardVideoAdDidRewardEffective:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

@end

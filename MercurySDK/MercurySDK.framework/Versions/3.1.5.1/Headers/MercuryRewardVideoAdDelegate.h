//
//  MercuryRewardVideoAdDelegate.h
//  MercurySDKExample
//
//  Created by 程立卿 on 2020/4/23.
//  Copyright © 2020 mercury. All rights reserved.
//

#ifndef MercuryRewardVideoAdDelegate_h
#define MercuryRewardVideoAdDelegate_h

@protocol MercuryRewardVideoAdDelegate <NSObject>

@optional
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad;

/// 广告加载失败回调
- (void)mercury_rewardAdFailError:(nullable NSError *)error;

/// 视频数据下载成功回调，已经下载过的视频会直接回调
- (void)mercury_rewardVideoAdVideoDidLoad;

/// 视频播放页即将曝光回调
- (void)mercury_rewardVideoAdWillVisible;

/// 视频广告曝光回调
- (void)mercury_rewardVideoAdDidExposed;

/// 视频播放页关闭回调
- (void)mercury_rewardVideoAdDidClose;

/// 视频广告信息点击回调
- (void)mercury_rewardVideoAdDidClicked;

/// 视频广告播放达到激励条件回调
- (void)mercury_rewardVideoAdDidRewardEffective;

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish;

@end

#endif

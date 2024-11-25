//
//  MercuryRewardVideoAd.h
//  MercurySDK
//
//  Created by guangyao on 2023/12/19.
//  Copyright © 2023 mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryAdMaterial.h"
#import "MercuryBaseAdObject.h"
#import "MercuryRewardedVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MercuryRewardVideoAd;
@protocol MercuryRewardVideoAdDelegate <NSObject>

@optional
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

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

/// 服务端验证奖励失败回调
- (void)mercury_rewardVideoAdServerRewardDidFail:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd error:(NSError *_Nullable)error;

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd;

@end


@interface MercuryRewardVideoAd : MercuryBaseAdObject

@property (nonatomic, weak) id<MercuryRewardVideoAdDelegate> delegate;

@property (nonatomic, strong) MercuryRewardedVideoModel *rewardedVideoModel;

/// 广告是否有效
@property (nonatomic, assign, readonly) BOOL isAdValid;

/// 实时价格（分）
@property (nonatomic, assign) NSInteger price;

@property (nonatomic, assign) NSTimeInterval timeoutTime __attribute__((deprecated("该字段已废弃，请忽略")));

/// 初始化激励广告
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryRewardVideoAdDelegate> _Nullable)delegate;

/// 构造方法 (可携带自定义参数)
/// @param adspotId 广告id
/// @param ext 自定义参数
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary * _Nullable)ext
                          delegate:(id<MercuryRewardVideoAdDelegate> _Nullable)delegate;

/// 加载广告
- (void)loadAd;
- (void)loadRewardVideoAd __attribute__((deprecated("接口即将废弃，请使用loadAd")));

/// 展示广告
- (void)showAdFromRootViewController:(UIViewController *)rootViewController;
- (void)showAdFromVC:(UIViewController *)vc __attribute__((deprecated("接口即将废弃，请使用showAdFromRootViewController:")));

#pragma mark: - S2S Bidding
/// 获取 sdkInfo 用于 Server Bidding 请求获取 token
- (NSString *)getSDKInfo;

/// 请求bidding广告
/// - Parameter token: 媒体传入竞价成功的广告token
- (void)loadBiddingAd:(NSString *)token;

/// 获取广告素材
- (MercuryAdMaterial *)getAdMaterial;

@end

NS_ASSUME_NONNULL_END

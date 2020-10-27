//
//  MercurySplashAdDelegate.h
//  MercurySDKExample
//
//  Created by 程立卿 on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#ifndef MercurySplashAdDelegate_h
#define MercurySplashAdDelegate_h

@class MercurySplashAd;

@protocol MercurySplashAdDelegate <NSObject>
@optional

/// 开屏广告模型加载成功
/// @param splashAd 广告数据
- (void)mercury_splashAdDidLoad:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告成功曝光
/// @param splashAd 广告数据
- (void)mercury_splashAdSuccessPresentScreen:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告曝光失败
/// @param error 异常返回
- (void)mercury_splashAdFailError:(NSError * _Nullable)error;

/// 应用进入后台时回调
/// @param splashAd 广告数据
- (void)mercury_splashAdApplicationWillEnterBackground:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告曝光回调
/// @param splashAd 广告数据
- (void)mercury_splashAdExposured:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告点击回调
/// @param splashAd 广告数据
- (void)mercury_splashAdClicked:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告点击跳过回调
/// @param splashAd 广告数据
- (void)mercury_splashAdSkipClicked:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告将要关闭回调
/// @param splashAd 广告数据
- (void)mercury_splashAdWillClosed:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告关闭回调
/// @param splashAd 广告数据
- (void)mercury_splashAdClosed:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告剩余时间回调
- (void)mercury_splashAdLifeTime:(NSUInteger)time;

@end

typedef NS_ENUM(NSUInteger, MercurySplashAdShowType) {
    /// 默认展示模式 资源不做裁剪 素材超长不展示底部控件(Logo BottomView)
    MercurySplashAdShowDefault = 0,
    /// 必须展示底部控件(Logo BottomView) 会对素材底部进行遮盖
    MercurySplashAdShowCutBottom,
};

#endif

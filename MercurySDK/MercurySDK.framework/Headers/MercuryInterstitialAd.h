//
//  MercuryInterstitialAd.h
//  MercurySDK
//
//  Created by guangyao on 2023/12/25.
//  Copyright © 2023 mercury. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryAdMaterial.h"
#import "MercuryBaseAdObject.h"

NS_ASSUME_NONNULL_BEGIN

@class MercuryInterstitialAd;
@protocol MercuryInterstitialAdDelegate <NSObject>

@optional

/**
 *  插屏广告预加载成功回调
 *  当接收服务器返回的广告数据成功且预加载后调用该函数
 */
- (void)mercury_interstitialSuccessToLoadAd:(MercuryInterstitialAd *)interstitialAd;

/**
 *  插屏广告预加载失败回调
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)mercury_interstitialFailToLoadAd:(MercuryInterstitialAd *)interstitialAd error:(NSError *)error;

/**
 *  插屏广告视频缓存完成
 */
- (void)mercury_interstitialDidDownloadVideo:(MercuryInterstitialAd *)interstitialAd;

/**
 *  插屏广告渲染成功
 */
- (void)mercury_interstitialRenderSuccess:(MercuryInterstitialAd *)interstitialAd;

/**
 *  插屏广告渲染失败
 */
- (void)mercury_interstitialRenderFail:(MercuryInterstitialAd *)interstitialAd error:(NSError *)error;

/**
 *  插屏广告视图展示成功回调
 *  插屏广告展示成功回调该函数
 */
- (void)mercury_interstitialDidPresentScreen:(MercuryInterstitialAd *)interstitialAd;

/**
 *  插屏广告视图展示失败回调
 *  插屏广告展示失败回调该函数
 */
- (void)mercury_interstitialFailToPresent:(MercuryInterstitialAd *)interstitialAd;

/**
 *  插屏广告展示结束回调
 *  插屏广告展示结束回调该函数
 */
- (void)mercury_interstitialDidDismissScreen:(MercuryInterstitialAd *)interstitialAd;

/**
 *  插屏广告曝光回调
 */
- (void)mercury_interstitialWillExposure:(MercuryInterstitialAd *)interstitialAd __attribute__((deprecated("接口即将废弃，请使用 mercury_interstitialDidPresentScreen:")));

/**
 *  插屏广告点击回调
 */
- (void)mercury_interstitialClicked:(MercuryInterstitialAd *)interstitialAd;

@end


@interface MercuryInterstitialAd : MercuryBaseAdObject

/// 代理对象
@property (nonatomic, weak) id<MercuryInterstitialAdDelegate> delegate;

/// 广告是否有效
@property (nonatomic, assign, readonly) BOOL isAdValid;

/// 实时价格（分）
@property (nonatomic, assign) NSInteger price;

/// 初始方法
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryInterstitialAdDelegate> _Nullable)delegate;


/// 初始方法
/// @param adspotId 广告Id
/// @param delegate 代理对象
/// @param ext 自定义拓展参数
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary *_Nullable)ext
                          delegate:(id<MercuryInterstitialAdDelegate> _Nullable)delegate;

/**
 *  广告发起请求方法
 *  详解：[必选]发起拉取广告请求
 */
- (void)loadAd;

/**
 *  广告展示方法
 *  详解：[必选]发起展示广告请求, 必须传入用于显示插屏广告的UIViewController
 */
- (void)presentAdFromViewController:(UIViewController *)viewController;

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

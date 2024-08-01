//
//  MercuryNativeExpressAd.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/22.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryNativeExpressAdView.h"
#import "MercuryAdMaterial.h"
#import "MercuryBaseAdObject.h"

NS_ASSUME_NONNULL_BEGIN

@class MercuryNativeExpressAd;
@protocol MercuryNativeExpressAdDelegete <NSObject>

@optional
/// 拉取原生模板广告成功
- (void)mercury_nativeExpressAdSuccessToLoad:(MercuryNativeExpressAd *)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views;

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoad:(MercuryNativeExpressAd *)nativeExpressAd error:(NSError *)error;
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error __attribute__((deprecated("接口即将废弃，请使用 mercury_nativeExpressAdFailToLoad:error:")));

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 广告详情页面即将展示回调
- (void)mercury_nativeExpressAdDetailViewWillPresentScreen:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 广告详情页关闭回调
- (void)mercury_nativeExpressAdDetailViewDidDismissScreen:(MercuryNativeExpressAdView *)nativeExpressAdView;

@end

@interface MercuryNativeExpressAd : MercuryBaseAdObject

/// 广告展示的尺寸
/// 可将宽度设置为屏宽，自适应时，可将高度直接设置为0
@property (nonatomic, assign) CGSize renderSize;

/// 广告展示的内部间距。范围[0, 30] pt，默认值12.f
@property (nonatomic, assign) CGFloat padding;

/// 代理
@property (nonatomic, weak) id<MercuryNativeExpressAdDelegete> delegate;

/// 是否静音。默认 YES。
@property (nonatomic, assign) BOOL videoMuted __attribute__((deprecated("该字段已废弃，请在Blink后台广告位下进行配置")));

/// 构造方法
/// @param adspotId 广告位 ID
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId;

/// 构造方法
/// @param adspotId 广告位 ID
/// @param ext 自定义拓展参数
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary *_Nullable)ext;

/// 加载广告
- (void)loadAdWithCount:(NSInteger)count;

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

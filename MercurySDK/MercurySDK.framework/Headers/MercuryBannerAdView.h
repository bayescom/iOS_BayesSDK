//
//  MercuryBannerAdView.h
//  MercurySDK
//
//  Created by guangyao on 2024/3/22.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryAdMaterial.h"

NS_ASSUME_NONNULL_BEGIN

@class MercuryBannerAdView;
@protocol MercuryBannerAdViewDelegate <NSObject>

@optional
/// 请求广告条数据成功后调用
- (void)mercury_bannerViewDidReceived:(MercuryBannerAdView *_Nonnull)banner;

/// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(MercuryBannerAdView *_Nonnull)banner error:(NSError *_Nullable)error;

/// banner条渲染失败回调
- (void)mercury_bannerViewRenderFail:(MercuryBannerAdView *_Nonnull)banner error:(NSError *_Nullable)error;

/// banner条曝光回调
- (void)mercury_bannerViewWillExposure:(MercuryBannerAdView *_Nonnull)banner;

/// banner条点击回调
- (void)mercury_bannerViewClicked:(MercuryBannerAdView *_Nonnull)banner;

/// banner条被用户关闭时调用
- (void)mercury_bannerViewWillClose:(MercuryBannerAdView *_Nonnull)banner;

@end

@interface MercuryBannerAdView : UIView

/// 委托 [可选]
@property(nonatomic, weak) id<MercuryBannerAdViewDelegate> delegate;

/// 用来显示广告的ViewController [必选]
@property (nonatomic, weak) UIViewController *controller;

/// 广告刷新间隔，范围 [10, 120] 秒，设 0 则不刷新。[可选]
@property(nonatomic, assign) NSInteger interval;

/// 实时价格（分）
@property(nonatomic, assign) NSInteger price;

/// 初始方法
/// @param frame banner 展示的位置和大小
/// @param adspotId 广告位id
/// @param delegate 代理
- (instancetype)initWithFrame:(CGRect)frame
                     adspotId:(NSString *_Nonnull)adspotId
                     delegate:(id<MercuryBannerAdViewDelegate> _Nullable)delegate;

/// 初始方法
/// @param frame banner 展示的位置和大小
/// @param adspotId 广告位id
/// @param ext 自定义拓展参数
/// @param delegate 代理
- (instancetype)initWithFrame:(CGRect)frame
                     adspotId:(NSString *_Nonnull)adspotId
                    customExt:(NSDictionary *_Nullable)ext
                     delegate:(id<MercuryBannerAdViewDelegate> _Nullable)delegate;

/// 拉取并展示广告
- (void)loadAdAndShow;

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

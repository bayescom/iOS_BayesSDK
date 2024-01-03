//
//  MercuryBannerAdView.h
//  Example
//
//  Created by CherryKing on 2019/11/8.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MercuryBannerAdView;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryBannerAdViewDelegate <NSObject>

@optional
/// 请求广告条数据成功后调用
- (void)mercury_bannerViewDidReceived:(MercuryBannerAdView *_Nonnull)banner;

/// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(MercuryBannerAdView *_Nonnull)banner error:(nullable NSError *)error;

/// banner条被用户关闭时调用
- (void)mercury_bannerViewWillClose:(MercuryBannerAdView *_Nonnull)banner;

/// banner条曝光回调
- (void)mercury_bannerViewWillExposure:(MercuryBannerAdView *_Nonnull)banner;

/// banner条点击回调
- (void)mercury_bannerViewClicked:(MercuryBannerAdView *_Nonnull)banner;

@end

@interface MercuryBannerAdView : UIView

/// 需设置为显示广告的UIViewController [必选]
@property (nonatomic, weak) UIViewController * _Nullable controller;

/// 委托 [可选]
@property(nonatomic, weak) id<MercuryBannerAdViewDelegate> _Nullable delegate;

/// 广告刷新间隔，范围 [30, 120] 秒，默认值 30 秒。设 0 则不刷新。 [可选]
@property(nonatomic, assign) int interval;

/// Banner曝光和轮播时的动画效果开关，默认打开
@property(nonatomic, assign, getter=isAnimateOn) BOOL animationOn;

/// Banner条曝光关闭按钮，默认打开
@property(nonatomic, assign, getter=isShowCloseBtn) BOOL showCloseBtn;


/// 实时价格
@property(nonatomic, assign) NSInteger price;

/// 初始方法
- (instancetype _Nullable )initWithAdspotId:(NSString *_Nullable)adspotId;


/// 初始方法
/// @param adspotId adspotId
/// @param ext 自定义拓展参数
- (instancetype _Nullable )initWithAdspotId:(NSString *_Nullable)adspotId
                                 customExt:(NSDictionary *_Nullable)ext;

/// 初始方法
- (instancetype _Nullable )initWithFrame:(CGRect)frame
                                adspotId:(NSString *_Nullable)adspotId
                                delegate:(id<MercuryBannerAdViewDelegate> _Nullable)delegate;


/// 初始方法
/// @param frame frame
/// @param adspotId adspotid
/// @param ext 自定义拓展参数
/// @param delegate delegate
- (instancetype _Nullable )initWithFrame:(CGRect)frame
                                adspotId:(NSString *_Nullable)adspotId
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

@end

NS_ASSUME_NONNULL_END

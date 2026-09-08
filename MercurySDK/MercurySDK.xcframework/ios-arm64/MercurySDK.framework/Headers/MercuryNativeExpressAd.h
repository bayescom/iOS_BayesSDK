//
//  MercuryNativeExpressAd.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/22.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryNativeExpressAdView.h"
#import "MercuryServerBiddingProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MercuryNativeExpressAd;
@protocol MercuryNativeExpressAdDelegate <NSObject>

@optional
/// 拉取原生模板广告成功
- (void)mercury_nativeExpressAdSuccessToLoad:(MercuryNativeExpressAd *)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views;

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoad:(MercuryNativeExpressAd *)nativeExpressAd error:(NSError *)error;

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

/// 历史拼写兼容，请使用 MercuryNativeExpressAdDelegate。
__attribute__((deprecated("Use MercuryNativeExpressAdDelegate instead")))
@protocol MercuryNativeExpressAdDelegete <MercuryNativeExpressAdDelegate>
@end

@interface MercuryNativeExpressAd : NSObject <MercuryServerBiddingProtocol>

/// 广告展示的尺寸
/// 可将宽度设置为屏宽，自适应时，可将高度直接设置为0
@property (nonatomic, assign) CGSize renderSize;

/// 广告展示的内部间距。范围[0, 30] pt，默认值12.f
@property (nonatomic, assign) CGFloat padding;

/// 代理
@property (nonatomic, weak) id<MercuryNativeExpressAdDelegate> delegate;

/// 构造方法
/// @param adspotId 广告位 ID
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId;

/// 构造方法
/// @param adspotId 广告位 ID
/// @param ext 自定义拓展参数
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary *_Nullable)ext;

/**
 加载广告，仅加载一条数据
 */
- (void)loadAd;

/**
 加载广告
 @param count 加载条数
 */
- (void)loadAdWithCount:(NSInteger)count __attribute__((deprecated("已弃用，只支持返回1个广告")));

@end

NS_ASSUME_NONNULL_END

//
//  MercuryNativeAdView.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/7.
//  Copyright © 2020 mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryPubEnumHeader.h"
#import "MercuryAdViewVideoHandle.h"

@class MercuryImp;
@class MercuryNativeAd;
@class MercuryNativeAdView;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryNativeAdViewDelegate <NSObject>

/// 广告曝光回调
/// @param nativeAdView MercuryNativeAdView 实例
- (void)mercury_nativeAdViewWillExpose:(MercuryNativeAdView *)nativeAdView;

/// 广告点击回调
/// @param nativeAdView MercuryNativeAdView 实例
- (void)mercury_nativeAdViewDidClick:(MercuryNativeAdView *)nativeAdView;

/// 广告渲染成功
/// @param nativeAdView MercuryNativeAdView 实例
/// @param adSize 广告的真实尺寸，可以根据此尺寸按比例自定义缩放视图
- (void)mercury_nativeAdViewRenderSuccess:(MercuryNativeAdView *)nativeAdView adSize:(CGSize)adSize;

/// 视频广告播放状态更改回调
/// @param nativeAdView MercuryNativeAdView 实例
/// @param status 视频广告播放状态
- (void)mercury_nativeAdView:(MercuryNativeAdView *)nativeAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

@end

@interface MercuryNativeAdView : UIView

/// 当前的Imp
@property (nonatomic, strong, readonly) MercuryImp *imp;

/// 设置代理
@property (nonatomic, weak) id<MercuryNativeAdViewDelegate> delegate;

/// 初始化方法 传入Imp和希望展示的尺寸
- (instancetype)initAdWithImp:(MercuryImp * _Nonnull)imp size:(CGSize)size;

/// 控制器
@property (nonatomic, weak) UIViewController *controller;

/// 是否渲染完整
@property (nonatomic, assign, readonly) BOOL isReady;

/// 显示模式
@property (nonatomic, assign) MercuryNativeExpressAdSizeMode adSizeMode;

/// 视频操作对象
@property (nonatomic, strong, readonly) MercuryAdViewVideoHandle *handle;

/// 按照 MercuryNativeExpressAd.renderSize 渲染广告
- (void)render;

/// 将views中的视图设置为点击可触发吊起广告的视图
- (void)registAdClickViews:(NSArray *)views;

/// 移除views中添加的手势
- (void)unregistAdClickViews:(NSArray *)views;

@end

NS_ASSUME_NONNULL_END

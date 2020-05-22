//
//  MercuryNativeExpressAdView.h
//  Example
//
//  Created by CherryKing on 2019/12/13.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryPubEnumHeader.h"
#import "MercuryAdViewVideoHandle.h"

@class MercuryImp;
@class MercuryNativeExpressAd;
@class MercuryNativeExpressAdView;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryNativeExpressAdViewDelegate <NSObject>

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

/// 原生模板视频广告 player 播放状态更新回调
- (void)mercury_nativeExpressAdView:(MercuryNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

@end

@interface MercuryNativeExpressAdView : UIView

/// 设置代理
@property (nonatomic, weak) id<MercuryNativeExpressAdViewDelegate> delegate;

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

@end

NS_ASSUME_NONNULL_END

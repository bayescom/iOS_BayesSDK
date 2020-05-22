//
//  MercuryAdView.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryPriEnumHeader.h"
#import "MercuryPubEnumHeader.h"
#import "MercuryAdViewVideoHandle.h"

@class MercuryImp;
@class MercuryAdModel;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryAdViewDelegate <NSObject>
@optional

/// 广告内容被点击
- (void)mercuryAdViewDidClickWithImp:(MercuryImp *)imp;

/// 广告内容被曝光 (曝光只会触发一次)
- (void)mercuryAdViewDidExpressWithImp:(MercuryImp *)imp;

/// 广告资源尺寸被获取成功
/// 当拉取失败，impSize 为 CGSIzeZero
- (void)mercuryAdViewAdSourceDidRecevedWithImp:(MercuryImp *)imp size:(CGSize)impSize;

// MARK: ======================= 视频 =======================
/// 播放状态发生变化
- (void)mercuryAdViewVideoStatusChangeWithImp:(MercuryImp *)imp status:(MercuryMediaPlayerStatus)status;

/// 播放时间变化
- (void)mercuryAdViewVideoTimeCurrentTime:(CGFloat)currentTime totalTime:(CGFloat)totalTime;

/// 视频缓存进度 如已经缓存到本地 则直接回调
- (void)mercuryAdViewVideoLoadProgressWithImp:(MercuryImp *)imp loadedProgress:(CGFloat)loadedProgress;

// MARK: ======================= SKStoreProductViewController | MercuryWebViewController 生命周期监听 =======================
/// 即将弹出全屏广告页
- (void)mercuryAdViewWillPresentFullScreenModal:(MercuryImp *)imp;

/// 已经弹出全屏广告页
- (void)mercuryAdViewDidPresentFullScreenModal:(MercuryImp *)imp;

/// 即将退出全屏广告页
- (void)mercuryAdViewWillDismissFullScreenModal:(MercuryImp *)imp;

/// 已经退出全屏广告页
- (void)mercuryAdViewDidDismissFullScreenModal:(MercuryImp *)imp;


@end

@interface MercuryAdView : UIView

/// 当前展示的广告
@property (nonatomic, strong, readonly) MercuryImp *curImp;

/// 是否渲染完成
@property (nonatomic, assign, readonly) BOOL renderSuccess;

/// 代理回调
@property (nonatomic, weak) id<MercuryAdViewDelegate> delegate;

/// 资源所需尺寸
@property (nonatomic, assign, readonly) CGSize impSize;

/// 水印Y轴偏移量
@property (nonatomic, assign) CGFloat waterMarkYOffset;

/// 用于弹出广告的controller
@property (nonatomic, strong) UIViewController *controller;

/// 允许在移动网络下下载
@property (nonatomic, assign) BOOL downloadOnWWAN;

/// 构建广告
- (instancetype)initAdWithImp:(MercuryImp * _Nonnull)imp;

/// 构建广告
- (instancetype)initAdWithImp:(MercuryImp * _Nonnull)imp handle:(MercuryAdViewVideoHandle *)handle;

/// 加载广告
- (void)loadAdWithImp:(MercuryImp *)imp;

/// 开始渲染广告
/// @param size 希望展示的尺寸
- (void)renderWithSize:(CGSize)size;

/// 销毁
- (void)destory;

/// 手动触发点击逻辑
@property (nonatomic, strong, readonly) UILongPressGestureRecognizer *tapGesRec;

/// 将views中的视图设置为点击可触发吊起广告的视图
- (void)registAdClickViews:(NSArray *)views;

/// 移除views中添加的手势
- (void)unregistAdClickViews:(NSArray *)views;

@end

/// 媒体操作
@interface MercuryAdView (Media) <MercuryAdViewVideoHandleDelegate>

/// 播放器 操作 | 配置 对象
@property (nonatomic, strong, readonly) MercuryAdViewVideoHandle *handle;

/// 视频总时长
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;

@end

NS_ASSUME_NONNULL_END

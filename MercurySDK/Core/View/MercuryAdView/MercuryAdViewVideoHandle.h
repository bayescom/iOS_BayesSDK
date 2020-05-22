//
//  MercuryAdViewVideoHandle.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/5/9.
//  Copyright © 2020 mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryPubEnumHeader.h"

@class MercuryAdView;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryAdViewVideoHandleDelegate <NSObject>
/// 播放
- (void)play;

/// 重新播放
- (void)replay;

/// 暂停播放
- (void)pause;

/// 停止播放
- (void)stop;

@end

@interface MercuryAdViewVideoHandle : NSObject

/// 使用默认的配置
+ (instancetype)defaultHandle;

/// 是否静音 YES 表示静音
@property (nonatomic, assign, getter=isMuted) BOOL muted;

/// 播放策略
@property (nonatomic, assign) MercuryVideoAutoPlayPolicy videoPlayPolicy;

/// 是否展示播放/缓存进度
@property (nonatomic, assign) BOOL showPlayProgress;

/// 关闭自动播放 检测 def: False
@property (nonatomic, assign) BOOL stopAutoExpCheckFlag;

/// 隐藏默认的广告标签
@property (nonatomic, assign) BOOL hiddenSource;

/// 是否启动自动续播功能，默认 NO
@property (nonatomic, assign) BOOL autoResumeEnable;

/// 是否支持用户点击 MediaView 改变视频播放暂停状态，默认 NO
@property (nonatomic, assign) BOOL userControlEnable;

/// 是否在暂停时展示暂停按钮
@property (nonatomic, assign) BOOL showPlayAndPause;

/// 是否在加载时显示加载动画
@property (nonatomic, assign) BOOL showLoading;

/// 是否去除手动添加的广告标记水印
@property (nonatomic, assign) BOOL removeWaterMarkFlag;

/// 初始化媒体控制器
+ (instancetype)managerWithAdView:(MercuryAdView *)adView;

/// 操作配置handle绑定到adView 配置会立即作用到播放器上
- (void)configAdView:(MercuryAdView *)adView;

@end

NS_ASSUME_NONNULL_END

//
//  MercurySplashAdView.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercurySplashAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercurySplashAdView : UIView
@property (nonatomic, weak) MercurySplashAd *ad;
@property (nonatomic, weak) id<MercurySplashAdDelegate> delegate;

/// 广告底部组件展示样式类型
@property (nonatomic, assign) MercurySplashAdShowType showType;

/// 父视图 详解：[必选]需设置为显示广告的UIViewController
@property (nonatomic, weak) UIViewController *controller;
/// 广告占位图
@property (nonatomic, strong) UIImage *placeholderImage;
/// Logo广告
@property (nonatomic, strong) UIImage *logoImage;

/// 自定义跳过按钮
@property (nonatomic, strong) UIView *skipView;
/// 自定义底部按钮
@property (nonatomic, strong) UIView *bottomView;

@property(nonatomic, copy) void (^dismissBlock)(void);

/// 初始化
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                        fetchDelay:(NSTimeInterval)fetchDelay;

/// 按照指定尺寸渲染广告
- (void)renderWithSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END

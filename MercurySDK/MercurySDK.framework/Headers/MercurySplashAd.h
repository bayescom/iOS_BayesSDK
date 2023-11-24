//
//  MercurySplashAd.h
//  MercurySDKExample
//
//  Created by 程立卿 on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercurySplashAdDelegate.h"
#import "MercuryPublicEnum.h"
NS_ASSUME_NONNULL_BEGIN

@interface MercurySplashAd : NSObject

/// 回调
@property (nonatomic, weak) id<MercurySplashAdDelegate> delegate;

/// 拉取广告超时时间，默认为3秒
/// Desc: 拉取广告超时时间，开发者调用 loadDataWithResultBlock 方法以后会立即曝光backgroundImage，然后在该超时时间内，如果广告拉取成功，则立马曝光开屏广告，否则放弃此次广告曝光机会。
@property (nonatomic, assign) NSInteger fetchDelay;

/// showType =  MercurySplashAdAutoAdaptScreen 或 showType =  MercurySplashAdAutoAdaptScreenWithLogoFirst 生效
/// 当底部留白 > blankGap 时 会显示logo
/// 默认值是 55
@property (nonatomic, assign) NSInteger blankGap;


/// 广告底部组件展示样式类型
@property (nonatomic, assign) MercurySplashAdShowType showType;

/// 广告占位图
@property (nonatomic, strong) UIImage *placeholderImage;
/// Logo广告
@property (nonatomic, strong) UIImage *logoImage;
/// controller 控制器 用于落地页的跳转 不传则获取当前最上层的viewcontroller
@property (nonatomic, weak) UIViewController *controller;

/// 广告的实时价格
@property (nonatomic, assign) NSInteger price;

/// 构造方法
/// @param adspotId 广告Id
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercurySplashAdDelegate> _Nullable)delegate;


/// 构造方法 (可携带自定义参数)
/// @param adspotId 广告id
/// @param ext 自定义参数
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary * _Nonnull)ext
                          delegate:(id<MercurySplashAdDelegate> _Nullable)delegate;

/// 拉取广告数据 只拉取 不展示
- (void)loadAd;


/// 展示广告 最好是keywindow, 且不要做遮挡
- (void)showAdInWindow:(UIWindow *)window;

/// 获取本次开屏广告的价格
- (NSInteger)getPrice;

/// 销毁广告
- (void)destory;

/// ServerBidding时 其他渠道曝光时 需调用该方法, 非ServerBidding是调用该方法则无效
- (void)reportAdExposured;

/// ServerBidding时 其他渠道被点击时 需调用该方法, 非ServerBidding是调用该方法则无效
- (void)reportAdClicked;

@end

NS_ASSUME_NONNULL_END

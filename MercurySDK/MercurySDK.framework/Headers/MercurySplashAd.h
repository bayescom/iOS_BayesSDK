//
//  MercurySplashAd.h
//  MercurySDK
//
//  Created by guangyao on 2024/3/27.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryAdMaterial.h"

NS_ASSUME_NONNULL_BEGIN

@class MercurySplashAd;
@protocol MercurySplashAdDelegate <NSObject>

@optional

/// 开屏广告物料加载成功
/// - Parameters:
///   - splashAd: 开屏广告对象
///   - isFromCache: 物料是否从缓存获取
- (void)mercury_materialDidLoad:(MercurySplashAd * _Nullable)splashAd isFromCache:(BOOL)isFromCache __attribute__((deprecated("接口即将废弃，请使用 mercury_splashAdDidLoad:")));

/// 开屏广告素材加载成功
- (void)mercury_splashAdDidLoad:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告加载失败
- (void)mercury_splashAdFailToLoad:(MercurySplashAd * _Nullable)splashAd error:(NSError * _Nullable)error;
- (void)mercury_splashAdFailError:(NSError * _Nullable)error __attribute__((deprecated("接口即将废弃，请使用 mercury_splashAdFailToLoad:")));

/// 开屏广告视图渲染成功
- (void)mercury_splashAdRenderSuccess:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告视图渲染失败
- (void)mercury_splashAdRenderFail:(MercurySplashAd * _Nullable)splashAd error:(NSError * _Nullable)error;

/// 开屏广告曝光
- (void)mercury_splashAdExposured:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告点击
- (void)mercury_splashAdClicked:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告跳过按钮点击
- (void)mercury_splashAdSkipClicked:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告关闭
- (void)mercury_splashAdClosed:(MercurySplashAd * _Nullable)splashAd;

/// 开屏广告剩余时间
- (void)mercury_splashAdLifeTime:(NSUInteger)time;

@end

@interface MercurySplashAd : NSObject

/// 代理对象
@property (nonatomic, weak) id<MercurySplashAdDelegate> delegate;

/// 拉取广告超时时间，默认为5秒
@property (nonatomic, assign) NSInteger fetchDelay;

/**
 *  开屏广告的背景图片
 *  可设置背景图片作为开屏加载时的默认背景
 */
@property (nonatomic, strong) UIImage *placeholderImage;

/// 开屏广告底部Logo视图
@property (nonatomic, strong) UIView *bottomLogoView;

/// 开发者需传入用来弹出目标页的ViewController，一般为当前ViewController
@property (nonatomic, weak) UIViewController *controller;

/// 实时价格（分）
@property (nonatomic, assign) NSInteger price;

/// 开屏广告底部Logo图片
@property (nonatomic, strong) UIImage *logoImage __attribute__((deprecated("该字段即将废弃，请使用`bottomLogoView`属性")));
@property (nonatomic, assign) NSInteger blankGap __attribute__((deprecated("该字段已废弃，请忽略")));

/// 构造方法
/// @param adspotId 广告Id
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercurySplashAdDelegate> _Nullable)delegate;

/// 构造方法
/// @param adspotId 广告Id
/// @param ext 自定义参数
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary * _Nullable)ext
                          delegate:(id<MercurySplashAdDelegate> _Nullable)delegate;

/// 拉取广告数据
- (void)loadAd;

/// 展示广告
- (void)showAdInWindow:(UIWindow *)window;

/// 获取本次开屏广告的价格
- (NSInteger)getPrice __attribute__((deprecated("该方法即将废弃，请使用`price`属性获取")));

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

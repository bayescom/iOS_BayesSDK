//
//  MercuryUnifiedNativeAdView.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/8.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryPublicEnum.h"
#import "MercuryUnifiedNativeAdDataObject.h"
#import "MercuryAdLogoView.h"
#import "MercuryMediaView.h"
#import "MercuryVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class MercuryUnifiedNativeAdView;

@protocol MercuryUnifiedNativeAdViewDelegate <NSObject>

@optional
/// 广告曝光回调
- (void)mercury_unifiedNativeAdViewWillExpose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView;

/// 广告点击回调
- (void)mercury_unifiedNativeAdViewDidClick:(MercuryUnifiedNativeAdView *)unifiedNativeAdView;

/// 广告关闭回调
- (void)mercury_unifiedNativeAdViewDidClose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView;

/// 广告详情页面即将展示回调
- (void)mercury_unifiedNativeAdDetailViewWillPresentScreen:(MercuryUnifiedNativeAdView *)unifiedNativeAdView;

/// 广告详情页关闭回调
- (void)mercury_unifiedNativeAdDetailViewClosed:(MercuryUnifiedNativeAdView *)unifiedNativeAdView;

@end


@interface MercuryUnifiedNativeAdView : UIView

/// 广告 View 事件回调对象
@property (nonatomic, weak) id<MercuryUnifiedNativeAdViewDelegate> delegate;

/// 绑定的数据对象
@property (nonatomic, strong, readonly) MercuryUnifiedNativeAdDataObject *dataObject;

/// 开发者需传入用来弹出目标页的ViewController，一般为当前ViewController
@property (nonatomic, weak) UIViewController *viewController;

/**
 视频广告的媒体View，自动生成
 
 @warning 开发者无需 addSubview 操作，建议自行指定视图尺寸进行布局
 @warning 若想得到视频准确尺寸，请先调用-[MercuryMediaView fetchMediaSize:]再布局（注意Block循环引用）
 */
@property (nonatomic, strong, readonly) MercuryMediaView *mediaView;

/// 视频广告播放配置
@property (nonatomic, strong, nullable) MercuryVideoConfig *videoConfig;

/**
 倍业广告 LogoView，自动生成
 
 @warning 请先调用-[MercuryUnifiedNativeAdView registerLogoViewWithLogoUrl:logoText:] 再获取logoView
 @warning 开发者无需 addSubview 操作，建议使用autolayout布局，宽度约束自适应，高度约束建议值：15.0f
 */
@property (nonatomic, strong, readonly) MercuryAdLogoView *logoView;

/// 注册倍业广告LogoView
/// @param logoUrl 图标
/// @param logoText 文字
- (void)registerLogoViewWithLogoUrl:(NSString *)logoUrl logoText:(NSString *)logoText;

/**
 自渲染 视图注册方法
 
 @warning 需要注意的是 -[MercuryUnifiedNativeAdView registerDataObject:clickableViews:closeableViews:]方法需要避免重复多次调用的情况
 @warning 当广告不需要展示并且销毁的时候，需要调用 -[MercuryUnifiedNativeAdView unregisterDataObject]方法
 
 @param dataObject 数据对象，必传字段
 @param clickableViews 可点击的视图数组，此数组内的广告元素才可以响应广告对应的点击事件
 @param closeableViews 可关闭的视图数组，此数组内的广告元素才可以响应广告对应的关闭事件
 */
- (void)registerDataObject:(MercuryUnifiedNativeAdDataObject *_Nonnull)dataObject
            clickableViews:(NSArray<UIView *> *_Nonnull)clickableViews
            closeableViews:(NSArray<UIView *> *_Nullable)closeableViews;

/**
 注销数据对象，在 tableView、collectionView 等场景需要复用 MercuryUnifiedNativeAdView 时，
 需要在合适的时机，例如 cell 的 prepareForReuse 方法内执行 unregisterDataObject 方法，
 将广告对象与 MercuryUnifiedNativeAdView 解绑
 */
- (void)unregisterDataObject;

@end

NS_ASSUME_NONNULL_END

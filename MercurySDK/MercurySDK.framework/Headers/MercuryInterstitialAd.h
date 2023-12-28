//
//  MercuryInterstitialAd.h
//  MercurySDK
//
//  Created by guangyao on 2023/12/25.
//  Copyright © 2023 mercury. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryInterstitialAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryInterstitialAd : NSObject

/// 代理对象
@property (nonatomic, weak) id<MercuryInterstitialAdDelegate> delegate;

/// 广告是否有效
@property (nonatomic, assign, readonly) BOOL isAdValid;

/// 实时价格（分）
@property (nonatomic, assign) NSInteger price;

/// 初始方法
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryInterstitialAdDelegate> _Nullable)delegate;


/// 初始方法
/// @param adspotId 广告Id
/// @param delegate 代理对象
/// @param ext 自定义拓展参数
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                         customExt:(NSDictionary *_Nullable)ext
                          delegate:(id<MercuryInterstitialAdDelegate> _Nullable)delegate;

/**
 *  广告发起请求方法
 *  详解：[必选]发起拉取广告请求
 */
- (void)loadAd;

/**
 *  广告展示方法
 *  详解：[必选]发起展示广告请求, 必须传入用于显示插屏广告的UIViewController
 */
- (void)presentAdFromViewController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END

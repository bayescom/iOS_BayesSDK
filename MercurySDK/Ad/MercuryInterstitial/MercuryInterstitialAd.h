//
//  MercuryInterstitialAd.h
//  Example
//
//  Created by CherryKing on 2019/11/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryInterstitialAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryInterstitialAd : NSObject

/// 代理对象
@property (nonatomic, weak) id<MercuryInterstitialAdDelegate> delegate;

/// 插屏广告是否加载完成
@property (nonatomic, assign, readonly) BOOL isAdValid;


/// 初始方法
/// @param adspotId 广告Id
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId;

/// 初始方法
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryInterstitialAdDelegate> _Nullable)delegate;

/**
 *  广告发起请求方法
 *  详解：[必选]发起拉取广告请求
 */
- (void)loadAd;

/**
 *  广告曝光方法
 *  详解：[必选]发起曝光广告请求, 必须传入用于显示插播广告的UIViewController
 */
- (void)presentAdFromViewController:(UIViewController *)fromViewController;

@end

NS_ASSUME_NONNULL_END

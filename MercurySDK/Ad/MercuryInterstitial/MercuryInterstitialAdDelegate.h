//
//  MercuryInterstitialAdDelegate.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/23.
//  Copyright © 2020 mercury. All rights reserved.
//

#ifndef MercuryInterstitialAdDelegate_h
#define MercuryInterstitialAdDelegate_h

@class MercuryInterstitialAd;

@protocol MercuryInterstitialAdDelegate <NSObject>
@optional

/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)mercury_interstitialSuccess;

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)mercury_interstitialFailError:(NSError *)error;

/// 插屏广告将要曝光回调，插屏广告即将曝光回调该函数
- (void)mercury_interstitialWillPresentScreen;

/// 插屏广告视图曝光成功回调，插屏广告曝光成功回调该函数
- (void)mercury_interstitialDidPresentScreen;

/// 插屏广告视图曝光失败回调，插屏广告曝光失败回调该函数
- (void)mercury_interstitialFailToPresent;

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)mercury_interstitialDidDismissScreen;

/// 插屏广告曝光回调
- (void)mercury_interstitialWillExposure;

/// 插屏广告点击回调
- (void)mercury_interstitialClicked;

@end

#endif

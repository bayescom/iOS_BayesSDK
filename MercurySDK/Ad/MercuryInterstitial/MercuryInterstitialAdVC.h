//
//  MercuryInterstitialAdVC.h
//  Example
//
//  Created by CherryKing on 2019/11/15.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryInterstitialAdDelegate.h"

@class MercuryPriInterstitialAd;

NS_ASSUME_NONNULL_BEGIN

@class MercuryInterstitialAd;

@interface MercuryInterstitialAdVC : UIViewController
/// 父视图 详解：[必选]需设置为显示广告的UIViewController
@property (nonatomic, weak) UIViewController *controller;

@property (nonatomic, weak) id<MercuryInterstitialAdDelegate> delegate;

/// 初始化
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                             appId:(NSString * _Nullable)appId
                          mediaKey:(NSString * _Nullable)mediaKey;

- (void)showFromVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END

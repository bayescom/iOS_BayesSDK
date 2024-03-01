//
//  MercuryNativeExpressAdView.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/22.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryNativeExpressAdView : UIView

/**
 *  viewControllerForPresentingModalView
 *  详解：[必选]开发者需传入用来弹出目标页的ViewController，一般为当前ViewController
 */
@property (nonatomic, weak) UIViewController *controller;

/**
 *[必选]
 *原生模板广告渲染
 */
- (void)render;

/// 实时价格（分）
@property (nonatomic, assign, readonly) NSInteger price;

@end

NS_ASSUME_NONNULL_END

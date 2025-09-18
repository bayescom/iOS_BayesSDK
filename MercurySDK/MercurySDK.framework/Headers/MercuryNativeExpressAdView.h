//
//  MercuryNativeExpressAdView.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/22.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryAdProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryNativeExpressAdView : UIView <MercuryAdProtocol>

/**
 *  viewControllerForPresentingModalView
 *  详解：[必选]开发者需传入用来弹出目标页的ViewController，一般为当前ViewController
 */
@property (nonatomic, weak) UIViewController *controller;

/// 广告是否有效，建议在调用render之前判断
@property (nonatomic, assign, readonly) BOOL isAdValid;

/// 实时价格（分）
@property (nonatomic, assign, readonly) NSInteger price;

/**
 *[必选]
 *原生模板广告渲染
 */
- (void)render;

@end

NS_ASSUME_NONNULL_END

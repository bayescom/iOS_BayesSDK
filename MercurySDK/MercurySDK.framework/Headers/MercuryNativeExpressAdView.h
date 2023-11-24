//
//  MercuryNativeExpressAdView.h
//  Example
//
//  Created by CherryKing on 2019/12/13.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryPublicEnum.h"

@class MercuryImp;
@class MercuryNativeExpressAd;

NS_ASSUME_NONNULL_BEGIN

@interface MercuryNativeExpressAdView : UIView
/// 广告model
@property (nonatomic, strong, readonly) MercuryImp *imp;

/// 控制器
@property (nonatomic, weak) UIViewController *controller;

/// 是否渲染完整
@property (nonatomic, assign, readonly) BOOL isReady;

/// 显示模式
@property (nonatomic, assign) MercuryNativeExpressAdSizeMode adSizeMode;

/// 自动播放时，是否静音。默认 NO。
@property (nonatomic, assign) BOOL videoMuted;

/// 实时价格
@property (nonatomic, assign) NSInteger price;

/// 按照 MercuryNativeExpressAd.renderSize 渲染广告
- (void)render;

// 是否停止该信息流view的摇一摇
// 该属性在拉取成功广告数据成功后 设置才有效
// 如果信息流有摇一摇的话, 开发者可手动置为 YES; 此时该视图便不在响应摇一摇
// 例如: 在信息流广告所载的vc上弹出了一个开发者自定义的弹窗, 此时想禁用摇一摇, 可设置为YES ,
// 在适当的时候 可以设置为NO 恢复摇一摇
// 注意: 这只是暂时不让该信息流view响应摇一摇, 内部仍然在监听摇动!!!!!!!!
@property (nonatomic, assign) BOOL isStopMotion;




//- (void)startMotionUpdates;
//
//
//- (void)stopMotionUpdates;

@end

NS_ASSUME_NONNULL_END

//
//  MercurySplashAdVC.h
//  MercurySDK
//
//  Created by CherryKing on 2020/5/21.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercurySplashAdDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercurySplashAdVC : UIViewController
@property (nonatomic, copy) NSString *adspotId;
/// 回调
@property (nonatomic, weak) id<MercurySplashAdDelegate> delegate;

/// 拉取广告超时时间，默认为3秒
/// Desc: 拉取广告超时时间，开发者调用 loadDataWithResultBlock 方法以后会立即曝光backgroundImage，然后在该超时时间内，如果广告拉取成功，则立马曝光开屏广告，否则放弃此次广告曝光机会。
@property (nonatomic, assign) NSInteger fetchDelay;

/// 广告底部组件展示样式类型
@property (nonatomic, assign) MercurySplashAdShowType showType;

/// 广告占位图
@property (nonatomic, strong) UIImage *placeholderImage;
/// Logo广告
@property (nonatomic, strong) UIImage *logoImage;
/// 父视图 详解：[必选]需设置为显示广告的UIViewController
@property (nonatomic, weak) UIViewController *controller;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *skipView;

@end

NS_ASSUME_NONNULL_END

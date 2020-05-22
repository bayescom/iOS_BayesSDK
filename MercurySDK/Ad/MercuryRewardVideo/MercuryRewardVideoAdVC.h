//
//  MercuryRewardVideoAdVC.h
//  Example
//
//  Created by CherryKing on 2019/11/18.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryRewardVideoAdDelegate.h"

@class MercuryPriRewardVideoAd;

NS_ASSUME_NONNULL_BEGIN

@interface MercuryRewardVideoAdVC : UIViewController

@property (nonatomic, weak) id<MercuryRewardVideoAdDelegate> delegate;

/// 父视图 详解：[必选]需设置为显示广告的UIViewController
@property (nonatomic, weak) UIViewController *controller;

- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                             appId:(NSString * _Nullable)appId
                          mediaKey:(NSString * _Nullable)mediaKey
                        completion: (void (^ _Nullable)(void))completion;

- (void)showFromVC:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END

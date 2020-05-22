//
//  MercurySplashAd.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "MercurySplashAd.h"
#import "MercurySplashAdVC.h"
#import "MercuryGCDTimer.h"
#import "MercuryPriHeader.h"
#import "UIWindow+Mercury.h"

@interface MercurySplashAd () 
@property (nonatomic, strong) MercurySplashAdVC *splashVC;

@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, strong) MercuryGCDTimer *timer;
@property (nonatomic, assign) BOOL splashVCShowFlag;

@property (nonatomic, strong) UIImageView *placeholderImageView;

@end

@implementation MercurySplashAd

/// 构造方法
/// @param adspotId 广告Id
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString *)adspotId delegate:(id<MercurySplashAdDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _adspotId = adspotId;
        _fetchDelay = 3;
    }
    return self;
}

- (void)loadAdAndShow {
    [self loadAdAndShowWithBottomView:nil skipView:nil];
}

- (void)loadAdAndShowWithBottomView:(UIView *)bottomView {
    [self loadAdAndShowWithBottomView:bottomView skipView:nil];
}

- (void)loadAdAndShowWithBottomView:(UIView *)bottomView skipView:(UIView *)skipView {
    if (!_controller) {
        NSLog(@"controller is required!!!");
        return;
    }
    if (!_placeholderImageView) {
        while (_controller.navigationController ||
               _controller.tabBarController) {
            if (_controller.navigationController) {
                _controller = _controller.navigationController;
            } else if (_controller.tabBarController) {
                _controller = _controller.tabBarController;
            }
        }
        UIView *targetView = _controller.view;
        _placeholderImageView = [[UIImageView alloc] initWithFrame:targetView.bounds];
        _placeholderImageView.image = _placeholderImage;
        [targetView addSubview:_placeholderImageView];
    }
    @mer_weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @mer_strongify(self);
        [self.placeholderImageView removeFromSuperview];
    });
    if (!_splashVC) {
        _splashVC = [[MercurySplashAdVC alloc] init];
        _splashVC.adspotId = _adspotId;
        _splashVC.delegate = _delegate;
        _splashVC.logoImage = _logoImage;
        _splashVC.placeholderImage = _placeholderImage;
        _splashVC.bottomView = bottomView;
        _splashVC.skipView = skipView;
        _splashVC.showType = _showType;
        _splashVC.controller = _controller;
        _splashVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        @mer_weakify(self);
        _timer = [MercuryGCDTimer timerWithTimeInterval:1/60.0 runBlock:^{
            @mer_strongify(self);
            if (self.controller.isViewLoaded && self.controller.view.window) {
                if (!self.splashVCShowFlag) {
                    [self.controller presentViewController:self.splashVC animated:YES completion:^{
                        [self.placeholderImageView removeFromSuperview];
                    }];
                }
                self.splashVCShowFlag = YES;
                [self.timer stopTimer];
            }
        }];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

//
//  MercurySplashAdVC.m
//  MercurySDK
//
//  Created by CherryKing on 2020/5/21.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercurySplashAdVC.h"

#import "MercurySplashAdView.h"
#import "MercuryPriHeader.h"
#import "UIView+Mercury.h"
#import "MercuryGCDTimer.h"
#import "MercuryDeviceInfoUtil.h"

#import <objc/runtime.h>

@interface MercurySplashAdVC () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAdView *adView;

@property (nonatomic, strong) MercuryGCDTimer *timer;

@end

@implementation MercurySplashAdVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor clearColor];
    UIView *targetV = self.view;
    if (!_adView) {
        _adView = [[MercurySplashAdView alloc] initAdWithAdspotId:_adspotId
                                                       fetchDelay:_fetchDelay];
        _adView.placeholderImage = _placeholderImage;
        _adView.logoImage = _logoImage;
        _adView.showType = _showType;
        _adView.delegate = _delegate;
        [targetV addSubview:_adView];
        _adView.frame = targetV.bounds;
        _adView.showType = _showType;
        _adView.bottomView = _bottomView;
        _adView.skipView = _skipView;
        _adView.controller = _controller;
        @mer_weakify(self);
        [_adView setDismissBlock:^{
            @mer_strongify(self);
            [self dismissViewControllerAnimated:NO completion:nil];
        }];
        [_adView renderWithSize:targetV.bounds.size];

        [targetV bringSubviewToFront:_adView];
    }
}

- (void)setController:(UIViewController *)controller {
    _controller = controller;
    _adView.controller = _controller;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

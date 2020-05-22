//
//  MercuryPreVideoViewController.m
//  Example
//
//  Created by CherryKing on 2019/12/6.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryPreVideoViewController.h"

#import "MercuryPrerollAdView.h"

@interface MercuryPreVideoViewController () <MercuryPrerollAdDelegate>
@property (nonatomic, strong) MercuryPrerollAdView *adView;

@end

@implementation MercuryPreVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"视频贴片(视频)", @"adspotId": @"10002664"},
        @{@"addesc": @"视频贴片(图片)", @"adspotId": @"10002665"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
    self.adShowView.hidden = NO;
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    [_adView removeFromSuperview];
    _adView = [[MercuryPrerollAdView alloc] initWithAdspotId:self.adspotId];
    _adView.delegate = self;
    _adView.showSkipTime = 0;
    _adView.videoMuted = YES;
    _adView.controller = self;
    [_adView loadAd];
}

- (void)loadAdBtn2Action {
    [_adView showAdWithView:self.adShowView];
}

// MARK: ======================= MercuryPrerollAdDelegate =======================
/// 贴片广告模型加载成功
- (void)mercury_prerollAdDidReceived {
    NSLog(@"贴片广告模型加载成功");
    [JDStatusBarNotification showWithStatus:@"贴片广告模型加载成功" dismissAfter:1.5];
}

// 贴片广告模型加载失败
- (void)mercury_prerollAdFailToReceived:(NSError *)error {
    NSLog(@"贴片广告模型加载失败 - %@", error);
    [JDStatusBarNotification showWithStatus:@"贴片广告模型加载失败" dismissAfter:1.5];
}

/// 贴片广告成功渲染
/// @param prerollAd 广告数据
- (void)mercury_prerollAdSuccessPresentScreen:(MercuryPrerollAdView *)prerollAd {
    NSLog(@"贴片广告成功渲染 - %@", prerollAd);
}

/// 贴片广告曝光失败
/// @param error 异常返回
- (void)mercury_prerollAdFailError:(nullable NSError *)error {
    NSLog(@"贴片广告曝光失败 - %@", error);
}

/// 贴片广告曝光回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdExposured:(MercuryPrerollAdView *)prerollAd {
    NSLog(@"贴片广告曝光回调 - %@", prerollAd);
}

/// 贴片广告点击回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdClicked:(MercuryPrerollAdView *)prerollAd {
    NSLog(@"贴片广告点击回调 - %@", prerollAd);
}

/// 贴片广告将要关闭回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdWillClosed:(MercuryPrerollAdView *)prerollAd {
    NSLog(@"贴片广告将要关闭回调 - %@", prerollAd);
}

/// 贴片广告关闭回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdClosed:(MercuryPrerollAdView *)prerollAd {
    NSLog(@"贴片广告关闭回调 - %@", prerollAd);
}

/// 贴片广告剩余时间回调
- (void)mercury_prerollAdLifeTime:(NSUInteger)time {
//    NSLog(@"贴片广告剩余时间回调 - %lu", time);
}

/// 播放状态变更回调
- (void)mercury_prerollAdView:(MercuryPrerollAdView *)nativeAdView playerStatusChanged:(MercuryMediaPlayerStatus)status {
    NSLog(@"%lu | 播放状态变更回调 - %@", status, nativeAdView);
}

@end

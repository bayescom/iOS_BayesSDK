//
//  MercuryRewardVideoViewController.m
//  Example
//
//  Created by CherryKing on 2019/12/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryRewardVideoViewController.h"

#import <MercurySDK/MercurySDK.h>

@interface MercuryRewardVideoViewController () <MercuryRewardVideoAdDelegate>
// 竖屏
@property (nonatomic, strong) MercuryRewardVideoAd *rewardVideoAd;

@end

@implementation MercuryRewardVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"竖屏激励视频", @"adspotId": @"10002595"},
        @{@"addesc": @"竖屏激励视频", @"adspotId": @"10002596"},
        
//        @{@"addesc": @"竖屏激励视频", @"adspotId": @"40000001"},
//        @{@"addesc": @"横屏激励视频", @"adspotId": @"40000002"},
    ];
    self.btn1Title = @"加载并显示广告";
//    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.rewardVideoAd = [[MercuryRewardVideoAd alloc] initAdWithAdspotId:self.adspotId delegate:self];
    [self.rewardVideoAd loadRewardVideoAd];
}

- (void)loadAdBtn2Action {
    [self.rewardVideoAd showAdFromVC:self];
}

//// 仅为方便调试提供的逻辑，应用接入流程中不需要程序设置方向
//if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
//    self.supportOrientation = UIInterfaceOrientationLandscapeRight;
//} else {
//    self.supportOrientation = UIInterfaceOrientationPortrait;
//}
//[[UIDevice currentDevice] setValue:@(self.supportOrientation) forKey:@"orientation"];

// MARK: ======================= MercuryRewardedVideoAdDelegate =======================
- (void)mercury_rewardVideoAdDidLoad {
    NSLog(@"广告数据加载成功回调");
    [JDStatusBarNotification showWithStatus:@"广告数据加载成功" dismissAfter:1.5];
}

- (void)mercury_rewardAdFailError:(nullable NSError *)error {
    NSLog(@"广告加载失败回调 %@", error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
}

// TODO: 缓存
- (void)mercury_rewardVideoAdVideoDidLoad {
    [JDStatusBarNotification showWithStatus:@"视频数据下载成功" dismissAfter:1.5];
    NSLog(@"视频数据下载成功回调，已经下载过的视频会直接回调");
    [self.rewardVideoAd showAdFromVC:self];
}

- (void)mercury_rewardVideoAdWillVisible {
    NSLog(@"视频播放页即将曝光回调");
}

- (void)mercury_rewardVideoAdDidExposed {
    NSLog(@"视频广告曝光回调");
}

- (void)mercury_rewardVideoAdDidClose {
    NSLog(@"视频播放页关闭回调");
}

- (void)mercury_rewardVideoAdDidClicked {
    NSLog(@"视频广告信息点击回调");
}

- (void)mercury_didFailWithError:(NSError *)error {
    NSLog(@"视频广告信息点击回调");
}

- (void)mercury_rewardVideoAdDidRewardEffective {
    NSLog(@"视频广告播放达到激励条件回调");
}

- (void)mercury_rewardVideoAdDidPlayFinish {
    NSLog(@"视频广告视频播放完成");
}

@end

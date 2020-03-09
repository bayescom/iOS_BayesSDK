//
//  MercuryInterstitialAdViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/15.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryInterstitialAdViewController.h"

#import <MercurySDK/MercurySDK.h>

@interface MercuryInterstitialAdViewController () <MercuryInterstitialAdDelegate>
@property (nonatomic, strong) MercuryInterstitialAd *ad;

@end

@implementation MercuryInterstitialAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"插屏图片", @"adspotId": @"10000559"},
//        @{@"addesc": @"插屏图片", @"adspotId": @"10000558"},
//        @{@"addesc": @"插屏", @"adspotId": @"30000001"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    _ad = [[MercuryInterstitialAd alloc] initAdWithAdspotId:self.adspotId delegate:self];

    [_ad loadAd];
}

- (void)loadAdBtn2Action {
    [_ad presentAdFromViewController:self];
}

// MARK: ======================= MercuryInterstitialAdDelegate =======================
- (void)mercury_interstitialSuccess {
    NSLog(@"插屏广告预加载成功回调");
    [JDStatusBarNotification showWithStatus:@"插屏广告预加载成功" dismissAfter:1.5];
}

- (void)mercury_interstitialFailError:(NSError *)error {
    NSLog(@"广告预加载失败回调 %@", error);
    [JDStatusBarNotification showWithStatus:@"广告预加载失败" dismissAfter:1.5];
}

- (void)mercury_interstitialWillPresentScreen {
    NSLog(@"广告将要曝光回调");
}

- (void)mercury_interstitialDidPresentScreen {
    NSLog(@"广告视图曝光成功回调");
}

- (void)mercury_interstitialFailToPresent {
    NSLog(@"广告视图曝光失败回调");
    [JDStatusBarNotification showWithStatus:@"广告视图曝光失败" dismissAfter:1.5];
}

- (void)mercury_interstitialDidDismissScreen {
    NSLog(@"广告曝光结束回调 %@", [NSThread currentThread]);
}

- (void)mercury_interstitialWillExposure {
    NSLog(@"插屏广告曝光回调");
}

- (void)mercury_interstitialClicked {
    NSLog(@"广告点击回调");
}

- (void)mercury_interstitialAdWillPresentFullScreenModal {
    NSLog(@"1. 点击插屏广告即将弹出全屏广告页");
}

- (void)mercury_interstitialAdDidPresentFullScreenModal {
    NSLog(@"2. 点击插屏广告以后弹出全屏广告页");
}

- (void)mercury_interstitialAdWillDismissFullScreenModal {
    NSLog(@"3. 全屏广告页将要关闭");
}

- (void)mercury_interstitialAdDidDismissFullScreenModal {
    NSLog(@"4. 全屏广告页被关闭");
}

@end

//
//  MercurySplashAdViewController.m
//  AAA
//
//  Created by CherryKing on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercurySplashAdViewController.h"

#import <MercurySDK/MercurySDK.h>

@interface MercurySplashAdViewController () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAd *ad;

@end

@implementation MercurySplashAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"开屏(长图)", @"adspotId": @"10002619"},
        @{@"addesc": @"开屏(短图)", @"adspotId": @"10000556"},
        @{@"addesc": @"开屏(Gif)", @"adspotId": @"10002435"},
        @{@"addesc": @"开屏(视频)", @"adspotId": @"10002436"},
        @{@"addesc": @"开屏(schemaLink)", @"adspotId": @"10002620"},
        @{@"addesc": @"开屏(universalLink)", @"adspotId": @"10002621"},
        
//        @{@"addesc": @"开屏无广告返回", @"adspotId": @"10000101"},
//        @{@"addesc": @"开屏数据解析失败", @"adspotId": @"10000102"},
//        @{@"addesc": @"开屏adtype匹配错误", @"adspotId": @"10000103"},
//        @{@"addesc": @"开屏creative_type匹配错误", @"adspotId": @"10000104"},
//        @{@"addesc": @"开屏网络超时", @"adspotId": @"10000105"},
//        @{@"addesc": @"开屏素材加载失败", @"adspotId": @"10000106"},
//        @{@"addesc": @"开屏长图", @"adspotId": @"10000001"},
//        @{@"addesc": @"开屏短图", @"adspotId": @"10000002"},
//        @{@"addesc": @"开屏Gif", @"adspotId": @"10000003"},
//        @{@"addesc": @"开屏视频", @"adspotId": @"10000004"},
    ];
    self.btn1Title = @"加载并显示广告";
}

// MARK: ======================= load ad =======================
- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    _ad = [[MercurySplashAd alloc] initAdWithAdspotId:self.adspotId delegate:self];
    _ad.controller = self;
    _ad.showType = MercurySplashAdShowCutBottom;
    // 自定义Logo，占位图
    _ad.placeholderImage = [UIImage imageNamed:@"LaunchImage_img"];
    _ad.logoImage = [UIImage imageNamed:@"app_logo"];
    [_ad loadAdAndShow];
}

// MARK: ======================= MercurySplashAdDelegate =======================
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告模型加载成功 %s", __func__);
}

- (void)mercury_splashAdSuccessPresentScreen:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告成功曝光 %s", __func__);
}

- (void)mercury_splashAdFailError:(NSError *)error {
    NSLog(@"开屏广告曝光失败 %s %@", __func__, error);
}

- (void)mercury_splashAdLifeTime:(NSUInteger)time {
    NSLog(@"开屏广告剩余时间回调 %s _ %ld", __func__, time);
}

- (void)mercury_splashAdApplicationWillEnterBackground:(MercurySplashAd *)splashAd {
    NSLog(@"应用进入后台时回调 %s", __func__);
}

- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告曝光回调 %s", __func__);
}

- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告点击回调 %s", __func__);
}

- (void)mercury_splashAdWillClosed:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告将要关闭回调 %s", __func__);
}

- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告关闭回调 %s", __func__);
}

@end

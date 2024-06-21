//
//  MercurySplashAdViewController.m
//  AAA
//
//  Created by CherryKing on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercurySplashAdViewController.h"

#import <MercurySDK/MercurySDK.h>
#import <objc/runtime.h>
#import <objc/message.h>

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
        @{@"addesc": @"开屏(universalLink)", @"adspotId": @"10000556"},

        @{@"addesc": @"富媒体开屏-Gallery", @"adspotId": @"10003412"},
        @{@"addesc": @"富媒体开屏-sliding", @"adspotId": @"10003411"},
        @{@"addesc": @"富媒体开屏-Cube", @"adspotId": @"10003409"},
        @{@"addesc": @"富媒体开屏-Swipe", @"adspotId": @"10003408"},
        @{@"addesc": @"开屏视频", @"adspotId": @"10006703"},
    ];
    NSLog(@"版本号: %@", [MercuryConfigManager sdkVersion]);
    self.btn1Title = @"加载并显示广告";
}



// MARK: ======================= load ad =======================
- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    _ad = [[MercurySplashAd alloc] initAdWithAdspotId:self.adspotId delegate:self];
    _ad.controller = self;
    // 自定义Logo，占位图
    _ad.placeholderImage = [UIImage imageNamed:@"LaunchImage_img"];
    _ad.logoImage = [UIImage imageNamed:@"app_logo"];
    [_ad loadAd];
}

// 广告素材宽高不确定 所以底部的留白高度不确定
- (UIView *)getTestBottomView {
    UIView *test = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 120, self.view.frame.size.width, 120)];
    test.backgroundColor = [UIColor redColor];
    return test;
}

- (void)showAd {
    [self.ad showAdInWindow:self.view.window];
}

// MARK: ======================= MercurySplashAdDelegate =======================
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告模型加载成功 %s %ld", __func__, (long)splashAd.price);
    [self showAd];
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
//    [NSClassFromString(@"MercuryMotionManager") performSelector:@selector(setupSDKWithAppID:andAppKey:) withObject:supplier.mediaid withObject:supplier.mediakey];

//    id manager = ((id(*)(id, SEL))objc_msgSend)(NSClassFromString(@"MercuryMotionManager"), @selector(sharedManager));
}

@end

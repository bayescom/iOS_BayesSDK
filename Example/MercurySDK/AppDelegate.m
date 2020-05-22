//
//  AppDelegate.m
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MercurySplashAd.h"
#import "MercuryConfigManager.h"


@interface AppDelegate () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAd *ad;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MercuryConfigManager setAppID:@"100255"
                          mediaKey:@"757d5119466abe3d771a211cc1278df7"];
    
    [MercuryConfigManager openDebug:YES];
    
    [self splashShow];
    
    return YES;
}

- (void)splashShow {   // 开屏
    _ad = [[MercurySplashAd alloc] initAdWithAdspotId:@"10002619" delegate:nil];
    _ad.controller = self.window.rootViewController;
    _ad.delegate = self;
    _ad.placeholderImage = [UIImage imageNamed:@"LaunchImage_img"];
    _ad.logoImage = [UIImage imageNamed:@"app_logo"];
    _ad.showType = MercurySplashAdShowCutBottom;
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
    splashAd = nil;
}

- (void)mercury_splashAdWillClosed:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告将要关闭回调 %s", __func__);
}

- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告关闭回调 %s", __func__);
}

- (void)mercury_splashAdSkipClicked:(MercurySplashAd *)splashAd {
    NSLog(@"开屏广告点击跳过回调 %s", __func__);
}

@end

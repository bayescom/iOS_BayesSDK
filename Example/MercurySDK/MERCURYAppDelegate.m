//
//  MERCURYAppDelegate.m
//  MercurySDK
//
//  Created by Cheng455153666 on 02/17/2020.
//  Copyright (c) 2020 Cheng455153666. All rights reserved.
//

#import "MERCURYAppDelegate.h"

#import "MERCURYViewController.h"

#import <MercurySDK/MercurySDK.h>
#define kPublicKey  @"用文本编辑打开pub_for_sdk.cer即可获取"

#define kPublicForApiKey @"用文本编辑打开public_for_api.pem即可获取"

#define kDevId @""


@interface MERCURYAppDelegate () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAd *ad;
@end

@implementation MERCURYAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[MERCURYViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
//    self.nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc]init];
        appearance.backgroundEffect = nil;
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.shadowColor = [UIColor whiteColor];
        [UINavigationBar appearance].scrollEdgeAppearance = appearance;
        [UINavigationBar appearance].standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
        nav.navigationBar.standardAppearance = appearance;

    } else {
        // Fallback on earlier versions
    }

    NSLog(@"version: %@", [MercuryConfigManager sdkVersion]);
    [self splashShow];
    
    return YES;
}

- (void)splashShow {   // 开屏
    // 设置AppId MediaKey
//    [MercuryConfigManager setAppID:@"100255"
//                     appKey:@"757d5119466abe3d771a211cc1278df7"];
    
    [MercuryConfigManager setAppID:@"101859"
                          appKey:@"9fd708c28a14006344301ef5cac76adb"
                            config:@{}];

    
    // 开启日志
    [MercuryConfigManager openDebug:YES];
    // 支持预缓存资源
    [MercuryConfigManager preloadedResourcesIfNeed:YES];
    NSLog(@"%@", [MercuryConfigManager sdkVersion]);
    _ad = [[MercurySplashAd alloc] initAdWithAdspotId:@"10002436" delegate:nil];
    _ad.controller = self.window.rootViewController;
    _ad.delegate = self;
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

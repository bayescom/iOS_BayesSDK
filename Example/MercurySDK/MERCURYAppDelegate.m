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
    
    [self initMercury];
    
    [MercuryConfigManager setAAIDWithMediaId:@"" mediaSecret:@""];
    
//    [MercuryConfigManager forbiddenIDFA:YES];
    
    return YES;
}

- (void)initMercury {   // 开屏
    // 设置AppId MediaKey
    [MercuryConfigManager setAppID:@"100255"
                     appKey:@"757d5119466abe3d771a211cc1278df7"];
    
    // 开启日志
    [MercuryConfigManager supportHttps:YES];
    [MercuryConfigManager openDebug:YES];
    [MercuryConfigManager preloadedResourcesIfNeed:YES];
}

@end

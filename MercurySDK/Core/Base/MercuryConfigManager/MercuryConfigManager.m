//
//  MercuryConfigManager.m
//  BayesSDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryConfigManager.h"

#import "MercuryPriHeader.h"
#import "MercuryLog.h"
#import "MercuryReachabilityManager.h"
#import <WebKit/WebKit.h>
#import "MercuryApiUtils.h"
#import "MercuryDeviceInfoUtil.h"

@interface MercuryConfigManager ()

@end

@implementation MercuryConfigManager

// MARK: 单例
static MercuryConfigManager *_instance = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [MercuryConfigManager sharedInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [MercuryConfigManager sharedInstance];
}

// Publish Method
+ (void)setAppID:(NSString *)appID mediaKey:(NSString *)mediaKey {
    /// 申请的应用ID
    MercuryDeviceInfoUtil.sharedInstance.appId = appID;
    MercuryDeviceInfoUtil.sharedInstance.mediaKey = mediaKey;
    // 网络状况监测
    [MercuryReachabilityManager.sharedManager startMonitoring];
    // 预处理user-agent
    [MercuryConfigManager storeUserAgentCompletion:nil];
}

+ (void)openDebug:(BOOL)isDebug {
    [MercuryLog setLogEnable:isDebug];
}

+ (NSString *)sdkVersion {
    return Mercury_SDK_VERSION;
}

// 预缓存素材资源
+ (void)preloadedResourcesIfNeed:(BOOL)isNeed {
    if (isNeed) {   // 延迟8s请求
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[MercuryApiUtils sharedInstance] preloadedResourcesIfNeed];
        });
    }
}

// MARK: ======================= private =======================
+ (void)storeUserAgentCompletion:(void (^ __nullable)(NSString *user_agent))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *store_ua = [[NSUserDefaults standardUserDefaults] objectForKey:@"_bayes_user_agent_key"];
        if (store_ua) { // 判断本地是否存了ua
            if (completion) { completion(store_ua); }
        }
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
//            [self setContentModeForWebViewConfiguration:configuration];
            WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            [window addSubview:wkWebView];
            [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
                if (!store_ua) { // 如果本地不存在ua 走动态获取
                    if (result == nil) {
                        NSLog(@"获取UA失败");
                    } else {
                        if (completion) { completion(result); }
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"_bayes_user_agent_key"];
                [wkWebView removeFromSuperview];
            }];
        }
    });
}

@end

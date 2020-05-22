//
//  UIWindow+Mercury.m
//  MercurySDK
//
//  Created by CherryKing on 2020/1/9.
//  Copyright © 2020 MercuryCOM. All rights reserved.
//

#import "UIWindow+Mercury.h"
#import "NSObject+Mercury.h"

@implementation UIApplication (Mercury)

// 注：有大佬说要注意Window要判断不是CPWindow，暂未遇到。保留注意事项

- (UIWindow *)mercury_getCurrentWindow {
    UIWindow *window = nil;
    // 先判断系统
    if (@available(iOS 13, *)) {
        // 判断设备
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
            // iPhone设备直接取windows第一个元素
            for (UIWindow *a_w in [UIApplication sharedApplication].windows) {
                if (a_w.isKeyWindow) {
                    window = a_w;
                }
            }
            
//            // 没有keywindow 直接取第一个
            if (!window) { window = [UIApplication sharedApplication].windows.firstObject; }
            if (!window) {   // 如果window还是不存在
                // 检测是否未支持iOS 13新特性，未采用兼容方案，看AppDelegate中是否有window
                if (!([[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:configurationForConnectingSceneSession:options:)] ||
                    [[UIApplication sharedApplication].delegate respondsToSelector:@selector(application:didDiscardSceneSessions:)])) {
                    NSDictionary *pDic = [((id)[UIApplication sharedApplication].delegate) mercury_getAllProperties];
                    for (id obj in pDic.allValues) {
                        // 找到window值，进行赋值
                        if ([obj isKindOfClass:[UIWindow class]]) {
                            NSString *windowPropName = pDic.allKeys[[pDic.allValues indexOfObject:obj]];
                            if (!windowPropName) { continue; }
                            SEL windowMethod = NSSelectorFromString(windowPropName);
                            if ([[UIApplication sharedApplication].delegate respondsToSelector:windowMethod]) {
                                window = [[UIApplication sharedApplication].delegate performSelector:windowMethod];
                                if (window.isHidden) {
                                    continue;
                                }
                            }
                            break;
                        }
                    }
                }
            }
        } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // ipad设备获取keywindow
            for (UIWindow *a_w in [UIApplication sharedApplication].windows) {
                if (a_w.isKeyWindow) {
                    window = a_w;
                }
            }
            if (!window) {  // 如果也没取到keyWindow，拿第一个Window
                window = [UIApplication sharedApplication].windows.firstObject;
            }
        }
    } else {
        window = UIApplication.sharedApplication.keyWindow;
    }
    return window;
}

@end

@implementation UIWindow (Mercury)

///获取Window中活动的控制器
- (UIViewController *)mercury_getCurrentActivityViewController {
//    UIWindow *window = [UIApplication sharedApplication].delegate.window;
//    NSLog(@"window level: %.0f", window.windowLevel);
//    if (window.windowLevel != UIWindowLevelNormal) {
//        NSArray *windows = [[UIApplication sharedApplication] windows];
//        for (UIWindow * tmpWin in windows) {
//            if (tmpWin.windowLevel == UIWindowLevelNormal) {
//                window = tmpWin;
//                break;
//            }
//        }
//    }
    
    //从根控制器开始查找
    UIViewController *rootVC = self.rootViewController;
    UIViewController *activityVC = nil;
    
    while (true) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            activityVC = [(UINavigationController *)rootVC visibleViewController];
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            activityVC = [(UITabBarController *)rootVC selectedViewController];
        } else if (rootVC.presentedViewController) {
            activityVC = rootVC.presentedViewController;
        } else {
            break;
        }
        
        rootVC = activityVC;
    }
    
    return activityVC;
}

@end

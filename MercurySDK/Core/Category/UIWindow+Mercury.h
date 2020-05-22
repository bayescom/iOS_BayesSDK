//
//  UIWindow+Mercury.h
//  MercurySDK
//
//  Created by CherryKing on 2020/1/9.
//  Copyright © 2020 MercuryCOM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (Mercury)
// 获取当前的Window
- (UIWindow *)mercury_getCurrentWindow;

@end

@interface UIWindow (Mercury)

///获取当前活动的控制器
- (UIViewController *)mercury_getCurrentActivityViewController;

@end

NS_ASSUME_NONNULL_END

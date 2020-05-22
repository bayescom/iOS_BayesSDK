//
//  MercuryPriHeader.h
//  MercurySDKExample
//
//  Created by CherryKing on 2020/4/22.
//  Copyright © 2020 mercury. All rights reserved.
//

#ifndef MercuryPriHeader_h
#define MercuryPriHeader_h

/// SDK 版本 【此SDKVersion用于接口请求】
static NSString * const Mercury_API_VERSION = @"3.0";
static NSString * const Mercury_SDK_VERSION = @"3.1.3";

static NSTimeInterval const kMercury_FetchDelay = 3;

#import <UIKit/UIKit.h>
/// 是否是刘海屏
static inline BOOL mercury_IsIPhoneXSeries() {
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow;
        if (@available(iOS 13, *)) {
            mainWindow = UIApplication.sharedApplication.windows.firstObject;
        } else {
            mainWindow = UIApplication.sharedApplication.keyWindow;
        }
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            return YES;
        }
    }
    return NO;
}

#define kMercury_ScreenHeight [UIScreen mainScreen].bounds.size.height
#define kMercury_TopHeight (mercury_IsIPhoneXSeries()?88:64)
#define kMercury_StatusBarHeight (mercury_IsIPhoneXSeries()?34:20)
#define kMercury_SafeTopH (mercury_IsIPhoneXSeries()?34:0)
#define kMercury_SafeBottomH (mercury_IsIPhoneXSeries()?34:0)
//#define kMercuryImageNamed(named) [UIImage imageNamed:named]
#import "MercuryBase64ImageManager.h"
#define kMercuryImageNamed(imageNamed) [MercuryBase64ImageManager base64ImageWithNamed:imageNamed]

#define kIsMockFlag 0

/// 请求地址
#if kIsMockFlag
static NSString * const Mercury_POST_URL = @"https://mock.yonyoucloud.com/mock/2650/api/v3/";
#else
static NSString * Mercury_POST_URL = @"http://raddus.bayescom.com/";
#endif

#define MercuryToPixels(a_by_value) (a_by_value * [UIScreen mainScreen].nativeScale)
/// 将Point转换为像素 (坐标系 * nativeScale)
#define MercuryToPixelsFromPoint(a_by_point) CGPointMake(MercuryToPixels(a_by_point.x), MercuryToPixels(a_by_point.y))

/// 在主线程处理Block
#define mer_dispatch_main_safe_sync(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define mer_dispatch_main_safe_async(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

/// Block 循环引用
#ifndef mer_weakify
#if DEBUG
#if __has_feature(objc_arc)
#define mer_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define mer_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define mer_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define mer_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef mer_strongify
#if DEBUG
#if __has_feature(objc_arc)
#define mer_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define mer_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define mer_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define mer_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

#endif

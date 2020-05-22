//
//  MercuryPlayer.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <Foundation/Foundation.h>

//! Project version number for MercuryPlayer.
FOUNDATION_EXPORT double MercuryPlayerVersionNumber;

//! Project version string for MercuryPlayer.
FOUNDATION_EXPORT const unsigned char MercuryPlayerVersionString[];

/**
 Synthsize a weak or strong reference.
 
 Example:
 @weakify(self)
 [self doSomething^{
 @strongify(self)
 if (!self) return;
 ...
 }];
 
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

// Screen width
#define MercuryPlayerScreenWidth     [[UIScreen mainScreen] bounds].size.width
// Screen height
#define MercuryPlayerScreenHeight    [[UIScreen mainScreen] bounds].size.height

#import "MercuryPlayerController.h"
#import "MercuryPlayerGestureControl.h"
#import "MercuryPlayerMediaPlayback.h"
#import "MercuryPlayerMediaControl.h"
#import "MercuryOrientationObserver.h"
#import "MercuryKVOController.h"
#import "UIScrollView+MercuryPlayer.h"
#import "MercuryPlayerLogManager.h"

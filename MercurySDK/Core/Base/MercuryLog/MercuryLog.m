//
//  MercuryLog.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryLog.h"
//#import "MercuryPriHeader.h"

#define kMercuryDebugDetails 1

// 默认值为NO
static BOOL kLogEnable = NO;
//// 日志输出View
//static UITextView *_logView = nil;

@implementation MercuryLog

+ (void)setLogEnable:(BOOL)enable {
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    return kLogEnable;
}

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    if ([self getLogEnable]) {// 开启了Log
        if (kMercuryDebugDetails) {  // SDK内部调试
//            if (!_logView) {
//                _logView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height*0.3)];
//                _logView.layer.shadowOffset = CGSizeMake(-3, -3);
//                _logView.layer.backgroundColor = [UIColor lightGrayColor].CGColor;
//                _logView.editable = NO;
//                [[UIApplication sharedApplication].keyWindow addSubview:_logView];
//                // 添加手势
//                UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doMoveAction:)];
//                [_logView addGestureRecognizer:panGestureRecognizer];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *logMsg = [NSString stringWithFormat:@"%s[%d] >>> %@", function, lineNumber, formatString];
//                _logView.text = [NSString stringWithFormat:@"%@\n%@", _logView.text, logMsg];
//            });
            NSLog(@"========================== [Mercury Log] ==============================\n%s[%d]\n[DEBUG] %@\n", function, lineNumber, formatString);
            
        } else {
//            [_logView removeFromSuperview];
//            _logView = nil;
            NSLog(@"%@", formatString);
        }
    }
}
//
//+ (void)doMoveAction:(UIPanGestureRecognizer *)recognizer {
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//
//    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint location = [recognizer locationInView:[UIApplication sharedApplication].keyWindow];
//
//        if (location.y < 0 || location.y > [UIApplication sharedApplication].keyWindow.bounds.size.height) {
//            return;
//        }
//        CGPoint translation = [recognizer translationInView:[UIApplication sharedApplication].keyWindow];
//
//
//        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y + translation.y);
//        [recognizer setTranslation:CGPointZero inView:[UIApplication sharedApplication].keyWindow];
//
//    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
//
//    }
//}

@end

//
//  UIView+Mercury.m
//  Example
//
//  Created by CherryKing on 2019/11/25.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "UIView+Mercury.h"
#import "UIWindow+Mercury.h"
#import "MercuryPriHeader.h"

@implementation UIView (Mercury)

- (CGRect)mercury_displayFromWindow {
    UIWindow *window = [UIApplication sharedApplication].mercury_getCurrentWindow;
    // window隐藏了 也算无交集
    if (window.hidden) { return CGRectZero; }
    if (![self mercury_checkIfViewInScreen]) {
        return CGRectZero;
    }
    
    CGRect rect =  [self convertRect:self.bounds toView:window];
    rect = CGRectIntersection(rect, window.frame);
    
    if (isinf(rect.origin.x)) {
        rect.origin.x = 0;
    }
    if (isinf(rect.origin.y)) {
        rect.origin.y = 0;
    }
    if (isnan(rect.size.width) ||
        isnan(rect.size.height)) {
        return CGRectZero;
    }

    return rect;
}

- (BOOL)mercury_checkIfViewInScreen {
    if (![self isKindOfClass:[UIView class]]) {
        return NO;
    }
    // 是否隐藏
    UIView *currentNode = self;
    while (currentNode.superview != nil) {
        if (currentNode.hidden) {
            return NO;
        }
        currentNode = currentNode.superview;
    }
    // 没有superView
    currentNode = self;
    while (currentNode.superview != nil) {
        currentNode = currentNode.superview;
    }
    if (![currentNode isKindOfClass:([UIWindow class])]) {
        return NO;
    }
    
    return YES;
}

- (UIViewController*)mercury_belongViewController {
    for(UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


/// 判断View是否显示在屏幕上
- (BOOL)mercury_isDisplayedInScreen {
    if (self == nil) {
        return FALSE;
    }
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    // 转换view对应window的Rect
    CGRect rect = [self mercury_displayFromWindow];
    
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return FALSE;
    }
    
    // 若view 隐藏
    if (self.hidden) {
        return FALSE;
    }
    
    // 若alpha < 0.1
    if (self.alpha < 0.1) {
        return FALSE;
    }
    
    // 若没有superview
    if (self.superview == nil) {
        return FALSE;
    }
    
    // 若size为CGrectZero
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return  FALSE;
    }
    
    // 获取 该view与window 交叉的 Rect
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) ||
        CGRectIsNull(intersectionRect)) {
        return FALSE;
    }
    
    return TRUE;
}

- (CGRect)mercury_displayRect:(CGRect)rect targetV:(UIView *)targetV {
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) { return CGRectZero; }
    UIView *v1 = self.superview;    // 父视图
    UIView *v2 = v1.superview;      // 爷爷视图
    if (!v1) {
        return CGRectZero;
    }
    if (!targetV) {
        targetV = [UIApplication sharedApplication].mercury_getCurrentWindow;
    }
    if (v1 == targetV) {
        return rect;
//        return CGRectIntersection(rect, v1.frame);
    }
    if ([v2 isKindOfClass:[UIScrollView class]]) {
        UIScrollView *_v2 = (UIScrollView *)v2;
        CGRect _r = CGRectIntersection([v1 convertRect:rect toView:_v2],
                                       CGRectMake(_v2.contentOffset.x,
                                                  _v2.contentOffset.y,
                                                  _v2.bounds.size.width, _v2.bounds.size.height));
        return [v1 mercury_displayRect:_r targetV:targetV];
    } else if ([v2 isKindOfClass:[UIView class]]) {
        CGRect _r = CGRectIntersection([v1 convertRect:rect toView:v2],
                                       CGRectMake(v2.frame.origin.x, v2.frame.origin.y, v2.bounds.size.width, v2.bounds.size.height));
        return [v1 mercury_displayRect:_r targetV:targetV];
    }
//    CGRectIntersection
    return CGRectZero;
}

- (BOOL)mercury_isDisplayedInSuperViewOffset:(CGFloat)offset {
    return [self mercury_isDisplayedInScreenTargetView:self.superview offset:0.5];
}

- (BOOL)mercury_isDisplayedInScreenTargetView:(UIView *)targetView offset:(CGFloat)offset {
    if (!targetView) { return FALSE; }
    if (![self mercury_isDisplayedInScreen]) { return FALSE; }
    // 不正常显示 不做位置检测
    if (self.bounds.size.height <= 0 || self.bounds.size.width <= 0) { return FALSE; }
    
    // 找到距离scv最近的View
    UIView *static_v = self;
    UIScrollView *scv_v = (UIScrollView *)self.superview;
    while (static_v && scv_v &&
           ![scv_v isKindOfClass:[UIScrollView class]]) {
        static_v = scv_v;
        scv_v = (UIScrollView *)static_v.superview;
    }
    
    // 处理低版本层级变化问题
    BOOL isRealScvFlag = FALSE;
    if ([scv_v isMemberOfClass:[UITableView class]]) {
        isRealScvFlag = TRUE;
    } else if ([scv_v isMemberOfClass:[UICollectionView class]]) {
        isRealScvFlag = TRUE;
    } else if ([scv_v isMemberOfClass:[UIScrollView class]]) {
        isRealScvFlag = TRUE;
    }
    if (!isRealScvFlag) {
        scv_v = (UIScrollView *)scv_v.superview;
    }
    
    CGRect r, r1;
    if (scv_v) {
        r = [static_v mercury_displayRect:static_v.frame targetV:scv_v];
        r1 = CGRectIntersection(CGRectMake(scv_v.contentOffset.x, scv_v.contentOffset.y, scv_v.bounds.size.width, scv_v.bounds.size.height), r);
    } else {
        r1 = [self mercury_displayFromWindow];
    }

    if (!CGSizeEqualToSize(CGSizeZero, r1.size)) {
        if (r1.size.height*r1.size.width >
            self.bounds.size.height*self.bounds.size.width*0.5) {    // 暴露面积 > offset%  | 激活状态
            return TRUE;
        } else if (r1.size.width > 0 &&
                   r1.size.height > 0) {    // 暴露面积 > offset% > 0  | ?
            return FALSE;
        } else {
            return FALSE;
        }
    } else {
        return FALSE;
    }
    return FALSE;
}

- (void)mercury_removeAllAutoLayout {
    [self removeConstraints:self.constraints];
    for (NSLayoutConstraint *constraint in self.superview.constraints) {
        if ([constraint.firstItem isEqual:self]) {
            [self.superview removeConstraint:constraint];
        }
    }
}

- (void)mercury_removeAutoLayout:(NSLayoutConstraint *)constraint {
    for (NSLayoutConstraint *constraint in self.superview.constraints) {
        if ([constraint isEqual:constraint]) {
            [self.superview removeConstraint:constraint];
        }
    }
}

@end

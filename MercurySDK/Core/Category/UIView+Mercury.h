//
//  UIView+Mercury.h
//  Example
//
//  Created by CherryKing on 2019/11/25.
//  Copyright © 2019 CherryKing. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Mercury)
/// 判断View是否显示在屏幕上
- (BOOL)mercury_isDisplayedInScreen;

/// 判断View是否在父视图上处于暴露状态
/// @param offset 大于offset 返回YES
- (BOOL)mercury_isDisplayedInSuperViewOffset:(CGFloat)offset;

/// 自身坐标系Window坐标系 
- (CGRect)mercury_displayFromWindow;

/// 坐标转换
- (CGRect)mercury_displayRect:(CGRect)rect targetV:(UIView *)targetV;

/// 返回UIView所属控制器
- (UIViewController*)mercury_belongViewController;


// MARK: ======================= 约束 =======================
//- (void)mercury_removeAllAutoLayout;

@end


NS_ASSUME_NONNULL_END

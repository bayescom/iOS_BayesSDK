//
//  MercuryCircleontrolView.h
//  Example
//
//  Created by CherryKing on 2019/11/19.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface MercuryCircleontrolView : UIView

/// @brief Width of Progress Bar
@property (nonatomic) IBInspectable CGFloat progressBarWidth;
/// @brief Progress color in Progress Bar
@property (nonatomic) IBInspectable UIColor *progressBarProgressColor;
/// @brief Track color in Progress Bar
@property (nonatomic) IBInspectable UIColor *progressBarTrackColor;
/// @brief Start Angle
@property (nonatomic) IBInspectable CGFloat startAngle;

/// @brief Current ProgressBar's progress (Read-Only)
/// To change ProgressBar's progress use setProgress:animated:
@property (nonatomic, readonly) IBInspectable CGFloat progress;

/// @brief Indicates of there is ongoing animation
@property (nonatomic, readonly) BOOL isAnimating;

/// 文本和图片互斥，后被设置上的会被最终显示
@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *centerImage;

/** Used to set progress with animation or without
 @param progress progress to be set
 @param animated should control animate progress change or not
 */
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

/** Used to set progress with animation and custom duration
 
 @param progress progress to be set
 @param animated should control animate progress change or not
 @param duration animation duration (default is 0.2f)
 */
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration;

/// Used to stop ongoing animation
- (void)stopAnimation;

@end

//
//  UIView+MercuryFrame.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>

@interface UIView (MercuryFrame)

@property (nonatomic) CGFloat mer_x;
@property (nonatomic) CGFloat mer_y;
@property (nonatomic) CGFloat mer_width;
@property (nonatomic) CGFloat mer_height;

@property (nonatomic) CGFloat mer_top;
@property (nonatomic) CGFloat mer_bottom;
@property (nonatomic) CGFloat mer_left;
@property (nonatomic) CGFloat mer_right;

@property (nonatomic) CGFloat mer_centerX;
@property (nonatomic) CGFloat mer_centerY;

@property (nonatomic) CGPoint mer_origin;
@property (nonatomic) CGSize  mer_size;

@end

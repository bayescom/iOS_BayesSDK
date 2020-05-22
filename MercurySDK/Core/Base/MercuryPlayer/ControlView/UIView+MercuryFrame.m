//
//  UIView+MercuryFrame.m
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import "UIView+MercuryFrame.h"

@implementation UIView (MercuryFrame)

- (CGFloat)mer_x {
    return self.frame.origin.x;
}

- (void)setMer_x:(CGFloat)mer_x {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = mer_x;
    self.frame        = newFrame;
}

- (CGFloat)mer_y {
    return self.frame.origin.y;
}

- (void)setMer_y:(CGFloat)mer_y {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = mer_y;
    self.frame        = newFrame;
}

- (CGFloat)mer_width {
    return CGRectGetWidth(self.bounds);
}

- (void)setMer_width:(CGFloat)mer_width {
    CGRect newFrame     = self.frame;
    newFrame.size.width = mer_width;
    self.frame          = newFrame;
}

- (CGFloat)mer_height {
    return CGRectGetHeight(self.bounds);
}

- (void)setMer_height:(CGFloat)mer_height {
    CGRect newFrame      = self.frame;
    newFrame.size.height = mer_height;
    self.frame           = newFrame;
}

- (CGFloat)mer_top {
    return self.frame.origin.y;
}

- (void)setMer_top:(CGFloat)mer_top {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = mer_top;
    self.frame        = newFrame;
}

- (CGFloat)mer_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setMer_bottom:(CGFloat)mer_bottom {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = mer_bottom - self.frame.size.height;
    self.frame        = newFrame;
}

- (CGFloat)mer_left {
    return self.frame.origin.x;
}

- (void)setMer_left:(CGFloat)mer_left {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = mer_left;
    self.frame        = newFrame;
}

- (CGFloat)mer_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setMer_right:(CGFloat)mer_right {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = mer_right - self.frame.size.width;
    self.frame        = newFrame;
}

- (CGFloat)mer_centerX {
    return self.center.x;
}

- (void)setMer_centerX:(CGFloat)mer_centerX {
    CGPoint newCenter = self.center;
    newCenter.x       = mer_centerX;
    self.center       = newCenter;
}

- (CGFloat)mer_centerY {
    return self.center.y;
}

- (void)setMer_centerY:(CGFloat)mer_centerY {
    CGPoint newCenter = self.center;
    newCenter.y       = mer_centerY;
    self.center       = newCenter;
}

- (CGPoint)mer_origin {
    return self.frame.origin;
}

- (void)setMer_origin:(CGPoint)mer_origin {
    CGRect newFrame = self.frame;
    newFrame.origin = mer_origin;
    self.frame      = newFrame;
}

- (CGSize)mer_size {
    return self.frame.size;
}

- (void)setMer_size:(CGSize)mer_size {
    CGRect newFrame = self.frame;
    newFrame.size   = mer_size;
    self.frame      = newFrame;
}

@end

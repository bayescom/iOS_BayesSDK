//
//  MercuryFloatView.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>

@interface MercuryFloatView : UIView

/// The parent View
@property(nonatomic, weak) UIView *parentView;

/// Safe margins, mainly for those with Navbar and tabbar
@property(nonatomic, assign) UIEdgeInsets safeInsets;

@end

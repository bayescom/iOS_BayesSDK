//
//  MercuryLoadingView.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MercuryLoadingType) {
    MercuryLoadingTypeKeep,
    MercuryLoadingTypeFadeOut,
};

@interface MercuryLoadingView : UIView

/// default is MercuryLoadingTypeKeep.
@property (nonatomic, assign) MercuryLoadingType animType;

/// default is whiteColor.
@property (nonatomic, strong, null_resettable) UIColor *lineColor;

/// Sets the line width of the spinner's circle.
@property (nonatomic) CGFloat lineWidth;

/// Sets whether the view is hidden when not animating.
@property (nonatomic) BOOL hidesWhenStopped;

/// Property indicating the duration of the animation, default is 1.5s.
@property (nonatomic, readwrite) NSTimeInterval duration;

/// anima state
@property (nonatomic, assign, readonly, getter=isAnimating) BOOL animating;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END

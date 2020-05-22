//
//  MercuryCircleontrolView.m
//  Example
//
//  Created by CherryKing on 2019/11/19.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryCircleontrolView.h"

// Common
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

// Progress Bar Defaults
#define DefaultProgressBarProgressColor [UIColor colorWithRed:0.71 green:0.099 blue:0.099 alpha:0.7]
#define DefaultProgressBarTrackColor [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7]
const CGFloat DefaultProgressBarWidth = 33.0f;

// Hint View Defaults
#define DefaultHintBackgroundColor [UIColor colorWithWhite:0 alpha:0.7]
#define DefaultHintTextFont [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:30.0f]
#define DefaultHintTextColor [UIColor whiteColor]

// Animation Constants
const CGFloat AnimationChangeTimeDuration = 0.2f;
const CGFloat AnimationChangeTimeStep = 0.01f;

@interface MercuryCircleontrolView ()
@property (nonatomic, strong) UILabel *timeLbl;
@property (nonatomic, strong) UIImageView *centerImgV;

@end

@interface MercuryCircleontrolView (Private)

// Common
- (CGFloat)progressAccordingToBounds:(CGFloat)progress;

// Base Drawing
- (void)drawBackground:(CGContextRef)context;

// ProgressBar Drawing
- (UIColor*)progressBarProgressColorForDrawing;
- (UIColor*)progressBarTrackColorForDrawing;
- (CGFloat)progressBarWidthForDrawing;
- (void)drawProgressBar:(CGContextRef)context progressAngle:(CGFloat)progressAngle center:(CGPoint)center radius:(CGFloat)radius;

// Animation
- (void)animateProgressBarChangeFrom:(CGFloat)startProgress to:(CGFloat)endProgress duration:(CGFloat)duration;
- (void)updateProgressBarForAnimation;

@end

@implementation MercuryCircleontrolView {
    NSTimer *_animationTimer;
    CGFloat _currentAnimationProgress, _startProgress, _endProgress, _animationProgressStep;
}

- (BOOL)isAnimating {
    return _animationTimer != nil;
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self setProgress:progress animated:animated duration:AnimationChangeTimeDuration];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated duration:(CGFloat)duration; {
    progress = [self progressAccordingToBounds:progress];
    if (_progress == progress) {
        return;
    }
    
    [_animationTimer invalidate];
    _animationTimer = nil;
    
    if (animated) {
        [self animateProgressBarChangeFrom:_progress to:progress duration:duration];
    } else {
        _progress = progress;
        [self setNeedsDisplay];
    }
}

- (void)stopAnimation {
    if (!self.isAnimating) {
        return;
    }
    
    [_animationTimer invalidate];
    _animationTimer = nil;
    _progress = _endProgress;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGPoint innerCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(innerCenter.x, innerCenter.y);
    CGFloat currentProgressAngle = (_progress * 360) + _startAngle;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    [self drawBackground:context];
    
    [self drawProgressBar:context progressAngle:currentProgressAngle center:innerCenter radius:radius];
    
    [self addSubview:self.timeLbl];
    [self addSubview:self.centerImgV];
    // layout
    [_timeLbl.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [_timeLbl.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
    [_timeLbl.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
    [_timeLbl.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    
    [_centerImgV.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [_centerImgV.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
    [_centerImgV.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:0.6].active = YES;
    [_centerImgV.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.6].active = YES;
}

- (void)setText:(NSString *)text {
    _text = text;
    self.timeLbl.text = _text;
    _timeLbl.hidden = NO;
    self.centerImgV.hidden = !_timeLbl.hidden;
}

- (void)setCenterImage:(UIImage *)centerImage {
    _centerImage = centerImage;
    self.timeLbl.hidden = YES;
    self.centerImgV.hidden = !_timeLbl.hidden;
    _centerImgV.image = _centerImage;
}

#pragma mark - Setters with View Update

- (void)setProgressBarWidth:(CGFloat)progressBarWidth {
    _progressBarWidth = progressBarWidth;
    [self setNeedsDisplay];
}

- (void)setProgressBarProgressColor:(UIColor *)progressBarProgressColor {
    _progressBarProgressColor = progressBarProgressColor;
    [self setNeedsDisplay];
}

- (void)setProgressBarTrackColor:(UIColor *)progressBarTrackColor {
    _progressBarTrackColor = progressBarTrackColor;
    [self setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
    [self setNeedsDisplay];
}

// MARK: ======================= get =======================
- (UILabel *)timeLbl {
    if (!_timeLbl) {
        _timeLbl = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLbl.textAlignment = NSTextAlignmentCenter;
        _timeLbl.textColor = _progressBarProgressColor;
        _timeLbl.font = [UIFont systemFontOfSize:13];
        _timeLbl.translatesAutoresizingMaskIntoConstraints = NO;
        _timeLbl.hidden = YES;
    }
    return _timeLbl;
}

- (UIImageView *)centerImgV {
    if (!_centerImgV) {
        _centerImgV = [[UIImageView alloc] initWithFrame:CGRectZero];
        _centerImgV.hidden = YES;
        _centerImgV.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _centerImgV;
}

@end

@implementation MercuryCircleontrolView (Private)

#pragma mark - Common

- (CGFloat)progressAccordingToBounds:(CGFloat)progress {
    progress = MIN(progress, 1);
    progress = MAX(progress, 0);
    return progress;
}

#pragma mark - Base Drawing

- (void)drawBackground:(CGContextRef)context {
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, self.bounds);
}

#pragma mark - ProgressBar Drawing

- (UIColor*)progressBarProgressColorForDrawing {
    return (_progressBarProgressColor != nil ? _progressBarProgressColor : DefaultProgressBarProgressColor);
}

- (UIColor*)progressBarTrackColorForDrawing {
    return (_progressBarTrackColor != nil ? _progressBarTrackColor : DefaultProgressBarTrackColor);
}

- (CGFloat)progressBarWidthForDrawing {
    return (_progressBarWidth > 0 ? _progressBarWidth : DefaultProgressBarWidth);
}

- (void)drawProgressBar:(CGContextRef)context progressAngle:(CGFloat)progressAngle center:(CGPoint)center radius:(CGFloat)radius {
    CGFloat barWidth = self.progressBarWidthForDrawing;
    if (barWidth > radius) {
        barWidth = radius;
    }
    
    CGContextSetFillColorWithColor(context, self.progressBarProgressColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(_startAngle), DEGREES_TO_RADIANS(progressAngle), 0);
    CGContextAddArc(context, center.x, center.y, radius - barWidth, DEGREES_TO_RADIANS(progressAngle), DEGREES_TO_RADIANS(_startAngle), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextSetFillColorWithColor(context, self.progressBarTrackColorForDrawing.CGColor);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, DEGREES_TO_RADIANS(progressAngle), DEGREES_TO_RADIANS(_startAngle + 360), 0);
    CGContextAddArc(context, center.x, center.y, radius - barWidth, DEGREES_TO_RADIANS(_startAngle + 360), DEGREES_TO_RADIANS(progressAngle), 1);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

#pragma mark - Amination

- (void)animateProgressBarChangeFrom:(CGFloat)startProgress to:(CGFloat)endProgress duration:(CGFloat)duration {
    _currentAnimationProgress = _startProgress = startProgress;
    _endProgress = endProgress;
    
    _animationProgressStep = (_endProgress - _startProgress) * AnimationChangeTimeStep / duration;
    if (!_animationTimer) {
        _animationTimer = [NSTimer scheduledTimerWithTimeInterval:AnimationChangeTimeStep target:self selector:@selector(updateProgressBarForAnimation) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)updateProgressBarForAnimation {
    _currentAnimationProgress += _animationProgressStep;
    _progress = _currentAnimationProgress;
    if ((_animationProgressStep > 0 && _currentAnimationProgress >= _endProgress) || (_animationProgressStep < 0 && _currentAnimationProgress <= _endProgress)) {
        [_animationTimer invalidate];
        _animationTimer = nil;
        _progress = _endProgress;
    }
    [self setNeedsDisplay];
}

@end

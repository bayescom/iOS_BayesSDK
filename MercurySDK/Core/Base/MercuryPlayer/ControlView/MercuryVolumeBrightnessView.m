//
//  MercuryVolumeBrightnessView.m
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import "MercuryVolumeBrightnessView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MercuryUtilities.h"
#import "MercuryPriHeader.h"
#if __has_include(<MercuryPlayer.h>)
#import "MercuryPlayer.h"
#else
#import "MercuryPlayer.h"
#endif

@interface MercuryVolumeBrightnessView ()

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) MercuryVolumeBrightnessType volumeBrightnessType;
@property (nonatomic, strong) MPVolumeView *volumeView;

@end

@implementation MercuryVolumeBrightnessView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconImageView];
        [self addSubview:self.progressView];
        [self hideTipView];
    }
    return self;
}

- (void)dealloc {
    [self addSystemVolumeView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.frame.size.width;
    CGFloat min_view_h = self.frame.size.height;
    CGFloat margin = 10;
    
    min_x = margin;
    min_w = 20;
    min_h = min_w;
    min_y = (min_view_h-min_h)/2;
    self.iconImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = CGRectGetMaxX(self.iconImageView.frame) + margin;
    min_h = 2;
    min_y = (min_view_h-min_h)/2;
    min_w = min_view_w - min_x - margin;
    self.progressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    self.layer.cornerRadius = min_view_h/2;
    self.layer.masksToBounds = YES;
}

- (void)hideTipView {
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

/// 添加系统音量view
- (void)addSystemVolumeView {
    [self.volumeView removeFromSuperview];
}

/// 移除系统音量view
- (void)removeSystemVolumeView {
    [[UIApplication sharedApplication].keyWindow addSubview:self.volumeView];
}

- (void)updateProgress:(CGFloat)progress withVolumeBrightnessType:(MercuryVolumeBrightnessType)volumeBrightnessType {
    if (progress >= 1) {
        progress = 1;
    } else if (progress <= 0) {
        progress = 0;
    }
    self.progressView.progress = progress;
    self.volumeBrightnessType = volumeBrightnessType;
    UIImage *playerImage = nil;
    if (volumeBrightnessType == MercuryVolumeBrightnessTypeVolume) {
        if (progress == 0) {
            playerImage = kMercuryImageNamed(@"MercuryPlayer_muted");
        } else if (progress > 0 && progress < 0.5) {
            playerImage = kMercuryImageNamed(@"MercuryPlayer_volume_low");
        } else {
            playerImage = kMercuryImageNamed(@"MercuryPlayer_volume_high");
        }
    } else if (volumeBrightnessType == MercuryVolumeBrightnessTypeumeBrightness) {
        if (progress >= 0 && progress < 0.5) {
            playerImage = kMercuryImageNamed(@"_mercury_sdk3_0_brightness_low");
        } else {
            playerImage = kMercuryImageNamed(@"_mercury_sdk3_0_brightness_high");
        }
    }
    self.iconImageView.image = playerImage;
    self.hidden = NO;
    self.alpha = 1;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTipView) object:nil];
    [self performSelector:@selector(hideTipView) withObject:nil afterDelay:1.5];
}

- (void)setVolumeBrightnessType:(MercuryVolumeBrightnessType)volumeBrightnessType {
    _volumeBrightnessType = volumeBrightnessType;
    if (volumeBrightnessType == MercuryVolumeBrightnessTypeVolume) {
        self.iconImageView.image = kMercuryImageNamed(@"MercuryPlayer_volume");
    } else {
        self.iconImageView.image = kMercuryImageNamed(@"MercuryPlayer_brightness");
    }
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] init];
        _progressView.progressTintColor = [UIColor whiteColor];
        _progressView.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];;
    }
    return _progressView;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [UIImageView new];
    }
    return _iconImageView;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.frame = CGRectMake(-1000, -1000, 100, 100);
    }
    return _volumeView;
}

@end

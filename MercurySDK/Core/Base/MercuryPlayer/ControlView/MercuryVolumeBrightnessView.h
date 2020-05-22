//
//  MercuryVolumeBrightnessView.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MercuryVolumeBrightnessType) {
    MercuryVolumeBrightnessTypeVolume,       // volume
    MercuryVolumeBrightnessTypeumeBrightness // brightness
};

@interface MercuryVolumeBrightnessView : UIView

@property (nonatomic, assign, readonly) MercuryVolumeBrightnessType volumeBrightnessType;
@property (nonatomic, strong, readonly) UIProgressView *progressView;
@property (nonatomic, strong, readonly) UIImageView *iconImageView;

- (void)updateProgress:(CGFloat)progress withVolumeBrightnessType:(MercuryVolumeBrightnessType)volumeBrightnessType;

/// 添加系统音量view
- (void)addSystemVolumeView;

/// 移除系统音量view
- (void)removeSystemVolumeView;

@end

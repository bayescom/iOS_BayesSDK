//
//  MercuryOrentationObserver.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Full screen mode
typedef NS_ENUM(NSUInteger, MercuryFullScreenMode) {
    MercuryFullScreenModeAutomatic,  // Determine full screen mode automatically
    MercuryFullScreenModeLandscape,  // Landscape full screen mode
    MercuryFullScreenModePortrait    // Portrait full screen Model
};

/// Full screen mode on the view
typedef NS_ENUM(NSUInteger, MercuryRotateType) {
    MercuryRotateTypeNormal,         // Normal
    MercuryRotateTypeCell,           // Cell
    MercuryRotateTypeCellOther       // Cell mode add to other view
};

/**
 Rotation of support direction
 */
typedef NS_OPTIONS(NSUInteger, MercuryInterfaceOrientationMask) {
    MercuryInterfaceOrientationMaskPortrait = (1 << 0),
    MercuryInterfaceOrientationMaskLandscapeLeft = (1 << 1),
    MercuryInterfaceOrientationMaskLandscapeRight = (1 << 2),
    MercuryInterfaceOrientationMaskPortraitUpsideDown = (1 << 3),
    MercuryInterfaceOrientationMaskLandscape = (MercuryInterfaceOrientationMaskLandscapeLeft | MercuryInterfaceOrientationMaskLandscapeRight),
    MercuryInterfaceOrientationMaskAll = (MercuryInterfaceOrientationMaskPortrait | MercuryInterfaceOrientationMaskLandscapeLeft | MercuryInterfaceOrientationMaskLandscapeRight | MercuryInterfaceOrientationMaskPortraitUpsideDown),
    MercuryInterfaceOrientationMaskAllButUpsideDown = (MercuryInterfaceOrientationMaskPortrait | MercuryInterfaceOrientationMaskLandscapeLeft | MercuryInterfaceOrientationMaskLandscapeRight),
};

@interface MercuryOrientationObserver : NSObject

/// update the rotateView and containerView.
- (void)updateRotateView:(UIView *)rotateView
           containerView:(UIView *)containerView;

/// list play
- (void)cellModelRotateView:(UIView *)rotateView
           rotateViewAtCell:(UIView *)cell
              playerViewTag:(NSInteger)playerViewTag;

/// cell other view rotation
- (void)cellOtherModelRotateView:(UIView *)rotateView
                   containerView:(UIView *)containerView;

/// Container view of a full screen state player.
@property (nonatomic, strong) UIView *fullScreenContainerView;

/// Container view of a small screen state player.
@property (nonatomic, weak) UIView *containerView;

/// If the full screen.
@property (nonatomic, readonly, getter=isFullScreen) BOOL fullScreen;

/// Use device orientation, default NO.
@property (nonatomic, assign) BOOL forceDeviceOrientation;

/// Lock screen orientation
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

/// The block invoked When player will rotate.
@property (nonatomic, copy, nullable) void(^orientationWillChange)(MercuryOrientationObserver *observer, BOOL isFullScreen);

/// The block invoked when player rotated.
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(MercuryOrientationObserver *observer, BOOL isFullScreen);

/// Full screen mode, the default landscape into full screen
@property (nonatomic) MercuryFullScreenMode fullScreenMode;

/// rotate duration, default is 0.30
@property (nonatomic) float duration;

/// The statusbar hidden.
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

/// The current orientation of the player.
/// Default is UIInterfaceOrientationPortrait.
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

/// Whether allow the video orientation rotate.
/// default is YES.
@property (nonatomic) BOOL allowOrentitaionRotation;

/// The support Interface Orientation,default is MercuryInterfaceOrientationMaskAllButUpsideDown
@property (nonatomic, assign) MercuryInterfaceOrientationMask supportInterfaceOrientation;

/// Add the device orientation observer.
- (void)addDeviceOrientationObserver;

/// Remove the device orientation observer.
- (void)removeDeviceOrientationObserver;

/// Enter the fullScreen while the MercuryFullScreenMode is MercuryFullScreenModeLandscape.
- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/// Enter the fullScreen while the MercuryFullScreenMode is MercuryFullScreenModePortrait.
- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated;

/// Exit the fullScreen.
- (void)exitFullScreenWithAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END



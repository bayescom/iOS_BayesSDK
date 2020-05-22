
//  MercuryOrentationObserver.m
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import "MercuryOrientationObserver.h"
#import "MercuryPlayer.h"

#define SysVersion [[UIDevice currentDevice] systemVersion].floatValue

@interface MercuryFullViewController : UIViewController

@property (nonatomic, assign) UIInterfaceOrientationMask interfaceOrientationMask;

@end

@implementation MercuryFullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.interfaceOrientationMask) {
        return self.interfaceOrientationMask;
    }
    return UIInterfaceOrientationMaskLandscape;
}

@end

@interface UIWindow (CurrentViewController)

/*!
 @method currentViewController
 @return Returns the topViewController in stack of topMostController.
 */
+ (UIViewController*)mer_currentViewController;

@end

@implementation UIWindow (CurrentViewController)

+ (UIViewController*)mer_currentViewController; {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        } else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        } else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        } else {
            break;
        }
    }
    return topViewController;
}

@end

@interface MercuryOrientationObserver ()

@property (nonatomic, weak) UIView *view;

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

@property (nonatomic, strong) UIView *cell;

@property (nonatomic, assign) NSInteger playerViewTag;

@property (nonatomic, assign) MercuryRotateType roateType;

@property (nonatomic, strong) UIView *blackView;

@property (nonatomic, strong) UIWindow *customWindow;

@end

@implementation MercuryOrientationObserver

- (instancetype)init {
    self = [super init];
    if (self) {
        _duration = 0.30;
        _fullScreenMode = MercuryFullScreenModeLandscape;
        _supportInterfaceOrientation = MercuryInterfaceOrientationMaskAllButUpsideDown;
        _allowOrentitaionRotation = YES;
        _roateType = MercuryRotateTypeNormal;
        _currentOrientation = UIInterfaceOrientationPortrait;
    }
    return self;
}

- (void)updateRotateView:(UIView *)rotateView
           containerView:(UIView *)containerView {
    self.view = rotateView;
    self.containerView = containerView;
}

- (void)cellModelRotateView:(UIView *)rotateView rotateViewAtCell:(UIView *)cell playerViewTag:(NSInteger)playerViewTag {
    self.roateType = MercuryRotateTypeCell;
    self.view = rotateView;
    self.cell = cell;
    self.playerViewTag = playerViewTag;
}

- (void)cellOtherModelRotateView:(UIView *)rotateView containerView:(UIView *)containerView {
    self.roateType = MercuryRotateTypeCellOther;
    self.view = rotateView;
    self.containerView = containerView;
}

- (void)dealloc {
    [self removeDeviceOrientationObserver];
    [self.blackView removeFromSuperview];
}

- (void)addDeviceOrientationObserver {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeDeviceOrientationObserver {
    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleDeviceOrientationChange {
    if (self.fullScreenMode == MercuryFullScreenModePortrait || !self.allowOrentitaionRotation) return;

    UIInterfaceOrientation currentOrientation = UIInterfaceOrientationUnknown;
    if (UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) {
        currentOrientation = (UIInterfaceOrientation)[UIDevice currentDevice].orientation;
    } else {
        return;
    }

    // Determine that if the current direction is the same as the direction you want to rotate, do nothing
    if (currentOrientation == _currentOrientation && !self.forceDeviceOrientation) return;
    
    switch (currentOrientation) {
        case UIInterfaceOrientationPortrait: {
            if ([self isSupportedPortrait]) {
                [self enterLandscapeFullScreen:UIInterfaceOrientationPortrait animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            if ([self isSupportedLandscapeLeft]) {
                [self enterLandscapeFullScreen:UIInterfaceOrientationLandscapeLeft animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            if ([self isSupportedLandscapeRight]) {
                [self enterLandscapeFullScreen:UIInterfaceOrientationLandscapeRight animated:YES];
            }
        }
            break;
        default: break;
    }
}

- (void)forceDeviceOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    UIView *superview = nil;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        /// It's not set from the other side of the screen to this side
        if (!self.isFullScreen) {
            self.view.frame = [self.view convertRect:self.view.frame toView:superview];
        }
        self.fullScreen = YES;
        superview = self.fullScreenContainerView;
    } else {
        if (!self.fullScreen) return;
        self.fullScreen = NO;
        if (self.roateType == MercuryRotateTypeCell) superview = [self.cell viewWithTag:self.playerViewTag];
        else superview = self.containerView;
        if (self.blackView.superview != nil) [self.blackView removeFromSuperview];
    }
    if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
    [UIViewController attemptRotationToDeviceOrientation];

    [superview addSubview:self.view];
    if (animated) {
        [UIView animateWithDuration:self.duration animations:^{
            self.view.frame = superview.bounds;
            [self.view layoutIfNeeded];
            [self interfaceOrientation:orientation];
        } completion:^(BOOL finished) {
            if (self.fullScreen) {
                [superview insertSubview:self.blackView belowSubview:self.view];
                self.blackView.frame = superview.bounds;
            }
            if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
        }];
    } else {
        self.view.frame = superview.bounds;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:0 animations:^{
            [self interfaceOrientation:orientation];
        }];
        if (self.fullScreen) {
            [superview insertSubview:self.blackView belowSubview:self.view];
            self.blackView.frame = superview.bounds;
        }
        if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
    }
}

- (void)normalOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    UIView *superview = nil;
    CGRect frame;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        superview = self.fullScreenContainerView;
        /// It's not set from the other side of the screen to this side
        if (!self.isFullScreen) {
            self.view.frame = [self.view convertRect:self.view.frame toView:superview];
        }
        [superview addSubview:self.view];
        self.fullScreen = YES;
        if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
        
        MercuryFullViewController *fullVC = [[MercuryFullViewController alloc] init];
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            fullVC.interfaceOrientationMask = UIInterfaceOrientationMaskLandscapeLeft;
        } else {
            fullVC.interfaceOrientationMask = UIInterfaceOrientationMaskLandscapeRight;
        }
        self.customWindow.rootViewController = fullVC;
    } else {
        self.fullScreen = NO;
        if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
        MercuryFullViewController *fullVC = [[MercuryFullViewController alloc] init];
        fullVC.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait;
        self.customWindow.rootViewController = fullVC;
        
        if (self.roateType == MercuryRotateTypeCell) superview = [self.cell viewWithTag:self.playerViewTag];
        else superview = self.containerView;
        if (self.blackView.superview != nil) [self.blackView removeFromSuperview];
    }
    frame = [superview convertRect:superview.bounds toView:self.fullScreenContainerView];
    
    if (animated) {
        [UIView animateWithDuration:self.duration animations:^{
            self.view.transform = [self getTransformRotationAngle:orientation];
            [UIView animateWithDuration:self.duration animations:^{
                self.view.frame = frame;
                [self.view layoutIfNeeded];
            }];
        } completion:^(BOOL finished) {
            [superview addSubview:self.view];
            self.view.frame = superview.bounds;
            if (self.fullScreen) {
                [superview insertSubview:self.blackView belowSubview:self.view];
                self.blackView.frame = superview.bounds;
            }
            if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
        }];
    } else {
        self.view.transform = [self getTransformRotationAngle:orientation];
        [superview addSubview:self.view];
        self.view.frame = superview.bounds;
        [self.view layoutIfNeeded];
        if (self.fullScreen) {
            [superview insertSubview:self.blackView belowSubview:self.view];
            self.blackView.frame = superview.bounds;
        }
        if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        UIInterfaceOrientation val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

/// Gets the rotation Angle of the transformation.
- (CGAffineTransform)getTransformRotationAngle:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if(orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI_2);
    }
    return CGAffineTransformIdentity;
}

#pragma mark - public

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    if (self.fullScreenMode == MercuryFullScreenModePortrait) return;
    _currentOrientation = orientation;
    if (self.forceDeviceOrientation) {
        [self forceDeviceOrientation:orientation animated:animated];
    } else {
        [self normalOrientation:orientation animated:animated];
    }
}

- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    if (self.fullScreenMode == MercuryFullScreenModeLandscape) return;
    UIView *superview = nil;
    if (fullScreen) {
        superview = self.fullScreenContainerView;
        self.view.frame = [self.view convertRect:self.view.frame toView:superview];
        [superview addSubview:self.view];
        self.fullScreen = YES;
    } else {
        if (self.roateType == MercuryRotateTypeCell) {
            superview = [self.cell viewWithTag:self.playerViewTag];
        } else {
            superview = self.containerView;
        }
        self.fullScreen = NO;
    }
    if (self.orientationWillChange) self.orientationWillChange(self, self.isFullScreen);
    CGRect frame = [superview convertRect:superview.bounds toView:self.fullScreenContainerView];
    if (animated) {
        [UIView animateWithDuration:self.duration animations:^{
            self.view.frame = frame;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [superview addSubview:self.view];
            self.view.frame = superview.bounds;
            if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
        }];
    } else {
        [superview addSubview:self.view];
        self.view.frame = superview.bounds;
        [self.view layoutIfNeeded];
        if (self.orientationDidChanged) self.orientationDidChanged(self, self.isFullScreen);
    }
}

- (void)exitFullScreenWithAnimated:(BOOL)animated {
    if (self.fullScreenMode == MercuryFullScreenModeLandscape) {
        [self enterLandscapeFullScreen:UIInterfaceOrientationPortrait animated:animated];
    } else if (self.fullScreenMode == MercuryFullScreenModePortrait) {
        [self enterPortraitFullScreen:NO animated:animated];
    }
}

#pragma mark - private

/// is support portrait
- (BOOL)isSupportedPortrait {
    return self.supportInterfaceOrientation & MercuryInterfaceOrientationMaskPortrait;
}

/// is support landscapeLeft
- (BOOL)isSupportedLandscapeLeft {
    return self.supportInterfaceOrientation & MercuryInterfaceOrientationMaskLandscapeLeft;
}

/// is support landscapeRight
- (BOOL)isSupportedLandscapeRight {
    return self.supportInterfaceOrientation & MercuryInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - getter

- (UIView *)blackView {
    if (!_blackView) {
        _blackView = [UIView new];
        _blackView.backgroundColor = [UIColor blackColor];
    }
    return _blackView;
}

- (UIWindow *)customWindow {
    if (!_customWindow) {
        if (@available(iOS 13.0, *)) {
            UIWindowScene *windowScene = nil;
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    windowScene = (UIWindowScene *)scene;
                }
                if (!windowScene && [UIApplication sharedApplication].connectedScenes.count == 1) {
                    windowScene = (UIWindowScene *)scene;
                }
            }
            if (windowScene) {
                _customWindow = [[UIWindow alloc] initWithWindowScene:windowScene];
            } else {
                _customWindow = [[UIWindow alloc] initWithFrame:CGRectZero];
            }
        } else {
            _customWindow = [[UIWindow alloc] initWithFrame:CGRectZero];
        }
    }
    return _customWindow;
}

#pragma mark - setter

- (void)setLockedScreen:(BOOL)lockedScreen {
    _lockedScreen = lockedScreen;
    if (lockedScreen) {
        [self removeDeviceOrientationObserver];
    } else {
        [self addDeviceOrientationObserver];
    }
}

- (UIView *)fullScreenContainerView {
    if (!_fullScreenContainerView) {
        _fullScreenContainerView = [UIApplication sharedApplication].keyWindow;
    }
    return _fullScreenContainerView;
}

- (void)setFullScreen:(BOOL)fullScreen {
    _fullScreen = fullScreen;
    [[UIWindow mer_currentViewController] setNeedsStatusBarAppearanceUpdate];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [[UIWindow mer_currentViewController] setNeedsStatusBarAppearanceUpdate];
}

@end

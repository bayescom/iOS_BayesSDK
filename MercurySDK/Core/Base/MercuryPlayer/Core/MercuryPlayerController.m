//
//  MercuryPlayerController.m
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import "MercuryPlayerController.h"
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIScrollView+MercuryPlayer.h"
#import "MercuryReachabilityManager.h"
#import "MercuryPlayer.h"
#import "BY_HTTPCache.h"

@interface MercuryPlayerController ()

@property (nonatomic, strong) MercuryPlayerNotification *notification;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UISlider *volumeViewSlider;
@property (nonatomic, assign) NSInteger containerViewTag;
@property (nonatomic, assign) MercuryPlayerContainerType containerType;
/// The player's small container view.
@property (nonatomic, strong) MercuryFloatView *smallFloatView;
/// Whether the small window is displayed.
@property (nonatomic, assign) BOOL isSmallFloatViewShow;
/// The indexPath is playing.
@property (nonatomic, nullable) NSIndexPath *playingIndexPath;

@end

@implementation MercuryPlayerController

- (instancetype)init {
    self = [super init];
    if (self) {
        @weakify(self)
        [[MercuryReachabilityManager sharedManager] startMonitoring];
        [[MercuryReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(MercuryReachabilityStatus status) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(videoPlayer:reachabilityChanged:)]) {
                [self.controlView videoPlayer:self reachabilityChanged:status];
            }
        }];
        [self configureVolume];
    }
    return self;
}

/// Get system volume
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)dealloc {
    [BY_HTTPCache proxyStop];
    [self.currentPlayerManager stop];
    NSLog(@"%s", __func__);
}

+ (instancetype)playerWithPlayerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView {
    MercuryPlayerController *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
    return player;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag {
    MercuryPlayerController *player = [[self alloc] initWithScrollView:scrollView playerManager:playerManager containerViewTag:containerViewTag];
    return player;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView {
    MercuryPlayerController *player = [[self alloc] initWithScrollView:scrollView playerManager:playerManager containerView:containerView];
    return player;
}

- (instancetype)initWithPlayerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView {
    MercuryPlayerController *player = [self init];
    player.containerView = containerView;
    player.currentPlayerManager = playerManager;
    player.containerType = MercuryPlayerContainerTypeView;
    return player;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag {
    MercuryPlayerController *player = [self init];
    player.scrollView = scrollView;
    player.containerViewTag = containerViewTag;
    player.currentPlayerManager = playerManager;
    player.containerType = MercuryPlayerContainerTypeCell;
    return player;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView {
    MercuryPlayerController *player = [self init];
    player.scrollView = scrollView;
    player.containerView = containerView;
    player.currentPlayerManager = playerManager;
    player.containerType = MercuryPlayerContainerTypeView;
    return player;
}

- (void)playerManagerCallbcak {
    @weakify(self)
    self.currentPlayerManager.playerPrepareToPlay = ^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        self.currentPlayerManager.view.hidden = NO;
        [self.notification addNotification];
        [self addDeviceOrientationObserver];
        if (self.scrollView) {
            self.scrollView.mer_stopPlay = NO;
        }
        [self layoutPlayerSubViews];
        if (self.playerPrepareToPlay) self.playerPrepareToPlay(asset,assetURL);
        if ([self.controlView respondsToSelector:@selector(videoPlayer:prepareToPlay:)]) {
            [self.controlView videoPlayer:self prepareToPlay:assetURL];
        }
    };
    
    self.currentPlayerManager.playerReadyToPlay = ^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
        @strongify(self)
        if (self.playerReadyToPlay) self.playerReadyToPlay(asset,assetURL);
        if (!self.customAudioSession) {
            // Apps using this category don't mute when the phone's mute button is turned on, but play sound when the phone is silent
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
        if (self.viewControllerDisappear) self.pauseByEvent = YES;
    };
    
    self.currentPlayerManager.playerPlayTimeChanged = ^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self)
        if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(asset,currentTime,duration);
        if ([self.controlView respondsToSelector:@selector(videoPlayer:currentTime:totalTime:)]) {
            [self.controlView videoPlayer:self currentTime:currentTime totalTime:duration];
        }
    };
    
    self.currentPlayerManager.playerBufferTimeChanged = ^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval bufferTime) {
        @strongify(self)
        if ([self.controlView respondsToSelector:@selector(videoPlayer:bufferTime:)]) {
            [self.controlView videoPlayer:self bufferTime:bufferTime];
        }
        if (self.playerBufferTimeChanged) self.playerBufferTimeChanged(asset,bufferTime);
    };
    
    self.currentPlayerManager.playerPlayStateChanged = ^(id  _Nonnull asset, MercuryPlayerPlaybackState playState) {
        @strongify(self)
        if (self.playerPlayStateChanged) self.playerPlayStateChanged(asset, playState);
        if ([self.controlView respondsToSelector:@selector(videoPlayer:playStateChanged:)]) {
            [self.controlView videoPlayer:self playStateChanged:playState];
        }
    };
    
    self.currentPlayerManager.playerLoadStateChanged = ^(id  _Nonnull asset, MercuryPlayerLoadState loadState) {
        @strongify(self)
        if (self.playerLoadStateChanged) self.playerLoadStateChanged(asset, loadState);
        if ([self.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
            [self.controlView videoPlayer:self loadStateChanged:loadState];
        }
    };
    
    self.currentPlayerManager.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        if (self.playerDidToEnd) self.playerDidToEnd(asset);
        if ([self.controlView respondsToSelector:@selector(videoPlayerPlayEnd:)]) {
            [self.controlView videoPlayerPlayEnd:self];
        }
    };
    
    self.currentPlayerManager.playerPlayFailed = ^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        @strongify(self)
        if (self.playerPlayFailed) self.playerPlayFailed(asset, error);
        if ([self.controlView respondsToSelector:@selector(videoPlayerPlayFailed:error:)]) {
            [self.controlView videoPlayerPlayFailed:self error:error];
        }
    };
    
    self.currentPlayerManager.presentationSizeChanged = ^(id<MercuryPlayerMediaPlayback>  _Nonnull asset, CGSize size){
        @strongify(self)
        if (self.orientationObserver.fullScreenMode == MercuryFullScreenModeAutomatic) {
            if (size.width > size.height) {
                self.orientationObserver.fullScreenMode = MercuryFullScreenModeLandscape;
            } else {
                self.orientationObserver.fullScreenMode = MercuryFullScreenModePortrait;
            }
        }
        if (self.presentationSizeChanged) self.presentationSizeChanged(asset, size);
        if ([self.controlView respondsToSelector:@selector(videoPlayer:presentationSizeChanged:)]) {
            [self.controlView videoPlayer:self presentationSizeChanged:size];
        }
    };
}

- (void)layoutPlayerSubViews {
    if (self.containerView && self.currentPlayerManager.view) {
        UIView *superview = nil;
        if (self.isFullScreen) {
            superview = self.orientationObserver.fullScreenContainerView;
        } else if (self.containerView) {
            superview = self.containerView;
        }
        [superview addSubview:self.currentPlayerManager.view];
        [self.currentPlayerManager.view addSubview:self.controlView];
        
        self.currentPlayerManager.view.frame = superview.bounds;
        self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.controlView.frame = self.currentPlayerManager.view.bounds;
        self.controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.orientationObserver updateRotateView:self.currentPlayerManager.view containerView:self.containerView];
    }
}

#pragma mark - getter

- (MercuryPlayerNotification *)notification {
    if (!_notification) {
        _notification = [[MercuryPlayerNotification alloc] init];
        @weakify(self)
        _notification.willResignActive = ^(MercuryPlayerNotification * _Nonnull registrar) {
            @strongify(self)
            if (self.isViewControllerDisappear) return;
            if (self.pauseWhenAppResignActive && self.currentPlayerManager.isPlaying) {
                self.pauseByEvent = YES;
            }
            self.orientationObserver.lockedScreen = YES;
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            if (!self.pauseWhenAppResignActive) {
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            }
        };
        _notification.didBecomeActive = ^(MercuryPlayerNotification * _Nonnull registrar) {
            @strongify(self)
            if (self.isViewControllerDisappear) return;
            if (self.isPauseByEvent) self.pauseByEvent = NO;
            self.orientationObserver.lockedScreen = NO;
        };
        _notification.oldDeviceUnavailable = ^(MercuryPlayerNotification * _Nonnull registrar) {
            @strongify(self)
            if (self.currentPlayerManager.isPlaying) {
                [self.currentPlayerManager play];
            }
        };
    }
    return _notification;
}

- (MercuryFloatView *)smallFloatView {
    if (!_smallFloatView) {
        _smallFloatView = [[MercuryFloatView alloc] init];
        _smallFloatView.parentView = [UIApplication sharedApplication].keyWindow;
        _smallFloatView.hidden = YES;
    }
    return _smallFloatView;
}

#pragma mark - setter

- (void)setCurrentPlayerManager:(id<MercuryPlayerMediaPlayback>)currentPlayerManager {
    if (!currentPlayerManager) return;
    if (_currentPlayerManager.isPreparedToPlay) {
        [_currentPlayerManager stop];
        [_currentPlayerManager.view removeFromSuperview];
        [self.orientationObserver removeDeviceOrientationObserver];
        [self.gestureControl removeGestureToView:self.currentPlayerManager.view];
    }
    _currentPlayerManager = currentPlayerManager;
    _currentPlayerManager.view.hidden = YES;
    self.gestureControl.disableTypes = self.disableGestureTypes;
    [self.gestureControl addGestureToView:currentPlayerManager.view];
    [self playerManagerCallbcak];
    [self.orientationObserver updateRotateView:currentPlayerManager.view containerView:self.containerView];
    self.controlView.player = self;
    [self layoutPlayerSubViews];
}

- (void)setContainerView:(UIView *)containerView {
    _containerView = containerView;
    if (self.scrollView) {
        self.scrollView.mer_containerView = containerView;
    }
    if (!containerView) return;
    containerView.userInteractionEnabled = YES;
    [self layoutPlayerSubViews];
}

- (void)setControlView:(UIView<MercuryPlayerMediaControl> *)controlView {
    _controlView = controlView;
    if (!controlView) return;
    controlView.player = self;
    [self layoutPlayerSubViews];
}

- (void)setContainerType:(MercuryPlayerContainerType)containerType {
    _containerType = containerType;
    if (self.scrollView) {
        self.scrollView.mer_containerType = containerType;
    }
}

@end

@implementation MercuryPlayerController (MercuryPlayerTimeControl)

- (NSTimeInterval)currentTime {
    return self.currentPlayerManager.currentTime;
}

- (NSTimeInterval)totalTime {
    return self.currentPlayerManager.totalTime;
}

- (NSTimeInterval)bufferTime {
    return self.currentPlayerManager.bufferTime;
}

- (float)progress {
    if (self.totalTime == 0) return 0;
    return self.currentTime/self.totalTime;
}

- (float)bufferProgress {
    if (self.totalTime == 0) return 0;
    return self.bufferTime/self.totalTime;
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.currentPlayerManager seekToTime:time completionHandler:completionHandler];
}

@end

@implementation MercuryPlayerController (MercuryPlayerPlaybackControl)

- (void)playTheNext {
    if (self.assetURLs.count > 0) {
        NSInteger index = self.currentPlayIndex + 1;
        if (index >= self.assetURLs.count) return;
        NSURL *assetURL = [self.assetURLs objectAtIndex:index];
        self.assetURL = assetURL;
        self.currentPlayIndex = [self.assetURLs indexOfObject:assetURL];
    }
}

- (void)playThePrevious {
    if (self.assetURLs.count > 0) {
        NSInteger index = self.currentPlayIndex - 1;
        if (index < 0) return;
        NSURL *assetURL = [self.assetURLs objectAtIndex:index];
        self.assetURL = assetURL;
        self.currentPlayIndex = [self.assetURLs indexOfObject:assetURL];
    }
}

- (void)playTheIndex:(NSInteger)index {
    if (self.assetURLs.count > 0) {
        if (index >= self.assetURLs.count) return;
        NSURL *assetURL = [self.assetURLs objectAtIndex:index];
        self.assetURL = assetURL;
        self.currentPlayIndex = index;
    }
}

- (void)stop {
    [self.notification removeNotification];
    [self.orientationObserver removeDeviceOrientationObserver];
    if (self.isFullScreen && self.exitFullScreenWhenStop) {
        [self.orientationObserver exitFullScreenWithAnimated:NO];
    }
    [self.currentPlayerManager stop];
    [self.currentPlayerManager.view removeFromSuperview];
    if (self.scrollView) {
        self.scrollView.mer_stopPlay = YES;
    }
}

- (void)replaceCurrentPlayerManager:(id<MercuryPlayerMediaPlayback>)playerManager {
    self.currentPlayerManager = playerManager;
}

//// Add video to the cell
- (void)addPlayerViewToCell {
    self.isSmallFloatViewShow = NO;
    self.smallFloatView.hidden = YES;
    UIView *cell = [self.scrollView mer_getCellForIndexPath:self.playingIndexPath];
    self.containerView = [cell viewWithTag:self.containerViewTag];
    [self.containerView addSubview:self.currentPlayerManager.view];
    self.currentPlayerManager.view.frame = self.containerView.bounds;
    self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver cellModelRotateView:self.currentPlayerManager.view rotateViewAtCell:cell playerViewTag:self.containerViewTag];
    if ([self.controlView respondsToSelector:@selector(videoPlayer:floatViewShow:)]) {
        [self.controlView videoPlayer:self floatViewShow:NO];
    }
}

//// Add video to the container view
- (void)addPlayerViewToContainerView:(UIView *)containerView {
    self.isSmallFloatViewShow = NO;
    self.smallFloatView.hidden = YES;
    self.containerView = containerView;
    [self.containerView addSubview:self.currentPlayerManager.view];
    self.currentPlayerManager.view.frame = self.containerView.bounds;
    self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver cellOtherModelRotateView:self.currentPlayerManager.view containerView:self.containerView];
    if ([self.controlView respondsToSelector:@selector(videoPlayer:floatViewShow:)]) {
        [self.controlView videoPlayer:self floatViewShow:NO];
    }
}

/// Add to the keyWindow
- (void)addPlayerViewToKeyWindow {
    self.isSmallFloatViewShow = YES;
    self.smallFloatView.hidden = NO;
    [self.smallFloatView addSubview:self.currentPlayerManager.view];
    self.currentPlayerManager.view.frame = self.smallFloatView.bounds;
    self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver cellOtherModelRotateView:self.currentPlayerManager.view containerView:self.smallFloatView];
    if ([self.controlView respondsToSelector:@selector(videoPlayer:floatViewShow:)]) {
        [self.controlView videoPlayer:self floatViewShow:YES];
    }
}

- (void)stopCurrentPlayingView {
    if (self.containerView) {
        [self stop];
        self.isSmallFloatViewShow = NO;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
    }
}

- (void)stopCurrentPlayingCell {
    if (self.scrollView.mer_playingIndexPath) {
        [self stop];
        self.isSmallFloatViewShow = NO;
        self.playingIndexPath = nil;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
    }
}

#pragma mark - getter

- (NSURL *)assetURL {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSArray<NSURL *> *)assetURLs {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isLastAssetURL {
    if (self.assetURLs.count > 0) {
        return self.assetURL == self.assetURLs.lastObject;
    }
    return NO;
}

- (BOOL)isFirstAssetURL {
    if (self.assetURLs.count > 0) {
        return self.assetURL == self.assetURLs.firstObject;
    }
    return NO;
}

- (BOOL)isPauseByEvent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (float)brightness {
    return [UIScreen mainScreen].brightness;
}

- (float)volume {
    CGFloat volume = self.volumeViewSlider.value;
    if (volume == 0) {
        volume = [[AVAudioSession sharedInstance] outputVolume];
    }
    return volume;
}

- (BOOL)isMuted {
    return self.currentPlayerManager.isMuted;
}

- (float)lastVolumeValue {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (MercuryPlayerPlaybackState)playState {
    return self.currentPlayerManager.playState;
}

- (BOOL)isPlaying {
    return self.currentPlayerManager.isPlaying;
}

- (BOOL)pauseWhenAppResignActive {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.pauseWhenAppResignActive = YES;
    return YES;
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerPrepareToPlay {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerReadyToPlay {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSTimeInterval, NSTimeInterval))playerPlayTimeChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSTimeInterval))playerBufferTimeChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, MercuryPlayerPlaybackState))playerPlayStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, MercuryPlayerLoadState))playerLoadStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull))playerDidToEnd {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, id _Nonnull))playerPlayFailed {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, CGSize ))presentationSizeChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSInteger)currentPlayIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)isViewControllerDisappear {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)customAudioSession {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setAssetURL:(NSURL *)assetURL {
    objc_setAssociatedObject(self, @selector(assetURL), assetURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (!self.disableCache) {
        // 启用缓存
        NSError *error;
        if (![BY_HTTPCache proxyIsRunning]) {
            [BY_HTTPCache proxyStart:&error];
        }
        assetURL = [BY_HTTPCache proxyURLWithOriginalURL:assetURL];
        if (error) {
            
        }
    } else {
        [BY_HTTPCache proxyStop];
    }
    self.currentPlayerManager.assetURL = assetURL;
}

- (void)setAssetURLs:(NSArray<NSURL *> * _Nullable)assetURLs {
    objc_setAssociatedObject(self, @selector(assetURLs), assetURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setVolume:(float)volume {
    volume = MIN(MAX(0, volume), 1);
    objc_setAssociatedObject(self, @selector(volume), @(volume), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.volumeViewSlider.value = volume;
}

- (void)setMuted:(BOOL)muted {
//    if (muted) {
//        if (self.volumeViewSlider.value > 0) {
//            self.lastVolumeValue = self.volumeViewSlider.value;
//        }
//        self.volumeViewSlider.value = 0;
//    } else {
//        self.volumeViewSlider.value = self.lastVolumeValue;
//    }
    self.currentPlayerManager.muted = muted;
}

- (void)setLastVolumeValue:(float)lastVolumeValue {
    objc_setAssociatedObject(self, @selector(lastVolumeValue), @(lastVolumeValue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBrightness:(float)brightness {
    brightness = MIN(MAX(0, brightness), 1);
    objc_setAssociatedObject(self, @selector(brightness), @(brightness), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [UIScreen mainScreen].brightness = brightness;
}

- (void)setPauseByEvent:(BOOL)pauseByEvent {
    objc_setAssociatedObject(self, @selector(isPauseByEvent), @(pauseByEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (pauseByEvent) {
        [self.currentPlayerManager pause];
    } else {
        [self.currentPlayerManager play];
    }
}

- (void)setPauseWhenAppResignActive:(BOOL)pauseWhenAppResignActive {
    objc_setAssociatedObject(self, @selector(pauseWhenAppResignActive), @(pauseWhenAppResignActive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerPrepareToPlay:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerPrepareToPlay {
    objc_setAssociatedObject(self, @selector(playerPrepareToPlay), playerPrepareToPlay, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerReadyToPlay:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerReadyToPlay {
    objc_setAssociatedObject(self, @selector(playerReadyToPlay), playerReadyToPlay, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerPlayTimeChanged:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSTimeInterval, NSTimeInterval))playerPlayTimeChanged {
    objc_setAssociatedObject(self, @selector(playerPlayTimeChanged), playerPlayTimeChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerBufferTimeChanged:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, NSTimeInterval))playerBufferTimeChanged {
    objc_setAssociatedObject(self, @selector(playerBufferTimeChanged), playerBufferTimeChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerPlayStateChanged:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, MercuryPlayerPlaybackState))playerPlayStateChanged {
    objc_setAssociatedObject(self, @selector(playerPlayStateChanged), playerPlayStateChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerLoadStateChanged:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, MercuryPlayerLoadState))playerLoadStateChanged {
    objc_setAssociatedObject(self, @selector(playerLoadStateChanged), playerLoadStateChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerDidToEnd:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull))playerDidToEnd {
    objc_setAssociatedObject(self, @selector(playerDidToEnd), playerDidToEnd, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerPlayFailed:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, id _Nonnull))playerPlayFailed {
    objc_setAssociatedObject(self, @selector(playerPlayFailed), playerPlayFailed, OBJC_ASSOCIATION_COPY);
}

- (void)setPresentationSizeChanged:(void (^)(id<MercuryPlayerMediaPlayback> _Nonnull, CGSize))presentationSizeChanged {
    objc_setAssociatedObject(self, @selector(presentationSizeChanged), presentationSizeChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setCurrentPlayIndex:(NSInteger)currentPlayIndex {
    objc_setAssociatedObject(self, @selector(currentPlayIndex), @(currentPlayIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setViewControllerDisappear:(BOOL)viewControllerDisappear {
    objc_setAssociatedObject(self, @selector(isViewControllerDisappear), @(viewControllerDisappear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.scrollView) self.scrollView.mer_viewControllerDisappear = viewControllerDisappear;
    if (!self.currentPlayerManager.isPreparedToPlay) return;
    if (viewControllerDisappear) {
        [self removeDeviceOrientationObserver];
        if (self.currentPlayerManager.isPlaying) self.pauseByEvent = YES;
    } else {
        if (self.isPauseByEvent) self.pauseByEvent = NO;
        [self addDeviceOrientationObserver];
    }
}

- (void)setCustomAudioSession:(BOOL)customAudioSession {
    objc_setAssociatedObject(self, @selector(customAudioSession), @(customAudioSession), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation MercuryPlayerController (MercuryPlayerOrientationRotation)

- (void)addDeviceOrientationObserver {
    [self.orientationObserver addDeviceOrientationObserver];
}

- (void)removeDeviceOrientationObserver {
    [self.orientationObserver removeDeviceOrientationObserver];
}

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    self.orientationObserver.fullScreenMode = MercuryFullScreenModeLandscape;
    [self.orientationObserver enterLandscapeFullScreen:orientation animated:animated];
}

- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    self.orientationObserver.fullScreenMode = MercuryFullScreenModePortrait;
    [self.orientationObserver enterPortraitFullScreen:fullScreen animated:animated];
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    if (self.orientationObserver.fullScreenMode == MercuryFullScreenModePortrait) {
        [self.orientationObserver enterPortraitFullScreen:fullScreen animated:animated];
    } else {
        UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
        orientation = fullScreen? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
        [self.orientationObserver enterLandscapeFullScreen:orientation animated:animated];
    }
}

- (BOOL)shouldForceDeviceOrientation {
    return self.forceDeviceOrientation;
}

#pragma mark - getter

- (MercuryOrientationObserver *)orientationObserver {
    @weakify(self)
    MercuryOrientationObserver *orientationObserver = objc_getAssociatedObject(self, _cmd);
    if (!orientationObserver) {
        orientationObserver = [[MercuryOrientationObserver alloc] init];
        orientationObserver.orientationWillChange = ^(MercuryOrientationObserver * _Nonnull observer, BOOL isFullScreen) {
            @strongify(self)
            if (self.orientationWillChange) self.orientationWillChange(self, isFullScreen);
            if ([self.controlView respondsToSelector:@selector(videoPlayer:orientationWillChange:)]) {
                [self.controlView videoPlayer:self orientationWillChange:observer];
            }
            [self.controlView setNeedsLayout];
            [self.controlView layoutIfNeeded];
        };
        orientationObserver.orientationDidChanged = ^(MercuryOrientationObserver * _Nonnull observer, BOOL isFullScreen) {
            @strongify(self)
            if (self.orientationDidChanged) self.orientationDidChanged(self, isFullScreen);
            if ([self.controlView respondsToSelector:@selector(videoPlayer:orientationDidChanged:)]) {
                [self.controlView videoPlayer:self orientationDidChanged:observer];
            }
        };
        objc_setAssociatedObject(self, _cmd, orientationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return orientationObserver;
}

- (void (^)(MercuryPlayerController * _Nonnull, BOOL))orientationWillChange {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(MercuryPlayerController * _Nonnull, BOOL))orientationDidChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isFullScreen {
    return self.orientationObserver.isFullScreen;
}

- (BOOL)exitFullScreenWhenStop {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.exitFullScreenWhenStop = YES;
    return YES;
}

- (UIInterfaceOrientation)currentOrientation {
    return self.orientationObserver.currentOrientation;
}

- (BOOL)isStatusBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)shouldAutorotate {
    return [self shouldForceDeviceOrientation];
}

- (BOOL)allowOrentitaionRotation {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.allowOrentitaionRotation = YES;
    return YES;
}

- (BOOL)forceDeviceOrientation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setOrientationWillChange:(void (^)(MercuryPlayerController * _Nonnull, BOOL))orientationWillChange {
    objc_setAssociatedObject(self, @selector(orientationWillChange), orientationWillChange, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setOrientationDidChanged:(void (^)(MercuryPlayerController * _Nonnull, BOOL))orientationDidChanged {
    objc_setAssociatedObject(self, @selector(orientationDidChanged), orientationDidChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    objc_setAssociatedObject(self, @selector(isStatusBarHidden), @(statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.statusBarHidden = statusBarHidden;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.lockedScreen = lockedScreen;
    if ([self.controlView respondsToSelector:@selector(lockedVideoPlayer:lockedScreen:)]) {
        [self.controlView lockedVideoPlayer:self lockedScreen:lockedScreen];
    }
}

- (void)setAllowOrentitaionRotation:(BOOL)allowOrentitaionRotation {
    objc_setAssociatedObject(self, @selector(allowOrentitaionRotation), @(allowOrentitaionRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.allowOrentitaionRotation = allowOrentitaionRotation;
}

- (void)setForceDeviceOrientation:(BOOL)forceDeviceOrientation {
    objc_setAssociatedObject(self, @selector(forceDeviceOrientation), @(forceDeviceOrientation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.forceDeviceOrientation = forceDeviceOrientation;
}

- (void)setExitFullScreenWhenStop:(BOOL)exitFullScreenWhenStop {
    objc_setAssociatedObject(self, @selector(exitFullScreenWhenStop), @(exitFullScreenWhenStop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation MercuryPlayerController (MercuryPlayerViewGesture)

#pragma mark - getter

- (MercuryPlayerGestureControl *)gestureControl {
    MercuryPlayerGestureControl *gestureControl = objc_getAssociatedObject(self, _cmd);
    if (!gestureControl) {
        gestureControl = [[MercuryPlayerGestureControl alloc] init];
        @weakify(self)
        gestureControl.triggerCondition = ^BOOL(MercuryPlayerGestureControl * _Nonnull control, MercuryPlayerGestureType type, UIGestureRecognizer * _Nonnull gesture, UITouch *touch) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureTriggerCondition:gestureType:gestureRecognizer:touch:)]) {
                return [self.controlView gestureTriggerCondition:control gestureType:type gestureRecognizer:gesture touch:touch];
            }
            return YES;
        };
        
        gestureControl.singleTapped = ^(MercuryPlayerGestureControl * _Nonnull control) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureSingleTapped:)]) {
                [self.controlView gestureSingleTapped:control];
            }
        };
        
        gestureControl.doubleTapped = ^(MercuryPlayerGestureControl * _Nonnull control) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureDoubleTapped:)]) {
                [self.controlView gestureDoubleTapped:control];
            }
        };
        
        gestureControl.beganPan = ^(MercuryPlayerGestureControl * _Nonnull control, MercuryPanDirection direction, MercuryPanLocation location) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureBeganPan:panDirection:panLocation:)]) {
                [self.controlView gestureBeganPan:control panDirection:direction panLocation:location];
            }
        };
        
        gestureControl.changedPan = ^(MercuryPlayerGestureControl * _Nonnull control, MercuryPanDirection direction, MercuryPanLocation location, CGPoint velocity) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureChangedPan:panDirection:panLocation:withVelocity:)]) {
                [self.controlView gestureChangedPan:control panDirection:direction panLocation:location withVelocity:velocity];
            }
        };
        
        gestureControl.endedPan = ^(MercuryPlayerGestureControl * _Nonnull control, MercuryPanDirection direction, MercuryPanLocation location) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureEndedPan:panDirection:panLocation:)]) {
                [self.controlView gestureEndedPan:control panDirection:direction panLocation:location];
            }
        };
        
        gestureControl.pinched = ^(MercuryPlayerGestureControl * _Nonnull control, float scale) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gesturePinched:scale:)]) {
                [self.controlView gesturePinched:control scale:scale];
            }
        };
        objc_setAssociatedObject(self, _cmd, gestureControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gestureControl;
}

- (MercuryPlayerDisableGestureTypes)disableGestureTypes {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (MercuryPlayerDisablePanMovingDirection)disablePanMovingDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

#pragma mark - setter

- (void)setDisableGestureTypes:(MercuryPlayerDisableGestureTypes)disableGestureTypes {
    objc_setAssociatedObject(self, @selector(disableGestureTypes), @(disableGestureTypes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.gestureControl.disableTypes = disableGestureTypes;
}

- (void)setDisablePanMovingDirection:(MercuryPlayerDisablePanMovingDirection)disablePanMovingDirection {
    objc_setAssociatedObject(self, @selector(disablePanMovingDirection), @(disablePanMovingDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.gestureControl.disablePanMovingDirection = disablePanMovingDirection;
}

@end

@implementation MercuryPlayerController (MercuryPlayerScrollView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            NSSelectorFromString(@"dealloc")
        };
        
        for (NSInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"mer_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

- (void)mer_dealloc {
    [self.smallFloatView removeFromSuperview];
    self.smallFloatView = nil;
    [self mer_dealloc];
}

#pragma mark - setter

- (void)setScrollView:(UIScrollView *)scrollView {
    objc_setAssociatedObject(self, @selector(scrollView), scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.mer_WWANAutoPlay = self.isWWANAutoPlay;
    @weakify(self)
    scrollView.mer_playerWillAppearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.mer_playerWillAppearInScrollView) self.mer_playerWillAppearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerDidAppearInScrollView:)]) {
            [self.controlView playerDidAppearInScrollView:self];
        }
    };
    
    scrollView.mer_playerDidAppearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.mer_playerDidAppearInScrollView) self.mer_playerDidAppearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerDidAppearInScrollView:)]) {
            [self.controlView playerDidAppearInScrollView:self];
        }
    };
    
    scrollView.mer_playerWillDisappearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.mer_playerWillDisappearInScrollView) self.mer_playerWillDisappearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerWillDisappearInScrollView:)]) {
            [self.controlView playerWillDisappearInScrollView:self];
        }
    };
    
    scrollView.mer_playerDidDisappearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.mer_playerDidDisappearInScrollView) self.mer_playerDidDisappearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerDidDisappearInScrollView:)]) {
            [self.controlView playerDidDisappearInScrollView:self];
        }
    };
    
    scrollView.mer_playerAppearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerApperaPercent) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.mer_playerAppearingInScrollView) self.mer_playerAppearingInScrollView(indexPath, playerApperaPercent);
        if ([self.controlView respondsToSelector:@selector(playerAppearingInScrollView:playerApperaPercent:)]) {
            [self.controlView playerAppearingInScrollView:self playerApperaPercent:playerApperaPercent];
        }
        if (!self.stopWhileNotVisible && playerApperaPercent >= self.playerApperaPercent) {
            if (self.containerType == MercuryPlayerContainerTypeView) {
                [self addPlayerViewToContainerView:self.containerView];
            } else if (self.containerType == MercuryPlayerContainerTypeCell) {
                [self addPlayerViewToCell];
            }
        }
    };
    
    scrollView.mer_playerDisappearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerDisapperaPercent) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.mer_playerDisappearingInScrollView) self.mer_playerDisappearingInScrollView(indexPath, playerDisapperaPercent);
        if ([self.controlView respondsToSelector:@selector(playerDisappearingInScrollView:playerDisapperaPercent:)]) {
            [self.controlView playerDisappearingInScrollView:self playerDisapperaPercent:playerDisapperaPercent];
        }
        /// stop playing
        if (self.stopWhileNotVisible && playerDisapperaPercent >= self.playerDisapperaPercent) {
            if (self.containerType == MercuryPlayerContainerTypeView) {
                [self stopCurrentPlayingView];
            } else if (self.containerType == MercuryPlayerContainerTypeCell) {
                [self stopCurrentPlayingCell];
            }
        }
        /// add to window
        if (!self.stopWhileNotVisible && playerDisapperaPercent >= self.playerDisapperaPercent) [self addPlayerViewToKeyWindow];
    };
    
    scrollView.mer_playerShouldPlayInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.mer_playerShouldPlayInScrollView) self.mer_playerShouldPlayInScrollView(indexPath);
    };
    
    scrollView.mer_scrollViewDidEndScrollingCallback = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.mer_scrollViewDidEndScrollingCallback) self.mer_scrollViewDidEndScrollingCallback(indexPath);
    };
}

- (void)setWWANAutoPlay:(BOOL)WWANAutoPlay {
    objc_setAssociatedObject(self, @selector(isWWANAutoPlay), @(WWANAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.scrollView) self.scrollView.mer_WWANAutoPlay = self.isWWANAutoPlay;
}

- (void)setStopWhileNotVisible:(BOOL)stopWhileNotVisible {
    self.scrollView.mer_stopWhileNotVisible = stopWhileNotVisible;
    objc_setAssociatedObject(self, @selector(stopWhileNotVisible), @(stopWhileNotVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setContainerViewTag:(NSInteger)containerViewTag {
    objc_setAssociatedObject(self, @selector(containerViewTag), @(containerViewTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.mer_containerViewTag = containerViewTag;
}

- (void)setPlayingIndexPath:(NSIndexPath *)playingIndexPath {
    objc_setAssociatedObject(self, @selector(playingIndexPath), playingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (playingIndexPath) {
        // Stop the current playing cell video.
        [self stop];
        self.isSmallFloatViewShow = NO;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
        
        UIView *cell = [self.scrollView mer_getCellForIndexPath:playingIndexPath];
        self.containerView = [cell viewWithTag:self.containerViewTag];
        [self.orientationObserver cellModelRotateView:self.currentPlayerManager.view rotateViewAtCell:cell playerViewTag:self.containerViewTag];
        [self addDeviceOrientationObserver];
        self.scrollView.mer_playingIndexPath = playingIndexPath;
        [self layoutPlayerSubViews];
    } else {
        self.scrollView.mer_playingIndexPath = playingIndexPath;
    }
}

- (void)setShouldAutoPlay:(BOOL)shouldAutoPlay {
    objc_setAssociatedObject(self, @selector(shouldAutoPlay), @(shouldAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.mer_shouldAutoPlay = shouldAutoPlay;
}

- (void)setSectionAssetURLs:(NSArray<NSArray<NSURL *> *> * _Nullable)sectionAssetURLs {
    objc_setAssociatedObject(self, @selector(sectionAssetURLs), sectionAssetURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerDisapperaPercent:(CGFloat)playerDisapperaPercent {
    playerDisapperaPercent = MIN(MAX(0.0, playerDisapperaPercent), 1.0);
    self.scrollView.mer_playerDisapperaPercent = playerDisapperaPercent;
    objc_setAssociatedObject(self, @selector(playerDisapperaPercent), @(playerDisapperaPercent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerApperaPercent:(CGFloat)playerApperaPercent {
    playerApperaPercent = MIN(MAX(0.0, playerApperaPercent), 1.0);
    self.scrollView.mer_playerApperaPercent = playerApperaPercent;
    objc_setAssociatedObject(self, @selector(playerApperaPercent), @(playerApperaPercent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setMer_playerAppearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerAppearingInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerAppearingInScrollView), mer_playerAppearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerDisappearingInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerDisappearingInScrollView), mer_playerDisappearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerDidAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerDidAppearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerDidAppearInScrollView), mer_playerDidAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerWillDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerWillDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerWillDisappearInScrollView), mer_playerWillDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerWillAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerWillAppearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerWillAppearInScrollView), mer_playerWillAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerDidDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerDidDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerDidDisappearInScrollView), mer_playerDidDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_playerShouldPlayInScrollView:(void (^)(NSIndexPath * _Nonnull))mer_playerShouldPlayInScrollView {
    objc_setAssociatedObject(self, @selector(mer_playerShouldPlayInScrollView), mer_playerShouldPlayInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setMer_scrollViewDidEndScrollingCallback:(void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidEndScrollingCallback {
    objc_setAssociatedObject(self, @selector(mer_scrollViewDidEndScrollingCallback), mer_scrollViewDidEndScrollingCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - getter

- (UIScrollView *)scrollView {
    UIScrollView *scrollView = objc_getAssociatedObject(self, _cmd);
    return scrollView;
}

- (BOOL)isWWANAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)stopWhileNotVisible {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.stopWhileNotVisible = YES;
    return YES;
}

- (NSInteger)containerViewTag {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (NSIndexPath *)playingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSIndexPath *)shouldPlayIndexPath {
    return self.scrollView.mer_shouldPlayIndexPath;
}

- (NSArray<NSArray<NSURL *> *> *)sectionAssetURLs {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)shouldAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (CGFloat)playerDisapperaPercent {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.floatValue;
    self.playerDisapperaPercent = 0.5;
    return 0.5;
}

- (CGFloat)playerApperaPercent {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.floatValue;
    self.playerApperaPercent = 0.0;
    return 0.0;
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerAppearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))mer_playerDisappearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerDidAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerWillDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerWillAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerDidDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_playerShouldPlayInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))mer_scrollViewDidEndScrollingCallback {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Public method

- (void)mer_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    [self.scrollView mer_filterShouldPlayCellWhileScrolled:handler];
}

- (void)mer_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    [self.scrollView mer_filterShouldPlayCellWhileScrolling:handler];
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath {
    self.playingIndexPath = indexPath;
    NSURL *assetURL;
    if (self.sectionAssetURLs.count) {
        assetURL = self.sectionAssetURLs[indexPath.section][indexPath.row];
    } else if (self.assetURLs.count) {
        assetURL = self.assetURLs[indexPath.row];
        self.currentPlayIndex = indexPath.row;
    }
    self.assetURL = assetURL;
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop completionHandler:(void (^ _Nullable)(void))completionHandler {
    NSURL *assetURL;
    if (self.sectionAssetURLs.count) {
        assetURL = self.sectionAssetURLs[indexPath.section][indexPath.row];
    } else if (self.assetURLs.count) {
        assetURL = self.assetURLs[indexPath.row];
        self.currentPlayIndex = indexPath.row;
    }
    if (scrollToTop) {
        @weakify(self)
        [self.scrollView mer_scrollToRowAtIndexPath:indexPath completionHandler:^{
            @strongify(self)
            if (completionHandler) completionHandler();
            self.playingIndexPath = indexPath;
            self.assetURL = assetURL;
        }];
    } else {
        if (completionHandler) completionHandler();
        self.playingIndexPath = indexPath;
        self.assetURL = assetURL;
    }
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    if ([indexPath compare:self.playingIndexPath] == NSOrderedSame) return;
    if (scrollToTop) {
        @weakify(self)
        [self.scrollView mer_scrollToRowAtIndexPath:indexPath completionHandler:^{
            @strongify(self)
            [self playTheIndexPath:indexPath];
        }];
    } else {
        [self playTheIndexPath:indexPath];
    }
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath assetURL:(NSURL *)assetURL scrollToTop:(BOOL)scrollToTop {
    self.playingIndexPath = indexPath;
    self.assetURL = assetURL;
    if (scrollToTop) {
        [self.scrollView mer_scrollToRowAtIndexPath:indexPath completionHandler:nil];
    }
}

@end

@implementation MercuryPlayerController (MercuryPlayerDeprecated)

- (void)updateScrollViewPlayerToCell {
    if (self.currentPlayerManager.view && self.playingIndexPath && self.containerViewTag) {
        UIView *cell = [self.scrollView mer_getCellForIndexPath:self.playingIndexPath];
        self.containerView = [cell viewWithTag:self.containerViewTag];
        [self.orientationObserver cellModelRotateView:self.currentPlayerManager.view rotateViewAtCell:cell playerViewTag:self.containerViewTag];
        [self layoutPlayerSubViews];
    }
}

- (void)updateNoramlPlayerWithContainerView:(UIView *)containerView {
    if (self.currentPlayerManager.view && self.containerView) {
        self.containerView = containerView;
        [self.orientationObserver cellOtherModelRotateView:self.currentPlayerManager.view containerView:self.containerView];
        [self layoutPlayerSubViews];
    }
}

@end

//
//  MercuryPlayerController.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MercuryPlayerMediaPlayback.h"
#import "MercuryOrientationObserver.h"
#import "MercuryPlayerMediaControl.h"
#import "MercuryPlayerGestureControl.h"
#import "MercuryPlayerNotification.h"
#import "MercuryFloatView.h"
#import "UIScrollView+MercuryPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryPlayerController : NSObject

/// The video contrainerView in normal model.
@property (nonatomic, strong) UIView *containerView;

/// The currentPlayerManager must conform `MercuryPlayerMediaPlayback` protocol.
@property (nonatomic, strong) id<MercuryPlayerMediaPlayback> currentPlayerManager;

/// The custom controlView must conform `MercuryPlayerMediaControl` protocol.
@property (nonatomic, strong) UIView<MercuryPlayerMediaControl> *controlView;

/// The notification manager class.
@property (nonatomic, strong, readonly) MercuryPlayerNotification *notification;

/// The container view type.
@property (nonatomic, assign, readonly) MercuryPlayerContainerType containerType;

/// The player's small container view.
@property (nonatomic, strong, readonly) MercuryFloatView *smallFloatView;

/// Whether the small window is displayed.
@property (nonatomic, assign, readonly) BOOL isSmallFloatViewShow;

/// don't use cache, default: NO
@property (nonatomic, assign) BOOL disableCache;

/*!
 @method            playerWithPlayerManager:containerView:
 @abstract          Create an MercuryPlayerController that plays a single audiovisual item.
 @param             playerManager must conform `MercuryPlayerMediaPlayback` protocol.
 @param             containerView to see the video frames must set the contrainerView.
 @result            An instance of MercuryPlayerController.
 */
+ (instancetype)playerWithPlayerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView;

/*!
 @method            initWithPlayerManager:containerView:
 @abstract          Create an MercuryPlayerController that plays a single audiovisual item.
 @param             playerManager must conform `MercuryPlayerMediaPlayback` protocol.
 @param             containerView to see the video frames must set the contrainerView.
 @result            An instance of MercuryPlayerController.
 */
- (instancetype)initWithPlayerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView;

/*!
 @method            playerWithScrollView:playerManager:containerViewTag:
 @abstract          Create an MercuryPlayerController that plays a single audiovisual item. Use in `UITableView` or `UICollectionView`.
 @param             scrollView is `tableView` or `collectionView`.
 @param             playerManager must conform `MercuryPlayerMediaPlayback` protocol.
 @param             containerViewTag to see the video at scrollView must set the contrainerViewTag.
 @result            An instance of MercuryPlayerController.
 */
+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag;

/*!
 @method            initWithScrollView:playerManager:containerViewTag:
 @abstract          Create an MercuryPlayerController that plays a single audiovisual item. Use in `UITableView` or `UICollectionView`.
 @param             scrollView is `tableView` or `collectionView`.
 @param             playerManager must conform `MercuryPlayerMediaPlayback` protocol.
 @param             containerViewTag to see the video at scrollView must set the contrainerViewTag.
 @result            An instance of MercuryPlayerController.
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag;

/*!
 @method            playerWithScrollView:playerManager:containerView:
 @abstract          Create an MercuryPlayerController that plays a single audiovisual item. Use in `UIScrollView`.
 @param             playerManager must conform `MercuryPlayerMediaPlayback` protocol.
 @param             containerView to see the video at the scrollView.
 @result            An instance of MercuryPlayerController.
 */
+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView;

/*!
 @method            initWithScrollView:playerManager:containerView:
 @abstract          Create an MercuryPlayerController that plays a single audiovisual item. Use in `UIScrollView`.
 @param             playerManager must conform `MercuryPlayerMediaPlayback` protocol.
 @param             containerView to see the video at the scrollView.
 @result            An instance of MercuryPlayerController.
 */
- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<MercuryPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView;

@end

@interface MercuryPlayerController (MercuryPlayerTimeControl)

/// The player current play time.
@property (nonatomic, readonly) NSTimeInterval currentTime;

/// The player total time.
@property (nonatomic, readonly) NSTimeInterval totalTime;

/// The player buffer time.
@property (nonatomic, readonly) NSTimeInterval bufferTime;

/// The player progress, 0...1
@property (nonatomic, readonly) float progress;

/// The player bufferProgress, 0...1
@property (nonatomic, readonly) float bufferProgress;

/**
 Use this method to seek to a specified time for the current player and to be notified when the seek operation is complete.

 @param time seek time.
 @param completionHandler completion handler.
 */
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end

@interface MercuryPlayerController (MercuryPlayerPlaybackControl)

/// 0...1.0
/// Only affects audio volume for the device instance and not for the player.
/// You can change device volume or player volume as needed,change the player volume you can conform the `MercuryPlayerMediaPlayback` protocol.
@property (nonatomic) float volume;

/// The device muted.
/// Only affects audio muting for the device instance and not for the player.
/// You can change device mute or player mute as needed,change the player mute you can conform the `MercuryPlayerMediaPlayback` protocol.
@property (nonatomic, getter=isMuted) BOOL muted;

// 0...1.0, where 1.0 is maximum brightness. Only supported by main screen.
@property (nonatomic) float brightness;

/// The play asset URL.
@property (nonatomic) NSURL *assetURL;

/// If tableView or collectionView has only one section , use `assetURLs`.
/// If tableView or collectionView has more sections , use `sectionAssetURLs`.
/// Set this you can use `playTheNext` `playThePrevious` `playTheIndex:` method.
@property (nonatomic, copy, nullable) NSArray <NSURL *>*assetURLs;

/// The currently playing index,limited to one-dimensional arrays.
@property (nonatomic) NSInteger currentPlayIndex;

/// is the last asset URL in `assetURLs`.
@property (nonatomic, readonly) BOOL isLastAssetURL;

/// is the first asset URL in `assetURLs`.
@property (nonatomic, readonly) BOOL isFirstAssetURL;

/// If Yes, player will be called pause method When Received `UIApplicationWillResignActiveNotification` notification.
/// default is YES.
@property (nonatomic) BOOL pauseWhenAppResignActive;

/// When the player is playing, it is paused by some event,not by user click to pause.
/// For example, when the player is playing, application goes into the background or pushed to another viewController
@property (nonatomic, getter=isPauseByEvent) BOOL pauseByEvent;

/// The current player controller is disappear, not dealloc
@property (nonatomic, getter=isViewControllerDisappear) BOOL viewControllerDisappear;

/// You can custom the AVAudioSession,
/// default is NO.
@property (nonatomic, assign) BOOL customAudioSession;

/// The block invoked when the player is Prepare to play.
@property (nonatomic, copy, nullable) void(^playerPrepareToPlay)(id<MercuryPlayerMediaPlayback> asset, NSURL *assetURL);

/// The block invoked when the player is Ready to play.
@property (nonatomic, copy, nullable) void(^playerReadyToPlay)(id<MercuryPlayerMediaPlayback> asset, NSURL *assetURL);

/// The block invoked when the player play progress changed.
@property (nonatomic, copy, nullable) void(^playerPlayTimeChanged)(id<MercuryPlayerMediaPlayback> asset, NSTimeInterval currentTime, NSTimeInterval duration);

/// The block invoked when the player play buffer changed.
@property (nonatomic, copy, nullable) void(^playerBufferTimeChanged)(id<MercuryPlayerMediaPlayback> asset, NSTimeInterval bufferTime);

/// The block invoked when the player playback state changed.
@property (nonatomic, copy, nullable) void(^playerPlayStateChanged)(id<MercuryPlayerMediaPlayback> asset, MercuryPlayerPlaybackState playState);

/// The block invoked when the player load state changed.
@property (nonatomic, copy, nullable) void(^playerLoadStateChanged)(id<MercuryPlayerMediaPlayback> asset, MercuryPlayerLoadState loadState);

/// The block invoked when the player play failed.
@property (nonatomic, copy, nullable) void(^playerPlayFailed)(id<MercuryPlayerMediaPlayback> asset, id error);

/// The block invoked when the player play end.
@property (nonatomic, copy, nullable) void(^playerDidToEnd)(id<MercuryPlayerMediaPlayback> asset);

// The block invoked when video size changed.
@property (nonatomic, copy, nullable) void(^presentationSizeChanged)(id<MercuryPlayerMediaPlayback> asset, CGSize size);

/**
 Play the next url ,while the `assetURLs` is not NULL.
 */
- (void)playTheNext;

/**
  Play the previous url ,while the `assetURLs` is not NULL.
 */
- (void)playThePrevious;

/**
 Play the index of url ,while the `assetURLs` is not NULL.

 @param index play the index.
 */
- (void)playTheIndex:(NSInteger)index;

/**
 Player stop and playerView remove from super view,remove other notification.
 */
- (void)stop;

/*!
 @method           replaceCurrentPlayerManager:
 @abstract         Replaces the player's current playeranager with the specified player item.
 @param            manager must conform `MercuryPlayerMediaPlayback` protocol
 @discussion       The playerManager that will become the player's current playeranager.
 */
- (void)replaceCurrentPlayerManager:(id<MercuryPlayerMediaPlayback>)manager;

/**
 Add video to the cell.
 */
- (void)addPlayerViewToCell;

/**
 Add video to the container view.
 */
- (void)addPlayerViewToContainerView:(UIView *)containerView;

/**
 Add to the keyWindow.
 */
- (void)addPlayerViewToKeyWindow;

/**
 Stop the current playing video and remove the playerView.
 */
- (void)stopCurrentPlayingView;

/**
 stop the current playing video on cell.
 */
- (void)stopCurrentPlayingCell;

@end

@interface MercuryPlayerController (MercuryPlayerOrientationRotation)

@property (nonatomic, readonly) MercuryOrientationObserver *orientationObserver;

/// Whether automatic screen rotation is supported.
/// iOS8.1~iOS8.3 the value is YES, other iOS version the value is NO.
/// This property is used for the return value of UIViewController `shouldAutorotate` method.
@property (nonatomic, readonly) BOOL shouldAutorotate;

/// Whether allow the video orientation rotate.
/// default is YES.
@property (nonatomic) BOOL allowOrentitaionRotation;

/// When MercuryFullScreenMode is MercuryFullScreenModeLandscape the orientation is LandscapeLeft or LandscapeRight, this value is YES.
/// When MercuryFullScreenMode is MercuryFullScreenModePortrait, while the player fullSceen this value is YES.
@property (nonatomic, readonly) BOOL isFullScreen;

/// when call the `stop` method, exit the fullScreen model, default is YES.
@property (nonatomic, assign) BOOL exitFullScreenWhenStop;

/// Lock the screen orientation.
@property (nonatomic, getter=isLockedScreen) BOOL lockedScreen;

/// The statusbar hidden.
@property (nonatomic, getter=isStatusBarHidden) BOOL statusBarHidden;

/// Use device orientation, default NO.
@property (nonatomic, assign) BOOL forceDeviceOrientation;

/// The current orientation of the player.
/// Default is UIInterfaceOrientationPortrait.
@property (nonatomic, readonly) UIInterfaceOrientation currentOrientation;

/// The block invoked When player will rotate.
@property (nonatomic, copy, nullable) void(^orientationWillChange)(MercuryPlayerController *player, BOOL isFullScreen);

/// The block invoked when player rotated.
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(MercuryPlayerController *player, BOOL isFullScreen);

/**
 Add the device orientation observer.
 */
- (void)addDeviceOrientationObserver;

/**
 Remove the device orientation observer.
 */
- (void)removeDeviceOrientationObserver;

/**
 Enter the fullScreen while the MercuryFullScreenMode is MercuryFullScreenModeLandscape.

 @param orientation UIInterfaceOrientation
 @param animated is animated.
 */
- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/**
 Enter the fullScreen while the MercuryFullScreenMode is MercuryFullScreenModePortrait.

 @param fullScreen is fullscreen.
 @param animated is animated.
 */
- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated;

/**
 FullScreen mode is determined by MercuryFullScreenMode.

 @param fullScreen is fullscreen.
 @param animated is animated.
 */
- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated;

@end

@interface MercuryPlayerController (MercuryPlayerViewGesture)

/// An instance of MercuryPlayerGestureControl.
@property (nonatomic, readonly) MercuryPlayerGestureControl *gestureControl;

/// The gesture types that the player not support.
@property (nonatomic, assign) MercuryPlayerDisableGestureTypes disableGestureTypes;

/// The pan gesture moving direction that the player not support.
@property (nonatomic) MercuryPlayerDisablePanMovingDirection disablePanMovingDirection;

@end

@interface MercuryPlayerController (MercuryPlayerScrollView)

/// The scroll view is `tableView` or `collectionView`.
@property (nonatomic, readonly, nullable) UIScrollView *scrollView;

/// The scrollView player should auto player, default is YES.
@property (nonatomic) BOOL shouldAutoPlay;

/// WWAN network auto play, only support in scrollView mode when the `shouldAutoPlay` is YES, default is NO.
@property (nonatomic, getter=isWWANAutoPlay) BOOL WWANAutoPlay;

/// The indexPath is playing.
@property (nonatomic, readonly, nullable) NSIndexPath *playingIndexPath;

/// The indexPath should be play while scrolling.
@property (nonatomic, readonly, nullable) NSIndexPath *shouldPlayIndexPath;

/// The view tag that the player display in scrollView.
@property (nonatomic, readonly) NSInteger containerViewTag;

/// The current playing cell stop playing when the cell has out off the screen，defalut is YES.
@property (nonatomic) BOOL stopWhileNotVisible;

/**
 The current player scroll slides off the screen percent.
 the property used when the `stopWhileNotVisible` is YES, stop the current playing player.
 the property used when the `stopWhileNotVisible` is NO, the current playing player add to small container view.
 The range is 0.0~1.0, defalut is 0.5.
 0.0 is the player will disappear.
 1.0 is the player did disappear.
 */
@property (nonatomic) CGFloat playerDisapperaPercent;

/**
 The current player scroll to the screen percent to play the video.
 The range is 0.0~1.0, defalut is 0.0.
 0.0 is the player will appear.
 1.0 is the player did appear.
 */
@property (nonatomic) CGFloat playerApperaPercent;

/// If tableView or collectionView has more sections, use `sectionAssetURLs`.
@property (nonatomic, copy, nullable) NSArray <NSArray <NSURL *>*>*sectionAssetURLs;

/// The block invoked When the player appearing.
@property (nonatomic, copy, nullable) void(^mer_playerAppearingInScrollView)(NSIndexPath *indexPath, CGFloat playerApperaPercent);

/// The block invoked When the player disappearing.
@property (nonatomic, copy, nullable) void(^mer_playerDisappearingInScrollView)(NSIndexPath *indexPath, CGFloat playerDisapperaPercent);

/// The block invoked When the player will appeared.
@property (nonatomic, copy, nullable) void(^mer_playerWillAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did appeared.
@property (nonatomic, copy, nullable) void(^mer_playerDidAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player will disappear.
@property (nonatomic, copy, nullable) void(^mer_playerWillDisappearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did disappeared.
@property (nonatomic, copy, nullable) void(^mer_playerDidDisappearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player should play.
@property (nonatomic, copy, nullable) void(^mer_playerShouldPlayInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did stop scroll.
@property (nonatomic, copy, nullable) void(^mer_scrollViewDidEndScrollingCallback)(NSIndexPath *indexPath);

/// Filter the cell that should be played when the scroll is stopped (to play when the scroll is stopped).
- (void)mer_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// Filter the cell that should be played while scrolling (you can use this to filter the highlighted cell).
- (void)mer_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/**
 Play the indexPath of url, while the `assetURLs` or `sectionAssetURLs` is not NULL.

 @param indexPath Play the indexPath of url.
 */
- (void)playTheIndexPath:(NSIndexPath *)indexPath;

/**
 Play the indexPath of url ,while the `assetURLs` or `sectionAssetURLs` is not NULL.
 
 @param indexPath Play the indexPath of url
 @param scrollToTop Scroll the current cell to top with animations.
 */
- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop;

/**
 Play the indexPath of url ,while the `assetURLs` or `sectionAssetURLs` is not NULL.
 
 @param indexPath Play the indexPath of url
 @param assetURL The player URL.
 @param scrollToTop Scroll the current cell to top with animations.
 */
- (void)playTheIndexPath:(NSIndexPath *)indexPath assetURL:(NSURL *)assetURL scrollToTop:(BOOL)scrollToTop;

/**
 Play the indexPath of url ,while the `assetURLs` or `sectionAssetURLs` is not NULL.
 
 @param indexPath Play the indexPath of url
 @param scrollToTop scroll the current cell to top with animations.
 @param completionHandler Scroll completion callback.
 */
- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop completionHandler:(void (^ __nullable)(void))completionHandler;

@end

@interface MercuryPlayerController (MercuryPlayerDeprecated)

/**
 Add the playerView to cell.
 */
- (void)updateScrollViewPlayerToCell  __attribute__((deprecated("use `addPlayerViewToCell:` instead.")));

/**
 Add the playerView to containerView.
 
 @param containerView The playerView containerView.
 */
- (void)updateNoramlPlayerWithContainerView:(UIView *)containerView __attribute__((deprecated("use `addPlayerViewToContainerView:` instead.")));

@end

NS_ASSUME_NONNULL_END

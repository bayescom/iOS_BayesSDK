//
//  MercuryPlayerMediaControl.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <Foundation/Foundation.h>
#import "MercuryPlayerMediaPlayback.h"
#import "MercuryOrientationObserver.h"
#import "MercuryPlayerGestureControl.h"
#import "MercuryReachabilityManager.h"
@class MercuryPlayerController;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryPlayerMediaControl <NSObject>

@required
/// Current playerController
@property (nonatomic, weak) MercuryPlayerController *player;

@optional

#pragma mark - Playback state

/// When the player prepare to play the video.
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL;

/// When th player playback state changed.
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer playStateChanged:(MercuryPlayerPlaybackState)state;

/// When th player loading state changed.
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer loadStateChanged:(MercuryPlayerLoadState)state;

#pragma mark - progress

/**
 When the playback changed.
 
 @param videoPlayer the player.
 @param currentTime the current play time.
 @param totalTime the video total time.
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer
        currentTime:(NSTimeInterval)currentTime
          totalTime:(NSTimeInterval)totalTime;

/**
 When buffer progress changed.
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer
         bufferTime:(NSTimeInterval)bufferTime;

/**
 When you are dragging to change the video progress.
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer
       draggingTime:(NSTimeInterval)seekTime
          totalTime:(NSTimeInterval)totalTime;

/**
 When play end.
 */
- (void)videoPlayerPlayEnd:(MercuryPlayerController *)videoPlayer;

/**
 When play failed.
 */
- (void)videoPlayerPlayFailed:(MercuryPlayerController *)videoPlayer error:(id)error;

#pragma mark - lock screen

/**
 When set `videoPlayer.lockedScreen`.
 */
- (void)lockedVideoPlayer:(MercuryPlayerController *)videoPlayer lockedScreen:(BOOL)locked;

#pragma mark - Screen rotation

/**
 When the fullScreen maode will changed.
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer orientationWillChange:(MercuryOrientationObserver *)observer;

/**
 When the fullScreen maode did changed.
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer orientationDidChanged:(MercuryOrientationObserver *)observer;

#pragma mark - The network changed

/**
 When the network changed
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer reachabilityChanged:(MercuryReachabilityStatus)status;

#pragma mark - The video size changed

/**
 When the video size changed
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size;

#pragma mark - Gesture

/**
 When the gesture condition
 */
- (BOOL)gestureTriggerCondition:(MercuryPlayerGestureControl *)gestureControl
                    gestureType:(MercuryPlayerGestureType)gestureType
              gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                          touch:(UITouch *)touch;

/**
 When the gesture single tapped
 */
- (void)gestureSingleTapped:(MercuryPlayerGestureControl *)gestureControl;

/**
 When the gesture double tapped
 */
- (void)gestureDoubleTapped:(MercuryPlayerGestureControl *)gestureControl;

/**
 When the gesture begin panGesture
 */
- (void)gestureBeganPan:(MercuryPlayerGestureControl *)gestureControl
           panDirection:(MercuryPanDirection)direction
            panLocation:(MercuryPanLocation)location;

/**
 When the gesture paning
 */
- (void)gestureChangedPan:(MercuryPlayerGestureControl *)gestureControl
             panDirection:(MercuryPanDirection)direction
              panLocation:(MercuryPanLocation)location
             withVelocity:(CGPoint)velocity;

/**
 When the end panGesture
 */
- (void)gestureEndedPan:(MercuryPlayerGestureControl *)gestureControl
           panDirection:(MercuryPanDirection)direction
            panLocation:(MercuryPanLocation)location;

/**
 When the pinchGesture changed
 */
- (void)gesturePinched:(MercuryPlayerGestureControl *)gestureControl
                 scale:(float)scale;

#pragma mark - scrollview

/**
 When the player will appear in scrollView.
 */
- (void)playerWillAppearInScrollView:(MercuryPlayerController *)videoPlayer;

/**
 When the player did appear in scrollView.
 */
- (void)playerDidAppearInScrollView:(MercuryPlayerController *)videoPlayer;

/**
 When the player will disappear in scrollView.
 */
- (void)playerWillDisappearInScrollView:(MercuryPlayerController *)videoPlayer;

/**
 When the player did disappear in scrollView.
 */
- (void)playerDidDisappearInScrollView:(MercuryPlayerController *)videoPlayer;

/**
 When the player appearing in scrollView.
 */
- (void)playerAppearingInScrollView:(MercuryPlayerController *)videoPlayer playerApperaPercent:(CGFloat)playerApperaPercent;

/**
 When the player disappearing in scrollView.
 */
- (void)playerDisappearingInScrollView:(MercuryPlayerController *)videoPlayer playerDisapperaPercent:(CGFloat)playerDisapperaPercent;

/**
 When the small float view show.
 */
- (void)videoPlayer:(MercuryPlayerController *)videoPlayer floatViewShow:(BOOL)show;

@end

NS_ASSUME_NONNULL_END


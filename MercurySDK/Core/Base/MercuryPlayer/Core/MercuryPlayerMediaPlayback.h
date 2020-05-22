//
//  MercuryMediaPlayback.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <Foundation/Foundation.h>
#import "MercuryPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MercuryPlayerPlaybackState) {
    MercuryPlayerPlayStateUnknown,
    MercuryPlayerPlayStatePlaying,
    MercuryPlayerPlayStatePaused,
    MercuryPlayerPlayStatePlayFailed,
    MercuryPlayerPlayStatePlayStopped
};

typedef NS_OPTIONS(NSUInteger, MercuryPlayerLoadState) {
    MercuryPlayerLoadStateUnknown        = 0,
    MercuryPlayerLoadStatePrepare        = 1 << 0,
    MercuryPlayerLoadStatePlayable       = 1 << 1,
    MercuryPlayerLoadStatePlaythroughOK  = 1 << 2, // Playback will be automatically started.
    MercuryPlayerLoadStateStalled        = 1 << 3, // Playback will be automatically paused in this state, if started.
};

typedef NS_ENUM(NSInteger, MercuryPlayerScalingMode) {
    MercuryPlayerScalingModeNone,       // No scaling.
    MercuryPlayerScalingModeAspectFit,  // Uniform scale until one dimension fits.
    MercuryPlayerScalingModeAspectFill, // Uniform scale until the movie fills the visible bounds. One dimension may have clipped contents.
    MercuryPlayerScalingModeFill        // Non-uniform scale. Both render dimensions will exactly match the visible bounds.
};

@protocol MercuryPlayerMediaPlayback <NSObject>

@required
/// The view must inherited `MercuryPlayerView`,this view deals with some gesture conflicts.
@property (nonatomic) MercuryPlayerView *view;

@optional
/// The player volume.
/// Only affects audio volume for the player instance and not for the device.
/// You can change device volume or player volume as needed,change the player volume you can folllow the `MercuryPlayerMediaPlayback` protocol.
@property (nonatomic) float volume;

/// The player muted.
/// indicates whether or not audio output of the player is muted. Only affects audio muting for the player instance and not for the device.
/// You can change device volume or player muted as needed,change the player muted you can folllow the `MercuryPlayerMediaPlayback` protocol.
@property (nonatomic, getter=isMuted) BOOL muted;

/// Playback speed,0.5...2
@property (nonatomic) float rate;

/// The player current play time.
@property (nonatomic, readonly) NSTimeInterval currentTime;

/// The player total time.
@property (nonatomic, readonly) NSTimeInterval totalTime;

/// The player buffer time.
@property (nonatomic, readonly) NSTimeInterval bufferTime;

/// The player seek time.
@property (nonatomic) NSTimeInterval seekTime;

/// The player play state,playing or not playing.
@property (nonatomic, readonly) BOOL isPlaying;

/// Determines how the content scales to fit the view. Defaults to MercuryPlayerScalingModeNone.
@property (nonatomic) MercuryPlayerScalingMode scalingMode;

/**
 @abstract Check whether video preparation is complete.
 @discussion isPreparedToPlay processing logic
 
 * If isPreparedToPlay is true, you can call [MercuryPlayerMediaPlayback play] API start playing;
 * If isPreparedToPlay to false, direct call [MercuryPlayerMediaPlayback play], in the play the internal automatic call [MercuryPlayerMediaPlayback prepareToPlay] API.
 * Returns true if prepared for playback.
 */
@property (nonatomic, readonly) BOOL isPreparedToPlay;

/// The player should auto player, default is YES.
@property (nonatomic) BOOL shouldAutoPlay;

/// The play asset URL.
@property (nonatomic) NSURL *assetURL;

/// The video size.
@property (nonatomic, readonly) CGSize presentationSize;

/// The playback state.
@property (nonatomic, readonly) MercuryPlayerPlaybackState playState;

/// The player load state.
@property (nonatomic, readonly) MercuryPlayerLoadState loadState;

///------------------------------------
/// If you don't appoint the controlView, you can called the following blocks.
/// If you appoint the controlView, The following block cannot be called outside, only for `MercuryPlayerController` calls.
///------------------------------------

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

///------------------------------------
/// end
///------------------------------------

/// Prepares the current queue for playback, interrupting any active (non-mixible) audio sessions.
- (void)prepareToPlay;

/// Reload player.
- (void)reloadPlayer;

/// Play playback.
- (void)play;

/// Pauses playback.
- (void)pause;

/// Replay playback.
- (void)replay;

/// Stop playback.
- (void)stop;

/// Video UIImage at the current time.
- (UIImage *)thumbnailImageAtCurrentTime;

/// Use this method to seek to a specified time for the current player and to be notified when the seek operation is complete.
- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^ __nullable)(BOOL finished))completionHandler;

@end

NS_ASSUME_NONNULL_END

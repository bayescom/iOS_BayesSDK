//
//  MercuryPlayerNotification.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MercuryPlayerBackgroundState) {
    MercuryPlayerBackgroundStateForeground,  // Enter the foreground from the background.
    MercuryPlayerBackgroundStateBackground,  // From the foreground to the background.
};

@interface MercuryPlayerNotification : NSObject

@property (nonatomic, readonly) MercuryPlayerBackgroundState backgroundState;

@property (nonatomic, copy, nullable) void(^willResignActive)(MercuryPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^didBecomeActive)(MercuryPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^newDeviceAvailable)(MercuryPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^oldDeviceUnavailable)(MercuryPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^categoryChange)(MercuryPlayerNotification *registrar);

@property (nonatomic, copy, nullable) void(^volumeChanged)(float volume);

@property (nonatomic, copy, nullable) void(^audioInterruptionCallback)(AVAudioSessionInterruptionType interruptionType);

- (void)addNotification;

- (void)removeNotification;

@end

NS_ASSUME_NONNULL_END

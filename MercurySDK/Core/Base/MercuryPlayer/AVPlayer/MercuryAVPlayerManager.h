//
//  MercuryAVPlayerManager.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#if __has_include(<MercuryPlayerMediaPlayback.h>)
#import <MercuryPlayerMediaPlayback.h>
#else
#import "MercuryPlayerMediaPlayback.h"
#endif

@interface MercuryAVPlayerManager : NSObject <MercuryPlayerMediaPlayback>

@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, strong, readonly) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, assign) NSTimeInterval timeRefreshInterval;
/// 视频请求头
@property (nonatomic, strong) NSDictionary *requestHeader;

@end

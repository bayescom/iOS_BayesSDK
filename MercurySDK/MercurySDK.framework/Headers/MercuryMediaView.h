//
//  MercuryMediaView.h
//  MercurySDK
//
//  Created by guangyao on 2024/1/9.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MercuryMediaView;
@protocol MercuryMediaViewDelegate <NSObject>

@optional

- (void)mercury_mediaViewDidPlayFinish:(MercuryMediaView *)mediaView;

@end

@interface MercuryMediaView : UIView

/// MercuryMediaView 回调对象
@property (nonatomic, weak) id <MercuryMediaViewDelegate> delegate;

/// 播放静音开关
/// - Parameter flag: 是否静音
- (void)muteEnable:(BOOL)flag;

/// 播放
- (void)play;

/// 暂停
- (void)pause;

/// 销毁播放器视图
- (void)destory;

@end

NS_ASSUME_NONNULL_END

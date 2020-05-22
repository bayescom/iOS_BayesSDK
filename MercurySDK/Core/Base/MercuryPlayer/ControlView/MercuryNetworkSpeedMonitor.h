//
//  MercuryNetworkSpeedMonitor.h
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import <Foundation/Foundation.h>

extern NSString *const MercuryDownloadNetworkSpeedNotificationKey;
extern NSString *const MercuryUploadNetworkSpeedNotificationKey;
extern NSString *const MercuryNetworkSpeedNotificationKey;

@interface MercuryNetworkSpeedMonitor : NSObject

@property (nonatomic, copy, readonly) NSString *downloadNetworkSpeed;
@property (nonatomic, copy, readonly) NSString *uploadNetworkSpeed;

- (void)startNetworkSpeedMonitor;
- (void)stopNetworkSpeedMonitor;

@end

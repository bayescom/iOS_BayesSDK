//
//  MercuryPreloadMediaInfo.h
//  MercurySDK
//
//  Created by CherryKing on 2020/2/27.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MercuryPreloadMediaInfo;
@class MercuryPreloadMediaInfoItem;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Object interfaces

@interface MercuryPreloadMediaInfo : NSObject
@property (nonatomic, copy) NSString *appid;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSArray<MercuryPreloadMediaInfoItem *> *urls;

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error;
- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error;
- (NSData *_Nullable)toData:(NSError *_Nullable *)error;
@end

@interface MercuryPreloadMediaInfoItem : NSObject
@property (nonatomic, copy)   NSString *url;
@property (nonatomic, copy)   NSString *fileType;
@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;

/// 是否是视频
@property (nonatomic, assign) BOOL isVideo;

@end

NS_ASSUME_NONNULL_END

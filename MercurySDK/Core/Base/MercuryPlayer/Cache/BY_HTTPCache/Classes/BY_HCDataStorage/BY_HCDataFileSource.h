//
//  BY_HCDataFileSource.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataSource.h"

@class BY_HCDataFileSource;

@protocol BY_HCDataFileSourceDelegate <NSObject>

- (void)ktv_fileSourceDidPrepare:(BY_HCDataFileSource *)fileSource;
- (void)ktv_fileSource:(BY_HCDataFileSource *)fileSource didFailWithError:(NSError *)error;

@end

@interface BY_HCDataFileSource : NSObject <BY_HCDataSource>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPath:(NSString *)path range:(BY_HCRange)range readRange:(BY_HCRange)readRange NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, readonly) BY_HCRange readRange;

@property (nonatomic, weak, readonly) id<BY_HCDataFileSourceDelegate> delegate;
@property (nonatomic, strong, readonly) dispatch_queue_t delegateQueue;

- (void)setDelegate:(id<BY_HCDataFileSourceDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

@end

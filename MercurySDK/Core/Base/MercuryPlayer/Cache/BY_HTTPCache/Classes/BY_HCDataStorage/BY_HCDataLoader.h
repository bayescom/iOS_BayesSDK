//
//  BY_HCDataLoader.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2018/6/7.
//  Copyright © 2018 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BY_HCDataLoader;
@class BY_HCDataRequest;
@class BY_HCDataResponse;

@protocol BY_HCDataLoaderDelegate <NSObject>

- (void)ktv_loaderDidFinish:(BY_HCDataLoader *)loader;
- (void)ktv_loader:(BY_HCDataLoader *)loader didFailWithError:(NSError *)error;
- (void)ktv_loader:(BY_HCDataLoader *)loader didChangeProgress:(double)progress;

@end

@interface BY_HCDataLoader : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id <BY_HCDataLoaderDelegate> delegate;
@property (nonatomic, strong) id object;

@property (nonatomic, strong, readonly) BY_HCDataRequest *request;
@property (nonatomic, strong, readonly) BY_HCDataResponse *response;

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly, getter=isClosed) BOOL closed;

@property (nonatomic, readonly) long long loadedLength;
@property (nonatomic, readonly) double progress;

- (void)prepare;
- (void)close;

@end

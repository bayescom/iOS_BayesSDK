//
//  BY_HCDataReader.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BY_HCDataReader;
@class BY_HCDataRequest;
@class BY_HCDataResponse;

@protocol BY_HCDataReaderDelegate <NSObject>

- (void)ktv_readerDidPrepare:(BY_HCDataReader *)reader;
- (void)ktv_readerHasAvailableData:(BY_HCDataReader *)reader;
- (void)ktv_reader:(BY_HCDataReader *)reader didFailWithError:(NSError *)error;

@end

@interface BY_HCDataReader : NSObject <NSLocking>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, weak) id <BY_HCDataReaderDelegate> delegate;
@property (nonatomic, strong) id object;

@property (nonatomic, strong, readonly) BY_HCDataRequest *request;
@property (nonatomic, strong, readonly) BY_HCDataResponse *response;

@property (nonatomic, copy, readonly) NSError *error;

@property (nonatomic, readonly, getter=isPrepared) BOOL prepared;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;
@property (nonatomic, readonly, getter=isClosed) BOOL closed;

@property (nonatomic, readonly) long long readedLength;
@property (nonatomic, readonly) double progress;

- (void)prepare;
- (void)close;

- (NSData *)readDataOfLength:(NSUInteger)length;

@end

//
//  BY_HCDataLoader.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2018/6/7.
//  Copyright © 2018 Single. All rights reserved.
//

#import "BY_HCDataLoader.h"
#import "BY_HCData+Internal.h"
#import "BY_HCLog.h"

@interface BY_HCDataLoader () <BY_HCDataReaderDelegate>

@property (nonatomic, strong) BY_HCDataReader *reader;

@end

@implementation BY_HCDataLoader

- (instancetype)initWithRequest:(BY_HCDataRequest *)request
{
    if (self = [super init]) {
        BY_HCLogAlloc(self);
        self.reader = [[BY_HCDataReader alloc] initWithRequest:request];
        self.reader.delegate = self;
        BY_HCLogDataLoader(@"%p, Create loader\norignalRequest : %@\nreader : %@", self, request, self.reader);
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
    [self close];
    BY_HCLogDataLoader(@"%p, Destory reader\nError : %@\nprogress : %f", self, self.error, self.progress);
}

- (void)prepare
{
    BY_HCLogDataLoader(@"%p, Call prepare", self);
    [self.reader prepare];
}

- (void)close
{
    BY_HCLogDataLoader(@"%p, Call close", self);
    [self.reader close];
}

- (BY_HCDataRequest *)request
{
    return self.reader.request;
}

- (BY_HCDataResponse *)response
{
    return self.reader.response;
}

- (NSError *)error
{
    return self.reader.error;
}

- (BOOL)isFinished
{
    return self.reader.isFinished;
}

- (BOOL)isClosed
{
    return self.reader.isClosed;
}

#pragma mark - BY_HCDataReaderDelegate

- (void)ktv_readerDidPrepare:(BY_HCDataReader *)reader
{
    [self readData];
}

- (void)ktv_readerHasAvailableData:(BY_HCDataReader *)reader
{
    [self readData];
}

- (void)ktv_reader:(BY_HCDataReader *)reader didFailWithError:(NSError *)error
{
    BY_HCLogDataLoader(@"%p, Callback for failed", self);
    if ([self.delegate respondsToSelector:@selector(ktv_loader:didFailWithError:)]) {
        [self.delegate ktv_loader:self didFailWithError:error];
    }
}

- (void)readData
{
    while (YES) {
        @autoreleasepool {
            NSData *data = [self.reader readDataOfLength:1024 * 1024 * 1];
            if (self.reader.isFinished) {
                self->_loadedLength = self.reader.readedLength;
                self->_progress = 1.0f;
                if ([self.delegate respondsToSelector:@selector(ktv_loader:didChangeProgress:)]) {
                    [self.delegate ktv_loader:self didChangeProgress:self.progress];
                }
                BY_HCLogDataLoader(@"%p, Callback finished", self);
                if ([self.delegate respondsToSelector:@selector(ktv_loaderDidFinish:)]) {
                    [self.delegate ktv_loaderDidFinish:self];
                }
            } else if (data) {
                self->_loadedLength = self.reader.readedLength;
                if (self.response.contentLength > 0) {
                    self->_progress = (double)self.reader.readedLength / (double)self.response.contentLength;
                }
                if ([self.delegate respondsToSelector:@selector(ktv_loader:didChangeProgress:)]) {
                    [self.delegate ktv_loader:self didChangeProgress:self.progress];
                }
                BY_HCLogDataLoader(@"%p, read data progress %f", self, self.progress);
                continue;
            }
            BY_HCLogDataLoader(@"%p, read data break", self);
            break;
        }
    }
}

@end

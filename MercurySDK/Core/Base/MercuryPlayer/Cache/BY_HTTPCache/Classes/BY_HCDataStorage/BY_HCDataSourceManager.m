//
//  BY_HCDataSourceManager.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataSourceManager.h"
#import "BY_HCDataCallback.h"
#import "BY_HCLog.h"

@interface BY_HCDataSourceManager () <NSLocking, BY_HCDataFileSourceDelegate, BY_HCDataNetworkSourceDelegate>

@property (nonatomic, strong) NSLock *coreLock;
@property (nonatomic, strong) id <BY_HCDataSource> currentSource;
@property (nonatomic, strong) BY_HCDataNetworkSource *currentNetworkSource;
@property (nonatomic, strong) NSMutableArray<id<BY_HCDataSource>> *sources;
@property (nonatomic) BOOL calledPrepare;
@property (nonatomic) BOOL calledReceiveResponse;

@end

@implementation BY_HCDataSourceManager

@synthesize error = _error;
@synthesize range = _range;
@synthesize closed = _closed;
@synthesize prepared = _prepared;
@synthesize finished = _finished;
@synthesize readedLength = _readedLength;

- (instancetype)initWithSources:(NSArray<id<BY_HCDataSource>> *)sources delegate:(id<BY_HCDataSourceManagerDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    if (self = [super init]) {
        BY_HCLogAlloc(self);
        self->_sources = [sources mutableCopy];
        self->_delegate = delegate;
        self->_delegateQueue = delegateQueue;
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
    BY_HCLogDataReader(@"%p, Destory reader\nError : %@\ncurrentSource : %@\ncurrentNetworkSource : %@", self, self.error, self.currentSource, self.currentNetworkSource);
}

- (void)prepare
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    if (self.calledPrepare) {
        [self unlock];
        return;
    }
    self->_calledPrepare = YES;
    BY_HCLogDataSourceManager(@"%p, Call prepare", self);
    BY_HCLogDataSourceManager(@"%p, Sort sources - Begin\nSources : %@", self, self.sources);
    [self.sources sortUsingComparator:^NSComparisonResult(id <BY_HCDataSource> obj1, id <BY_HCDataSource> obj2) {
        if (obj1.range.start < obj2.range.start) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    BY_HCLogDataSourceManager(@"%p, Sort sources - End  \nSources : %@", self, self.sources);
    for (id <BY_HCDataSource> obj in self.sources) {
        if ([obj isKindOfClass:[BY_HCDataFileSource class]]) {
            BY_HCDataFileSource *source = (BY_HCDataFileSource *)obj;
            [source setDelegate:self delegateQueue:self.delegateQueue];
        }
        else if ([obj isKindOfClass:[BY_HCDataNetworkSource class]]) {
            BY_HCDataNetworkSource *source = (BY_HCDataNetworkSource *)obj;
            [source setDelegate:self delegateQueue:self.delegateQueue];
        }
    }
    self.currentSource = self.sources.firstObject;
    for (id<BY_HCDataSource> obj in self.sources) {
        if ([obj isKindOfClass:[BY_HCDataNetworkSource class]]) {
            self.currentNetworkSource = obj;
            break;
        }
    }
    BY_HCLogDataSourceManager(@"%p, Sort source\ncurrentSource : %@\ncurrentNetworkSource : %@", self, self.currentSource, self.currentNetworkSource);
    [self.currentSource prepare];
    [self.currentNetworkSource prepare];
    [self unlock];
}

- (void)close
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    self->_closed = YES;
    BY_HCLogDataSourceManager(@"%p, Call close", self);
    for (id <BY_HCDataSource> obj in self.sources) {
        [obj close];
    }
    [self unlock];
}

- (NSData *)readDataOfLength:(NSUInteger)length
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return nil;
    }
    if (self.isFinished) {
        [self unlock];
        return nil;
    }
    if (self.error) {
        [self unlock];
        return nil;
    }
    NSData *data = [self.currentSource readDataOfLength:length];
    self->_readedLength += data.length;
    BY_HCLogDataSourceManager(@"%p, Read data : %lld", self, (long long)data.length);
    if (self.currentSource.isFinished) {
        self.currentSource = [self nextSource];
        if (self.currentSource) {
            BY_HCLogDataSourceManager(@"%p, Switch to next source, %@", self, self.currentSource);
            if ([self.currentSource isKindOfClass:[BY_HCDataFileSource class]]) {
                [self.currentSource prepare];
            }
        } else {
            BY_HCLogDataSourceManager(@"%p, Read data did finished", self);
            self->_finished = YES;
        }
    }
    [self unlock];
    return data;
}

- (id<BY_HCDataSource>)nextSource
{
    NSUInteger index = [self.sources indexOfObject:self.currentSource] + 1;
    if (index < self.sources.count) {
        BY_HCLogDataSourceManager(@"%p, Fetch next source : %@", self, [self.sources objectAtIndex:index]);
        return [self.sources objectAtIndex:index];
    }
    BY_HCLogDataSourceManager(@"%p, Fetch netxt source failed", self);
    return nil;
}

- (BY_HCDataNetworkSource *)nextNetworkSource
{
    NSUInteger index = [self.sources indexOfObject:self.currentNetworkSource] + 1;
    for (; index < self.sources.count; index++) {
        id <BY_HCDataSource> obj = [self.sources objectAtIndex:index];
        if ([obj isKindOfClass:[BY_HCDataNetworkSource class]]) {
            BY_HCLogDataSourceManager(@"%p, Fetch next network source : %@", self, obj);
            return obj;
        }
    }
    BY_HCLogDataSourceManager(@"%p, Fetch netxt network source failed", self);
    return nil;
}

#pragma mark - BY_HCDataFileSourceDelegate

- (void)ktv_fileSourceDidPrepare:(BY_HCDataFileSource *)fileSource
{
    [self lock];
    [self callbackForPrepared];
    [self unlock];
}

- (void)ktv_fileSource:(BY_HCDataFileSource *)fileSource didFailWithError:(NSError *)error
{
    [self callbackForFailed:error];
}

#pragma mark - BY_HCDataNetworkSourceDelegate

- (void)ktv_networkSourceDidPrepare:(BY_HCDataNetworkSource *)networkSource
{
    [self lock];
    [self callbackForPrepared];
    [self callbackForReceiveResponse:networkSource.response];
    [self unlock];
}

- (void)ktv_networkSourceHasAvailableData:(BY_HCDataNetworkSource *)networkSource
{
    [self lock];
    if ([self.delegate respondsToSelector:@selector(ktv_sourceManagerHasAvailableData:)]) {
        BY_HCLogDataSourceManager(@"%p, Callback for has available data - Begin\nSource : %@", self, networkSource);
        [BY_HCDataCallback callbackWithQueue:self.delegateQueue block:^{
            BY_HCLogDataSourceManager(@"%p, Callback for has available data - End", self);
            [self.delegate ktv_sourceManagerHasAvailableData:self];
        }];
    }
    [self unlock];
}

- (void)ktv_networkSourceDidFinisheDownload:(BY_HCDataNetworkSource *)networkSource
{
    [self lock];
    self.currentNetworkSource = [self nextNetworkSource];
    [self.currentNetworkSource prepare];
    [self unlock];
}

- (void)ktv_networkSource:(BY_HCDataNetworkSource *)networkSource didFailWithError:(NSError *)error
{
    [self callbackForFailed:error];
}

#pragma mark - Callback

- (void)callbackForPrepared
{
    if (self.isClosed) {
        return;
    }
    if (self.isPrepared) {
        return;
    }
    self->_prepared = YES;
    if ([self.delegate respondsToSelector:@selector(ktv_sourceManagerDidPrepare:)]) {
        BY_HCLogDataSourceManager(@"%p, Callback for prepared - Begin", self);
        [BY_HCDataCallback callbackWithQueue:self.delegateQueue block:^{
            BY_HCLogDataSourceManager(@"%p, Callback for prepared - End", self);
            [self.delegate ktv_sourceManagerDidPrepare:self];
        }];
    }
}

- (void)callbackForReceiveResponse:(BY_HCDataResponse *)response
{
    if (self.isClosed) {
        return;
    }
    if (self.calledReceiveResponse) {
        return;
    }
    self->_calledReceiveResponse = YES;
    if ([self.delegate respondsToSelector:@selector(ktv_sourceManager:didReceiveResponse:)]) {
        BY_HCLogDataSourceManager(@"%p, Callback for did receive response - End", self);
        [BY_HCDataCallback callbackWithQueue:self.delegateQueue block:^{
            BY_HCLogDataSourceManager(@"%p, Callback for did receive response - End", self);
            [self.delegate ktv_sourceManager:self didReceiveResponse:response];
        }];
    }
}

- (void)callbackForFailed:(NSError *)error
{
    if (!error) {
        return;
    }
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    if (self.error) {
        [self unlock];
        return;
    }
    self->_error = error;
    BY_HCLogDataSourceManager(@"failure, %d", (int)self.error.code);
    if (self.error && [self.delegate respondsToSelector:@selector(ktv_sourceManager:didFailWithError:)]) {
        BY_HCLogDataSourceManager(@"%p, Callback for network source failed - Begin\nError : %@", self, self.error);
        [BY_HCDataCallback callbackWithQueue:self.delegateQueue block:^{
            BY_HCLogDataSourceManager(@"%p, Callback for network source failed - End", self);
            [self.delegate ktv_sourceManager:self didFailWithError:self.error];
        }];
    }
    [self unlock];
}

#pragma mark - NSLocking

- (void)lock
{
    if (!self.coreLock) {
        self.coreLock = [[NSLock alloc] init];
    }
    [self.coreLock lock];
}

- (void)unlock
{
    [self.coreLock unlock];
}

@end

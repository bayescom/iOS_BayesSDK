//
//  BY_HCDataReader.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataReader.h"
#import "BY_HCData+Internal.h"
#import "BY_HCDataSourceManager.h"
#import "BY_HCDataUnitPool.h"
#import "BY_HCDataCallback.h"
#import "BY_HCLog.h"

@interface BY_HCDataReader () <BY_HCDataSourceManagerDelegate>

@property (nonatomic, strong) BY_HCDataUnit *unit;
@property (nonatomic, strong) NSRecursiveLock *coreLock;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) dispatch_queue_t internalDelegateQueue;
@property (nonatomic, strong) BY_HCDataSourceManager *sourceManager;
@property (nonatomic) BOOL calledPrepare;

@end

@implementation BY_HCDataReader

- (instancetype)initWithRequest:(BY_HCDataRequest *)request
{
    if (self = [super init]) {
        BY_HCLogAlloc(self);
        self.unit = [[BY_HCDataUnitPool pool] unitWithURL:request.URL];
        self->_request = [request newRequestWithTotalLength:self.unit.totalLength];
        self.delegateQueue = dispatch_queue_create("BY_HCDataReader_delegateQueue", DISPATCH_QUEUE_SERIAL);
        self.internalDelegateQueue = dispatch_queue_create("BY_HCDataReader_internalDelegateQueue", DISPATCH_QUEUE_SERIAL);
        BY_HCLogDataReader(@"%p, Create reader\norignalRequest : %@\nfinalRequest : %@\nUnit : %@", self, request, self.request, self.unit);
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
    [self close];
    BY_HCLogDataReader(@"%p, Destory reader\nError : %@\nreadOffset : %lld", self, self.error, self.readedLength);
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
    BY_HCLogDataReader(@"%p, Call prepare", self);
    [self prepareSourceManager];
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
    BY_HCLogDataReader(@"%p, Call close", self);
    [self.sourceManager close];
    [self.unit workingRelease];
    self.unit = nil;
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
    NSData *data = [self.sourceManager readDataOfLength:length];
    if (data.length > 0) {
        self->_readedLength += data.length;
        if (self.response.contentLength > 0) {
            self->_progress = (double)self.readedLength / (double)self.response.contentLength;
        }
    }
    BY_HCLogDataReader(@"%p, Read data : %lld", self, (long long)data.length);
    if (self.sourceManager.isFinished) {
        BY_HCLogDataReader(@"%p, Read data did finished", self);
        self->_finished = YES;
        [self close];
    }
    [self unlock];
    return data;
}

- (void)prepareSourceManager
{
    NSMutableArray<BY_HCDataFileSource *> *fileSources = [NSMutableArray array];
    NSMutableArray<BY_HCDataNetworkSource *> *networkSources = [NSMutableArray array];
    long long min = self.request.range.start;
    long long max = self.request.range.end;
    NSArray *unitItems = self.unit.unitItems;
    for (BY_HCDataUnitItem *item in unitItems) {
        long long itemMin = item.offset;
        long long itemMax = item.offset + item.length - 1;
        if (itemMax < min || itemMin > max) {
            continue;
        }
        if (min > itemMin) {
            itemMin = min;
        }
        if (max < itemMax) {
            itemMax = max;
        }
        min = itemMax + 1;
        BY_HCRange range = BY_HCMakeRange(item.offset, item.offset + item.length - 1);
        BY_HCRange readRange = BY_HCMakeRange(itemMin - item.offset, itemMax - item.offset);
        BY_HCDataFileSource *source = [[BY_HCDataFileSource alloc] initWithPath:item.absolutePath range:range readRange:readRange];
        [fileSources addObject:source];
    }
    [fileSources sortUsingComparator:^NSComparisonResult(BY_HCDataFileSource *obj1, BY_HCDataFileSource *obj2) {
        if (obj1.range.start < obj2.range.start) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    long long offset = self.request.range.start;
    long long length = BY_HCRangeIsFull(self.request.range) ? BY_HCRangeGetLength(self.request.range) : (self.request.range.end - offset + 1);
    for (BY_HCDataFileSource *obj in fileSources) {
        long long delta = obj.range.start + obj.readRange.start - offset;
        if (delta > 0) {
            BY_HCRange range = BY_HCMakeRange(offset, offset + delta - 1);
            BY_HCDataRequest *request = [self.request newRequestWithRange:range];
            BY_HCDataNetworkSource *source = [[BY_HCDataNetworkSource alloc] initWithRequest:request];
            [networkSources addObject:source];
            offset += delta;
            length -= delta;
        }
        offset += BY_HCRangeGetLength(obj.readRange);
        length -= BY_HCRangeGetLength(obj.readRange);
    }
    if (length > 0) {
        BY_HCRange range = BY_HCMakeRange(offset, self.request.range.end);
        BY_HCDataRequest *request = [self.request newRequestWithRange:range];
        BY_HCDataNetworkSource *source = [[BY_HCDataNetworkSource alloc] initWithRequest:request];
        [networkSources addObject:source];
    }
    NSMutableArray<id<BY_HCDataSource>> *sources = [NSMutableArray array];
    [sources addObjectsFromArray:fileSources];
    [sources addObjectsFromArray:networkSources];
    self.sourceManager = [[BY_HCDataSourceManager alloc] initWithSources:sources delegate:self delegateQueue:self.internalDelegateQueue];
    [self.sourceManager prepare];
}

- (void)ktv_sourceManagerDidPrepare:(BY_HCDataSourceManager *)sourceManager
{
    [self lock];
    [self callbackForPrepared];
    [self unlock];
}

- (void)ktv_sourceManager:(BY_HCDataSourceManager *)sourceManager didReceiveResponse:(BY_HCDataResponse *)response
{
    [self lock];
    [self.unit updateResponseHeaders:response.headers totalLength:response.totalLength];
    [self callbackForPrepared];
    [self unlock];
}

- (void)ktv_sourceManagerHasAvailableData:(BY_HCDataSourceManager *)sourceManager
{
    [self lock];
    if (self.isClosed) {
        [self unlock];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(ktv_readerHasAvailableData:)]) {
        BY_HCLogDataReader(@"%p, Callback for has available data - Begin", self);
        [BY_HCDataCallback callbackWithQueue:self.delegateQueue block:^{
            BY_HCLogDataReader(@"%p, Callback for has available data - End", self);
            [self.delegate ktv_readerHasAvailableData:self];
        }];
    }
    [self unlock];
}

- (void)ktv_sourceManager:(BY_HCDataSourceManager *)sourceManager didFailWithError:(NSError *)error
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
    [self close];
    [[BY_HCLog log] addError:self.error forURL:self.request.URL];
    if ([self.delegate respondsToSelector:@selector(ktv_reader:didFailWithError:)]) {
        BY_HCLogDataReader(@"%p, Callback for failed - Begin\nError : %@", self, self.error);
        [BY_HCDataCallback callbackWithQueue:self.delegateQueue block:^{
            BY_HCLogDataReader(@"%p, Callback for failed - End", self);
            [self.delegate ktv_reader:self didFailWithError:self.error];
        }];
    }
    [self unlock];
}

- (void)callbackForPrepared
{
    if (self.isClosed) {
        return;
    }
    if (self.isPrepared) {
        return;
    }
    if (self.sourceManager.isPrepared && self.unit.totalLength > 0) {
        long long totalLength = self.unit.totalLength;
        BY_HCRange range = BY_HCRangeWithEnsureLength(self.request.range, totalLength);
        NSDictionary *headers = BY_HCRangeFillToResponseHeaders(range, self.unit.responseHeaders, totalLength);
        self->_response = [[BY_HCDataResponse alloc] initWithURL:self.request.URL headers:headers];
        self->_prepared = YES;
        BY_HCLogDataReader(@"%p, Reader did prepared\nResponse : %@", self, self.response);
        if ([self.delegate respondsToSelector:@selector(ktv_readerDidPrepare:)]) {
            BY_HCLogDataReader(@"%p, Callback for prepared - Begin", self);
            [BY_HCDataCallback callbackWithQueue:self.delegateQueue block:^{
                BY_HCLogDataReader(@"%p, Callback for prepared - End", self);
                [self.delegate ktv_readerDidPrepare:self];
            }];
        }
    }
}

- (void)lock
{
    if (!self.coreLock) {
        self.coreLock = [[NSRecursiveLock alloc] init];
    }
    [self.coreLock lock];
}

- (void)unlock
{
    [self.coreLock unlock];
}

@end

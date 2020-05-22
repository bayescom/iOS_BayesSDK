//
//  BY_HCHTTPResponse.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCHTTPResponse.h"
#import "BY_HCHTTPConnection.h"
#import "BY_HCDataStorage.h"
#import "BY_HCLog.h"

@interface BY_HCHTTPResponse () <BY_HCDataReaderDelegate>

@property (nonatomic) BOOL waitingResponse;
@property (nonatomic, strong) BY_HCDataReader *reader;
@property (nonatomic, weak) BY_HCHTTPConnection *connection;

@end

@implementation BY_HCHTTPResponse

- (instancetype)initWithConnection:(BY_HCHTTPConnection *)connection dataRequest:(BY_HCDataRequest *)dataRequest
{
    if (self = [super init]) {
        BY_HCLogAlloc(self);
        self.connection = connection;
        self.reader = [[BY_HCDataStorage storage] readerWithRequest:dataRequest];
        self.reader.delegate = self;
        [self.reader prepare];
        BY_HCLogHTTPResponse(@"%p, Create response\nrequest : %@", self, dataRequest);
    }
    return self;
}

- (void)dealloc
{
    [self.reader close];
    BY_HCLogDealloc(self);
}

#pragma mark - HTTPResponse

- (NSData *)readDataOfLength:(NSUInteger)length
{
    NSData *data = [self.reader readDataOfLength:length];
    BY_HCLogHTTPResponse(@"%p, Read data : %lld", self, (long long)data.length);
    if (self.reader.isFinished) {
        BY_HCLogHTTPResponse(@"%p, Read data did finished", self);
        [self.reader close];
        [self.connection responseDidAbort:self];
    }
    return data;
}

- (BOOL)delayResponseHeaders
{
    BOOL waiting = !self.reader.isPrepared;
    self.waitingResponse = waiting;
    BY_HCLogHTTPResponse(@"%p, Delay response : %d", self, self.waitingResponse);
    return waiting;
}

- (UInt64)contentLength
{
    BY_HCLogHTTPResponse(@"%p, Conetnt length : %lld", self, self.reader.response.totalLength);
    return self.reader.response.totalLength;
}

- (NSDictionary *)httpHeaders
{
    NSMutableDictionary *headers = [self.reader.response.headers mutableCopy];
    [headers removeObjectForKey:@"Content-Range"];
    [headers removeObjectForKey:@"content-range"];
    [headers removeObjectForKey:@"Content-Length"];
    [headers removeObjectForKey:@"content-length"];
    BY_HCLogHTTPResponse(@"%p, Header\n%@", self, headers);
    return headers;
}

- (UInt64)offset
{
    BY_HCLogHTTPResponse(@"%p, Offset : %lld", self, self.reader.readedLength);
    return self.reader.readedLength;
}

- (void)setOffset:(UInt64)offset
{
    BY_HCLogHTTPResponse(@"%p, Set offset : %lld, %lld", self, offset, self.reader.readedLength);
}

- (BOOL)isDone
{
    BY_HCLogHTTPResponse(@"%p, Check done : %d", self, self.reader.isFinished);
    return self.reader.isFinished;
}

- (void)connectionDidClose
{
    BY_HCLogHTTPResponse(@"%p, Connection did closed : %lld, %lld", self, self.reader.response.contentLength, self.reader.readedLength);
    [self.reader close];
}

#pragma mark - BY_HCDataReaderDelegate

- (void)ktv_readerDidPrepare:(BY_HCDataReader *)reader
{
    BY_HCLogHTTPResponse(@"%p, Prepared", self);
    if (self.reader.isPrepared && self.waitingResponse == YES) {
        BY_HCLogHTTPResponse(@"%p, Call connection did prepared", self);
        [self.connection responseHasAvailableData:self];
    }
}

- (void)ktv_readerHasAvailableData:(BY_HCDataReader *)reader
{
    BY_HCLogHTTPResponse(@"%p, Has available data", self);
    [self.connection responseHasAvailableData:self];
}

- (void)ktv_reader:(BY_HCDataReader *)reader didFailWithError:(NSError *)error
{
    BY_HCLogHTTPResponse(@"%p, Failed\nError : %@", self, error);
    [self.reader close];
    [self.connection responseDidAbort:self];
}

@end

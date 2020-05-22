//
//  BY_HCDataUnit.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDataUnit.h"
#import "BY_HCPathTool.h"
#import "BY_HCURLTool.h"
#import "BY_HCError.h"
#import "BY_HCLog.h"

@interface BY_HCDataUnit ()

@property (nonatomic, strong) NSRecursiveLock *coreLock;
@property (nonatomic, strong) NSMutableArray<BY_HCDataUnitItem *> *unitItemsInternal;
@property (nonatomic, strong) NSMutableArray<NSArray<BY_HCDataUnitItem *> *> *lockingUnitItems;

@end

@implementation BY_HCDataUnit

- (instancetype)initWithURL:(NSURL *)URL
{
    if (self = [super init]) {
        self->_URL = [URL copy];
        self->_key = [[BY_HCURLTool tool] keyWithURL:self.URL];
        self->_createTimeInterval = [NSDate date].timeIntervalSince1970;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        @try {
            self->_URL = [NSURL URLWithString:[aDecoder decodeObjectForKey:@"URLString"]];
            self->_key = [aDecoder decodeObjectForKey:@"uniqueIdentifier"];
        } @catch (NSException *exception) {
            self->_error = [BY_HCError errorForException:exception];
        }
        @try {
            self->_createTimeInterval = [[aDecoder decodeObjectForKey:@"createTimeInterval"] doubleValue];
            self->_responseHeaders = [aDecoder decodeObjectForKey:@"responseHeaderFields"];
            self->_totalLength = [[aDecoder decodeObjectForKey:@"totalContentLength"] longLongValue];
            self->_unitItemsInternal = [[aDecoder decodeObjectForKey:@"unitItems"] mutableCopy];
            [self commonInit];
        } @catch (NSException *exception) {
            self->_error = [BY_HCError errorForException:exception];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self lock];
    [aCoder encodeObject:self.URL.absoluteString forKey:@"URLString"];
    [aCoder encodeObject:self.key forKey:@"uniqueIdentifier"];
    [aCoder encodeObject:@(self.createTimeInterval) forKey:@"createTimeInterval"];
    [aCoder encodeObject:self.responseHeaders forKey:@"responseHeaderFields"];
    [aCoder encodeObject:@(self.totalLength) forKey:@"totalContentLength"];
    [aCoder encodeObject:self.unitItemsInternal forKey:@"unitItems"];
    [self unlock];
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
}

- (void)commonInit
{
    BY_HCLogAlloc(self);
    [self lock];
    if (!self.unitItemsInternal) {
        self.unitItemsInternal = [NSMutableArray array];
    }
    NSMutableArray *removal = [NSMutableArray array];
    for (BY_HCDataUnitItem *obj in self.unitItemsInternal) {
        if (obj.length == 0) {
            [BY_HCPathTool deleteFileAtPath:obj.absolutePath];
            [removal addObject:obj];
        }
    }
    [self.unitItemsInternal removeObjectsInArray:removal];
    [self sortUnitItems];
    BY_HCLogDataUnit(@"%p, Create Unit\nURL : %@\nkey : %@\ntimeInterval : %@\ntotalLength : %lld\ncacheLength : %lld\nvaildLength : %lld\nresponseHeaders : %@\nunitItems : %@", self, self.URL, self.key, [NSDate dateWithTimeIntervalSince1970:self.createTimeInterval], self.totalLength, self.cacheLength, self.validLength, self.responseHeaders, self.unitItemsInternal);
    [self unlock];
}

- (void)sortUnitItems
{
    [self lock];
    BY_HCLogDataUnit(@"%p, Sort unitItems - Begin\n%@", self, self.unitItemsInternal);
    [self.unitItemsInternal sortUsingComparator:^NSComparisonResult(BY_HCDataUnitItem *obj1, BY_HCDataUnitItem *obj2) {
        NSComparisonResult result = NSOrderedDescending;
        if (obj1.offset < obj2.offset) {
            result = NSOrderedAscending;
        } else if ((obj1.offset == obj2.offset) && (obj1.length > obj2.length)) {
            result = NSOrderedAscending;
        }
        return result;
    }];
    BY_HCLogDataUnit(@"%p, Sort unitItems - End  \n%@", self, self.unitItemsInternal);
    [self unlock];
}

- (NSArray<BY_HCDataUnitItem *> *)unitItems
{
    [self lock];
    NSMutableArray *objs = [NSMutableArray array];
    for (BY_HCDataUnitItem *obj in self.unitItemsInternal) {
        [objs addObject:[obj copy]];
    }
    BY_HCLogDataUnit(@"%p, Get unitItems\n%@", self, self.unitItemsInternal);
    [self unlock];
    return objs;
}

- (void)insertUnitItem:(BY_HCDataUnitItem *)unitItem
{
    [self lock];
    [self.unitItemsInternal addObject:unitItem];
    [self sortUnitItems];
    BY_HCLogDataUnit(@"%p, Insert unitItem, %@", self, unitItem);
    [self unlock];
    [self.delegate ktv_unitDidChangeMetadata:self];
}

- (void)updateResponseHeaders:(NSDictionary *)responseHeaders totalLength:(long long)totalLength
{
    [self lock];
    BOOL needs = NO;
    static NSArray *whiteList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whiteList = @[@"Accept-Ranges",
                      @"Connection",
                      @"Content-Type",
                      @"Server"];
    });
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    for (NSString *key in whiteList) {
        NSString *value = [responseHeaders objectForKey:key];
        if (value) {
            [headers setObject:value forKey:key];
        }
    }
    if (self.totalLength != totalLength || ![self.responseHeaders isEqualToDictionary:headers]) {
        self->_responseHeaders = headers;
        self->_totalLength = totalLength;
        needs = YES;
    }
    BY_HCLogDataUnit(@"%p, Update responseHeaders\ntotalLength : %lld\n%@", self, self.totalLength, self.responseHeaders);
    [self unlock];
    if (needs) {
        [self.delegate ktv_unitDidChangeMetadata:self];
    }
}

- (NSURL *)completeURL
{
    [self lock];
    NSURL *completeURL = nil;
    BY_HCDataUnitItem *item = self.unitItemsInternal.firstObject;
    if (item.offset == 0 && item.length > 0 && item.length == self.totalLength) {
        completeURL = [NSURL fileURLWithPath:item.absolutePath];
        BY_HCLogDataUnit(@"%p, Get file path\n%@", self, completeURL);
    }
    [self unlock];
    return completeURL;
}

- (long long)cacheLength
{
    [self lock];
    long long length = 0;
    for (BY_HCDataUnitItem *obj in self.unitItemsInternal) {
        length += obj.length;
    }
    [self unlock];
    return length;
}

- (long long)validLength
{
    [self lock];
    long long offset = 0;
    long long length = 0;
    for (BY_HCDataUnitItem *obj in self.unitItemsInternal) {
        long long invalidLength = MAX(offset - obj.offset, 0);
        long long vaildLength = MAX(obj.length - invalidLength, 0);
        offset = MAX(offset, obj.offset + obj.length);
        length += vaildLength;
    }
    [self unlock];
    return length;
}

- (NSTimeInterval)lastItemCreateInterval
{
    [self lock];
    NSTimeInterval timeInterval = self.createTimeInterval;
    for (BY_HCDataUnitItem *obj in self.unitItemsInternal) {
        if (obj.createTimeInterval > timeInterval) {
            timeInterval = obj.createTimeInterval;
        }
    }
    [self unlock];
    return timeInterval;
}

- (void)workingRetain
{
    [self lock];
    self->_workingCount += 1;
    BY_HCLogDataUnit(@"%p, Working retain  : %ld", self, (long)self.workingCount);
    [self unlock];
}

- (void)workingRelease
{
    [self lock];
    self->_workingCount -= 1;
    BY_HCLogDataUnit(@"%p, Working release : %ld", self, (long)self.workingCount);
    BOOL needs = [self mergeFilesIfNeeded];
    [self unlock];
    if (needs) {
        [self.delegate ktv_unitDidChangeMetadata:self];
    }
}

- (void)deleteFiles
{
    if (!self.URL) {
        return;
    }
    [self lock];
    NSString *path = [BY_HCPathTool directoryPathWithURL:self.URL];
    [BY_HCPathTool deleteDirectoryAtPath:path];
    BY_HCLogDataUnit(@"%p, Delete files", self);
    [self unlock];
}

- (BOOL)mergeFilesIfNeeded
{
    [self lock];
    if (self.workingCount > 0 || self.totalLength == 0 || self.unitItemsInternal.count == 0) {
        [self unlock];
        return NO;
    }
    NSString *path = [BY_HCPathTool completeFilePathWithURL:self.URL];
    if ([self.unitItemsInternal.firstObject.absolutePath isEqualToString:path]) {
        [self unlock];
        return NO;
    }
    if (self.totalLength != self.validLength) {
        [self unlock];
        return NO;
    }
    NSError *error = nil;
    long long offset = 0;
    [BY_HCPathTool deleteFileAtPath:path];
    [BY_HCPathTool createFileAtPath:path];
    NSFileHandle *writingHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    for (BY_HCDataUnitItem *obj in self.unitItemsInternal) {
        if (error) {
            break;
        }
        NSAssert(offset >= obj.offset, @"invaild unit item.");
        if (offset >= (obj.offset + obj.length)) {
            BY_HCLogDataUnit(@"%p, Merge files continue", self);
            continue;
        }
        NSFileHandle *readingHandle = [NSFileHandle fileHandleForReadingAtPath:obj.absolutePath];
        @try {
            [readingHandle seekToFileOffset:offset - obj.offset];
        } @catch (NSException *exception) {
            BY_HCLogDataUnit(@"%p, Merge files seek exception\n%@", self, exception);
            error = [BY_HCError errorForException:exception];
        }
        if (error) {
            break;
        }
        while (!error) {
            @autoreleasepool {
                NSData *data = [readingHandle readDataOfLength:1024 * 1024 * 1];
                if (data.length == 0) {
                    BY_HCLogDataUnit(@"%p, Merge files break", self);
                    break;
                }
                BY_HCLogDataUnit(@"%p, Merge write data : %lld", self, (long long)data.length);
                @try {
                    [writingHandle writeData:data];
                } @catch (NSException *exception) {
                    BY_HCLogDataUnit(@"%p, Merge files write exception\n%@", self, exception);
                    error = [BY_HCError errorForException:exception];
                }
            }
        }
        [readingHandle closeFile];
        offset = obj.offset + obj.length;
        BY_HCLogDataUnit(@"%p, Merge next : %lld", self, offset);
    }
    @try {
        [writingHandle synchronizeFile];
        [writingHandle closeFile];
    } @catch (NSException *exception) {
        BY_HCLogDataUnit(@"%p, Merge files close exception, %@", self, exception);
        error = [BY_HCError errorForException:exception];
    }
    BY_HCLogDataUnit(@"%p, Merge finished\ntotalLength : %lld\noffset : %lld", self, self.totalLength, offset);
    if (error || [BY_HCPathTool sizeAtPath:path] != self.totalLength) {
        [BY_HCPathTool deleteFileAtPath:path];
        [self unlock];
        return NO;
    }
    BY_HCLogDataUnit(@"%p, Merge replace items", self);
    BY_HCDataUnitItem *item = [[BY_HCDataUnitItem alloc] initWithPath:path];
    for (BY_HCDataUnitItem *obj in self.unitItemsInternal) {
        [BY_HCPathTool deleteFileAtPath:obj.absolutePath];
    }
    [self.unitItemsInternal removeAllObjects];
    [self.unitItemsInternal addObject:item];
    [self unlock];
    return YES;
}

- (void)lock
{
    if (!self.coreLock) {
        self.coreLock = [[NSRecursiveLock alloc] init];
    }
    [self.coreLock lock];
    if (!self.lockingUnitItems) {
        self.lockingUnitItems = [NSMutableArray array];
    }
    NSArray<BY_HCDataUnitItem *> *objs = [NSArray arrayWithArray:self.unitItemsInternal];
    [self.lockingUnitItems addObject:objs];
    for (BY_HCDataUnitItem *obj in objs) {
        [obj lock];
    }
}

- (void)unlock
{
    NSArray<BY_HCDataUnitItem *> *objs = self.lockingUnitItems.lastObject;
    [self.lockingUnitItems removeLastObject];
    if (self.lockingUnitItems.count <= 0) {
        self.lockingUnitItems = nil;
    }
    for (BY_HCDataUnitItem *obj in objs) {
        [obj unlock];
    }
    [self.coreLock unlock];
}

@end

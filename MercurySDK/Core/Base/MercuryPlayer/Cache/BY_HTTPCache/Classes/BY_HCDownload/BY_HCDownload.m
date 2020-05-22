//
//  BY_HCDataDownload.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/12.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCDownload.h"
#import "BY_HCData+Internal.h"
#import "BY_HCDataUnitPool.h"
#import "BY_HCDataStorage.h"
#import "BY_HCError.h"
#import "BY_HCLog.h"

#import <UIKit/UIKit.h>

NSString * const BY_HCContentTypeVideo                  = @"video/";
NSString * const BY_HCContentTypeAudio                  = @"audio/";
NSString * const BY_HCContentTypeApplicationMPEG4       = @"application/mp4";
NSString * const BY_HCContentTypeApplicationOctetStream = @"application/octet-stream";
NSString * const BY_HCContentTypeBinaryOctetStream      = @"binary/octet-stream";

@interface BY_HCDownload () <NSURLSessionDataDelegate, NSLocking>

@property (nonatomic, strong) NSLock *coreLock;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSOperationQueue *sessionDelegateQueue;
@property (nonatomic, strong) NSURLSessionConfiguration *sessionConfiguration;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, NSError *> *errorDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, BY_HCDataRequest *> *requestDictionary;
@property (nonatomic, strong) NSMutableDictionary<NSURLSessionTask *, id<BY_HCDownloadDelegate>> *delegateDictionary;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end

@implementation BY_HCDownload

+ (instancetype)download
{
    static BY_HCDownload *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        BY_HCLogAlloc(self);
        self.timeoutInterval = 30.0f;
        self.backgroundTask = UIBackgroundTaskInvalid;
        self.errorDictionary = [NSMutableDictionary dictionary];
        self.requestDictionary = [NSMutableDictionary dictionary];
        self.delegateDictionary = [NSMutableDictionary dictionary];
        self.sessionDelegateQueue = [[NSOperationQueue alloc] init];
        self.sessionDelegateQueue.qualityOfService = NSQualityOfServiceUserInteractive;
        self.sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.sessionConfiguration.timeoutIntervalForRequest = self.timeoutInterval;
        self.sessionConfiguration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        self.session = [NSURLSession sessionWithConfiguration:self.sessionConfiguration
                                                     delegate:self
                                                delegateQueue:self.sessionDelegateQueue];
        self.acceptableContentTypes = @[BY_HCContentTypeVideo,
                                        BY_HCContentTypeAudio,
                                        BY_HCContentTypeApplicationMPEG4,
                                        BY_HCContentTypeApplicationOctetStream,
                                        BY_HCContentTypeBinaryOctetStream];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:[UIApplication sharedApplication]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray<NSString *> *)availableHeaderKeys
{
    static NSArray<NSString *> *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = @[@"User-Agent",
                @"Connection",
                @"Accept",
                @"Accept-Encoding",
                @"Accept-Language",
                @"Range"];
    });
    return obj;
}

- (NSURLSessionTask *)downloadWithRequest:(BY_HCDataRequest *)request delegate:(id<BY_HCDownloadDelegate>)delegate
{
    [self lock];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:request.URL];
    mRequest.timeoutInterval = self.timeoutInterval;
    mRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    [request.headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        if ([self.availableHeaderKeys containsObject:key] ||
            [self.whitelistHeaderKeys containsObject:key]) {
            [mRequest setValue:obj forHTTPHeaderField:key];
        }
    }];
    [self.additionalHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [mRequest setValue:obj forHTTPHeaderField:key];
    }];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:mRequest];
    [self.requestDictionary setObject:request forKey:task];
    [self.delegateDictionary setObject:delegate forKey:task];
    task.priority = 1.0;
    [task resume];
    // BY_HCLogDownload(@"%p, Add Request\nrequest : %@\nURL : %@\nheaders : %@\nHTTPRequest headers : %@\nCount : %d", self, request, request.URL, request.headers, mRequest.allHTTPHeaderFields, (int)self.delegateDictionary.count);
    [self unlock];
    return task;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    [self lock];
    // BY_HCLogDownload(@"%p, Complete\nError : %@", self, error);
    if ([self.errorDictionary objectForKey:task]) {
        error = [self.errorDictionary objectForKey:task];
    }
    id<BY_HCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:task];
    [delegate ktv_download:self didCompleteWithError:error];
    [self.delegateDictionary removeObjectForKey:task];
    [self.requestDictionary removeObjectForKey:task];
    [self.errorDictionary removeObjectForKey:task];
    if (self.delegateDictionary.count <= 0) {
        [self endBackgroundTaskDelay];
    }
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self lock];
    BY_HCDataRequest *dataRequest = [self.requestDictionary objectForKey:task];
    BY_HCDataResponse *dataResponse = [[BY_HCDataResponse alloc] initWithURL:dataRequest.URL headers:response.allHeaderFields];
    // BY_HCLogDownload(@"%p, Receive response\nrequest : %@\nresponse : %@\nHTTPResponse : %@", self, dataRequest, dataResponse, response.allHeaderFields);
    NSError *error = nil;
    if (!error) {
        if (response.statusCode > 400) {
            error = [BY_HCError errorForResponseUnavailable:task.currentRequest.URL
                                                    request:task.currentRequest
                                                   response:task.response];
        }
    }
    if (!error) {
        BOOL vaild = NO;
        if (dataResponse.contentType.length > 0) {
            for (NSString *obj in self.acceptableContentTypes) {
                if ([[dataResponse.contentType lowercaseString] containsString:[obj lowercaseString]]) {
                    vaild = YES;
                }
            }
            if (!vaild && self.unacceptableContentTypeDisposer) {
                vaild = self.unacceptableContentTypeDisposer(dataRequest.URL, dataResponse.contentType);
            }
        }
        if (!vaild) {
            error = [BY_HCError errorForUnsupportContentType:task.currentRequest.URL
                                                     request:task.currentRequest
                                                    response:task.response];
        }
    }
    if (!error) {
        if (dataResponse.contentLength <= 0 ||
            (!BY_HCRangeIsFull(dataRequest.range) &&
             (dataResponse.contentLength != BY_HCRangeGetLength(dataRequest.range)))) {
                error = [BY_HCError errorForUnsupportContentType:task.currentRequest.URL
                                                         request:task.currentRequest
                                                        response:task.response];
            }
    }
    if (!error) {
        long long (^getDeletionLength)(long long) = ^(long long desireLength){
            return desireLength + [BY_HCDataStorage storage].totalCacheLength - [BY_HCDataStorage storage].maxCacheLength;
        };
        long long length = getDeletionLength(dataResponse.contentLength);
        if (length > 0) {
            [[BY_HCDataUnitPool pool] deleteUnitsWithLength:length];
            length = getDeletionLength(dataResponse.contentLength);
            if (length > 0) {
                error = [BY_HCError errorForNotEnoughDiskSpace:dataResponse.totalLength
                                                       request:dataResponse.contentLength
                                              totalCacheLength:[BY_HCDataStorage storage].totalCacheLength
                                                maxCacheLength:[BY_HCDataStorage storage].maxCacheLength];
            }
        }
    }
    if (error) {
        // BY_HCLogDownload(@"%p, Invaild response\nError : %@", self, error);
        [self.errorDictionary setObject:error forKey:task];
        completionHandler(NSURLSessionResponseCancel);
    } else {
        id<BY_HCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:task];
        [delegate ktv_download:self didReceiveResponse:dataResponse];
        completionHandler(NSURLSessionResponseAllow);
    }
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    [self lock];
    // BY_HCLogDownload(@"%p, Perform HTTP redirection\nresponse : %@\nrequest : %@", self, response, request);
    completionHandler(request);
    [self unlock];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self lock];
    // BY_HCLogDownload(@"%p, Receive data - Begin\nLength : %lld\nURL : %@", self, (long long)data.length, dataTask.originalRequest.URL.absoluteString);
    id<BY_HCDownloadDelegate> delegate = [self.delegateDictionary objectForKey:dataTask];
    [delegate ktv_download:self didReceiveData:data];
    // BY_HCLogDownload(@"%p, Receive data - End\nLength : %lld\nURL : %@", self, (long long)data.length, dataTask.originalRequest.URL.absoluteString);
    [self unlock];
}

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

#pragma mark - Background Task

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self lock];
    if (self.delegateDictionary.count > 0) {
        [self beginBackgroundTask];
    }
    [self unlock];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self endBackgroundTask];
}

- (void)beginBackgroundTask
{
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundTask];
    }];
}

- (void)endBackgroundTask
{
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

- (void)endBackgroundTaskDelay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self lock];
        if (self.delegateDictionary.count <= 0) {
            [self endBackgroundTask];
        }
        [self unlock];
    });
}

@end

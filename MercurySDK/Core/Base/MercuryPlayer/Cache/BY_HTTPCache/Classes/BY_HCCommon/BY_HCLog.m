//
//  BY_HCLog.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/17.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCLog.h"
#import "BY_HCPathTool.h"

#import <UIKit/UIKit.h>

@interface BY_HCLog ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSFileHandle *writingHandle;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSError *> *internalErrors;

@end

@implementation BY_HCLog

+ (instancetype)log
{
    static BY_HCLog *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.consoleLogEnable = NO;
        self.recordLogEnable = NO;
        self.lock = [[NSLock alloc] init];
        self.internalErrors = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addRecordLog:(NSString *)log
{
    if (!self.recordLogEnable) {
        return;
    }
    if (log.length <= 0) {
        return;
    }
    [self.lock lock];
    NSString *string = [NSString stringWithFormat:@"%@  %@\n", [NSDate date], log];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (!self.writingHandle) {
        [BY_HCPathTool deleteFileAtPath:[BY_HCPathTool logPath]];
        [BY_HCPathTool createFileAtPath:[BY_HCPathTool logPath]];
        self.writingHandle = [NSFileHandle fileHandleForWritingAtPath:[BY_HCPathTool logPath]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    [self.writingHandle writeData:data];
    [self.lock unlock];
}

- (NSURL *)recordLogFileURL
{
    NSURL *URL = nil;
    [self.lock lock];
    long long size = [BY_HCPathTool sizeAtPath:[BY_HCPathTool logPath]];
    if (size > 0) {
        URL = [NSURL fileURLWithPath:[BY_HCPathTool logPath]];
    }
    [self.lock unlock];
    return URL;
}

- (void)deleteRecordLogFile
{
    [self.lock lock];
    [self.writingHandle synchronizeFile];
    [self.writingHandle closeFile];
    self.writingHandle = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [self.lock unlock];
}

- (void)addError:(NSError *)error forURL:(NSURL *)URL
{
    if (!URL || ![error isKindOfClass:[NSError class]]) {
        return;
    }
    [self.lock lock];
    [self.internalErrors setObject:error forKey:URL];
    [self.lock unlock];
}

- (NSDictionary<NSURL *,NSError *> *)errors
{
    [self.lock lock];
    NSDictionary<NSURL *,NSError *> *ret = [self.internalErrors copy];
    [self.lock unlock];
    return ret;
}

- (NSError *)errorForURL:(NSURL *)URL
{
    if (!URL) {
        return nil;
    }
    [self.lock lock];
    NSError *ret = [self.internalErrors objectForKey:URL];
    [self.lock unlock];
    return ret;
}

- (void)cleanErrorForURL:(NSURL *)URL
{
    [self.lock lock];
    [self.internalErrors removeObjectForKey:URL];
    [self.lock unlock];
}

#pragma mark - UIApplicationWillTerminateNotification

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self deleteRecordLogFile];
}

@end

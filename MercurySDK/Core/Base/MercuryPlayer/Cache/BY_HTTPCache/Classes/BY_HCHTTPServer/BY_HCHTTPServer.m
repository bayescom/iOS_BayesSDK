//
//  BY_HCHTTPServer.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCHTTPServer.h"
#import "BY_HCHTTPConnection.h"
#import "BY_HCHTTPHeader.h"
#import "BY_HCURLTool.h"
#import "BY_HCLog.h"

@interface BY_HCHTTPServer ()

@property (nonatomic, strong) BY_HTTPServer *server;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@property (nonatomic) BOOL wantsRunning;

@end

@implementation BY_HCHTTPServer

+ (instancetype)server
{
    static BY_HCHTTPServer *obj = nil;
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
        self.server = [[BY_HTTPServer alloc] init];
        [self.server setConnectionClass:[BY_HCHTTPConnection class]];
        [self.server setType:@"_http._tcp."];
        [self.server setPort:61234];
        self.backgroundTask = UIBackgroundTaskInvalid;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidEnterBackground)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(HTTPConnectionDidDie)
                                                     name:HTTPConnectionDidDieNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
    [self stopInternal];
}

- (BOOL)isRunning
{
    return self.server.isRunning;
}

- (BOOL)start:(NSError **)error
{
    self.wantsRunning = YES;
    return [self startInternal:error];
}

- (void)stop
{
    self.wantsRunning = NO;
    [self stopInternal];
}

- (NSURL *)URLWithOriginalURL:(NSURL *)URL
{
    if (!URL || URL.isFileURL || URL.absoluteString.length == 0) {
        return URL;
    }
    if (!self.isRunning) {
        return URL;
    }
    NSString *original = [[BY_HCURLTool tool] URLEncode:URL.absoluteString];
    NSString *server = [NSString stringWithFormat:@"http://localhost:%d/", self.server.listeningPort];
    NSString *extension = URL.pathExtension ? [NSString stringWithFormat:@".%@", URL.pathExtension] : @"";
    NSString *URLString = [NSString stringWithFormat:@"%@request%@?url=%@", server, extension, original];
    URL = [NSURL URLWithString:URLString];
    BY_HCLogHTTPServer(@"%p, Return URL\nURL : %@", self, URL);
    return URL;
}

#pragma mark - Internal

- (BOOL)startInternal:(NSError **)error
{
    BOOL ret = [self.server start:error];
    if (ret) {
        BY_HCLogHTTPServer(@"%p, Start server success", self);
    } else {
        BY_HCLogHTTPServer(@"%p, Start server failed", self);
    }
    return ret;
}

- (void)stopInternal
{
    [self.server stop];
}

#pragma mark - Background Task

- (void)applicationDidEnterBackground
{
    if (self.server.numberOfHTTPConnections > 0) {
        BY_HCLogHTTPServer(@"%p, enter background", self);
        [self beginBackgroundTask];
    } else {
        BY_HCLogHTTPServer(@"%p, enter background and stop server", self);
        [self stopInternal];
    }
}

- (void)applicationWillEnterForeground
{
    BY_HCLogHTTPServer(@"%p, enter foreground", self);
    if (self.backgroundTask == UIBackgroundTaskInvalid && self.wantsRunning) {
        BY_HCLogHTTPServer(@"%p, restart server", self);
        [self startInternal:nil];
    }
    [self endBackgroundTask];
}

- (void)HTTPConnectionDidDie
{
    BY_HCLogHTTPServer(@"%p, connection did die", self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
            self.server.numberOfHTTPConnections == 0) {
            BY_HCLogHTTPServer(@"%p, server idle", self);
            [self endBackgroundTask];
            [self stopInternal];
        }
    });
}

- (void)beginBackgroundTask
{
    BY_HCLogHTTPServer(@"%p, begin background task", self);
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        BY_HCLogHTTPServer(@"%p, background task expiration", self);
        [self endBackgroundTask];
        [self stopInternal];
    }];
}

- (void)endBackgroundTask
{
    if (self.backgroundTask != UIBackgroundTaskInvalid) {
        BY_HCLogHTTPServer(@"%p, end background task", self);
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

@end

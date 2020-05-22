//
//  BY_HCHTTPConnection.m
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "BY_HCHTTPConnection.h"
#import "BY_HCHTTPResponse.h"
#import "BY_HCDataStorage.h"
#import "BY_HCURLTool.h"
#import "BY_HCLog.h"

@implementation BY_HCHTTPConnection

- (id)initWithAsyncSocket:(BY_GCDAsyncSocket *)newSocket configuration:(BY_HTTPConfig *)aConfig
{
    if (self = [super initWithAsyncSocket:newSocket configuration:aConfig]) {
        BY_HCLogAlloc(self);
    }
    return self;
}

- (void)dealloc
{
    BY_HCLogDealloc(self);
}

- (NSObject<BY_HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    BY_HCLogHTTPConnection(@"%p, Receive request\nmethod : %@\npath : %@\nURL : %@", self, method, path, request.url);
    NSDictionary<NSString *,NSString *> *parameters = [[BY_HCURLTool tool] parseQuery:request.url.query];
    NSURL *URL = [NSURL URLWithString:[parameters objectForKey:@"url"]];
    BY_HCDataRequest *dataRequest = [[BY_HCDataRequest alloc] initWithURL:URL headers:request.allHeaderFields];
    BY_HCHTTPResponse *response = [[BY_HCHTTPResponse alloc] initWithConnection:self dataRequest:dataRequest];
    return response;
}


@end

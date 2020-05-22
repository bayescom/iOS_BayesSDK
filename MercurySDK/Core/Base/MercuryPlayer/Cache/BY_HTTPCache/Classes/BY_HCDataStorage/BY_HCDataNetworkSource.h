//
//  BY_HCDataNetworkSource.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataSource.h"
#import "BY_HCDataRequest.h"
#import "BY_HCDataResponse.h"

@class BY_HCDataNetworkSource;

@protocol BY_HCDataNetworkSourceDelegate <NSObject>

- (void)ktv_networkSourceDidPrepare:(BY_HCDataNetworkSource *)networkSource;
- (void)ktv_networkSourceHasAvailableData:(BY_HCDataNetworkSource *)networkSource;
- (void)ktv_networkSourceDidFinisheDownload:(BY_HCDataNetworkSource *)networkSource;
- (void)ktv_networkSource:(BY_HCDataNetworkSource *)networkSource didFailWithError:(NSError *)error;

@end

@interface BY_HCDataNetworkSource : NSObject <BY_HCDataSource>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithRequest:(BY_HCDataRequest *)reqeust NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) BY_HCDataRequest *request;
@property (nonatomic, strong, readonly) BY_HCDataResponse *response;

@property (nonatomic, weak, readonly) id<BY_HCDataNetworkSourceDelegate> delegate;
@property (nonatomic, strong, readonly) dispatch_queue_t delegateQueue;

- (void)setDelegate:(id<BY_HCDataNetworkSourceDelegate>)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

@end

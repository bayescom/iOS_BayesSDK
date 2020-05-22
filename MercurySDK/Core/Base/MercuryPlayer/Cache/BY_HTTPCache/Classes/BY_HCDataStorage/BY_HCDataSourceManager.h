//
//  BY_HCDataSourceManager.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/11.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BY_HCDataNetworkSource.h"
#import "BY_HCDataFileSource.h"

@class BY_HCDataSourceManager;

@protocol BY_HCDataSourceManagerDelegate <NSObject>

- (void)ktv_sourceManagerDidPrepare:(BY_HCDataSourceManager *)sourceManager;
- (void)ktv_sourceManagerHasAvailableData:(BY_HCDataSourceManager *)sourceManager;
- (void)ktv_sourceManager:(BY_HCDataSourceManager *)sourceManager didFailWithError:(NSError *)error;
- (void)ktv_sourceManager:(BY_HCDataSourceManager *)sourceManager didReceiveResponse:(BY_HCDataResponse *)response;

@end

@interface BY_HCDataSourceManager : NSObject <BY_HCDataSource>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithSources:(NSArray<id<BY_HCDataSource>> *)sources
                       delegate:(id <BY_HCDataSourceManagerDelegate>)delegate
                  delegateQueue:(dispatch_queue_t)delegateQueue NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak, readonly) id <BY_HCDataSourceManagerDelegate> delegate;
@property (nonatomic, strong, readonly) dispatch_queue_t delegateQueue;

@end

//
//  BY_HCDataCallback.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/12.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BY_HCDataCallback : NSObject

+ (void)callbackWithQueue:(dispatch_queue_t)queue block:(void (^)(void))block;      // Default is async.
+ (void)callbackWithQueue:(dispatch_queue_t)queue block:(void (^)(void))block async:(BOOL)async;

@end

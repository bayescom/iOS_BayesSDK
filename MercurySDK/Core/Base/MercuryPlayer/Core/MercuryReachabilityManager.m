//
//  MercuryReachabilityManager.m
//  MercuryPlayer
//
// Copyright (c) 2020年 bayescom
//


#import "MercuryReachabilityManager.h"
#if !TARGET_OS_WATCH
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString * const MercuryReachabilityDidChangeNotification = @"com.MercuryPlayer.reachability.change";
NSString * const MercuryReachabilityNotificationStatusItem = @"MercuryNetworkingReachabilityNotificationStatusItem";

typedef void (^MercuryReachabilityStatusBlock)(MercuryReachabilityStatus status);

NSString * MercuryStringFromNetworkReachabilityStatus(MercuryReachabilityStatus status) {
    switch (status) {
        case MercuryReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"MercuryPlayer", nil);
        case MercuryReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"MercuryPlayer", nil);
        case MercuryReachabilityStatusReachableVia2G:
            return NSLocalizedStringFromTable(@"Reachable via 2G", @"MercuryPlayer", nil);
        case MercuryReachabilityStatusReachableVia3G:
            return NSLocalizedStringFromTable(@"Reachable via 3G", @"MercuryPlayer", nil);
        case MercuryReachabilityStatusReachableVia4G:
            return NSLocalizedStringFromTable(@"Reachable via 4G", @"MercuryPlayer", nil);
        case MercuryReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"MercuryPlayer", nil);
    }
}

static MercuryReachabilityStatus MercuryReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    MercuryReachabilityStatus status = MercuryReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = MercuryReachabilityStatusNotReachable;
    }
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
        if (currentRadioAccessTechnology) {
            if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                status = MercuryReachabilityStatusReachableVia4G;
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                status = MercuryReachabilityStatusReachableVia2G;
            } else {
                status = MercuryReachabilityStatusReachableVia3G;
            }
        }
    }
#endif
    else {
        status = MercuryReachabilityStatusReachableViaWiFi;
    }
    return status;
    
}

/**
 * Queue a status change notification for the main thread.
 *
 * This is done to ensure that the notifications are received in the same order
 * as they are sent. If notifications are sent directly, it is possible that
 * a queued notification (for an earlier status condition) is processed after
 * the later update, resulting in the listener being left in the wrong state.
 */
static void MercuryPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, MercuryReachabilityStatusBlock block) {
    MercuryReachabilityStatus status = MercuryReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) block(status);
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ MercuryReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:MercuryReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static void AFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    MercuryPostReachabilityStatusChange(flags, (__bridge MercuryReachabilityStatusBlock)info);
}


static const void * MercuryReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void MercuryReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface MercuryReachabilityManager ()

@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) MercuryReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) MercuryReachabilityStatusBlock networkReachabilityStatusBlock;

@end

@implementation MercuryReachabilityManager

+ (instancetype)sharedManager {
    static MercuryReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });
    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    MercuryReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    MercuryReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    return manager;
}

+ (instancetype)manager {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    _networkReachability = CFRetain(reachability);
    self.networkReachabilityStatus = MercuryReachabilityStatusUnknown;
    
    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return (self.networkReachabilityStatus == MercuryReachabilityStatusReachableVia2G ||self.networkReachabilityStatus == MercuryReachabilityStatusReachableVia3G || self.networkReachabilityStatus == MercuryReachabilityStatusReachableVia4G);
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == MercuryReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];
    if (!self.networkReachability) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    MercuryReachabilityStatusBlock callback = ^(MercuryReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
    };
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, MercuryReachabilityRetainCallback, MercuryReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, AFNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            MercuryPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return MercuryStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(MercuryReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif

//
//  MercuryDeviceInfoUtil.m
//  MercurySDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "MercuryDeviceInfoUtil.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIScreen.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <sys/utsname.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonCrypto.h>

#import "MercuryPriHeader.h"
#import "MercuryExceptionCollector.h"
#import "NSDictionary+Mercury.h"
#import "NSMutableDictionary+Mercury.h"
#import "UIWindow+Mercury.h"
#import "MercuryReachability.h"

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

/// 存取本地不变字典的key
static NSString * const MercuryDeviceInfoUtilStaticDeviceInfoMKey = @"MercuryDeviceInfoUtilStaticDeviceInfoMKey";

@interface MercuryDeviceInfoUtil ()
/// 设备信息缓存(这里存储基本不变的信息)
@property (nonatomic, strong) NSMutableDictionary *staticDeviceInfoM;
/// 缓存的数据
@property (nonatomic, strong) NSMutableDictionary *cacheInfo;

@end

@implementation MercuryDeviceInfoUtil
// MARK: 单例
static MercuryDeviceInfoUtil *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

+ (id) allocWithZone:(struct _NSZone *)zone {
    return [MercuryDeviceInfoUtil sharedInstance] ;
}

- (id) copyWithZone:(struct _NSZone *)zone {
    return [MercuryDeviceInfoUtil sharedInstance] ;
}

// MARK: Publish
- (void)getDeviceInfoWithAdspotId:(NSString*)adspotId
                            appId:(NSString*)appId
                         mediaKey:(NSString*)mediaKey
                       completion:(void (^ __nullable)(NSDictionary *deviceInfo))completion {
    if (_cacheInfo) {
        // 请求的unix时间戳,精确到毫秒(13位)
        NSString *time = [MercuryDeviceInfoUtil getTime];
        [_cacheInfo setObject:time forKey:@"time"];
        // 流量校验码
        [_cacheInfo setObject:[MercuryDeviceInfoUtil getTokenWithAppId:appId mediaKey:mediaKey time:time] forKey:@"token"];
        // APP的id
        [_cacheInfo mercury_safeSetObject:appId forKey:@"appid"];
        // 广告位的id
        [_cacheInfo mercury_safeSetObject:adspotId forKey:@"adspotid"];
        // 此次请求的id,使用uuid格式,
        [_cacheInfo mercury_safeSetObject:[MercuryDeviceInfoUtil getReqid] forKey:@"reqid"];
        if (completion) {
            completion([_cacheInfo copy]);
        }
    } else {
        NSMutableDictionary * deviceInfoArrM = [[NSMutableDictionary alloc] initWithDictionary:self.staticDeviceInfoM];
        // 请求的unix时间戳,精确到毫秒(13位)
        NSString *time = [MercuryDeviceInfoUtil getTime];
        [deviceInfoArrM setObject:time forKey:@"time"];
        // 流量校验码
        [deviceInfoArrM setObject:[MercuryDeviceInfoUtil getTokenWithAppId:appId mediaKey:mediaKey time:time] forKey:@"token"];
        // APP的id
        [deviceInfoArrM mercury_safeSetObject:appId forKey:@"appid"];
        // 广告位的id
        [deviceInfoArrM mercury_safeSetObject:adspotId forKey:@"adspotid"];
        // 此次请求的id,使用uuid格式,
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getReqid] forKey:@"reqid"];
        // APP的版本号
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getAppVersion]forKey:@"appver"];
        // 运营商信息, 使用标准MCC/MNC码
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getCarrier] forKey:@"carrier"];
        // 网络连接类型, 0:未识别, 1:WIFI, 2:2G, 3:3G, 4:4G, 5:5G。
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getNetwork] forKey:@"network"];
        // 操作系统版本号
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getOsv] forKey:@"osv"];
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getIPAddress:YES] forKey:@"ip"];
        
        // 接口版本号
        [deviceInfoArrM mercury_safeSetObject:Mercury_API_VERSION forKey:@"version"];
        // idfa
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getIdfa] forKey:@"idfa"];
        // 设备机型
        [deviceInfoArrM mercury_safeSetObject:[MercuryDeviceInfoUtil getModel] forKey:@"model"];
        // sdk version
        [deviceInfoArrM mercury_safeSetObject:Mercury_SDK_VERSION forKey:@"sdk_version"];
        [[MercuryDeviceInfoUtil sharedInstance] configUserAgentCompletion:^(NSString *user_agent) {
            [deviceInfoArrM mercury_safeSetObject:user_agent forKey:@"ua"];
            if (!self.cacheInfo) {
                self.cacheInfo = [NSMutableDictionary dictionaryWithDictionary:[deviceInfoArrM copy]];
            }
            completion([deviceInfoArrM copy]);
        }];
    }
}

- (void)clearDeviceInfoCache {
    _staticDeviceInfoM = nil;
    _cacheInfo = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:MercuryDeviceInfoUtilStaticDeviceInfoMKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// MARK: publich value
- (NSString *)ua {
    return [self.cacheInfo mercury_objectForKeyNotNil:@"ua"];
}

- (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (CGRect)bounds {
    return [UIScreen mainScreen].bounds;
}

/// 设置不变的设备数据
- (NSMutableDictionary *)staticDeviceInfoM {
    // 有值直接返回
    if (_staticDeviceInfoM) { return _staticDeviceInfoM; }
    // 无值先查找本地
    id diskMemoryDeviceInfo = [[NSUserDefaults standardUserDefaults] objectForKey:MercuryDeviceInfoUtilStaticDeviceInfoMKey];
    if (diskMemoryDeviceInfo) { // 如果有本地缓存 设置值后直接返回
        _staticDeviceInfoM = [diskMemoryDeviceInfo mutableCopy];
        return _staticDeviceInfoM;
    }
    if (!_staticDeviceInfoM) {  // 如果到这里_staticDeviceInfoM还不存在，则取一次，并缓存
        _staticDeviceInfoM = [[NSMutableDictionary alloc] init];
        // 请求广告的数量,默认是1
        [_staticDeviceInfoM mercury_safeSetObject:@1 forKey:@"impsize"];
        // 设备屏幕宽度,物理像素
        [_staticDeviceInfoM mercury_safeSetObject:[MercuryDeviceInfoUtil getScreenWidth] forKey:@"sw"];
        // 设备屏幕高度,物理像素
        [_staticDeviceInfoM mercury_safeSetObject:[MercuryDeviceInfoUtil getScreenHeight] forKey:@"sh"];
        // 设备像素密度,物理像素
        [_staticDeviceInfoM mercury_safeSetObject:[MercuryDeviceInfoUtil getPPI] forKey:@"ppi"];
        // 设备制造商
        [_staticDeviceInfoM mercury_safeSetObject:[MercuryDeviceInfoUtil getMake] forKey:@"make"];
        // 操作系统类型,0:未识别, 1:ios, 2:android
        [_staticDeviceInfoM mercury_safeSetObject:@1 forKey:@"os"];
        
        /// 设备信息存储到本地
        [[NSUserDefaults standardUserDefaults] setObject:_staticDeviceInfoM forKey:MercuryDeviceInfoUtilStaticDeviceInfoMKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    return _staticDeviceInfoM;
}

- (void)configUserAgentCompletion:(void (^ __nullable)(NSString *user_agent))completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *store_ua = [[NSUserDefaults standardUserDefaults] objectForKey:@"_Mercury_user_agent_key"];
        if (store_ua) { // 判断本地是否存了ua
            if (completion) { completion(store_ua); }
        }
        UIWindow *window = [UIApplication sharedApplication].mercury_getCurrentWindow;
        if (window) {
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
//            [self setContentModeForWebViewConfiguration:configuration];
            WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
            [window addSubview:wkWebView];
            [wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
                if (!store_ua) { // 如果本地不存在ua 走动态获取
                    if (result == nil) {
                        NSLog(@"获取UA失败");
                    } else {
                        if (completion) { completion(result); }
                    }
                }
                [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"_Mercury_user_agent_key"];
                [wkWebView removeFromSuperview];
            }];
        }
    });
}

- (void)setContentModeForWebViewConfiguration:(WKWebViewConfiguration*)configuration {
    if (@available(iOS 13.0, *)) {
        if ([configuration respondsToSelector:@selector(defaultWebpagePreferences)]
            && NSClassFromString(@"WKWebpagePreferences")) {
            id defaultWebpagePreferences = [configuration performSelector:@selector(defaultWebpagePreferences)];
            NSInteger wkContentMode = 1;
            NSMethodSignature* methodSignature = [NSClassFromString(@"WKWebpagePreferences") instanceMethodSignatureForSelector:@selector(setPreferredContentMode:)];
            NSInvocation *anInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
            [anInvocation setSelector:@selector(setPreferredContentMode:)];
            [anInvocation setTarget:defaultWebpagePreferences];
            [anInvocation setArgument:&wkContentMode atIndex:2];
            [anInvocation invoke];
        }
    }
}

+ (NSString *)getAppVersion {
    NSString *appVersion = @"";
    @try {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        appVersion = [infoDictionary mercury_objectForKeyNotNil:@"CFBundleShortVersionString"];
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return appVersion;
    }
}

+ (NSString *)getTime {
    NSString*timeString = @"";
    @try {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval a=[dat timeIntervalSince1970];
        timeString = [NSString stringWithFormat:@"%0.0f", a*1000];
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return timeString;
    }
}

+ (NSString *)getMake {
    return @"apple";
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4 {
    __block NSString *address;
    @try {
        NSArray *searchArray = preferIPv4 ?
          @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
          @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
          
          NSDictionary *addresses = [self getIPAddresses];
        //  MercuryLog(@"addresses: %@", addresses);
          
          [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
               address = addresses[key];
               //筛选出IP地址格式
               if([self isValidatIP:address]) *stop = YES;
           } ];
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return address ? address : @"0.0.0.0";
    }
    
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    BOOL passFlag = NO;
    @try {
        if (ipAddress.length == 0) {
                passFlag = NO;
            }
            NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
            "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
            "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
            "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
            
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
            
            if (regex && ipAddress) {
                NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
                
                if (firstMatch) {
        //            NSRange resultRange = [firstMatch rangeAtIndex:0];
        //            NSString *result=[ipAddress substringWithRange:resultRange];
                    //输出结果
         //           MercuryLog(@"%@",result);
                    passFlag = YES;
                }
            }
            passFlag = NO;
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return passFlag;
    }
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    @try {
        // retrieve the current interfaces - returns 0 on success
        struct ifaddrs *interfaces;
        if(!getifaddrs(&interfaces)) {
            // Loop through linked list of interfaces
            struct ifaddrs *interface;
            for(interface=interfaces; interface; interface=interface->ifa_next) {
                if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                    continue; // deeply nested code harder to read
                }
                const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
                char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
                if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                    NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                    NSString *type;
                    if(addr->sin_family == AF_INET) {
                        if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv4;
                        }
                    } else {
                        const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                        if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                            type = IP_ADDR_IPv6;
                        }
                    }
                    if(type) {
                        NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                        addresses[key] = [NSString stringWithUTF8String:addrBuf];
                    }
                }
            }
            // Free memory
            freeifaddrs(interfaces);
        }
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return [addresses count] ? addresses : nil;
    }
}

+ (NSNumber *)getScreenHeight {
   return [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.height*[UIScreen mainScreen].scale];
}

+ (NSNumber *)getScreenWidth {
   return [NSNumber numberWithFloat:[UIScreen mainScreen].bounds.size.width*[UIScreen mainScreen].scale];
}

+ (NSNumber *)getPPI {
    NSNumber *ppi = @(0);
    @try {
        NSString *model = [MercuryDeviceInfoUtil getModel];
        NSDictionary *modelPPiDict = [MercuryDeviceInfoUtil getModelPPIDict];
        ppi = [modelPPiDict objectForKey:model];
        if(!ppi) { ppi = @401; }
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return ppi;
    }
}

+ (NSString *)getModel {
    NSString *model = @"";
    @try {
        struct utsname systemInfo;
        uname(&systemInfo);
        model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return model;
    }
}

+ (NSString *)getOsv {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSDictionary *)getModelPPIDict {   //https://en.wikipedia.org/wiki/List_of_iOS_devices
    return    @{
                // 1st Gen
                @"iPhone1,1": @163,
                // 3G
                @"iPhone1,2": @163,
                // 3GS
                @"iPhone2,1": @163,
                //4
                @"iPhone3,1": @326,
                @"iPhone3,2": @326,
                @"iPhone3,3": @326,
                
                // 4S
                @"iPhone4,1": @326,
                
                // 5
                @"iPhone5,1": @326,
                @"iPhone5,2": @326,
                
                // 5c
                @"iPhone5,3": @326,
                @"iPhone5,4": @326,
                
                // 5s
                @"iPhone6,1": @326,
                @"iPhone6,2": @326,
                
                // 6 Plus
                @"iPhone7,1": @401,
                // 6
                @"iPhone7,2": @326,
                
                // 6s
                @"iPhone8,1": @326,
                
                // 6s Plus
                @"iPhone8,2": @401,
                
                // SE
                @"iPhone8,4": @326,
                
                // 7
                @"iPhone9,1": @326,
                @"iPhone9,3": @326,
                
                // 7 Plus
                @"iPhone9,2": @401,
                @"iPhone9,4": @401,
                
                //8
                @"iPhone10,1": @401,
                @"iPhone10,4": @401,
                
                //8 Plus
                @"iPhone10,2": @401,
                @"iPhone10,5": @401,
                
                //X
                @"iPhone10,3": @458,
                @"iPhone10,6": @458,
                //XS
                @"iPhone11,2":@458,
                //XS-MAX
                @"iPhone11,4" :@458,
                @"iPhone11,6" :@458,
                //XR
                @"iPhone11,8" :@326,
                @"iPhone12,1" :@326,
                @"iPhone12,3" :@458,
                @"iPhone12,5" :@458,
                
                
                //iPod
                // 1st Gen
                @"iPod1,1":@163,
                
                // 2nd Gen
                @"iPod2,1":@163,

                // 3rd Gen
                @"iPod3,1":@163,

                // 4th Gen
                @"iPod4,1":@326,

                // 5th Gen
                @"iPod5,1":@326,

                // 6th Gen
                @"iPod7,1":@326,
                
                //iPad

                @"iPad1,1":@132,
                // 2
                @"iPad2,1":@132,
                @"iPad2,2":@132,
                @"iPad2,3":@132,
                @"iPad2,4":@132,

                // Mini
                @"iPad2,5":@163,
                @"iPad2,6":@163,
                @"iPad2,7":@163,

                // 3
                @"iPad3,1":@264,
                @"iPad3,2":@264,
                @"iPad3,3":@264,

                // 4
                @"iPad3,4":@264,
                @"iPad3,5":@264,
                @"iPad3,6":@264,

                // Air
                @"iPad4,1":@264,
                @"iPad4,2":@264,
                @"iPad4,3":@264,

                // Mini 2
                
                @"iPad4,4":@326,
                @"iPad4,5":@326,
                @"iPad4,6":@326,

                // Mini 3
                @"iPad4,7":@326,
                @"iPad4,8":@326,
                @"iPad4,9":@326,

                // Mini 4
                @"iPad5,1":@326,
                @"iPad5,2":@326,

                // Air 2
                @"iPad5,3":@264,
                @"iPad5,4":@264,

                // Pro 12.9-inch
                @"iPad6,7":@264,
                @"iPad6,8":@264,

                // Pro 9.7-inch
                @"iPad6,3":@264,
                @"iPad6,4":@264,

                // iPad 5th Gen, 2017

                @"iPad6,11":@264,
                @"iPad6,12":@264,
                
                // iPad 2018
                @"iPad7,5":@264,
                @"iPad7,6":@264,
                };
}

+ (NSString *)getIdfa {
   return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (NSString *)getCarrier {
    NSString *result = @"";
    @try {
        CTTelephonyNetworkInfo *netInfo = [[CTTelephonyNetworkInfo alloc]init];
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        NSString *mcc = [carrier mobileCountryCode];
        NSString *mnc = [carrier mobileNetworkCode];
        if(!mcc) {
            return  @"";
        }
        result = [NSString stringWithFormat:@"%@%@",mcc,mnc];
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return result;
    }
}

+ (NSNumber *)getNetwork {
    NSNumber *res = @(0);
    @try {
        MercuryReachability *reach = [MercuryReachability reachabilityWithHostName:@"www.apple.com"];
        switch ([reach currentReachabilityStatus]) {
            case MercuryNetworkStatusNotReachable: { // 没有网络
                res = @(0);
            } break;
            case MercuryNetworkStatusReachableViaWiFi: { // Wifis
                res = @(1);
            } break;
            case MercuryNetworkStatusReachableViaWWAN: { // 手机自带网络
                CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
                NSString *currentStatus = info.currentRadioAccessTechnology;
                
                if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                    //netconnType = @"GPRS";
                    res = @2;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                   // netconnType = @"2.75G EDGE";
                    res = @2;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]) {
                    //netconnType = @"3G";
                    res = @3;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]) {
                   // netconnType = @"3.5G HSDPA";
                    res = @3;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]) {
                  //  netconnType = @"3.5G HSUPA";
                    res = @3;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]) {
                  //  netconnType = @"2G";
                    res = @2;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]) {
                  //  netconnType = @"3G";
                    res = @3;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]) {
                  //  netconnType = @"3G";
                    res = @3;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]) {
                   // netconnType = @"3G";
                    res = @3;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]) {
                  //  netconnType = @"HRPD";
                    res = @3;
                } else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]) {
                  //  netconnType = @"4G";
                    res = @4;
                } else {//TD-SCDMA WCDMA CDMA2000
                    res = @3;
                }
            }
        }
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return res;
    }
    return 0;
}
+ (NSNumber *)getDeviceType {
    NSNumber *res = @(0);
    @try {
        NSString *model = [MercuryDeviceInfoUtil getModel];
        NSRange rangeIphone = [model rangeOfString:@"iPhone"];
        NSRange rangeIpod =[model rangeOfString:@"iPod"];
        NSRange rangeX86 =[model rangeOfString:@"x86"];
        NSRange rangeIpad = [model rangeOfString:@"iPad"];

        if(rangeIphone.location != NSNotFound ||
           rangeIpod.location != NSNotFound ||
           rangeX86.location != NSNotFound) {
            res = @1;
        } else if(rangeIpad.location != NSNotFound) {
            res = @2;
        } else {
            res = @3;
        }
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return res;
    }
}

+ (NSString *)getTokenWithAppId:(NSString *)appId mediaKey:(NSString *)mediaKey time:(NSString *)time {
    NSString *res = @"";
    @try {
        NSString *beforeEncode = [NSString stringWithFormat:@"%@%@%@",appId,mediaKey,time];
        //进行UTF8的转码
        const char* input = [beforeEncode UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(input, (CC_LONG)strlen(input), result);
        
        NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
        for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            [digest appendFormat:@"%02x", result[i]];
        }
        res = [digest copy];
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return res;
    }
}

+ (NSString *)getReqid {
    NSString *uuidResult = @"";
    @try {
        NSString *uuidOrigin = [NSUUID UUID].UUIDString;
        NSString *uuidWithout = [uuidOrigin stringByReplacingOccurrencesOfString:@"-" withString:@""];
        uuidResult =[uuidWithout lowercaseString];
    } @catch (NSException *exception) {
        mercury_handleErrorWithException(exception);
    } @finally {
        return uuidResult;
    }
}

+ (NSString *)getIdfv {
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

@end

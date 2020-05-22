//
//  BY_HCLog.h
//  BY_BTVHTTPCache
//
//  Created by Single on 2017/8/17.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Log Enable Config
 */
#define BY_HCLogEnable(target, console_log_enable, record_log_enable)               \
static BOOL const BY_HCLog_##target##_ConsoleLogEnable = console_log_enable;        \
static BOOL const BY_HCLog_##target##_RecordLogEnable = record_log_enable;

#define BY_HCLogEnableValueConsoleLog(target)       BY_HCLog_##target##_ConsoleLogEnable
#define BY_HCLogEnableValueRecordLog(target)        BY_HCLog_##target##_RecordLogEnable

/**
 *  Common
 */
BY_HCLogEnable(Common,            YES, YES)

/**
 *  HTTP Server
 */
BY_HCLogEnable(HTTPServer,        YES, YES)
BY_HCLogEnable(HTTPConnection,    YES, YES)
BY_HCLogEnable(HTTPResponse,      YES, YES)

/**
 *  Data Storage
 */
BY_HCLogEnable(DataStorage,       YES, YES)
BY_HCLogEnable(DataRequest,       YES, YES)
BY_HCLogEnable(DataResponse,      YES, YES)
BY_HCLogEnable(DataReader,        YES, YES)
BY_HCLogEnable(DataLoader,        YES, YES)

BY_HCLogEnable(DataUnit,          YES, YES)
BY_HCLogEnable(DataUnitItem,      YES, YES)
BY_HCLogEnable(DataUnitPool,      YES, YES)
BY_HCLogEnable(DataUnitQueue,     YES, YES)

BY_HCLogEnable(DataSourceManager, YES, YES)
BY_HCLogEnable(DataFileSource,    YES, YES)
BY_HCLogEnable(DataNetworkSource, YES, YES)

/**
 *  Download
 */
BY_HCLogEnable(Download,          YES, YES)

/**
 *  Alloc & Dealloc
 */
BY_HCLogEnable(Alloc,             YES, YES)
BY_HCLogEnable(Dealloc,           YES, YES)

/**
 *  Log
 */
#define BY_HCLogging(target, console_log_enable, record_log_enable, ...)            \
if (([BY_HCLog log].consoleLogEnable && console_log_enable) || ([BY_HCLog log].recordLogEnable && record_log_enable))       \
{                                                                                   \
    NSString *va_args = [NSString stringWithFormat:__VA_ARGS__];                    \
    NSString *log = [NSString stringWithFormat:@"%@  :   %@", target, va_args];     \
    if ([BY_HCLog log].recordLogEnable && record_log_enable) {                      \
        [[BY_HCLog log] addRecordLog:log];                                          \
    }                                                                               \
    if ([BY_HCLog log].consoleLogEnable && console_log_enable) {                    \
        NSLog(@"%@", log);                                                          \
    }                                                                               \
}


/**
 *  Common
 */
#define BY_HCLogCommon(...)                 BY_HCLogging(@"BY_HCMacro           ", BY_HCLogEnableValueConsoleLog(Common),            BY_HCLogEnableValueRecordLog(Common),            ##__VA_ARGS__)

/**
 *  HTTP Server
 */
#define BY_HCLogHTTPServer(...)             BY_HCLogging(@"BY_HCHTTPServer       ", BY_HCLogEnableValueConsoleLog(HTTPServer),        BY_HCLogEnableValueRecordLog(HTTPServer),        ##__VA_ARGS__)
#define BY_HCLogHTTPConnection(...)         BY_HCLogging(@"BY_HCHTTPConnection   ", BY_HCLogEnableValueConsoleLog(HTTPConnection),    BY_HCLogEnableValueRecordLog(HTTPConnection),    ##__VA_ARGS__)
#define BY_HCLogHTTPResponse(...)           BY_HCLogging(@"BY_HCHTTPResponse     ", BY_HCLogEnableValueConsoleLog(HTTPResponse),      BY_HCLogEnableValueRecordLog(HTTPResponse),      ##__VA_ARGS__)

/**
 *  Data Storage
 */
#define BY_HCLogDataStorage(...)            BY_HCLogging(@"BY_HCDataStorage      ", BY_HCLogEnableValueConsoleLog(DataStorage),       BY_HCLogEnableValueRecordLog(DataStorage),       ##__VA_ARGS__)
#define BY_HCLogDataRequest(...)            BY_HCLogging(@"BY_HCDataRequest      ", BY_HCLogEnableValueConsoleLog(DataRequest),       BY_HCLogEnableValueRecordLog(DataRequest),       ##__VA_ARGS__)
#define BY_HCLogDataResponse(...)           BY_HCLogging(@"BY_HCDataResponse     ", BY_HCLogEnableValueConsoleLog(DataResponse),      BY_HCLogEnableValueRecordLog(DataResponse),      ##__VA_ARGS__)
#define BY_HCLogDataReader(...)             BY_HCLogging(@"BY_HCDataReader       ", BY_HCLogEnableValueConsoleLog(DataReader),        BY_HCLogEnableValueRecordLog(DataReader),        ##__VA_ARGS__)
#define BY_HCLogDataLoader(...)             BY_HCLogging(@"BY_HCDataLoader       ", BY_HCLogEnableValueConsoleLog(DataLoader),        BY_HCLogEnableValueRecordLog(DataLoader),        ##__VA_ARGS__)

#define BY_HCLogDataUnit(...)               BY_HCLogging(@"BY_HCDataUnit         ", BY_HCLogEnableValueConsoleLog(DataUnit),          BY_HCLogEnableValueRecordLog(DataUnit),          ##__VA_ARGS__)
#define BY_HCLogDataUnitItem(...)           BY_HCLogging(@"BY_HCDataUnitItem     ", BY_HCLogEnableValueConsoleLog(DataUnitItem),      BY_HCLogEnableValueRecordLog(DataUnitItem),      ##__VA_ARGS__)
#define BY_HCLogDataUnitPool(...)           BY_HCLogging(@"BY_HCDataUnitPool     ", BY_HCLogEnableValueConsoleLog(DataUnitPool),      BY_HCLogEnableValueRecordLog(DataUnitPool),      ##__VA_ARGS__)
#define BY_HCLogDataUnitQueue(...)          BY_HCLogging(@"BY_HCDataUnitQueue    ", BY_HCLogEnableValueConsoleLog(DataUnitQueue),     BY_HCLogEnableValueRecordLog(DataUnitQueue),     ##__VA_ARGS__)

#define BY_HCLogDataSourceManager(...)      BY_HCLogging(@"BY_HCDataSourceManager", BY_HCLogEnableValueConsoleLog(DataSourceManager), BY_HCLogEnableValueRecordLog(DataSourceManager), ##__VA_ARGS__)
#define BY_HCLogDataFileSource(...)         BY_HCLogging(@"BY_HCDataFileSource   ", BY_HCLogEnableValueConsoleLog(DataFileSource),    BY_HCLogEnableValueRecordLog(DataFileSource),    ##__VA_ARGS__)
#define BY_HCLogDataNetworkSource(...)      BY_HCLogging(@"BY_HCDataNetworkSource", BY_HCLogEnableValueConsoleLog(DataNetworkSource), BY_HCLogEnableValueRecordLog(DataNetworkSource), ##__VA_ARGS__)

/**
 *  Download
 */
#define BY_HCLogDownload(...)               BY_HCLogging(@"BY_HCDownload         ", BY_HCLogEnableValueConsoleLog(Download),          BY_HCLogEnableValueRecordLog(Download),          ##__VA_ARGS__)

/**
 *  Alloc & Dealloc
 */
#define BY_HCLogAlloc(obj)                  BY_HCLogging(obj, BY_HCLogEnableValueConsoleLog(Alloc),   BY_HCLogEnableValueRecordLog(Alloc),   @"alloc")
#define BY_HCLogDealloc(obj)                BY_HCLogging(obj, BY_HCLogEnableValueConsoleLog(Dealloc), BY_HCLogEnableValueRecordLog(Dealloc), @"dealloc")

@interface BY_HCLog : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)log;

/**
 *  DEBUG   : default is NO.
 *  RELEASE : default is NO.
 */
@property (nonatomic) BOOL consoleLogEnable;

/**
 *  DEBUG   : default is NO.
 *  RELEASE : default is NO.
 */
@property (nonatomic) BOOL recordLogEnable;

- (void)addRecordLog:(NSString *)log;

- (NSURL *)recordLogFileURL;
- (void)deleteRecordLogFile;

/**
 *  Error
 */
- (void)addError:(NSError *)error forURL:(NSURL *)URL;
- (NSDictionary<NSURL *, NSError *> *)errors;
- (NSError *)errorForURL:(NSURL *)URL;
- (void)cleanErrorForURL:(NSURL *)URL;

@end

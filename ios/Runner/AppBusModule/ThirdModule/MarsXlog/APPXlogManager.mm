//
//  ALXlogManager.m
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import "APPXlogManager.h"
#import <mars/xlog/appender.h>
#import <mars/xlog/xlogger.h>
#import <sys/xattr.h>

static NSUInteger g_processID = 0;

@interface APPXlogManager ()


@end

@implementation APPXlogManager

static APPXlogManager *shareInstance = nil;
+ (APPXlogManager *)shared {
    if (!shareInstance) shareInstance = [[self allocWithZone:NULL] init];
    return shareInstance;
}

- (void)initXlog:(const char *)prefixName pathName:(NSString *)pathName {
    
    // set do not backup for logpath
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    setxattr([pathName UTF8String], attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    // init xlog
#if DEBUG
    xlogger_SetLevel(kLevelDebug);
    mars::xlog::appender_set_console_log(true);
#else
    xlogger_SetLevel(kLevelInfo);
    mars::xlog::appender_set_console_log(false);
#endif
    mars::xlog::XLogConfig config;
    config.mode_ = mars::xlog::kAppenderAsync;
    config.logdir_ = [pathName UTF8String];
    config.nameprefix_ = prefixName;
    config.compress_mode_ = mars::xlog::kZlib;
    config.compress_level_ = 0;
    config.cachedir_ = "";
    config.cache_days_ = 0;
    appender_open(config);
}

// 关闭Xlog
- (void)closeXlog {
    mars::xlog::appender_close();
}

- (void)synchronizedFile {
    mars::xlog::appender_flush();
}

- (void)writelogModuleName:(const char*)moduleName
                  fileName:(const char*)fileName
                lineNumber:(int)lineNumber
                  funcName:(const char*)funcName
                   message:(NSString *)message{
    XLoggerInfo info;
    info.level = kLevelInfo;
    info.tag = moduleName;
    info.filename = fileName;
    info.func_name = funcName;
    info.line = lineNumber;
    gettimeofday(&info.timeval, NULL);
    info.tid = (uintptr_t)[NSThread currentThread];
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = g_processID;
    xlogger_Write(&info, message.UTF8String);
    
}

@end

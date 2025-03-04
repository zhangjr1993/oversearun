//
//  APPXlogManager.h
//  xlog_ios_demo
//
//  Created by 逸风 on 2022/3/5.
//

#import <Foundation/Foundation.h>



@interface APPXlogManager : NSObject

+ (instancetype)shared;

/// 初始化
- (void)initXlog:(const char *)prefixName pathName:(NSString *)pathName;

/// 关闭Xlog
- (void)closeXlog;

/// 同步
- (void)synchronizedFile;

/// 写入日志
- (void)writelogModuleName:(const char*)moduleName
                  fileName:(const char*)fileName
                lineNumber:(int)lineNumber
                  funcName:(const char*)funcName
                   message:(NSString *)message;

@end

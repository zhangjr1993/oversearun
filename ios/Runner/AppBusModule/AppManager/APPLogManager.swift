//
//  APPLogManager.swift
//  AIRun
//
//  Created by AIRun on 20248/4.
//

import UIKit
import Moya


class APPLogManager: NSObject {
    
    static let `default` = APPLogManager()

    
    static var txIMLogPath: String? {
        get {
            if let path = AppCacheManager.cachesDirectory {
                let fullPath = path.appending("/com_tencent_imsdk_log")
                return fullPath
            }
            return nil
        }
    }
    static var appLogPath: String? {
        get {
            if let path = AppCacheManager.cachesDirectory {
                let fullPath = path.appending("/com_Mars_log")
                return fullPath
            }
            return nil
        }
    }
    
    func initMarsXlog(content: String) {
        /// 日志初始化
        APPXlogManager.shared().closeXlog()
        let uid = "xlog_userId_App".cString(using: .utf8)
        APPXlogManager.shared().initXlog(uid, pathName: APPLogManager.appLogPath)
        self.writeLog(logStr: content)
    }

}

extension APPLogManager {
   
    func getTmpLogPath() -> String {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
        let tmpLogPath = directory + "/com_tmp_logPath"
        if FileManager.default.fileExists(atPath: tmpLogPath) == false {
            try? FileManager.default.createDirectory(atPath: tmpLogPath, withIntermediateDirectories: true, attributes: nil)
        }
        return tmpLogPath
    }
    
   
    /// 上报
    func reportAllLog(showMsg: Bool = true) {
        let reachability = try? Reachability()
        if reachability?.connection == .unavailable {
            self.showErrorTipMsg(msg: "Net failed")
            return
        }
        
        APPXlogManager.shared().synchronizedFile()
        
        
        let tmpPath = self.getTmpLogPath()
        
        if let path = APPLogManager.txIMLogPath {
            processCopyLogFiles(at: path, to: tmpPath)
        }
        if let path = APPLogManager.appLogPath {
            processCopyLogFiles(at: path, to: tmpPath)
        }
        guard let arr = FileManager.default.subpaths(atPath: tmpPath), arr.count > 0 else {
            self.showErrorTipMsg(msg: "Empty Log")
            return
        }
        
        self.showLoading()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd_HH-mm"
        let currentDate = Date()
        let zipPathComponent = "logs_\(formatter.string(from: currentDate)).zip"
        let zipPath = (tmpPath as NSString).appendingPathComponent(zipPathComponent)
        DispatchQueue.global().async {
            let result = SSZipArchive.createZipFile(atPath: zipPath, withContentsOfDirectory: tmpPath)
            DispatchQueue.main.async {
                if result, let file = NSData.init(contentsOfFile: zipPath) {
                    AppRequest(MineModuleApi.appUpload(imageData: file as Data, fileType: .log), modelType: BaseSmartModel.self) {[weak self] dataModel, model in
                        guard let `self` = self else { return }
                        let result: [String: Any] = model.data
                        if let url: String = result["url"] as? String {
                            
                            let params: [String: Any] = ["url": url]
                            self.uploadLogRequest(params: params, tempPath: tmpPath, showTip: showMsg)
                        }
                    } errorBlock: { [weak self] code, msg in
                        guard let `self` = self else { return }
                        self.hideLoading()
                        self.reportSuccessHandle(isUpload: false, tmpPath: tmpPath)
                    }
                }else {
                    self.hideLoading()
                }
            }
        }
       
    }
    
    // 提取公共逻辑到单独的方法
    private func processCopyLogFiles(at path: String, to tmpPath: String) {

        if let pathArr = FileManager.default.subpaths(atPath: path) {
            for fileName in pathArr {
                let fullPath = path + "/" + fileName
                let dict = try? FileManager.default.attributesOfItem(atPath: fullPath)
                
                if let date: Date = dict?[FileAttributeKey.modificationDate] as? Date {
                    // 3天
                    let time = 7.0 * 24.0 * 3600.0
                    let lastWeek = Date().addingTimeInterval(-time)
                    
                    let currentStr = date.formatterDate(formatter: "yyyy-MM-dd")
                    let lastStr = lastWeek.formatterDate(formatter: "yyyy-MM-dd")
                    
                    if currentStr.compare(lastStr) != .orderedAscending, fileName.hasSuffix(".xlog") {
                        let movePath = tmpPath + "/" + fileName
                        try? FileManager.default.copyItem(atPath: fullPath, toPath: movePath)
                    }
                }
            }
        }
    }
    
    private func uploadLogRequest(params: [String: Any], tempPath: String, showTip: Bool = true) {

        AppRequest(MineModuleApi.reportDeviceLog(params: params), modelType: BaseSmartModel.self) { [weak self] dataModel, model in
            guard let `self` = self else { return }
            self.hideLoading()
            if showTip {
                self.showSuccessTipMsg(msg: "Report Success")
            }
            self.reportSuccessHandle(isUpload: true, tmpPath: tempPath)

        } errorBlock: { [weak self] code, msg in
            guard let `self` = self else { return }
            self.hideLoading()
            self.reportSuccessHandle(isUpload: false, tmpPath: tempPath)
        }
    }
    
    private func reportSuccessHandle(isUpload: Bool, tmpPath: String) {
        let fileManager = FileManager.default
        
        if isUpload {
            if let path = APPLogManager.txIMLogPath {
                processDeleteFiles(path: path)
            }
            if let path = APPLogManager.appLogPath {
                processDeleteFiles(path: path)
            }
        }
        do {
            // zip
            try FileManager.default.removeItem(atPath: tmpPath)
                        
        } catch {
            print("Error while clearing files: \(error)")
        }
        
        
    }
    private func processDeleteFiles(path: String) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: path)
            // 遍历目录下的所有内容
            for fileName in contents {
                let filePath = (path as NSString).appendingPathComponent(fileName)
                if fileManager.fileExists(atPath: filePath), fileName.hasSuffix(".xlog") {
                    try fileManager.removeItem(atPath: filePath)
                }
            }
        }catch {
            print("Error while clearing files: \(error)")
        }
    }
    
}

extension APPLogManager {
    
    func requestCatchErrorLog(target: TargetType, errorMsg: String) {
        var userInfo: [String: Any] = [:]
        userInfo["errorMsg"] = errorMsg
        userInfo["url"] = target.baseURL.absoluteString
        userInfo["path"] = target.path
        self.dealUserInfo(userInfo)
    }
    
    func requestLogging(response: HTTPURLResponse?, errorMsg: String?, responseModel: ResponseModel?) {
        var userInfo: [String: Any] = [:]
        
        if let response {
            userInfo["url"] = response.url?.absoluteString
        }
        
        if let errorMsg {
            userInfo["errorMsg"] = errorMsg
        }
        
        if let responseModel {
            userInfo["code"] = responseModel.code
            userInfo["msg"] = responseModel.message
        }
        
        self.dealUserInfo(userInfo)
    }
    
    private func dealUserInfo(_ info: [String: Any]) {
        
        if let data = try? JSONSerialization.data(withJSONObject: info), let logStr = String(data: data, encoding: .utf8) {
            self.writeLog(logStr: logStr)
        }
    }
    
    func writeLog(logStr: String, file: String = #file, method: String = #function, line: Int = #line) {
        let tag = "uid = \(APPManager.default.loginUID)".cString(using: .utf8)
        APPXlogManager.shared().writelogModuleName(tag,
                                                   fileName: file,
                                                   lineNumber: Int32(line),
                                                   funcName: method,
                                                   message: logStr)
        APPXlogManager.shared().synchronizedFile()
    }
    
}

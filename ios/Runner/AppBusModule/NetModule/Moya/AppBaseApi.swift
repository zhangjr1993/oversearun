//
//  AppApi.swift
//  SwiftApp
//
//  Created by AIRun on 20244/12.
//

import Foundation
import Moya

// 服务器返回的数据
class ResponseModel {
    var code: Int = -999
    var message: String = ""
    // 这里的data用String类型 保存response.data
    var data: Dictionary<String, Any> = [:]
}

/// 通用
struct BaseSmartModel: SmartCodable {
    var mid = 0    
}

protocol AppBaseApi: TargetType {
   
    // 请求路径
    var appPath: String { get }
    
    var appVersion: String { get }

    var encoding: ParameterEncoding { get }
    
    /// 基础参数
    var baseParams: [String: String] { get }

    /// 路径参数 仅Get 需要
    var pathParams: [String: Any]? { get }
    
    /// 请求路径参数
    var urlParameters: [String: Any] { get }

    
}

extension AppBaseApi {
    
    var baseURL: URL {
        var baseUrlStr = RequestManager.share.baseUrlStr
        if UserDefaults.requestEncryption && !RequestManager.share.whiteUrlArr.contains(appPath) {
            if RequestManager.share.slowUrlArr.contains(appPath){
                baseUrlStr.append("/v1/route/slowindex")
            }else{
                baseUrlStr.append("/v1/route/index")
            }
            baseUrlStr.append("?path=/\(appVersion)/\(appPath)")
        }
        return URL.init(string: baseUrlStr)!
    }

    var path: String {
        if UserDefaults.requestEncryption && !RequestManager.share.whiteUrlArr.contains(appPath) {
            return ""
        }else {
            return "\(appVersion)/\(appPath)"
        }
    }
    
    var headers: [String: String]? {
        return ["platform": "ios", "version": AppConfig.runningNetVersion, "packageId": AppConfig.runningPkgID, "bundleId": AppConfig.runningBundleID, "deviceName": UIDevice.getIphoneType(), "iosVersion": UIDevice.current.systemVersion, "language": "en-US", "channelCode": "ios-appstore-\(AppConfig.runningPkgID)"]
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.httpBody
    }
    
    var baseParams: [String : String] {
        return [:]
    }
    var urlParameters: [String : Any] {
        var parhDic: [String: Any] = [:]
        if UserDefaults.requestEncryption && !RequestManager.share.whiteUrlArr.contains(appPath) {
            var requestP = ""
            if method == .post {
                if let param = pathParams, param.count > 0 {
                    let json = JSON(param)
                    requestP = json.rawString() ?? ""
                }
            }else{
                if let param = pathParams, param.count > 0 {
                    
                    var strArr: [String] = []
                    for (key, value) in param {
                        strArr.append("\(key)=\(value)")
                    }
                    requestP = strArr.joined(separator: "&")
                }
            }
            if method == .post {
                parhDic["path"] = "/\(appVersion)/\(appPath)"
            }
            parhDic["params"] = requestP.aes256Encrypt(key: RequestManager.share.encryKeyStr)
            parhDic["nonce"] = RequestManager.share.randomStr
        }else {
            if let pathParams {
                parhDic += pathParams
            }
        }
        return parhDic
    }
}

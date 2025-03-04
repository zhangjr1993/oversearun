//
//  AppConfigApi.swift
//  SwiftApp
//
//  Created by AIRun on 20244/12.
//

import Foundation
import Moya

enum AppConfigApi {
    /// 获取app启动配置
    case appConfig
    /// 上报设备标识
    case reportDevice(udid: String, deviceId: String)
    /// 上报设备APP日志
    case reportLog(fileUrl: String)
    /// 获取用户配置接口
    case getAppIndex
    /// 推送上报
    case reportMessagingID(gid: String)
}

extension AppConfigApi: AppBaseApi {
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    var pathParams: [String : Any]? {
        switch self {
        case .reportDevice(let udid, let deviceId):
            if udid.isValidStr {
                return ["udid": udid.rsaEncrypted(), "deviceId": deviceId.rsaEncrypted()]
            }else {
                return ["deviceId": deviceId.rsaEncrypted()]
            }
        case .reportLog(let fileUrl):
            return ["url": fileUrl]
        case .reportMessagingID(let gid):
            return ["googlePushId": gid]
        default:
            return nil
        }
    }
    var appVersion: String {
        return "v1"
    }
    var appPath: String {
        switch self {
        case .appConfig:
            return "app/getConfig"
        case .reportDevice(_,_):
            return "report/deviceInfo"
        case .getAppIndex:
            return "app/index"
        case .reportLog(_):
            return "report/log/device"
        case .reportMessagingID:
            return "report/GooglePushId"
        }
    }
    var method: Moya.Method {
        switch self {
        case .reportDevice, .reportLog, .reportMessagingID:
            return .post
        default:
            return .get
        }
    }
    var task: Moya.Task {
        switch self {
        case .appConfig, .getAppIndex:
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
        case .reportDevice, .reportLog, .reportMessagingID:
            return .requestCompositeParameters(bodyParameters: urlParameters, bodyEncoding: encoding, urlParameters: [:])
        }
        
    }
}

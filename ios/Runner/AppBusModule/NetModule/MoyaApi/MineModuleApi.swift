
//
//  configure.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//

import UIKit
import Moya

enum UploadFileType: Int {
    case image = 1
    case video = 2
    case log
}

enum MineModuleApi {
    
    case getMyInfo                                  /// 获取我的信息
    case memberOrder(params: [String: Any])
    case memberCheck(params: [String: Any])
    /// 用户拉黑列表
    case userBlockList(params: [String: Any])
    /// 关注列表
    case followingList(params: [String: Any])
    /// 修改用户资料
    case userModify(file: Data?, nick: String, sex: String)
    /// 上传文件
    case appUpload(imageData: Data?, fileType: UploadFileType)
    /// 上报日志
    case reportDeviceLog(params: [String: Any])

    
}

extension MineModuleApi: AppBaseApi {
    var encoding: ParameterEncoding { JSONEncoding.default }

    var pathParams: [String: Any]? {
        switch self {
        case    .memberOrder(let params),
                .memberCheck(let params),
                .userBlockList(let params),
                .followingList(let params),
                .reportDeviceLog(let params):
            return params
        default:
            return nil
        }
    }
    
    var appPath: String {
        switch self {
        case .getMyInfo:
            return "user/getMyInfo"
        case .memberOrder(_) :
            return "recharge/membershipApple"
        case .memberCheck(_) :
            return "recharge/notifyMembershipApple"
        case .userBlockList:
            return "user/blockList"
        case .followingList:
            return "user/followList"
        case .userModify:
            return "user/modify"
        case .appUpload:
            return "app/upload"
        case .reportDeviceLog:
            return "report/log/device"
            
        }
    }
    var appVersion: String {
        return "v1"
    }
    var method: Moya.Method {
        switch self {
        case    .userModify,
                .memberOrder,
                .memberCheck,
                .appUpload,
                .reportDeviceLog:
            return .post
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .appUpload(let imageData, let type) :
            let arr: [Moya.MultipartFormData] = APPManager.default.getMultipartFormData(type: type, imageData: imageData)
            return .uploadCompositeMultipart(arr, urlParameters: urlParameters)

        case .getMyInfo, .followingList, .userBlockList:
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
            
        case .memberOrder, .memberCheck, .reportDeviceLog:
            return .requestCompositeParameters(bodyParameters: urlParameters, bodyEncoding: encoding, urlParameters: [:])
        
        case .userModify(let imgData, let nick, let sex) :
            let param: [String: Any] = ["nickname": nick, "sex": sex]
            let dataArr = APPManager.default.getMultipartFormData(imageData: imgData, param: param, name: nil, dataName: "headPic")
            return .uploadCompositeMultipart(dataArr, urlParameters: urlParameters)
        }
    }
}

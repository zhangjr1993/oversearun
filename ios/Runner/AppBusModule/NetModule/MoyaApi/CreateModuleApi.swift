//
//  CreateModuleApi.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import Foundation

enum CreateModuleApi {
    /// 用户创建的AI列表接口
    case diyAIList(params: [String: Any])
    /// 编辑-保存AI信息
    case aiModify(params: [String: Any])
    /// 编辑-获取AI信息
    case editAIInfo(params: [String: Any])
    /// 删除AI接口
    case deleteAI(params: [String: Any])
    /// 定制AI上传图片接口-同时过机审
    case diyUploadImage(type: String, url: String, file: Data?)
    /// 创建-保存AI信息
    case createAI(params: [String: Any])
    /// AI文本信息过机审
    case createAICheckText(params: [String: Any])
    
}

extension CreateModuleApi: AppBaseApi {
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    var pathParams: [String : Any]? {
        switch self {
        case .diyAIList(let params), .aiModify(let params), .editAIInfo(let params),
                .deleteAI(let params), .createAI(let params), .createAICheckText(let params):
            return params
        default:
            return nil
        }
    }
    var appVersion: String {
        return "v1"
    }
    var appPath: String {
        switch self {
        case .diyAIList:
            return "user/diyAIList"
        case .aiModify:
            return "diyAI/modify"
        case .editAIInfo:
            return "diyAI/info"
        case .deleteAI:
            return "diyAI/delete"
        case .createAI:
            return "diyAI/save"
        case .createAICheckText:
            return "diyAI/check"
        case .diyUploadImage:
            return "diyAI/upload"
//        case .userBlock:
//            return ""
        }
    }
    var method: Moya.Method {
        switch self {
        case .diyAIList, .editAIInfo:
            return .get
        default:
            return .post
        }
    }
    var task: Moya.Task {
        switch self {
        case .diyAIList, .editAIInfo:
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
            
        case .diyUploadImage(let type, let url, let imgData):
            var param: [String: Any] = ["type": type]
            if url.isValidStr {
                param["url"] = url
            }
            let dataArr = APPManager.default.getMultipartFormData(imageData: imgData, param: param, name: nil, dataName: "data")
            return .uploadCompositeMultipart(dataArr, urlParameters: urlParameters)
            
        default:
            return .requestCompositeParameters(bodyParameters: urlParameters, bodyEncoding: encoding, urlParameters: [:])
        }
        
    }
}

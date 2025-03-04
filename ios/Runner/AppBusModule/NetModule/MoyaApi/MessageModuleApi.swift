//
//  Login.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import UIKit
import Moya

enum MessageModuleApi {
    /// 发送消息
    case IMSendMsg(params: [String: Any])
    /// 重置聊天上下文接口
    case resetChat(params: [String: Any])
    /// 获取AI信息接口
    case aiChatInfo(params: [String: Any])
    /// 批量获取AI信息接口
    case aiQuery(params: [String: Any])
}

extension MessageModuleApi: AppBaseApi {
    
    var encoding: ParameterEncoding { JSONEncoding.default }

    var pathParams: [String: Any]? {
        switch self {
        case .IMSendMsg(let params), .resetChat(let params), .aiChatInfo(let params), .aiQuery(let params):
            return params
        default:
            return nil
        }
    }
    var appPath: String {
        switch self {
        case .IMSendMsg:
            return "im/sendMsg"
        case .resetChat:
            return "im/resetChat"
        case .aiChatInfo:
            return "ai/chatInfo"
        case .aiQuery:
            return "ai/query"
        }
    }
    var appVersion: String {
        switch self {
        default:
            return "v1"
        }
    }
    var method: Moya.Method {
        switch self {
        case .IMSendMsg, .resetChat:
            return .post
        default:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .IMSendMsg, .resetChat:
            return .requestCompositeParameters(bodyParameters: urlParameters, bodyEncoding: encoding, urlParameters: [:])

        default:
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
        }


    }
}

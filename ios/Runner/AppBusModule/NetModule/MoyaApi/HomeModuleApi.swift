//
//  HomeModuleApi.swift
//  AIRun
//
//  Created by Bolo on 2025/1/21.
//

import Foundation
import Moya

enum HomeModuleApi {
    /// 首页列表
    case homeList(params: [String: Any])
    /// 搜索列表
    case searchList(params: [String: Any])
    /// ai主页
    case aiHomePage(params: [String: Any])
    /// ai/用户举报
    case allReport(params: [String: Any])
    /// ai拉黑
    case aiBlock(params: [String: Any])
    /// 用户拉黑
    case userBlock(params: [String: Any])
    /// ai关注/取关
    case aiAttention(params: [String: Any])
    /// 创建者用户主页
    case creatorHomePage(params: [String: Any])
}

extension HomeModuleApi: AppBaseApi {
    var encoding: ParameterEncoding { JSONEncoding.default }
    
    var pathParams: [String : Any]? {
        switch self {
        case .homeList(let params), .searchList(let params), .aiHomePage(let params), .allReport(let params), .aiBlock(let params), .aiAttention(let params), .creatorHomePage(let params), .userBlock(let params):
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
        case .homeList:
            return "ai/list"
        case .searchList:
            return "ai/search"
        case .aiHomePage:
            return "ai/homepage"
        case .allReport:
            return "user/report"
        case .aiBlock:
            return "ai/block"
        case .aiAttention:
            return "ai/attention"
        case .creatorHomePage:
            return "user/homepage"
        case .userBlock:
            return "user/block"
        }
    }
    var method: Moya.Method {
        switch self {
        case .allReport, .aiBlock, .aiAttention, .userBlock:
            return .post
        default:
            return .get
        }
    }
    var task: Moya.Task {
        switch self {
        case .homeList, .searchList, .aiHomePage, .creatorHomePage:
            return .requestParameters(parameters: urlParameters, encoding: URLEncoding.default)
        default:
            return .requestCompositeParameters(bodyParameters: urlParameters, bodyEncoding: encoding, urlParameters: [:])
        }
        
    }
}

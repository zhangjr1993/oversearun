//
//  Untitled.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//

enum LoginModuleApi {
    case getEmailCode(params: [String: Any])        /// 获取邮件验证码
    case emailLogin(params: [String: Any])          /// 邮件登录
    case googleLogin(params: [String: Any])         /// 谷歌登录
    case appleLogin(params: [String: Any])          /// 苹果登录
    case discordLogin(params: [String: Any])        /// discord登陆
    case loginOut                                   /// 退出登录
    case deleteAccount                              /// 注销账号

}

extension LoginModuleApi: AppBaseApi {
    
    var encoding: ParameterEncoding { JSONEncoding.default }

    var pathParams: [String: Any]? {
        switch self {
        case .getEmailCode(let params), .emailLogin(let params), .googleLogin(let params), .appleLogin(let params), .discordLogin(let params):
            return params
        default:
            return nil
        }
    }
    var appPath: String {
        switch self {
        case .getEmailCode(_):
            return "login/sendMail"
        case .emailLogin(_):
            return "login/email"
        case .googleLogin:
            return "login/google"
        case .appleLogin(_):
            return "login/apple"
        case .discordLogin(_):
            return "login/discord"
        case .loginOut:
            return "user/logout"
        case .deleteAccount:
            return "user/delete"
        }
    }
    var appVersion: String {
        return "v1"
    }
    var method: Moya.Method {
        return .post
    }
    var task: Moya.Task {
        return .requestCompositeParameters(bodyParameters: urlParameters, bodyEncoding: encoding, urlParameters: [:])
    }
}

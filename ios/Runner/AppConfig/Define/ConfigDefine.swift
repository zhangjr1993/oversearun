//
//  Root.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//

import UIKit

struct AppConfig {
    static let runningEnvironment = true
    static let runningPkgID = runningEnvironment ? "501" : "500"
    static let runningNetVersion = "1.0.0"
    static let runningBundleID = Bundle.main.bundleIdentifier!
    static let runningShotBundle = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    /// URLScheme
    static let runningScheme = "airun"

    static let runningUrl = "myhonyai"

    static let runningRsaPublicKey = "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAurVnjT+IZGGN5YWxOs5S\nCSyXQCXhYkwaZOTKom6yREy+EqUUE5o0Sw+6BtpLeNs8Wt8Hq1nu/yNpn5gOUggz\nBx1hZToWuDJl5Q9KujZo6e3ccblb2ZDVUwCh5t1zjiLzdvP+yAlyYIsQiPLjf5hV\n2pfecNVmIaBkSq9NfWu7l443k8WAsJYHTcbDuM1SibNknooVXtytvir/C9DFl4cp\nYqw9QJfXuVuD3co1dOxVtI9tXY9DNlFFzsasuE3nJzOIRQuMnhsP8G7a7/o4kXyu\n7X+yzTnIjyStbNCE8S2flgOhxo2igMgRfJc2cBqZBARKD+7jNimg07gfdafVOg5V\nuwIDAQAB\n-----END PUBLIC KEY-----\n"
    
}

struct ThirdConfig {
    
    static let other_IMAppID: Int32 =  AppConfig.runningEnvironment ? 70000623 : 20019357
    ///
    static let other_googleClientID = Bundle.main.infoDictionary!["GIDClientID"] as! String
    
    /// discord
    static let other_discordClientID = "1326093546419388507"
    static let other_discordClientSecret = "s9GRztNUrFnYMkaIypzOSY0cW2ZjaBK2"
    static let other_discordRedirectUri = AppConfig.runningEnvironment ? "https://m.\(AppConfig.runningUrl).com/user/oauth/discord/ipad" : "https://beta.myhonyai.com/user/oauth/discord/iphone"

    static let other_discordAuthorizeURL = "https://discord.com/oauth2/authorize"
}


func printLog<T>(message: T,
                    file: String = #file,
                  method: String = #function,
                    line: Int = #line) {
    #if DEBUG
    
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

// MARK: - UserDefaults
extension UserDefaults {
    
    private enum Keys {
        static let requestEncryption = "krequestEncryption"
        static let loginUserId = "kloginUserId"
        static let configBasicData = "kconfigBaseData"
        static let indexBasicData = "kindexBasicData"
        static let socketString = "ksocketUrl"
        /// 过滤开关
        static let userUnfilteredStatus = "userUnfilteredStatus"
    }
    
    /// loginUserId
    static var loginUserId: Int {
        get {
            return standard.integer(forKey: Keys.loginUserId)
        }
        set {
            standard.set(newValue, forKey: Keys.loginUserId)
            standard.synchronize()
        }
    }
    
    /// 加密请求
    static var requestEncryption: Bool {
        get {
            
            if let local = standard.string(forKey: Keys.requestEncryption) {
                return local.boolValue
            }
            return AppConfig.runningEnvironment
        }
        set {
            UserDefaults.standard.set(newValue ? "1":"0", forKey: Keys.requestEncryption)
            standard.synchronize()
        }
    }
    
    /// app/getconfig。这里是用的YYCache
    static var configBasicData: String {
        return Keys.configBasicData
    }
    
    /// app/index 这里是用的YYCache
    static var indexBasicData: String {
        return Keys.indexBasicData
    }
    
    /// socketurl
    static var socketString: String {
        get {
            return standard.string(forKey: Keys.socketString) ?? ""
        }
        set {
            standard.set(newValue, forKey: Keys.socketString)
            standard.synchronize()
        }
    }
    
    /// 未过滤开关：默认为关闭状态（即展示已过滤列表），开启后展示全部列表（未过滤+已过滤）
    /// 用loginUserId而不是APPManager.loginUserModel.user.uid，因为重启打开首页loginUserModel还未赋值
    static var userUnfilteredStatus: Bool {
        get {
            let keys =  Keys.userUnfilteredStatus + "\(UserDefaults.loginUserId)"
            return standard.bool(forKey: keys)
        }
        set {
            let keys =  Keys.userUnfilteredStatus + "\(UserDefaults.loginUserId)"
            standard.set(newValue, forKey: keys)
            standard.synchronize()
            NotificationCenter.default.post(name: .userFilterUpdate, object: nil)
        }
    }
}

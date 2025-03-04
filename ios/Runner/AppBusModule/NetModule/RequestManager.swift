//
//  File.swift
//  AIRun
//
//  Created by AIRun on 20247/10.
//

import Foundation
import WebKit

class RequestManager: NSObject {
    @objc static let share = RequestManager()
    private override init() {
        super.init()
    }
    override func copy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
    
    let baseUrlStr = "http://app.\(AppConfig.runningUrl).com"

    lazy var slowUrlArr: [String] = {
        return ["login/apple",
                "login/discord",
                "login/google",
                "login/sendMail",
                "diyAI/check",
                "diyAI/modify",
                "diyAI/save",
                "ai/search",
                "ai/query",
                "recharge/membershipApple",
                "recharge/notifyMembershipApple",
                "im/sendMsg"
        ]
    }()
    
    lazy var whiteUrlArr: [String] = {
        return ["app/upload",
                "diyAI/upload",
                "user/modify"
                ]
    }()
    
    lazy var randomStr: String = {
        return String.randomString(length: 16)
    }()
    
    lazy var encryKeyStr: String = {
        let sufStr = randomStr.suffix(6)
        let reversedStr: String = String(sufStr.reversed())
        return "GJAI25" + reversedStr
    }()
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension RequestManager {
    func func__updateAPPCookies(cookies: Array<HTTPCookie>) {
        print("func__updateAPPCookies = \(cookies)")
        if cookies.count == 0 {
            return
        }
        var tempUrlArr: Array<URL> = []
        if let baseUrl = URL.init(string: self.baseUrlStr) {
            tempUrlArr.append(baseUrl)
        }
        if let h5Url = URL.init(string: APPManager.default.config.H5UrlDomain) {
            tempUrlArr.append(h5Url)
        }
        var addCookieArr: Array<HTTPCookie> = []
        for cookies in cookies {
            var cookieInfo: [HTTPCookiePropertyKey: Any] = cookies.properties!
            for url in tempUrlArr {
                cookieInfo[HTTPCookiePropertyKey.domain] = url.host
                cookieInfo.removeValue(forKey: HTTPCookiePropertyKey.discard)
                if let newCookie = HTTPCookie.init(properties: cookieInfo){
                    addCookieArr.append(newCookie)
                }
            }
        }
        for cookies in addCookieArr {
            HTTPCookieStorage.shared.setCookie(cookies)
        }
        for url in tempUrlArr {
            deleteTheSameCookie(url: url)
        }
        DispatchQueue.main.async {
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: [WKWebsiteDataTypeCookies]) { _ in
                
            }
        }
    }
    func deleteTheSameCookie(url: URL) {
        if let cookiesArr = HTTPCookieStorage.shared.cookies(for: url) {
            var tempDic: Dictionary<String, String> = [:]
            for cookie in cookiesArr {
                if cookie.name.isValidStr {
                    if tempDic.keys.contains(cookie.name){
                        printLog(message: "deleteTheSameCookie = \(cookie.name)")
                        HTTPCookieStorage.shared.deleteCookie(cookie)
                    }else {
                        tempDic[cookie.name] = "1"
                    }
                }
            }
        }
    }
}

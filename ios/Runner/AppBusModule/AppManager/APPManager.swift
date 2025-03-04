//
//  APPManager.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import UIKit
import Moya

class APPManager {
    
    static let `default` = APPManager()
    
    /// 计算高度用
    var fitLabel = UILabel()
    
    var config: AppConfigModel =  AppConfigModel.init()
    
    var loginUserModel: UserModel?

    
    // 网络连接状态
    var isReachability = true {
        didSet {
            isReachabilitySubject.accept(isReachability)
        }
    }
    var isReachabilitySubject: PublishRelay<Bool> = PublishRelay.init()
    
    
    var requestAppConfigSucess = false
    var isRequestAppConfig = false
    
    
    static func userSex() -> UserSexType {
        if let user = APPManager.default.loginUserModel?.user {
            return user.sex
        }
        return .unowned
    }
    
    
    
}

extension APPManager {
    @discardableResult
    func isHasLogin(needJump: Bool = true) -> Bool {
        
        if AppCacheManager.default.localLoginUid() > 0 {
            return true
        }
        if needJump { /// 弹出登录视图
            APPPushManager.default.pushToAppLoginVC()
        }
        return false
    }

    /// 登入成功
    func loginSuccessHandle() {
//        requestReportDeviceID()
        AppDBManager.default.connectDatabase()
//        requestReportMessagingID()
        AppLoginManager.default.getmyInfoReq {
            APPIMManager.share.loginInTXIM()
            APPPushManager.default.checkToRefreshTheTopPageIsCreated()
        }
        AppCacheManager.default.clearLastChosed()
        AppCacheManager.default.saveLoginUid(APPManager.default.loginUID.integerValue)
        Crashlytics.crashlytics().setUserID(APPManager.default.loginUID)
        NotificationCenter.default.post(name: .userDidLogin, object: nil)
        AppMemberManager.default.checkUnfinishedTransactions()
    }
    /// 登出
    func loginOutHandle() {
        AppCacheManager.default.clearLastChosed()
        AppCacheManager.default.saveLoginUid(0)
        APPManager.default.loginUserModel = nil
        APPIMManager.share.loginOutTXIM()
        AppMemberManager.default.resultBlock = nil
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            appDelegate.setupHomeWindow()
        }
    }
    
    var loginUID: String {
        if let url = URL(string: RequestManager.share.baseUrlStr), let cookieArr = HTTPCookieStorage.shared.cookies(for: url) {
            for cookie in cookieArr {
                if cookie.name.uppercased() == "UID" {
                    return cookie.value
                }
            }
        }
        return ""
    }
    var loginPHPSESSID: String {
        if let url = URL(string: RequestManager.share.baseUrlStr), let cookieArr = HTTPCookieStorage.shared.cookies(for: url) {
            for cookie in cookieArr {
                if cookie.name.uppercased() == "PHPSESSID" {
                    return cookie.value
                }
            }
        }
        return ""
    }
}

extension APPManager {
    // MARK: - 计算size
    // font 字号
    // limitWidth、limitHeight 宽度固定算高 或 高度固定算宽，只能传一个进入
    // numLine 几行
    func setFitSize(text: String, font: UIFont, limitWidth: CGFloat?, limitHeight: CGFloat?, numLine: Int = 0) -> CGSize {
        let tempStr = text.replacingOccurrences(of: "\r", with: "")
        fitLabel.text = tempStr
        fitLabel.font = font
        fitLabel.numberOfLines = numLine
        
        if limitWidth == nil, limitHeight != nil {
            let size = fitLabel.sizeThatFits(CGSize(width: CGFLOAT_MAX, height: limitHeight!))
            return CGSize(width: size.width, height: size.height)
        }else if limitWidth != nil, limitHeight == nil {
            let size = fitLabel.sizeThatFits(CGSize(width: limitWidth!, height: CGFLOAT_MAX))
            return CGSize(width: size.width, height: size.height)
        }
        
        return .zero
    }
    
    func setFitSize(attrtbuted: NSAttributedString, font: UIFont, limitWidth: CGFloat?, limitHeight: CGFloat?, numLine: Int = 0) -> CGSize {
        fitLabel.attributedText = attrtbuted
        fitLabel.font = font
        fitLabel.numberOfLines = numLine
        fitLabel.lineBreakMode = .byWordWrapping
        
        if limitWidth == nil, limitHeight != nil {
            let size = fitLabel.sizeThatFits(CGSize(width: CGFLOAT_MAX, height: limitHeight!))
            return CGSize(width: size.width, height: limitHeight!)
        }else if limitWidth != nil, limitHeight == nil {
            let size = fitLabel.sizeThatFits(CGSize(width: limitWidth!, height: CGFLOAT_MAX))
            return CGSize(width: limitWidth!, height: size.height)
        }
        
        return .zero
    }
}



extension APPManager {
    
    func getMultipartFormData(imageData: Data?, param: [String: Any], name: String?, dataName: String) -> [Moya.MultipartFormData] {

        var arr: [Moya.MultipartFormData] = []
        for obj in param {
            if let _p = obj.value as? String, let _pData = _p.data(using: .utf8) {
                arr.append(MultipartFormData(provider: .data(_pData), name: obj.key))
            }
        }
        
        var fileName = name
        if name == nil {
            let timeInterval = Date().timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            fileName = "\(timeStamp).jpg"
        }
        
        if let data = imageData {
            arr.append(MultipartFormData(provider: .data(data),
                                         name: dataName,
                                         fileName: fileName,
                                         mimeType: "image/jpeg"))
        }

        return arr
        
    }
    func getMultipartFormData(type: UploadFileType, imageData: Data?) -> [Moya.MultipartFormData] {
        var param = ["upType" : type == .log ? "2" : "1"]
        
        var arr: [Moya.MultipartFormData] = []
        for obj in param {
            if let _p = obj.value as? String,
               let _pData = _p.data(using: .utf8) {
                arr.append(MultipartFormData(provider: .data(_pData),
                                             name: obj.key))
            }
        }
        if let imageData {
            let timeInterval = Date().timeIntervalSince1970
            let timeStamp = Int(timeInterval)
            
            var fileName = ""
            var mineType = ""
            if type == .log {
                fileName = String(format: "%d-%d.zip", timeStamp, APPManager.default.loginUserModel?.user?.uid ?? 0)
                mineType = "multipart/form-data"
            }else if type == .image {
                fileName = "\(timeStamp).jpg"
                mineType = "image/jpeg"
            }else {
                fileName = "\(timeStamp).mp4"
                mineType = "video/mp4"
            }
                        
            arr.append(MultipartFormData(provider: .data(imageData),
                                         name: "file",
                                         fileName: fileName,
                                         mimeType: mineType))
        }
                
        return arr
    }

}

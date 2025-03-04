//
//  APPH5Manager.swift
//  AIRun
//
//  Created by AIRun on 20247/20.
//

import UIKit


enum H5MethodType: String, CaseIterable {
    case normal = "app://normal/"        // 方法不存在
    case method = "app://method/"        // 调用本地方法
    case startNativePage = "app://page/" // 打开本地页面
}

enum H5MethodPath: String, CaseIterable {

    // MARK: - 打开本地页面
    /// 登录页
    case login = "login"
    /// 打开网页
    case webview = "webview"
    
    // MARK: - 调用客户端方法
    /// 刷新用户信息
    case refreshInfo = "refreshinfo"
    /// 日志
    case log = "log"
    /// 上报
    case report = "report"
    /// 设置右边按钮
    case setRightMenu = "setrightmenu"
    /// 隐藏右边按钮
    case hideRightMenu = "hiderightmenu"
    /// 关闭WebView
    case closeWebview = "closewebview"
    /// 充值
    case recharge = "recharge"
    
}


class APPH5Manager: NSObject {

    @objc static let share = APPH5Manager()
    
    private override init() {
        super.init()
        
    }
    override func copy() -> Any { return self }
    override func mutableCopy() -> Any { return self }
    
}

/// H5 相关

extension APPH5Manager {
    func handleH5Info(scheme: String) -> APPH5Model {

        var model = APPH5Model()
        for prefix in H5MethodType.allCases {
            if scheme.lowercased().hasPrefix(prefix.rawValue) {
                model.method = prefix
                let tempUrl = scheme.dropFirst(prefix.rawValue.count).description
                let arr = tempUrl.components(separatedBy: "?")
                let path = arr[safe: 0] ?? ""
                model.path = H5MethodPath.init(rawValue: path.lowercased())
                if let queryStr = arr[safe: 1], let temModel = H5QueryModel.deserialize(from: queryStr.urlParameters) {
                    model.queryModel = temModel
                }
            }
        }
        if model.method == .startNativePage {
            APPH5Manager.share.handleStartNativePage(model: model)
        }
        return model
    }
    
    func handleStartNativePage(model: APPH5Model) { // 处理H5Flutter跳转
        if let path = model.path {
            switch path {
            case .login:
                APPManager.default.loginOutHandle()
                break
            case .webview:
                if let urlStr = model.queryModel?.url {
                    if model.queryModel?.isExternal ?? false { // 打开外部浏览器
                        guard let url = URL(string: urlStr) else { return }
                        UIApplication.appOpenUrl(url: url) { isOpen in }
                    }else {
                        var config = WebViewConfig()
                        config.isHalf =  model.queryModel?.isHalf ?? false
                        config.isTransparent =  model.queryModel?.isTransparent ?? false
                        if config.isHalf || config.isTransparent {
                            config.showClose = true
                        }
                        APPPushManager.default.pushToWebView(webStr: urlStr, webConfig: config)
                    }
                }
                break
         
            default: break
            
            }
        }
    }
}

struct APPH5Model {
    var method: H5MethodType?
    var path: H5MethodPath?
    var queryModel: H5QueryModel?    // 参数模型
}

struct H5QueryModel: SmartCodable {
    
    // webView
    var url = ""
    var isNew = false
    var isExternal = false //外部浏览器
    var isHalf = false
    var isTransparent = false
 
    
    
    /// log日志数据
    var msg = ""
    
    // setRightMenu
    var action = ""
    var text = ""
    var icon = ""
    
    /// recharge
    var type = ""
    var price = ""
    var productId = ""
       
    
}

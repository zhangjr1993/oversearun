//
//  APPPushManager.swift
//  AIRun
//
//  Created by AIRun on 20247/18.
//

import UIKit


/**
 * 选择Ai引导优先级更高，但是和视图绑定，依靠isDelayShow处理
 */


class APPPushManager: NSObject {
    
    static let `default` = APPPushManager()
    /// 跳转防抖
    private var isPushing = false
    
    func getCurrentActivityVC() -> UIViewController? {
         let window: UIWindow = (UIApplication.shared.delegate?.window!)!
         let rootVC = window.rootViewController
        
         var vc: UIViewController?

         if rootVC!.isKind(of: UITabBarController.self) {
             let tabbar = rootVC as! UITabBarController
             vc = tabbar.selectedViewController
         }
         vc = getCurrentTopNavVC(vc: vc!)
         
         if vc!.isKind(of: UIAlertController.self) {
             return nil
         }
         return vc!
     }
     
     func getCurrentTopNavVC(vc: UIViewController) -> UIViewController {
         var tempVC = vc
         if tempVC.isKind(of: UINavigationController.self) {
             let tempNav = tempVC as! UINavigationController
             tempVC = tempNav.topViewController!
         }
         if tempVC.presentedViewController != nil {
             tempVC = getCurrentTopPresentVC(vc: tempVC)
         }
         return tempVC
     }

    func getCurrentTopPresentVC(vc: UIViewController) -> UIViewController {
         var tempVC = vc
         while tempVC.presentedViewController != nil {
             tempVC = tempVC.presentedViewController!
         }
         if tempVC.isKind(of: UINavigationController.self) {
             tempVC = getCurrentTopNavVC(vc: tempVC)
         }
         return tempVC
     }
    
}

extension APPPushManager {
    func pushToAppLoginVC() {
        guard let currentVC = self.getCurrentActivityVC() else { return }
        let loginVC = LoginController()
        loginVC.modalPresentationStyle = .overFullScreen
        currentVC.present(loginVC, animated: true)
    }
}
    
// MARK: - 跳转H5
extension APPPushManager {
    
    func pushToWebView(webType: H5WebType, webConfig: WebViewConfig = WebViewConfig()){
        let h5String = APPManager.default.config.H5UrlDomain + webType.rawValue
        self.pushToWebView(webStr: h5String, webConfig: webConfig)
    }
    
    func pushToWebView(webStr: String, webConfig: WebViewConfig = WebViewConfig()){
        var tempStr = webStr
        let regularStr = "version=\(AppConfig.runningNetVersion)&packageId=\(AppConfig.runningPkgID)&bundleId=\(AppConfig.runningBundleID)&platform=ios"
        tempStr.append(tempStr.contains("?") ? "&":"?")
        tempStr.append(regularStr)
        let webVC = WebViewController(urlString: tempStr, config: webConfig)
        if let currentVC = getCurrentActivityVC() {
            if webConfig.isHalf || webConfig.isTransparent  {
                currentVC.present(webVC, animated: true)
            }else{
                if currentVC.navigationController != nil {
                    currentVC.navigationController?.pushViewController(webVC, animated: true)
                }else{
                    let navi = BaseNavigationController.init(rootViewController: webVC)
                    navi.modalPresentationStyle = .fullScreen
                    currentVC.present(navi, animated: true)
                }
            }
        }
    }
    
   
}

// MARK: - 消息跳转相关
extension APPPushManager {
    func pushToChatView(aiMID: Int){
        
        if aiMID == ALConversationType.userSystemId.rawValue ||
            aiMID == ALConversationType.userSecretaryId.rawValue {
            
            let type = ALConversationType.init(rawValue: aiMID) ?? .userSystemId
            var model = ChatInfoDataModel()
            model.mid = aiMID
            model.nickname = type == .userSecretaryId ? "Offical Notice" : "System Message"
            model.headPic = type == .userSecretaryId ? "icon_chat_xiaomi" : "icon_chat_system"
            self.pushToChatController(chatInfo: model, type: type)
            return
        }
        
        AppRequest(MessageModuleApi.aiChatInfo(params: ["mid": aiMID]), modelType: ChatInfoDataModel.self) { [weak self] dataModel, model in
            guard let `self` = self else { return }
            self.pushToChatController(chatInfo: dataModel, type: .privete)
        }errorBlock: { code, msg in
            if code == ResponseErrorCode.aiDeleted.rawValue {
                APPIMManager.share.deleteAiConversation(aiMid: aiMID)
            }
        }
    }
    
    private func pushToChatController(chatInfo: ChatInfoDataModel, type: ALConversationType) {
        guard let currentVC = self.getCurrentActivityVC() else { return }
        guard let viewControllers = currentVC.navigationController?.viewControllers else { return }

        if viewControllers.count > 2 {
            let lastSecondVC = viewControllers[viewControllers.count - 2]
            if let tempChatVC: ChatViewController = lastSecondVC as? ChatViewController,
                tempChatVC.aiMID == chatInfo.mid {
                currentVC.navigationController?.popViewController(animated: true)
                return
            }
        }
#if DEBUG
        // 116397, 116400 测试专用
        var tempInfo = chatInfo
//        tempInfo.mid = 116397
        let chatVC = ChatViewController(chatInfo: tempInfo, type: type)

#else
        let chatVC = ChatViewController(chatInfo: chatInfo, type: type)

#endif
        
        chatVC.hidesBottomBarWhenPushed = true
        if currentVC.navigationController?.topViewController is ChatViewController {
            var arrM = viewControllers
            arrM.removeAll { $0 == currentVC }
            arrM.append(chatVC)
            currentVC.navigationController?.setViewControllers(arrM, animated: true)
        }else {
            currentVC.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
   
}

// MARK: - ai主页
extension APPPushManager {
    func pushAIHomePage(mid: Int, isPresent: Bool) {
        
        if self.isPushing {
            return
        }
        self.isPushing = true
        
        AppRequest(HomeModuleApi.aiHomePage(params: ["mid": mid]), modelType: AIHomeMainModel.self) { [weak self] result, model in
            guard let `self` = self else { return }
            self.isPushing = false
            guard let currentVC = self.getCurrentActivityVC() else { return }
            
            var queryModel = ChatQueryInfoModel()
            queryModel.mid = result.mid
            queryModel.nickname = result.nickname
            queryModel.headPic = result.headPic
            AppDBManager.default.batchUpdateAIData(list: [queryModel])
            
            if isPresent {
                let main = AIHomeMainController(mid, aiModel: result)
                main.isPresent = isPresent
                main.modalPresentationStyle = .custom
                
                // Calculate heights for presentation
                let screenHeight = UIScreen.screenHeight
                let statusBarHeight = UIScreen.statusBarHeight
                /// 初始高度
                let initialHeight = screenHeight - (UIScreen.statusBarHeight+42)
                /// 最大高度
                let maxHeight = screenHeight - statusBarHeight
                /// 消失高度
                let dismissHeight = initialHeight - 60
                
                // Create and set custom presentation controller
                let presentationController = AICustomPresentationController(
                    presentedViewController: main,
                    presenting: currentVC,
                    initialHeight: initialHeight,
                    maxHeight: maxHeight,
                    dismissHeight: dismissHeight
                )
                main.transitioningDelegate = presentationController
                currentVC.present(main, animated: true)
            }else {
                guard let viewControllers = currentVC.navigationController?.viewControllers else { return }
               
                var tempController: AIHomeMainController? = nil
                for controller in viewControllers {
                    if let temp = controller as? AIHomeMainController, temp.mid == mid {
                        tempController = temp
                        break
                    }
                }
                if tempController != nil {
                    currentVC.navigationController?.popToViewController(tempController!, animated: true)
                } else {
                    let main = AIHomeMainController(mid, aiModel: result)
                    main.isPresent = isPresent
                    if currentVC.navigationController?.topViewController is AIHomeMainController {
                        var arrM = viewControllers
                        arrM.removeAll { $0 == currentVC }
                        arrM.append(main)
                        currentVC.navigationController?.setViewControllers(arrM, animated: true)
                    } else {
                        currentVC.navigationController?.pushViewController(main, animated: true)
                    }
                }
            }
        } errorBlock: { [weak self] code, msg in
            guard let `self` = self else { return }
            self.isPushing = false
//            self.hideLoading()
            if code == ResponseErrorCode.aiDeleted.rawValue {
                APPIMManager.share.deleteAiConversation(aiMid: mid)
            }
        }
    }
}

// MARK: - user主页
extension APPPushManager {
    func pushUserHomePage(uid: Int) {
        
//        let params: [String: Any] = ["uid": uid,
//                                     "page": 1]
//
//        AppRequest(HomeModuleApi.creatorHomePage(params: params), modelType: CreatorHomeMainModel.self) { [weak self] result, model in
//            guard let `self` = self else { return }
//        }
//        
        /// 用户接口报错，测试说可以不处理
        guard let currentVC = getCurrentActivityVC() else { return }
        guard let viewControllers = currentVC.navigationController?.viewControllers else { return }

        var tempController: UserHomeMainController? = nil
        for controller in viewControllers {
            if let temp = controller as? UserHomeMainController, temp.userId == uid {
                tempController = temp
                break
            }
        }
        if tempController != nil {
            currentVC.navigationController?.popToViewController(tempController!, animated: true)
        }else {
            let main = UserHomeMainController(uid)
            if currentVC.navigationController?.topViewController is UserHomeMainController {
                var arrM = viewControllers
                arrM.removeAll { $0 == currentVC }
                arrM.append(main)
                currentVC.navigationController?.setViewControllers(arrM, animated: true)
            }else {
                currentVC.navigationController?.pushViewController(main, animated: true)
            }
        }
    }
}

/// tabbar
extension APPPushManager {
   
    func selectTabbarPage(type: TabBarItemType, index: Int = 0) { ///
        
        if let currentVC = getCurrentActivityVC() {
            guard currentVC.presentingViewController == nil else {
                // 如果有present, 先dismiss
                currentVC.dismiss(animated: false) {
                    self.selectTabbarPage(type: type)
                }
                return
            }
            if let root = UIApplication.shared.keyWindow?.rootViewController, let tabbar = root as? BaseTabBarController {
                tabbar.selectTabbar(type: type)
                currentVC.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    /// 创建页面登录的刷新列表
    func checkToRefreshTheTopPageIsCreated() {
        if let root = UIApplication.shared.keyWindow?.rootViewController,
            let tabbar = root as? BaseTabBarController,
            let topVC = tabbar.selectedViewController as? BaseNavigationController, topVC.tabBarItemType == .create,
            let createVC = topVC.viewControllers.first as? CreateMainController  {
            
            createVC.loadDiyListData()
        }
        
    }
}



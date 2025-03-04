//
//  APPManager+Request.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import Foundation

// MARK: - 启动
extension APPManager {
    func requestReportMessagingID() {
        Messaging.messaging().token { token, error in
            if let token = token {
                AppRequest(AppConfigApi.reportMessagingID(gid: token), modelType: BaseSmartModel.self) { dataModel, model in
                    print("上报推送ID")
                }errorBlock: { code, msg in
                    print(msg, code)
                }
            }
        }
    }
    
    func requestAppConfigData() {
        if requestAppConfigSucess || isRequestAppConfig {
            return
        }
        isRequestAppConfig = true
        AppRequest(AppConfigApi.appConfig, modelType: AppConfigModel.self, showErrorTip: false) { dataModel, model in
            self.requestAppConfigSucess = true
            self.isRequestAppConfig = false
            
            let tabsN = dataModel.tabs.toJSONString()
            let tabsO = APPManager.default.config.tabs.toJSONString()
            
            let tagsN = dataModel.tagList.toJSONString()
            let tagsO = APPManager.default.config.tagList.toJSONString()

            
            APPManager.default.config = dataModel
            AppCacheManager.default.saveModelData(model: dataModel, key: UserDefaults.configBasicData)
            self.handleGetAppConfig()

            /// 首页更新视图
            if tabsN != tabsO {
                NotificationCenter.default.post(name: .appConfigTabsUpdate, object: nil)
            }
            if tagsN != tagsO {
                NotificationCenter.default.post(name: .appConfigTagsUpdate, object: nil)
            }
        }errorBlock: { code, str in
            self.isRequestAppConfig = false
            if let configModel = AppCacheManager.default.loadCurrentModelData(modelType: AppConfigModel.self, key: UserDefaults.configBasicData) {
                APPManager.default.config = configModel
                self.handleGetAppConfig()
            }
        }
    }
    /// 请求完app/getConfig
    private func handleGetAppConfig() {
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootVC = appDelegate.window?.rootViewController {
            if rootVC.isKind(of: LaunchController.self) {
                appDelegate.setupHomeWindow()
            }
        }
    }
    
    /// 上报设备信息
    func requestReportDeviceID() {
        UIDevice.getDeviceDeviceIdentifier { idfa in

            AppRequest(AppConfigApi.reportDevice(udid: idfa , deviceId: idfa), modelType: BaseSmartModel.self, showErrorTip: false) { dataModel, model in
            }
        }
    }
}

// MARK: - 关注、拉黑
extension APPManager {
    /// ai关注、取消关注 isAtten true关注，false取消
    /// tabId防止当前页面刷新影响按钮防抖(我的关注AI列表tabId == 10000, AI主页10001)
    /// 不回调也能靠通知刷新
    func aiAttentionReq(mid: Int, isAtten: Bool, tabId: Int, complete: ((Bool) -> Void)?) {
        guard APPManager.default.isHasLogin() else { return }
        
        let params = ["mid": mid,
                      "type": isAtten ? 1 : 2]
        
        AppRequest(HomeModuleApi.aiAttention(params: params), modelType: BaseSmartModel.self) { result, model in
            NotificationCenter.default.post(name: .aiAttentionUpdated, object: ["mid": mid,
                                                                                "status": isAtten,
                                                                                "tab": tabId])
            complete?(true)
            let text = isAtten ? "Follow Success" : "Unfollow Success"
            NSObject().showSuccessTipMsg(msg: text)
        }errorBlock: { code, msg in
            complete?(false)
        }
    }
    
    /// ai拉黑、取消拉黑 isBlock true拉黑，false取消
    func aiBlockedReq(mid: Int, isBlock: Bool, isNeedToast: Bool = true, complete: ((Bool) -> Void)?) {
        
        let params = ["mid": mid,
                      "type": isBlock ? 1 : 2]
        
        AppRequest(HomeModuleApi.aiBlock(params: params), modelType: BaseSmartModel.self) { result, model in
            NotificationCenter.default.post(name: .aiBlockedUpdated, object: ["mid": mid, "status": isBlock])
            if isBlock, isNeedToast {
                NSObject().showSuccessTipMsg(msg: "Blocked")
            }
            complete?(true)
        }errorBlock: { code, msg in
            complete?(false)
        }
    }
    
    /// user拉黑、取消拉黑 isBlock true拉黑，false取消
    func userBlockedReq(uid: Int, isBlock: Bool, isNeedToast: Bool = true, complete: ((Bool) -> Void)?) {
        let params = ["uid": uid,
                      "type": isBlock ? 1 : 2]
        
        AppRequest(HomeModuleApi.userBlock(params: params), modelType: BaseSmartModel.self) { result, model in
            NotificationCenter.default.post(name: .userBlockedUpdated, object: ["uid": uid, "status": isBlock])
            if isBlock, isNeedToast {
                NSObject().showSuccessTipMsg(msg: "Blocked")
            }
            complete?(true)
        }errorBlock: { code, msg in
            complete?(false)
        }
    }
}

//
//  AppDelegate.swift
//  AIRun
//
//  Created by AIRun on 20247/4.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// 窗口
    var window: UIWindow?
    var reachability: Reachability?                                     // 网络监听
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupLaunchWindow()
        setupLocationService()
        addNetWorkReachabilityStatus(launchOptions: launchOptions)
        setupFireBase()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let count = APPIMManager.share.unreadMsgNum
        application.applicationIconBadgeNumber = count
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
        return true
    }
   
}

extension AppDelegate {
    private func setupLaunchWindow() {
        // 启动window
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        if let configModel = AppCacheManager.default.loadCurrentModelData(modelType: AppConfigModel.self, key: UserDefaults.configBasicData) {
            APPManager.default.config = configModel
            self.window?.rootViewController = BaseTabBarController()
        }else{
            self.window?.rootViewController = LaunchController()
        }
        APPManager.default.requestAppConfigData()
    }
    public func setupHomeWindow() {
        // 新建Window
        self.window?.rootViewController = BaseTabBarController()
    }
   
}


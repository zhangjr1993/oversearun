import UIKit
import Flutter
import IQKeyboardToolbarManager

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
    
    var reachability: Reachability?                                     // 网络监听

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        
//        self.window = UIWindow.init(frame: UIScreen.main.bounds)
//        self.window?.backgroundColor = .white
//        self.window?.makeKeyAndVisible()
        
        setupLaunchWindow()
        setupLocationService()
        addNetWorkReachabilityStatus(launchOptions: launchOptions)
        setupFireBase()

        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        let count = APPIMManager.share.unreadMsgNum
        application.applicationIconBadgeNumber = count
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceStr = deviceToken.map { String(format: "%02hhx", $0) }.joined()
         Messaging.messaging().apnsToken = deviceToken
         printLog(message: "APNS Token = \(deviceStr)")
         Messaging.messaging().token { token, error in
             if let error = error {
                 printLog(message: "error = \(error)")
             } else if let token = token {
                 printLog(message: "token = \(token)")
             }
         }
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("推送注册失败: \(error)")
    }
   
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        handleRemoteNotification(userInfo)
        
        completionHandler(.newData)
    }
    
    /// 点击消息（app运行中）
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // 处理业务跳转
        if UIApplication.shared.applicationState == .active {
           
        } else {
            
        }
        completionHandler()
    }
   
    
    // MARK: ---------------------------------------
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
    
    /// 本地服务，不依赖网络
    func setupLocationService() {
        let _ = AppMemberManager.default
        initAppearanceService()
        initKeyboardService()
        initProgressHUDService()
        UIButton.initializeMethod()
        APPLogManager.default.initMarsXlog(content: "app init")
    }
    /// 三方服务，依赖网络，在授权之后初始化
    
    func setupThirdService(launchOptions : [UIApplication.LaunchOptionsKey: Any]?) {

        DispatchQueue.once(token: QueueConfig.appInit) {
            DispatchQueue.main.async {
                self.setupGoogle()
                self.setupTXIM()
                self.registerNotifications()
            }
        }
    }
    
    func setupGoogle(){
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: ThirdConfig.other_googleClientID)
    }
    func setupTXIM(){
        APPIMManager.share.initIMSDK()
    }
        
    private func initKeyboardService() {
        IQKeyboardManager.shared.isEnabled = true
//        IQKeyboardToolbarManager.shared.isEnabled = false
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    private func initProgressHUDService() {
        
        ProgressHUD.fontBannerTitle = UIFont.blackFont(size: 16)
        ProgressHUD.fontBannerMessage = UIFont.mediumFont(size: 14)
        ProgressHUD.colorBannerMessage = UIColor.whiteColor(alpha: 0.6)
        ProgressHUD.colorBanner = UIColor(hexStr: "#292929")
    }
    private func initAppearanceService() {
        
        /// UIToolbar
        UIToolbar.appearance().setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        UIToolbar.appearance().setShadowImage(UIImage(), forToolbarPosition: .any)

        /// UINavigationBar
        let barApp = UINavigationBarAppearance.init()
        barApp.backgroundColor = UIColor.appBgColor()
        barApp.backgroundImage = UIImage.createColorImg(color: .appBgColor())
        barApp.shadowImage = UIImage.init()
        barApp.shadowColor = UIColor.appBgColor()
        barApp.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.appTitle1Color(), NSAttributedString.Key.font: UIFont.mediumFont(size: 17)]
        UINavigationBar.appearance().scrollEdgeAppearance = barApp
        UINavigationBar.appearance().standardAppearance = barApp
        UINavigationBar.appearance().tintColor = UIColor.appTitle1Color()
        UINavigationBar.appearance().barTintColor = UIColor.appTitle1Color()
        UINavigationBar.appearance().isTranslucent = false
       
    }
    
    func setupFireBase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    func registerNotifications() {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: { (result, error) in
            print(error ?? "")
        })
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
   
    func handleRemoteNotification(_ userInfo: [AnyHashable : Any]?) {
        if UIApplication.shared.applicationState == .active {
            
        }else {
            
        }
    }
    
   
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        print("didReceiveRegistrationToken = \(dataDict)")
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
           object: nil,
            userInfo: dataDict)
    }
    func addNetWorkReachabilityStatus(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        
        if self.reachability == nil {
            guard let reachability = try? Reachability() else { return }
            self.reachability = reachability
        }
        reachability!.whenReachable = { reach in
            switch reach.connection {
            case .wifi, .cellular:
                print("Network reachable \(reach.connection)")
                self.setupThirdService(launchOptions: launchOptions)
                APPManager.default.requestAppConfigData()
                APPManager.default.isReachability = true
            default:
                print("Network not reachable")
                APPManager.default.isReachability = false
            }
        }
        reachability!.whenUnreachable = { _ in
            print("Not reachable")
            APPManager.default.isReachability = false
        }
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
}

//
//  AppCacheManager.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//


/// 缓存的config
class AppCacheManager {
    
    static let `default` = AppCacheManager()
    
    /// 首页的选项
    var homeFilter = AppHomeFilterModel()
        
    /// home
    static let homeDirectory = NSHomeDirectory()
    /// caches
    static let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    /// document
    static let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last
    
    var appCacheDirectory: String?


    init() {
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last {
            let tempPath = path.appending("/AppUserCache")
            let ret: UnsafeMutablePointer<ObjCBool> = UnsafeMutablePointer.allocate(capacity: 1)
            var isExist = FileManager.default.fileExists(atPath: tempPath, isDirectory: ret)
            if !isExist || !ret.pointee.boolValue {
                try? FileManager.default.createDirectory(at: URL(fileURLWithPath: tempPath), withIntermediateDirectories: false)
            }
            appCacheDirectory = tempPath
        }
        setupMemoryWarningHandler()
    }
    
    lazy var appCache: YYCache? = {
        if let yy = YYCache.init(path: AppCacheManager.default.appCacheDirectory ?? "") {
            return yy
        }
        return nil
    }()
}

extension AppCacheManager {
    func saveModelData<T: SmartCodable>(model: T, key: String) {
        if let yy = appCache {
            let jsonString = model.toJSONString()
            yy.setObject(jsonString as? any NSCoding, forKey: key)
        }
    }
    func loadCurrentModelData <T: SmartCodable>( modelType: T.Type , key: String) -> T? {
        if let yy = appCache , let jsonString = yy.object(forKey: key) as? String, let model = T.deserialize(from: jsonString) {
            return model
        }
        return nil
    }
}
// MARK: - uid
extension AppCacheManager {

    // 登入
    func saveLoginUid(_ uid: Int?) {
        if let uid {
            UserDefaults.loginUserId = uid
        }
    }
    // 本地登录的uid
    func localLoginUid() -> Int {
        
        return UserDefaults.loginUserId
    }
    
    /// 清楚选项
    func clearLastChosed() {
        self.homeFilter = AppHomeFilterModel()
    }
}

extension AppCacheManager {
    private func setupMemoryWarningHandler() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    @objc private func handleMemoryWarning() {
        // 清理内存缓存
        ImageCache.default.clearMemoryCache()
//        // 可选：清理磁盘缓存
//        ImageCache.default.clearDiskCache()
    }
    
    func startMonitoring() {
        // 设置缓存限制
        ImageCache.default.memoryStorage.config.totalCostLimit = 800 * 1024 * 1024  // 800MB
        ImageCache.default.diskStorage.config.sizeLimit = 1000 * 1024 * 1024       // 1GB
    }
}

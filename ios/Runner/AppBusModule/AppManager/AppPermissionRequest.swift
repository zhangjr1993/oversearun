//
//  AppPermissionRequest.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import UIKit
import Photos

enum ALPermissionResultType: Int {
    // 未知
    case unknown
    // 没有询问过
    case notDetermined
    // 允许
    case alwaysAllow
    // 允许，下次询问
    case onceAllow
    // 拒绝
    case refused
    
    /// 是否可以访问
    var isAuthorized: Bool {
        return self == .alwaysAllow || self == .onceAllow
    }
}

/// 系统权限
class AppPermissionRequest: NSObject {
    
    public typealias Callback = ((ALPermissionResultType, Bool) -> Void)?
    
    public typealias AlertClickBack = ((Int) -> Void)?
    
    static let `default` = AppPermissionRequest()
    
    override init() {
        super.init()
        addObserver()
    }
    
    /// 麦克风
    var microphoneStatus: ALPermissionResultType = .notDetermined {
        didSet {
            microphoneSubject.accept(microphoneStatus)
        }
    }
    var microphoneSubject: PublishRelay<ALPermissionResultType> = PublishRelay.init()

    /// 相机
    var cameraStatus: ALPermissionResultType = .notDetermined {
        didSet {
            cameraSubject.accept(cameraStatus)
        }
    }
    var cameraSubject: PublishRelay<ALPermissionResultType> = PublishRelay.init()
    
    /// 相册
    var photoAlbumStatus: ALPermissionResultType = .notDetermined {
        didSet {
            photoAlbumSubject.accept(photoAlbumStatus)
        }
    }
    var photoAlbumSubject: PublishRelay<ALPermissionResultType> = PublishRelay.init()
    
    /// 通知
    var apnsStatus: ALPermissionResultType = .notDetermined {
        didSet {
            apnsSubject.accept(apnsStatus)
        }
    }
    var apnsSubject: PublishRelay<ALPermissionResultType> = PublishRelay.init()
  
    
}

/// 麦克风
extension AppPermissionRequest {
    func requestMicrophonePermission(_ callBack: Callback) {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            microphoneStatus = .alwaysAllow
        case .undetermined:
            microphoneStatus = .notDetermined
        case .denied:
            microphoneStatus = .refused
        default:
            microphoneStatus = .unknown
        }
        
        if microphoneStatus == .notDetermined {
            AVAudioSession.sharedInstance().requestRecordPermission { auth in
                self.microphoneStatus = auth ? .alwaysAllow : .refused
                callBack?(self.microphoneStatus, true)
            }
        }else {
            callBack?(microphoneStatus, false)
        }
    }
}

/// 相册
extension AppPermissionRequest {
    func requestPhotoAlbumPermission(_ callBack: Callback) {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized: photoAlbumStatus = .alwaysAllow
        case .notDetermined: photoAlbumStatus = .notDetermined
        case .restricted: photoAlbumStatus = .refused
        case .denied: photoAlbumStatus = .refused
        default: photoAlbumStatus = .unknown
        }

        if photoAlbumStatus == .notDetermined {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized {
                    self.photoAlbumStatus = .alwaysAllow
                } else if status == .denied {
                    self.photoAlbumStatus = .refused
                }
                callBack?(self.photoAlbumStatus, true)
            }
        } else {
            callBack?(photoAlbumStatus, false)
        }
    }
    
    static func showPhotoAlbumAlert(_ clickBack: AlertClickBack) {
        
        var config = AlertConfig()
        config.title = "an't access photos in album"
        config.content = "Currently no photo access，System settings recommended，\nAllow access to all photos in photos."
        config.cancelTitle = "I knowd"
        config.confirmTitle = "Settings"
        
        let alert = BaseAlertView(config: config) { actionIndex in
            if actionIndex == 2 {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.appOpenUrl(url: url)
                }
            }
            clickBack?(actionIndex)
        }
        alert.show()
    }
}

/// 相机
extension AppPermissionRequest {
    func requestCameraPermission(_ callBack: Callback) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraStatus = .alwaysAllow
        case .notDetermined:
            cameraStatus = .notDetermined
        case .restricted:
            cameraStatus = .refused
        case .denied:
            cameraStatus = .refused
        default:
            cameraStatus = .unknown
        }
        
        if cameraStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: .video) { auth in
                self.cameraStatus = auth ? .alwaysAllow : .refused
                callBack?(self.cameraStatus, true)
            }
        }else {
            callBack?(cameraStatus, false)
        }
    }
}

/// 通知
extension AppPermissionRequest {
    func getNotificationSettings() -> UNAuthorizationStatus {
        var status: UNAuthorizationStatus = .notDetermined
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                status = settings.authorizationStatus
                semaphore.signal()
            }
        }
        semaphore.wait()
        return status
    }
    
    func requestNotificationPermission(_ callBack: Callback) {
        let userNotification = UNUserNotificationCenter.current()

        userNotification.getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .authorized:
                self.apnsStatus = .alwaysAllow
            case .notDetermined:
                self.apnsStatus = .notDetermined
            case .provisional:
                self.apnsStatus = .onceAllow
            case .denied:
                self.apnsStatus = .refused
            default:
                self.apnsStatus = .unknown
            }
            
            if self.apnsStatus == .notDetermined {
                userNotification.requestAuthorization(options: [.badge, .alert, .sound]) { authorized, error in
                    self.apnsStatus = authorized ? .alwaysAllow : .refused
                    callBack?(self.apnsStatus, true)
                }
            } else {
                callBack?(self.apnsStatus, false)
            }
        }

    }
}

extension AppPermissionRequest {
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(willBecomeAvailable(noti:)), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    
    @objc private func willBecomeAvailable(noti: Notification) {
        
    }
}

//
//  UIDevice+Extension.swift
//  AIRun
//
//  Created by AIRun on 20247/7.
//

import Foundation
import AdSupport
import AppTrackingTransparency

extension UIScreen {
    // 屏幕宽度
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    // 屏幕高度
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    // 屏幕比例
    static var screenScale: CGFloat {
        return UIScreen.main.scale
    }
    // 状态栏高度
    static var statusBarHeight: CGFloat {
        let statusBarManager: UIStatusBarManager = UIApplication.shared.windows.first!.windowScene!.statusBarManager!
        return statusBarManager.statusBarFrame.size.height
    }
    
    // 导航栏高度
    static var navigationBarHeight: CGFloat {
        return 44.0
    }
    
    // 导航栏高度 + 状态栏
    static var navigationStatusBarHeight: CGFloat {
        return navigationBarHeight + statusBarHeight
    }
    
    // 底部Tabbar高度
    static var tabBarHeight: CGFloat {
        return 44.0 + safeAreaInsets.bottom
    }
    
    // 安全区域
    static var safeAreaInsets: UIEdgeInsets {
        return UIApplication.shared.windows.first?.safeAreaInsets ?? .zero
    }
    
    /// 是否刘海屏
    static var isFullScreen: Bool {
        guard let w = UIApplication.shared.delegate?.window, let unwrapedWindow = w else {
            return false
        }
        if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
            return true
        }
        return false
    }
}

extension UIScreen {
    /// 首页瀑布流图片宽高
    static var homeListHeaderWidth: CGFloat {
        return (screenWidth-32-12)/2
    }
    
    //
    static func adaptWidth(_ width: CGFloat) -> CGFloat {
        return  width/375.0*screenWidth
    }
    
}

extension UIDevice {
    
    static func getDeviceDeviceIdentifier ( IdentifierBlock: @escaping (_ str: String) -> Void ) {
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
            if status == .authorized {
                IdentifierBlock(UIDevice.getDeviceRawAdvertisingId())
            } else {
                IdentifierBlock("00000000-0000-0000-0000-000000000000")
            }
        })
    }
    
    static func getDeviceRawAdvertisingId() -> String {
        var deviceIdentifier = "00000000-0000-0000-0000-000000000000"
        let adIdentifier =  ASIdentifierManager.shared().advertisingIdentifier
        if adIdentifier.uuidString.isValidStr {
            deviceIdentifier = adIdentifier.uuidString
        }
        return deviceIdentifier
    }
    
    static func getIphoneType() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = machineMirror
            .children.reduce("") { identifier, element in
                guard let value = element.value as? Int8,
                      value != 0 else {
                    return identifier
                }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
        return identifier
    }
}

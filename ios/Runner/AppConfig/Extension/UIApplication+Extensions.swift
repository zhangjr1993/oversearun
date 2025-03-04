//
//  UIApplication+Extensions.swift
//  AIRun
//
//  Created by AIRun on 20247/19.
//

import Foundation

extension UIApplication {
    
    static func appOpenUrl(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    static func appOpenUrl(url: URL, completion: @escaping ((Bool) -> Void)) {
        DispatchQueue.main.async {
            self.mianThreadOpenUrl(url: url, completion: completion)
        }
    }
    
    static func mianThreadOpenUrl(url: URL, completion: @escaping ((Bool) -> Void)) {
        UIApplication.shared.open(url, options: [:]) { (success) in
            completion(success)
        }
    }    
}

extension UIApplication {
    static var key: UIWindow? {
        return UIApplication.shared
            .connectedScenes
            .filter { $0.activationState == .foregroundActive && $0 is UIWindowScene }
            .compactMap { $0 as? UIWindowScene }.first?.windows
            .filter { $0.isKeyWindow }.first
    }
}

//
//  File.swift
//  AIRun
//
//  Created by AIRun on 20247/10.
//

import Foundation

struct QueueConfig {
    static let statusBarInit    = "statusBarInit"
    static let appInit          = "appInit"
    static let buttonInit       = "buttonInit"
}
extension DispatchQueue {
    private static var _onceTracket = [String]()
    class func once(token:String , block:() -> Void) {
        if _onceTracket.contains(token) {
            return
        }
        _onceTracket.append(token)
        block()
    }
}

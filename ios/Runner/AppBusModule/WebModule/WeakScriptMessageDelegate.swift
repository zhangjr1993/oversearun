//
//  WeakScriptMessageDelegate.swift
//  AIRun
//
//  Created by AIRun on 20247/27.
//

import UIKit
import WebKit

class WeakScriptMessageDelegate: NSObject, WKScriptMessageHandler {

    weak var scriptDelegate: WKScriptMessageHandler?
    
    init(_ scriptDelegate: WKScriptMessageHandler) {
        self.scriptDelegate = scriptDelegate
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("js call method name = \(message.name), message = \(message.body)")

        DispatchQueue.main.async {
            self.scriptDelegate?.userContentController(userContentController, didReceive: message)
        }
    }
    
}

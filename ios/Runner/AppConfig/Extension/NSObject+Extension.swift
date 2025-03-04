//
//  File.swift
//  AIRun
//
//  Created by AIRun on 20247/10.
//

import Foundation

extension NSObject {
        
    func showErrorTipMsg(msg: String, duration: CGFloat = 2.5) {
        guard msg.isValidStr else { return  }
        ProgressHUD.colorBannerTitle = UIColor.appYellowColor()
        
        ProgressHUD.banner("Error", msg)
    }
    
    func showSuccessTipMsg(msg: String, duration: CGFloat = 2.5) {

        guard msg.isValidStr else { return }
        ProgressHUD.colorBannerTitle = UIColor(hexStr: "#57E095")
        ProgressHUD.banner("Success", msg)
    }
    
}


extension NSObject {
    /// 是否可以透传
    func showLoading(text: String = "", interaction: Bool = false){
        /// text颜色
        ProgressHUD.colorStatus = UIColor.appPinkColor()
        /// 背景色
        ProgressHUD.colorHUD = UIColor(hexStr: "#242325")
        ProgressHUD.colorAnimation = .appPinkColor()
        ProgressHUD.animationType = .ballVerticalBounce
        ProgressHUD.animate(text, interaction: interaction)
    }
    func hideLoading(){
        ProgressHUD.dismiss()
    }
}


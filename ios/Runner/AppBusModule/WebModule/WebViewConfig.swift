//
//  File.swift
//  AIRun
//
//  Created by AIRun on 20247/11.
//

import Foundation


enum H5WebType: String {
    case defalut = ""
    ///
    case vip = "/vip"
    /// 用户协议
    case userAgreement = "/policy/userTerms"
    /// 隐私协议
    case privacyAgreement = "/policy/privacyPolicy"
    
}


struct WebViewConfig {
    
    var widthHeight: Double?  // 屏幕展示比例：0：全屏展示；大于0：屏幕高度 = 屏宽*weight
    var isHalf = false         // 是否半屏
    var isTransparent = false  // 是否透明
    var showClose = false  // 加载失败时增加关闭按钮
    var isFull = true  // 是否全页面
}

//
//  AppConfigModel.swift
//  AIRun
//
//  Created by AIRun on 20247/7.
//

import Foundation

struct AppConfigModel: SmartCodable {
    
    var staticDomain: String = ""       // 静态资源域名
    var urlDomain: String = ""          // H5资源域名
//    var ws: [String] = []               // Socket 链接
    var tabs: [HomeTabListModel] = []   // 首页Tab
    var tagList: [HomeTagListModel] = []   // 首页Tag
    
    var H5UrlDomain: String {
        return urlDomain.isValidStr ?  urlDomain : "https://m.\(AppConfig.runningUrl).com"
    }
    var staticUrlDomain: String {
        return staticDomain.isValidStr ?  staticDomain : "https://static.\(AppConfig.runningUrl).com"
    }
    
}

struct HomeTabListModel: SmartCodable {
    
    var tab = 0                 //
    var tabName: String = ""    // 名称
}

struct HomeTagListModel: SmartCodable {
    var id = 0                 //
    var name: String = ""    // 名称
    var sort = 0
    /// 1-过滤标签，2-未过滤标签
    var is_filter = 0
    
}


struct AppIndexModel: SmartCodable {
    var userSig: String = ""
    // 消息详情页面免责说明
    var disclaimer: String = ""
    /// 选择ai免责声明
    var aiDisclaimer = ""
    /// 默认选中tab
    var defaultTab = 1
    
}

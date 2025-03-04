//
//  HomeSearchModel.swift
//  AIRun
//
//  Created by Bolo on 2025/1/22.
//

import UIKit

struct TempHomeSearchModel: SmartCodable {
    var hasNext = false
    var list: [HomeSearchModel] = []
}

struct HomeSearchModel: SmartCodable {
    var mid = 0
    
    var nickname = ""
    
    var headPic = ""
    /// 简介
    var profile = ""
    /// ai收到的消息条数
    var msgNum = ""
    /// 1-过滤，2-未过滤
    var isFilter = 0
}

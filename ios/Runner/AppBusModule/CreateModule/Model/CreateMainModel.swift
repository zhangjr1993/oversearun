//
//  CreateMainModel.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import UIKit

struct CreateMainModel: SmartCodable {
    var hasNext = false
    var list: [CreateMainListModel] = []
}

struct CreateMainListModel: SmartCodable {
    
    var headPic = ""
    
    var mid = 0
    
    var nickname = ""
    
    var profile = ""
    
    var sex: UserSexType = .unowned
    
    var tags: [String] = []
    /// AI头像，false:已审核 true：审核中
    var isAudit = false
    /// 1:过滤2未过滤
    var isFilter = 0
}

//
//  CreatorHomeMainModel.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

struct CreatorHomeMainModel: SmartCodable {
    var nickname = ""
    var headPic = ""
    var isBlock = false
    var aiList: [HomeCommonListModel] = []
}



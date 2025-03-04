//
//  MineBlockListModel.swift
//  AIRun
//
//  Created by Bolo on 2025/2/6.
//

import UIKit

struct TransferMineBlockListModel: SmartCodable {
    var list: [MineBlockListModel] = []
    /// 更多
    var hasNext = false
}

struct MineBlockListModel: SmartCodable {
    var id = 0
    var nickname = ""
    var headPic = ""
}

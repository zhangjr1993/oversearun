//
//  AIHomeMainModel.swift
//  AIRun
//
//  Created by Bolo on 2025/1/23.
//

import UIKit

/// AI主页
struct AIHomeMainModel: SmartCodable {
    var mid = 0
    
    var nickname = ""
    
    var headPic = ""
    /// 简介
    var profile = ""
    /// 标签列表
    var tags: [String] = []
    /// 相册列表
    var gallery: [String] = []
    /// ai收到的消息条数
    var msgNum = ""
    /// 是否关注
    var isAttention = false
    /// 关注数
    var attentionNum = ""
    /// 1-过滤，2-未过滤
    var isFilter = 0
    /// 是否拉黑
    var isBlock = false
    ///
    var creatorInfo = CreatorMainModel()
}

/// 创建者
struct CreatorMainModel: SmartCodable {
    var uid = 0
    
    var nickname = ""
    
    var headPic = ""
    
    var characters: [CreatorCharactersModel] = []
}

/// 创建者创建过的AI
struct CreatorCharactersModel: SmartCodable{
    var mid = 0
    
    var nickname = ""
    
    var headPic = ""
}

//
//  ChatInfoDataModel.swift
//  AIRun
//
//  Created by Bolo on 2025/2/11.
//

import UIKit

struct ChatInfoDataModel: SmartCodable {
    var mid = 0
    
    var nickname = ""
    
    var headPic = ""
    /// 简介
    var profile = ""
    /// 开场白，仅游客模式本地插入用
    var greeting = ""
    /// 开场白图片，仅游客模式本地插入用
    var greetingPic = ""
    /// 创建者
    var creator = CreatorMainModel()
}

struct ChatMsgJumpModel: SmartCodable {
    /// 消息为文本msgContent内容
    var text = ""
    /// 消息为语音msgContent内容
    var color = ""
    var jumpUrl = ""
}

struct TransferChatQueryInfoModel: SmartCodable {
    var list: [ChatQueryInfoModel] = []
}

/// 数据库
struct ChatQueryInfoModel: SmartCodable, TableCodable {
    var mid = 0
    var headPic = ""
    var nickname = ""
    
    enum CodingKeys: String, CodingTableKey {
        typealias Root = ChatQueryInfoModel
        static let objectRelationalMapping = TableBinding(CodingKeys.self)
        case mid
        case headPic
        case nickname
    }
}

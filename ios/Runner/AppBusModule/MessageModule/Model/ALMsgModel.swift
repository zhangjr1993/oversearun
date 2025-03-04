//
//  ALMsgModel.swift
//  AIRun
//
//  Created by AIRun on 20247/20.
//

import Foundation

/// 后端返回类型，文案客户端写死
enum ALCustomLocalMsgType: Int {
    /// 月会员过期
    case lapseMonthMembership = 10001
    /// 年会员过期
    case lapseYearMembership = 10002
    /// 月会员激活
    case openMonthMember = 10003
    /// 年会员激活
    case openYearMember = 10004
}

struct ALMsgModel: SmartCodable {
    
    var msgId = 0       // 消息唯一id
    var replyId = 0     // 回复的消息id，ai主动发起的消息id为0
    var fromUid = 0     // 发送消息的ai
    var toUid = 0       // 接收消息用户uid
    var msgSeq = 0
    /*
     * 消息类型
     * 1-文本；2-图文(包含开场白)；6-枚举消息，本地写死的
     * 未登录 1000-开场白
     */
    var msgType = 0
    var tips = ""       // 新增消息类型兼容文案
    var msgSendTime = 0 //发送消息的时间戳秒
    var msgContent: String?   // 消息内容序列化后的字符串
    var userInfo: ALMsgUserModel?       // 用户信息

    var contentModel: ALMsgContentModel?       // 消息信息
    
    
    var themeID = 0     //图片主题id

}


struct ALMsgContentModel: SmartCodable {
    
    /// 消息为文本msgContent内容
    var text = ""
    
    /// 消息为语音msgContent内容
    var audioUrl = ""
    var audioLen = 0
    var audioLocalPath = "" // 本地文件路径

    /// 图文消息
    var imgMsg: ALMsgImageModel?
    
    /// 消息为jump List msgContent内容
    var textList: [ChatMsgJumpModel] = []
    var animation = "" // 动效
    
    /// 消息为剧情内容消息title&text
    var title = ""

    /// 展示对应枚举的消息内容
    var msg_enum = 0
    /// 0-普通消息展示，1-横幅展示
    var show_type = 0
}

struct ALMsgImageModel: SmartCodable {
    var imgUrl = ""
    var imgType = 0
}

struct ALMsgUserModel: SmartCodable {
    
    /// 消息为文本msgContent内容
    var nickname = ""

    var uid = ""
    
}


// MARK: - 发送消息结果Model
struct SendMsgResultModel: SmartCodable {
    var msgId = 0
}

struct MsgToAudioResultModel: SmartCodable {
    var url = ""
}



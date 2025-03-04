//
//  UserModel.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//

struct UserModel: SmartCodable {
    
    var user: UserInfoModel?
    var vip: UserVipModel?
    /// TX
    var userSig = ""
}

struct UserInfoModel: SmartCodable {
    ///
    var nickname = ""
    /// 头像
    var headPic = ""
    /// 头像审核状态 true表示审核中
    var headPicAudit = false
    ///
    var sex: UserSexType = .unowned
    ///
    var uid: Int = 0
    /// 剩余免费消息数量
    var freeMsgNum: Int = 0
    /// 用户是否已完善资料
    var isUpdateInfo = true
    /// 余额
    var coin = "0"
    /// 是否已经获得签到奖励，true领取过了
    var newcomerAward = false
}

struct UserVipModel: SmartCodable {
    /// vip
    var vipStatus: UserVipStatusType = .unowned
    /// 结束时间
    var endTime = ""
}


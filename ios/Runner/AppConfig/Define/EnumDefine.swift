//
//  EnumDefine.swift
//  AIRun
//
//  Created by AIRun on 2025/1/15.
//


enum UserSexType:Int, SmartCodable {
    init() {
        self = .unowned
    }
    case unowned
    case boy = 1
    case girl = 2
    case quadratic = 3 // 二次元
}

enum ImageCropType {
    /// 最大比例裁剪
    case maximumEdge(CGSize)
    /// 方块
    case equalProportion
}

enum ButtonBackgroundColorType {
    /// 正常按钮主色
    case normal
    /// 0.7主色
    case disableNormal
    /// 浅灰色
    case lightGray
}

/// 1普通2vip3vip过期
enum UserVipStatusType: Int, SmartCodable {
    init() {
        self = .unowned
    }
    case unowned = 0
    case normal = 1
    case vip = 2
    case expired = 3
}

// MARK: - 接口错误码
enum ResponseErrorCode: Int {
    /// 上传图片违规
    case uploadPic_illegal = 11011
    /// Ai已被删除
    case aiDeleted = 10003
    /// AI角色已被禁用
    case aiBanned = 10011
    /// 登录态失效，显示登录弹窗
    case loginTimeout = 10004
    /// 未登录，显示登录弹窗
    case notLogin = 10005
    /// 发消息数美拦截
    case shumeiBanned = 14010
    /// 免费消息用完
    case freeMsgLimited = 14011
}

// MARK: - 对话类型
enum ALConversationType: Int, CaseIterable {
    /// 官方小蜜
    case userSecretaryId = 1000
    /// 系统帐号
    case userSystemId = 1001
    /// 官方帐号
//    case userOfficialId = 1002
    /// 私信
    case privete
}

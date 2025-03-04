//
//  AIEditMainInfoModel.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

/// 编辑AI接口的
struct AIEditMainInfoModel: SmartCodable {
    /// 背景
    var background = ""
    ///
    var gallery: [AIEditMainGalleryModel] = []
    /// 开场白
    var greeting = ""
    /// 开场白图片
    var greetingUrl = ""
    ///
    var headPic = ""
    ///
    var isFilter = 0
    /// 1-私有2-公开
    var isShow = 0
    ///
    var mid = 0
    ///
    var nickname = ""
    ///
    var profile = ""
    ///
    var sex: UserSexType = .unowned
    ///
    var tags: [Int] = []
}

/// 上传图片用作解析model，修改时请注意关联
struct AIEditMainGalleryModel: SmartCodable {
    var id = 0
    var url = ""
}

/// 过机审文本
struct AIEditContentReqModel: SmartCodable {
    var text = ""
    // 2-AI昵称;3-AI简介;4-AI开场白
    var type = 0
}

/// 审核失败的类型
struct AIEditContentResponseModel: SmartCodable {
    /// 2-AI昵称;3-AI简介;4-AI开场白
    var illegalType: [Int] = []
}

/// 编辑资料机审失败
struct UserEditReviewModel: SmartCodable {
    /// 1昵称2头像
    var illegalType: [Int] = []
}

//
//  HomeCommonListModel.swift
//  AIRun
//
//  Created by Bolo on 2025/1/21.
//

import UIKit

struct TransferHomeCommonListModel: SmartCodable {
    var list: [HomeCommonListModel] = []
    /// 更多
    var hasNext = false
}

struct HomeCommonListModel: SmartCodable {

    var mid = 0
    
    var nickname = ""
    
    var headPic = ""
    
    var sex: UserSexType = .unowned
    
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
    /// 1-过滤，2-未过滤
    var isFilter = 0
    ///
    var createType = 0
    @IgnoredKey
    /// 计算高度
    var itemHeight: CGFloat = 0
    
    mutating func calculateHeight() {
        let imageHeight = UIScreen.homeListHeaderWidth
        let margin = 16.0
        let nickHeight = 8.0 + 16.0
        let profileHeight = 6.0 + 13.0
        
        var tagsHeight: CGFloat = 0
        var rect = CGRect(x: 0, y: 0, width: 0, height: 16)
        
        for text in tags {
            let size = text.textSizeIn(size: CGSize(width: CGFLOAT_MAX, height: 16), font: .regularFont(size: 12), lineSpace: 0, breakMode: .byWordWrapping, alignment: .center)
            rect.size = CGSize(width: size.width+12, height: 16)
            
            if rect.origin.x + rect.size.width > imageHeight - 16 {
                rect.origin = CGPoint(x: 8, y: CGRectGetMaxY(rect)+6)
            }
            rect.origin.x = CGRectGetMaxX(rect) + 4

            if rect.origin.y >= 38 {
                break
            }
        }
        tagsHeight = tags.count > 0 ? min(38, CGRectGetMaxY(rect)) : 0
        
        itemHeight = imageHeight + nickHeight + profileHeight + margin + tagsHeight
    }
}

//
//  AIEditingMainModel.swift
//  AIRun
//
//  Created by Bolo on 2025/2/8.
//

import UIKit

enum AIEditSectionType: String, CaseIterable {
    case avatar = "*Avatar"
    case name = "*Name"
    case gender = "*Gender"
    case visibility = "*Visibility"
    case rating = "*Rating"
    case tags = "*Tags"
    case intro = "*Intro"
    case greet = "*Greeting"
    case pic = "Pictures"
    case personal = "Personality & Background"
}

enum AIEditingComplianceStatus {
    case unowed
    case illegal
    case pass
}

class AIEditingMainModel: NSObject {
    /// 头像
    var avatarAsset: AIEditingGalleryModel?
    /// 昵称
    var nick = ""
    /// 性别
    var sex: UserSexType = .unowned
    /// 1私有2公开
    var isShow = 0
    /// 过滤
    var isFilter = 0
    /// tags
    var tags: [Int] = []
    /// tags字符串
    var tagsList: [String] = []
    /// intro
    var intro = ""
    /// 开场白
    var greetStr = ""
    /// 开场白图片
    var greetAsset: AIEditingGalleryModel?
    /// personal
    var personal = ""
    /// 9图
    var photoAssets: [AIEditingGalleryModel] = []
    
    override func deepCopy() -> Any? {
        let zone = AIEditingMainModel()
        zone.avatarAsset = self.avatarAsset
        zone.nick = self.nick
        zone.sex = self.sex
        zone.isShow = self.isShow
        zone.isFilter = self.isFilter
        zone.tags = self.tags
        zone.intro = self.intro
        zone.greetStr = self.greetStr
        zone.greetAsset = self.greetAsset
        zone.personal = self.personal
        zone.photoAssets = self.photoAssets
        return zone
    }
    
    /// 编辑
    convenience init(editInfo: AIEditMainInfoModel) {
        self.init()

        if let url = URL(string: editInfo.headPic) {
            let photoAsset = PhotoAsset(NetworkImageAsset(thumbnailURL: url, originalURL: url))
            let avatarModel = AIEditingGalleryModel(asset: photoAsset, type: "1")
            avatarModel.url = editInfo.headPic
            self.avatarAsset = avatarModel
        }
        
        self.nick = editInfo.nickname
        self.sex = editInfo.sex
        self.isShow = editInfo.isShow
        self.isFilter = editInfo.isFilter
        self.tags = editInfo.tags
        self.intro = editInfo.profile
        
        self.greetStr = editInfo.greeting
        if let url = URL(string: editInfo.greetingUrl) {
            let photoAsset = PhotoAsset(NetworkImageAsset(thumbnailURL: url, originalURL: url))
            let grertModel = AIEditingGalleryModel(asset: photoAsset, type: "3")
            grertModel.url = editInfo.greetingUrl
            self.greetAsset = grertModel
        }
        
        self.personal = editInfo.background
        
        var galleryList: [AIEditingGalleryModel] = []
        editInfo.gallery.forEach { subModel in
            if let url = URL(string: subModel.url.checkDomain()) {
                let photoAsset = PhotoAsset(NetworkImageAsset(thumbnailURL: url, originalURL: url))
                let model = AIEditingGalleryModel(asset: photoAsset, type: "2")
                model.url = subModel.url
                model.id = subModel.id
                galleryList.append(model)
            }
        }
        self.photoAssets = galleryList
    }
    
    /// 上传文件的jsonDict
    convenience init(parsed: [String: Any], origin: [String: Any]?, fileURL: URL) {
        self.init()
        
        let fileName = fileURL.lastPathComponent.lowercased()
        if fileName.hasSuffix(".json") {
            if let avatar = parsed["avatar"] as? String, let url = URL(string: avatar) {
                let photoAsset = PhotoAsset(NetworkImageAsset(thumbnailURL: url, originalURL: url))
                let model = AIEditingGalleryModel(asset: photoAsset, type: "1")
                model.url = avatar
                self.avatarAsset = model
            }
            
        }else {
            let photoAsset = PhotoAsset(localImageAsset: LocalImageAsset.init(imageURL: fileURL))
            let model = AIEditingGalleryModel(asset: photoAsset, type: "1")
            self.avatarAsset = model
        }
        
        self.nick = parsed["nickname"] as? String ?? ""
        self.intro = parsed["intro"] as? String ?? ""
        self.personal = parsed["personality"] as? String ?? ""
        self.tags = parsed["tags"] as? [Int] ?? []
    }
    
    
    static func getReuseId(type: AIEditSectionType) -> String {
        switch type {
        case .avatar:
            return AIEditMainAvatarCell.description()
        case .name:
            return AIEditMainNickCell.description()
        case .gender, .visibility, .rating:
            return AIEditMainButtonCell.description()
        case .tags:
            return AIEditMainTagsCell.description()
        case .intro, .personal:
            return AIEditMainTextViewCell.description()
        case .greet:
            return AIEditMainGreetingCell.description()
        case .pic:
            return AIEditMainGalleryCell.description()
        }
    }
    
    /// tagId >> tagStr
    static func getTagStr(with tagSet: [Int]) -> [HomeTagListModel] {
        let tempArr = APPManager.default.config.tagList
        let list = tempArr.filter({ tagSet.contains($0.id) })
        return list
    }
}

class AIEditingGalleryModel: NSObject {
    
    var photoAsset: PhotoAsset?
    
    var url = ""
    
    var id = 0
    /// 1AI头像，2AI相册，3AI开场白图片
    var type = ""
    /// 审核失败，标记删除
    var isDelete = false
    
    convenience init(asset: PhotoAsset, type: String) {
        self.init()
        self.photoAsset = asset
        self.type = type
    }
}

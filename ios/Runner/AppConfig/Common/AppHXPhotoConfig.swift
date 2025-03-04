//
//  AppHXPhotoConfig.swift
//  AIRun
//
//  Created by Bolo on 2025/2/7.
//

import Foundation

class AppHXPhotoConfig: NSObject {
    static func avatarConfig() -> PickerConfiguration {
        var config = PickerConfiguration()
        config.languageType = .english

        config.pickerPresentStyle = .present()
        config.modalPresentationStyle = .fullScreen
        // 图片和视频是否可以一起选择
        config.selectMode = .single
        config.selectOptions = [.photo]
        config.allowSelectedTogether = false
        config.maximumSelectedCount = 1
        config.photoSelectionTapAction = .openEditor
        // 创建时间排序
        config.creationDate = false
        // 倒序
        config.photoList.sort = .desc
        // 相机拍照
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoList.isSaveSystemAlbum = false
        // 编辑模式
        let tools: EditorConfiguration.ToolsView = {
            let cropSize = EditorConfiguration.ToolsView.Options(imageType: .local("hx_editor_photo_crop"), type: .cropSize)
            return .init(toolOptions: [cropSize])
        }()
        config.editor.toolsView = tools
        config.editor.photo.defaultSelectedToolOption = .cropSize
        config.editor.cropSize.aspectRatios = []
        config.editor.isFixedCropSizeState = true
        config.editor.cropSize.isFixedRatio = true
        config.editor.cropSize.aspectRatio = .init(width: 1, height: 1)
        var cameraConfig = CameraConfiguration()
        cameraConfig.sessionPreset = .hd1920x1080
        cameraConfig.modalPresentationStyle = .fullScreen
        cameraConfig.editor.cropSize.aspectRatio = .init(width: 1, height: 1)
        cameraConfig.editor.cropSize.isFixedRatio = true
        cameraConfig.editor.cropSize.aspectRatios = []
        cameraConfig.editor.cropSize.isResetToOriginal = false
        cameraConfig.editor.isFixedCropSizeState = true
        config.photoList.cameraType = .custom(cameraConfig)
        
        return config
    }
    
    static func onlyOnePhoto() -> PickerConfiguration {
        var config = PickerConfiguration()
        config.languageType = .english

        config.pickerPresentStyle = .present()
        config.modalPresentationStyle = .fullScreen
        // 图片和视频是否可以一起选择
        config.selectMode = .single
        config.selectOptions = [.photo]
        config.allowSelectedTogether = false
        config.maximumSelectedCount = 1
        config.photoSelectionTapAction = .openEditor
        // 创建时间排序
        config.creationDate = false
        // 倒序
        config.photoList.sort = .desc
        // 相机拍照
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.photoList.isSaveSystemAlbum = false
        config.editor.toolsView = EditorConfiguration.ToolsView.init()
        
        return config
    }
    
    static func addMorePhotos(maxCount: Int) -> PickerConfiguration {
        var config = PickerConfiguration()
        config.modalPresentationStyle = .fullScreen
        config.languageType = .english
        
        config.selectMode = maxCount > 1 ? .multiple : .single
        config.selectOptions = [.photo]
        config.allowSelectedTogether = false
        config.maximumSelectedPhotoCount = maxCount
        config.photoSelectionTapAction = .preview
        // 创建时间排序
        config.creationDate = false
        // 倒序
        config.photoList.sort = .desc
        // 相机拍照
        config.photoList.finishSelectionAfterTakingPhoto = true
        config.editor.toolsView = EditorConfiguration.ToolsView.init()
        var cameraConfig = CameraConfiguration()
        cameraConfig.sessionPreset = .hd1920x1080
        cameraConfig.modalPresentationStyle = .fullScreen
        cameraConfig.editor.cropSize.aspectRatios = []
        cameraConfig.editor.cropSize.isResetToOriginal = false
        cameraConfig.editor.toolsView = EditorConfiguration.ToolsView.init()
        config.photoList.cameraType = .custom(cameraConfig)
        return config
    }
    
    
}


extension AppHXPhotoConfig {
    /// fileSize 以兆为单位, 2k:1440 4k:1980
    static func compressdImage(image: UIImage, fileSize: Int, maxSizeLength: CGFloat = 1440, finishBlock: ((Data?) -> Void)?) {
        DispatchQueue.global().async(execute: {
            // 等比例压缩图片到最长边到
            var scaleSize = image.scaleImage(imageLength: maxSizeLength)
            let img: UIImage = image.reSizeImage(reSize: scaleSize)
            /// 压缩图片data 数据
            if var outIMGData = img.compressImage(maxLength: fileSize * 1024 * 1024) {
                var thumIMG = UIImage(data: outIMGData)!
                while outIMGData.count > fileSize * 1024 * 1024 {
                    scaleSize = CGSize(width: scaleSize.width * 0.8, height: scaleSize.height * 0.8)
                    thumIMG = thumIMG.reSizeImage(reSize: scaleSize)
                    outIMGData = thumIMG.compressImage(maxLength: fileSize * 1024 * 1024)!
                }
                finishBlock?(outIMGData)
            }
        })
    }
}
